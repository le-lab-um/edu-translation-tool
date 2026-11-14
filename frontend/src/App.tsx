/**
 * Componente principal do editor de tradução.
 * O aluno cola, escreve ou carrega o texto original em inglês (ou escolhe um exemplo),
 * o texto é dividido em segmentos e cada segmento é traduzido para português europeu.
 * A tradução é guardada na base de dados e verificada pelas regras determinísticas.
 */

import { useEffect, useMemo, useRef, useState } from 'react';
import type { ChangeEvent } from 'react';
import {
  checkTranslation, CheckTimeoutError, EVENTS_EXPORT_URL, getSegment, logEvent,
  requestHint, saveMemory, saveSegment, searchMemory,
} from './api';
import type { HintResult, Issue, IssueCategory, LlmStatus, MemoryMatch } from './api';
import { EXAMPLES, MAX_SEGMENTS, MAX_UPLOAD_BYTES, buildSegments, parseGlossary } from './exercise';

const STORAGE_KEY = 'ett.exercise.v1';

/** Nomes legíveis das categorias de alerta. */
const CATEGORY_LABELS: Record<IssueCategory, string> = {
  empty_translation: 'Tradução vazia',
  numeric_mismatch: 'Números',
  terminology: 'Terminologia',
  placeholder_mismatch: 'Marcadores',
  inline_tag_mismatch: 'Etiquetas de formatação',
  meaning_context: 'Significado e contexto',
};

type Draft = { sourceText: string; context: string; glossaryText: string };
type StoredExercise = Draft & { started: boolean; index: number };

type CheckState =
  | { status: 'idle' | 'loading' | 'error' | 'timeout' }
  | { status: 'success'; issues: Issue[] };

type HintState =
  | { status: 'idle' | 'loading' | 'error' }
  | { status: 'success'; result: HintResult };

/** Mensagem sobre o estado do modelo local, para o aluno saber o que foi usado. */
const LLM_NOTES: Record<LlmStatus, string> = {
  ok: '',
  skipped: '',
  disabled: 'O modelo local está desativado; só foram aplicadas as regras.',
  unavailable: 'O modelo local não está disponível (Ollama desligado?); só foram aplicadas as regras.',
  timeout: 'O modelo local demorou demasiado; só foram aplicadas as regras.',
  invalid: 'O modelo local devolveu uma resposta inutilizável; só foram aplicadas as regras.',
};

type SaveState =
  | { status: 'idle' | 'saving' | 'success' | 'error' };

type LoadState = { id?: string; status: 'loading' | 'ready' | 'error' };

// O browser pode não permitir localStorage (modo privado, por exemplo): a app funciona sem ele.
function loadStoredExercise(): StoredExercise | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const data = JSON.parse(raw) as Partial<StoredExercise>;
    if (
      typeof data.sourceText !== 'string' ||
      typeof data.context !== 'string' ||
      typeof data.glossaryText !== 'string'
    ) {
      return null;
    }
    return {
      sourceText: data.sourceText,
      context: data.context,
      glossaryText: data.glossaryText,
      started: data.started === true,
      index: typeof data.index === 'number' && Number.isInteger(data.index) && data.index >= 0
        ? data.index : 0,
    };
  } catch {
    return null;
  }
}

function storeExercise(exercise: StoredExercise) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(exercise));
  } catch {
    // Sem armazenamento local, o exercício só dura até fechar a página.
  }
}

/** Editor de segmentos com verificação e persistência local. */
export default function App() {
  const [stored] = useState(loadStoredExercise);
  const [draft, setDraft] = useState<Draft>({
    sourceText: stored?.sourceText ?? '',
    context: stored?.context ?? '',
    glossaryText: stored?.glossaryText ?? '',
  });
  const [started, setStarted] = useState(() => {
    if (!stored?.started) return false;
    const count = buildSegments(stored.sourceText).length;
    return count > 0 && count <= MAX_SEGMENTS
      && parseGlossary(stored.glossaryText).invalidLines.length === 0;
  });
  const [index, setIndex] = useState(stored?.index ?? 0);
  const [setupError, setSetupError] = useState('');
  const [navError, setNavError] = useState('');

  const [translation, setTranslation] = useState('');
  const [check, setCheck] = useState<CheckState>({ status: 'idle' });
  const [saveState, setSaveState] = useState<SaveState>({ status: 'idle' });
  const [hint, setHint] = useState<HintState>({ status: 'idle' });
  const [memoryMatches, setMemoryMatches] = useState<MemoryMatch[]>([]);
  const requestVersion = useRef(0);
  const [lastSaved, setLastSaved] = useState('');
  const [loadState, setLoadState] = useState<LoadState>({ status: 'loading' });
  const [saveUnconfirmed, setSaveUnconfirmed] = useState(false);
  const [loadAttempt, setLoadAttempt] = useState(0);
  // A referência bloqueia também cliques repetidos antes do próximo render.
  const saving = useRef(false);
  const fileVersion = useRef(0);

  const segments = useMemo(() => (started ? buildSegments(draft.sourceText) : []), [started, draft.sourceText]);
  const { glossary, invalidLines } = useMemo(() => parseGlossary(draft.glossaryText), [draft.glossaryText]);
  const segment = segments[Math.min(index, Math.max(segments.length - 1, 0))];
  const segmentIndex = segment ? segments.indexOf(segment) : 0;
  const segmentId = segment?.id;

  const ready = loadState.id === segmentId && loadState.status === 'ready';
  const busy = saveState.status === 'saving';
  const dirty = ready && (translation !== lastSaved || saveUnconfirmed);

  // Guarda a configuração; as traduções só são persistidas após Guardar/navegar.
  useEffect(() => {
    storeExercise({ ...draft, started, index });
  }, [draft, started, index]);

  // Não permitir editar antes da leitura: uma falha não equivale a tradução vazia.
  useEffect(() => {
    if (!segmentId) return;
    let active = true;
    requestVersion.current += 1;
    setLoadState({ id: segmentId, status: 'loading' });
    setTranslation('');
    setLastSaved('');
    setCheck({ status: 'idle' });
    setHint({ status: 'idle' });
    setMemoryMatches([]);
    setSaveState({ status: 'idle' });
    setSaveUnconfirmed(false);
    // A memória é uma ajuda opcional: se falhar, o exercício continua sem sugestões.
    searchMemory(segment.source)
      .then((matches) => { if (active) setMemoryMatches(matches); })
      .catch(() => {});
    getSegment(segmentId)
      .then((text) => {
        if (!active) return;
        setTranslation(text);
        setLastSaved(text);
        setLoadState({ id: segmentId, status: 'ready' });
      })
      .catch(() => {
        if (active) setLoadState({ id: segmentId, status: 'error' });
      });
    return () => { active = false; };
  }, [segmentId, loadAttempt]);

  // O aviso protege fechos/recarregamentos acidentais; não substitui a gravação.
  useEffect(() => {
    if (!dirty && !busy) return;
    const warn = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = '';
    };
    window.addEventListener('beforeunload', warn);
    return () => window.removeEventListener('beforeunload', warn);
  }, [dirty, busy]);

  function updateDraft(patch: Partial<Draft>) {
    fileVersion.current += 1;
    setDraft((current) => ({ ...current, ...patch }));
    setSetupError('');
  }

  function updateTranslation(value: string) {
    // Uma edição invalida o resultado e qualquer pedido de verificação ou estado de gravação
    if (!ready || saving.current) return;
    requestVersion.current += 1;
    setTranslation(value);
    setCheck({ status: 'idle' });
    setHint({ status: 'idle' });
    if (saveState.status !== 'idle') {
      setSaveState({ status: 'idle' });
    }
  }

  async function handleFile(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) return;
    const version = ++fileVersion.current;
    if (!file.name.toLowerCase().endsWith('.txt')) {
      setSetupError('Escolha um ficheiro de texto (.txt).');
      return;
    }

    if (file.size > MAX_UPLOAD_BYTES) {
      setSetupError(`O ficheiro excede o limite de ${MAX_UPLOAD_BYTES / 1024} KB.`);
      return;
    }
    try {
      const text = await file.text();
      if (version === fileVersion.current) updateDraft({ sourceText: text });
    } catch {
      if (version === fileVersion.current) {
        setSetupError('Não foi possível ler o ficheiro. Use um ficheiro de texto (.txt).');
      }
    }
  }

  function startExercise() {
    fileVersion.current += 1;
    if (invalidLines.length > 0) {
      setSetupError('Corrija as linhas inválidas ou repetidas do glossário antes de começar.');
      return;
    }
    const total = buildSegments(draft.sourceText).length;
    if (total === 0) {
      setSetupError('Cole, escreva ou carregue um texto em inglês para começar.');
      return;
    }
    if (total > MAX_SEGMENTS) {
      setSetupError(`O texto tem ${total} segmentos; o limite é ${MAX_SEGMENTS}.`);
      return;
    }
    setNavError('');
    setIndex(0);
    setStarted(true);
    void logEvent('session_started', undefined, { segments: total });
  }

  /** Uma única gravação de cada vez. Enquanto decorre, a edição fica bloqueada. */
  async function persistTranslation(): Promise<boolean> {
    if (!segment || !ready || saving.current) return false;
    if (!dirty) return true;
    saving.current = true;
    setSaveState({ status: 'saving' });
    setNavError('');
    try {
      await saveSegment(segment.id, translation);
      setLastSaved(translation);
      setSaveUnconfirmed(false);
      setSaveState({ status: 'success' });
      void logEvent('segment_saved', segment.id, { chars: translation.length });
      if (translation.trim()) void saveMemory(segment.source, translation).catch(() => {});
      return true;
    } catch {
      // Mesmo que o aluno volte ao texto anterior, é preciso confirmar a escrita:
      // um timeout pode ter ocorrido depois de o servidor guardar a nova versão.
      setSaveUnconfirmed(true);
      setSaveState({ status: 'error' });
      setNavError('A gravação não foi confirmada. A tradução foi mantida neste ecrã; tente novamente.');
      return false;
    } finally {
      saving.current = false;
    }
  }

  async function goToSegment(target: number) {
    if (target < 0 || target >= segments.length) return;
    if (await persistTranslation()) {
      requestVersion.current += 1;
      setCheck({ status: 'idle' });
      setIndex(target);
    }
  }

  async function editSource() {
    if (saving.current) return;
    if (loadState.status === 'error' || await persistTranslation()) {
      requestVersion.current += 1;
      setStarted(false);
    }
  }

  async function verifyTranslation() {
    if (!segment || !ready || saving.current) return;
    const version = ++requestVersion.current;
    setCheck({ status: 'loading' });

    try {
      const issues = await checkTranslation(translation, segment.source, glossary);
      // Só o pedido mais recente, sem edições posteriores, pode atualizar o ecrã
      if (version === requestVersion.current) {
        setCheck({ status: 'success', issues });
        void logEvent('check_run', segment.id, { issues: issues.length });
      }
    } catch (error) {
      if (version === requestVersion.current) {
        setCheck({ status: error instanceof CheckTimeoutError ? 'timeout' : 'error' });
      }
    }
  }

  async function askHint() {
    if (!segment || !ready || saving.current) return;
    const version = ++requestVersion.current;
    setHint({ status: 'loading' });
    void logEvent('hint_requested', segment.id);
    try {
      const result = await requestHint(translation, segment.source, glossary, draft.context);
      if (version === requestVersion.current) {
        setHint({ status: 'success', result });
        void logEvent('hint_shown', segment.id, {
          llm_status: result.llmStatus,
          rules: result.issues.filter((i) => i.source === 'rules').length,
          llm: result.issues.filter((i) => i.source === 'llm').length,
          sanitized: result.sanitized,
          elapsed_ms: result.elapsedMs,
        });
      }
    } catch {
      if (version === requestVersion.current) setHint({ status: 'error' });
    }
  }

  function useMemorySuggestion(match: MemoryMatch) {
    updateTranslation(match.target);
    void logEvent('memory_suggestion_used', segmentId, { score: match.score });
  }

  const glossaryEntries = Object.entries(glossary);

  return (
    <div className="app">
      <header className="page-header">
        <p className="brand">Educational Translation Tool</p>
        <p className="language-pair">Inglês → Português europeu</p>
      </header>

      <main>
        <p className="eyebrow">
          Prática de tradução{started && segment ? ` · Segmento ${segmentIndex + 1} de ${segments.length}` : ''}
        </p>
        <h1>{started ? 'Traduzir um texto' : 'Escolha o texto a traduzir'}</h1>

        {!started && (
          <section className="setup" aria-labelledby="setup-heading">
            <h2 id="setup-heading" className="visually-hidden">Texto original</h2>
            <p className="introduction">
              Cole ou escreva um texto em inglês, carregue um ficheiro de texto, ou comece por um exemplo.
              Cada linha não vazia passa a ser um segmento.
            </p>

            <div className="chips" role="group" aria-label="Exemplos">
              <span className="chips-label">Exemplos:</span>
              {EXAMPLES.map((example) => (
                <button
                  key={example.id}
                  type="button"
                  className="secondary"
                  onClick={() =>
                    updateDraft({
                      sourceText: example.sourceText,
                      context: example.context,
                      glossaryText: example.glossaryText,
                    })
                  }
                >
                  {example.label}
                </button>
              ))}
            </div>

            <div className="panel">
              <label htmlFor="source-input" className="field-label">
                Texto original <span>Inglês</span>
              </label>
              <textarea
                id="source-input"
                lang="en"
                rows={8}
                value={draft.sourceText}
                onChange={(event) => updateDraft({ sourceText: event.target.value })}
                placeholder="Cole ou escreva aqui o texto em inglês…"
              />
              <div className="file-row">
                <label className="button-like secondary" htmlFor="source-file">
                  Carregar ficheiro .txt
                </label>
                <input
                  id="source-file"
                  className="visually-hidden"
                  type="file"
                  accept=".txt,text/plain"
                  onChange={handleFile}
                />
                <span className="hint">
                  Até {MAX_UPLOAD_BYTES / 1024} KB · {buildSegments(draft.sourceText).length} segmento(s)
                </span>
              </div>
            </div>

            <div className="setup-extra">
              <div className="panel">
                <label htmlFor="context-input" className="field-label">
                  Contexto <span>Opcional</span>
                </label>
                <input
                  id="context-input"
                  type="text"
                  value={draft.context}
                  onChange={(event) => updateDraft({ context: event.target.value })}
                  placeholder="Onde aparece este texto? Quem o vai ler?"
                />
              </div>
              <div className="panel">
                <label htmlFor="glossary-input" className="field-label">
                  Glossário <span>Opcional · um termo por linha: termo = equivalente | variante</span>
                </label>
                <textarea
                  id="glossary-input"
                  rows={3}
                  value={draft.glossaryText}
                  onChange={(event) => updateDraft({ glossaryText: event.target.value })}
                  placeholder={'file = ficheiro\nfolder = pasta | diretório'}
                />
                {invalidLines.length > 0 && (
                  <p className="check-error" role="alert">
                    {invalidLines.length} linha(s) inválidas ou repetidas. Use termo = equivalente e uma entrada por termo.
                  </p>
                )}
              </div>
            </div>

            {setupError && <p className="check-error" role="alert">{setupError}</p>}

            <div className="actions">
              <button type="button" onClick={startExercise}>Começar a traduzir</button>
            </div>
          </section>
        )}

        {started && segment && (
          <>
            {draft.context.trim() && (
              <section className="context" aria-labelledby="context-heading">
                <h2 id="context-heading">Contexto</h2>
                <p>{draft.context}</p>
              </section>
            )}

            {glossaryEntries.length > 0 && (
              <section className="glossary" aria-labelledby="glossary-heading">
                <h2 id="glossary-heading">Glossário da tarefa</h2>
                <ul>
                  {glossaryEntries.map(([term, entry]) => (
                    <li key={term}>
                      <span lang="en">{term}</span> → <span lang="pt-PT">{[entry.target, ...(entry.variants ?? [])].join(', ')}</span>
                    </li>
                  ))}
                </ul>
              </section>
            )}

            <div className="editor">
              <section className="panel" aria-labelledby="source-heading">
                <h2 id="source-heading">Original <span>Inglês</span></h2>
                <p className="source-text" lang="en">{segment.source}</p>
                <div className="segment-nav">
                  <button
                    type="button"
                    className="secondary"
                    onClick={() => goToSegment(segmentIndex - 1)}
                    disabled={!ready || busy || segmentIndex === 0}
                  >
                    ← Anterior
                  </button>
                  <button
                    type="button"
                    className="secondary"
                    onClick={() => goToSegment(segmentIndex + 1)}
                    disabled={!ready || busy || segmentIndex >= segments.length - 1}
                  >
                    Seguinte →
                  </button>
                  <button type="button" className="link" onClick={editSource} disabled={busy || loadState.status === 'loading'}>
                    Alterar texto original
                  </button>
                </div>
                {navError && <p className="check-error" role="alert">{navError}</p>}
              </section>

              <section className="panel" aria-labelledby="translation-heading">
                <h2 id="translation-heading">
                  <label htmlFor="translation">A sua tradução <span>Português europeu</span></label>
                </h2>
                <textarea
                  id="translation"
                  name="translation"
                  lang="pt-PT"
                  rows={8}
                  disabled={!ready || busy}
                  value={translation}
                  onChange={(event) => updateTranslation(event.target.value)}
                  aria-describedby="verification-note"
                  placeholder="Escreva aqui a sua tradução…"
                />
              </section>
            </div>

            {memoryMatches.length > 0 && (
              <section className="memory" aria-labelledby="memory-heading">
                <h2 id="memory-heading">Memória de tradução</h2>
                <p>Estas sugestões vêm de traduções guardadas nesta instância. Reveja-as antes de as usar.</p>
                <ul>
                  {memoryMatches.map((match) => (
                    <li key={`${match.source}|${match.target}`}>
                      <span className="badge">{match.score}%</span>
                      <span lang="en">{match.source}</span> → <span lang="pt-PT">{match.target}</span>{' '}
                      <button type="button" className="secondary" onClick={() => useMemorySuggestion(match)}
                        disabled={!ready || busy}>
                        Usar
                      </button>
                    </li>
                  ))}
                </ul>
              </section>
            )}

            <section className="verification" aria-labelledby="actions-heading">
              <h2 id="actions-heading">Ações e Verificação</h2>
              <p id="verification-note">
                «Verificar» aplica as regras de texto presente, números, glossário, marcadores e etiquetas.
                «Pedir pista» pode acrescentar uma sugestão sobre o significado e o contexto.
              </p>

              {!ready && loadState.status !== 'error' && <p role="status">A recuperar a tradução guardada…</p>}
              {loadState.status === 'error' && (
                <div role="alert">
                  <p className="check-error">Não foi possível recuperar a tradução guardada. Confirme que a API está em execução.</p>
                  <button type="button" onClick={() => setLoadAttempt((attempt) => attempt + 1)}>Tentar carregar novamente</button>
                </div>
              )}
              {dirty && <p role="status">Alterações por guardar. Use «Guardar» ou mude de segmento antes de fechar.</p>}
              <div className="actions">
                <button
                  type="button"
                  onClick={persistTranslation}
                  disabled={!ready || busy || !dirty}
                >
                  {saveState.status === 'saving' ? 'A guardar…' : 'Guardar'}
                </button>

                <button
                  type="button"
                  onClick={verifyTranslation}
                  disabled={!ready || busy || check.status === 'loading'}
                >
                  {check.status === 'loading' ? 'A verificar…' : 'Verificar'}
                </button>

                <button
                  type="button"
                  className="secondary"
                  onClick={askHint}
                  disabled={!ready || busy || hint.status === 'loading'}
                >
                  {hint.status === 'loading' ? 'A pedir pista…' : 'Pedir pista'}
                </button>

                <div role="status" aria-live="polite">
                  {saveState.status === 'success' && (
                    <span className="save-ok">Tradução guardada.</span>
                  )}
                  {saveState.status === 'error' && (
                    <span className="save-error">Falha ao guardar. Tente novamente.</span>
                  )}
                </div>
              </div>

              <div role="status" aria-live="polite">
                {check.status === 'loading' && <p>A aguardar o resultado da verificação.</p>}
                {check.status === 'success' && (
                  check.issues.length === 0
                    ? <p>Não foram detetados problemas pelas regras aplicadas. Isto não garante que a tradução esteja correta.</p>
                    : <ul className="issues">
                        {check.issues.map((issue, issueIndex) => (
                          <li key={issueIndex}>
                            <p><strong>{CATEGORY_LABELS[issue.category]}:</strong> {issue.explanation}</p>
                            <p><strong>Pista:</strong> {issue.hint}</p>
                          </li>
                        ))}
                      </ul>
                )}
              </div>

              <div role="status" aria-live="polite">
                {hint.status === 'loading' && <p>A consultar as regras e o modelo local…</p>}
                {hint.status === 'success' && (
                  <div className="hints">
                    {hint.result.issues.length === 0
                      ? <p>{hint.result.llmStatus === 'ok'
                        ? 'As regras e o modelo local não sinalizaram problemas neste segmento.'
                        : 'As regras não sinalizaram problemas neste segmento.'} Isto não garante que a tradução esteja correta.</p>
                      : <ul className="issues">
                          {hint.result.issues.map((issue, i) => (
                            <li key={i}>
                              <p>
                                <span className={`badge ${issue.source}`}>
                                  {issue.source === 'rules' ? 'Regra' : 'Sugestão do modelo local'}
                                </span>{' '}
                                <strong>{CATEGORY_LABELS[issue.category]}:</strong> {issue.explanation}
                              </p>
                              <p><strong>Pista:</strong> {issue.hint}</p>
                            </li>
                          ))}
                        </ul>}
                    {LLM_NOTES[hint.result.llmStatus] && <p className="hint">{LLM_NOTES[hint.result.llmStatus]}</p>}
                    {hint.result.sanitized > 0 && (
                      <p className="hint">Sugestões generalizadas por possível revelação da solução: {hint.result.sanitized}.</p>
                    )}
                  </div>
                )}
                {hint.status === 'error' && (
                  <p className="check-error" role="alert">Não foi possível obter pistas. A sua tradução foi mantida.</p>
                )}
              </div>

              {(check.status === 'error' || check.status === 'timeout') && (
                <p className="check-error" role="alert">
                  {check.status === 'timeout'
                    ? 'A verificação excedeu o tempo limite de 10 segundos. Tente novamente.'
                    : 'Não foi possível obter a verificação. Confirme que a API está em execução e tente novamente.'}
                  {' '}A sua tradução foi mantida.
                </p>
              )}
            </section>
          </>
        )}
      </main>

      <footer>
        Projeto académico · Mestrado em Engenharia Informática · Universidade do Minho
        {' · '}Registos de utilização:{' '}
        <a href={EVENTS_EXPORT_URL('json')} download>JSON</a>{' / '}
        <a href={EVENTS_EXPORT_URL('csv')} download>CSV</a>
      </footer>
    </div>
  );
}
