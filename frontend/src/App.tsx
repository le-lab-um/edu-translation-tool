/**
 * Componente principal do editor de tradução.
 * O aluno cola, escreve ou carrega o texto original em inglês (ou escolhe um exemplo),
 * o texto é dividido em segmentos e cada segmento é traduzido para português europeu.
 * A tradução é guardada na base de dados e verificada pelas regras determinísticas.
 */

import { useEffect, useMemo, useRef, useState } from 'react';
import type { ChangeEvent } from 'react';
import { checkTranslation, CheckTimeoutError, getSegment, saveSegment } from './api';
import type { Issue, IssueCategory } from './api';
import { EXAMPLES, MAX_SEGMENTS, MAX_UPLOAD_BYTES, buildSegments, parseGlossary } from './exercise';

const STORAGE_KEY = 'ett.exercise.v1';

/** Nomes legíveis das categorias de alerta devolvidas pelo motor de regras. */
const CATEGORY_LABELS: Record<IssueCategory, string> = {
  empty_translation: 'Tradução vazia',
  numeric_mismatch: 'Números',
  terminology: 'Terminologia',
};

type Draft = { sourceText: string; context: string; glossaryText: string };
type StoredExercise = Draft & { started: boolean; index: number };

type CheckState =
  | { status: 'idle' | 'loading' | 'error' | 'timeout' }
  | { status: 'success'; issues: Issue[] };

type SaveState =
  | { status: 'idle' | 'saving' | 'success' | 'error' };

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
      index: typeof data.index === 'number' ? data.index : 0,
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
  const [started, setStarted] = useState(
    () => stored?.started === true && buildSegments(stored.sourceText).length > 0
  );
  const [index, setIndex] = useState(stored?.index ?? 0);
  const [setupError, setSetupError] = useState('');
  const [navError, setNavError] = useState('');

  const [translation, setTranslation] = useState('');
  const [check, setCheck] = useState<CheckState>({ status: 'idle' });
  const [saveState, setSaveState] = useState<SaveState>({ status: 'idle' });
  const requestVersion = useRef(0);
  const saveVersion = useRef(0);
  const lastSaved = useRef('');
  const editedSinceLoad = useRef(false);

  const segments = useMemo(() => (started ? buildSegments(draft.sourceText) : []), [started, draft.sourceText]);
  const { glossary, invalidLines } = useMemo(() => parseGlossary(draft.glossaryText), [draft.glossaryText]);
  const segment = segments[Math.min(index, Math.max(segments.length - 1, 0))];
  const segmentIndex = segment ? segments.indexOf(segment) : 0;
  const segmentId = segment?.id;

  // Guarda o exercício no browser para o texto não se perder ao recarregar a página
  useEffect(() => {
    storeExercise({ ...draft, started, index });
  }, [draft, started, index]);

  // Carrega a tradução persistida na base de dados sempre que o segmento muda
  useEffect(() => {
    if (!segmentId) return;
    let isMounted = true;
    editedSinceLoad.current = false;
    lastSaved.current = '';
    requestVersion.current += 1;
    saveVersion.current += 1;
    setTranslation('');
    setCheck({ status: 'idle' });
    setSaveState({ status: 'idle' });

    getSegment(segmentId)
      .then((savedText) => {
        // Se o aluno já começou a escrever, o texto carregado não pode sobrepor-se
        if (isMounted && !editedSinceLoad.current) {
          lastSaved.current = savedText;
          setTranslation(savedText);
        }
      })
      .catch(() => {
        // Falhas silenciosas no carregamento inicial mantêm o campo editável
      });

    return () => {
      isMounted = false;
    };
  }, [segmentId]);

  function updateDraft(patch: Partial<Draft>) {
    setDraft((current) => ({ ...current, ...patch }));
    setSetupError('');
  }

  function updateTranslation(value: string) {
    // Uma edição invalida o resultado e qualquer pedido de verificação ou estado de gravação
    editedSinceLoad.current = true;
    requestVersion.current += 1;
    setTranslation(value);
    setCheck({ status: 'idle' });
    if (saveState.status !== 'idle') {
      setSaveState({ status: 'idle' });
    }
  }

  async function handleFile(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) return;

    if (file.size > MAX_UPLOAD_BYTES) {
      setSetupError(`O ficheiro excede o limite de ${MAX_UPLOAD_BYTES / 1024} KB.`);
      return;
    }
    try {
      const text = await file.text();
      updateDraft({ sourceText: text });
    } catch {
      setSetupError('Não foi possível ler o ficheiro. Use um ficheiro de texto (.txt).');
    }
  }

  function startExercise() {
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
  }

  // Antes de mudar de segmento ou de ecrã, guarda o que ainda não foi gravado
  async function flushUnsaved(): Promise<boolean> {
    if (!segment || translation === lastSaved.current) return true;
    try {
      await saveSegment(segment.id, translation);
      lastSaved.current = translation;
      return true;
    } catch {
      setNavError('Não foi possível guardar a tradução atual. Use «Guardar» e tente novamente.');
      return false;
    }
  }

  async function goToSegment(target: number) {
    setNavError('');
    if (await flushUnsaved()) {
      setIndex(target);
    }
  }

  async function editSource() {
    setNavError('');
    if (await flushUnsaved()) {
      setStarted(false);
    }
  }

  async function handleSave() {
    if (!segment) return;
    const currentSaveVersion = ++saveVersion.current;
    const textToSave = translation;
    setSaveState({ status: 'saving' });

    try {
      await saveSegment(segment.id, textToSave);
      if (currentSaveVersion === saveVersion.current) {
        lastSaved.current = textToSave;
        setSaveState({ status: 'success' });
      }
    } catch {
      if (currentSaveVersion === saveVersion.current) {
        setSaveState({ status: 'error' });
      }
    }
  }

  async function verifyTranslation() {
    if (!segment) return;
    const version = ++requestVersion.current;
    setCheck({ status: 'loading' });

    try {
      const issues = await checkTranslation(translation, segment.source, glossary);
      // Só o pedido mais recente, sem edições posteriores, pode atualizar o ecrã
      if (version === requestVersion.current) {
        setCheck({ status: 'success', issues });
      }
    } catch (error) {
      if (version === requestVersion.current) {
        setCheck({ status: error instanceof CheckTimeoutError ? 'timeout' : 'error' });
      }
    }
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
              Cada linha ou parágrafo passa a ser um segmento.
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
                  accept=".txt,.md,text/plain"
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
                    {invalidLines.length} linha(s) do glossário serão ignoradas (formato: termo = equivalente).
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
                    disabled={segmentIndex === 0}
                  >
                    ← Anterior
                  </button>
                  <button
                    type="button"
                    className="secondary"
                    onClick={() => goToSegment(segmentIndex + 1)}
                    disabled={segmentIndex >= segments.length - 1}
                  >
                    Seguinte →
                  </button>
                  <button type="button" className="link" onClick={editSource}>
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
                  value={translation}
                  onChange={(event) => updateTranslation(event.target.value)}
                  aria-describedby="verification-note"
                  placeholder="Escreva aqui a sua tradução…"
                />
              </section>
            </div>

            <section className="verification" aria-labelledby="actions-heading">
              <h2 id="actions-heading">Ações e Verificação</h2>
              <p id="verification-note">
                Pode guardar a sua tradução ou verificá-la com as regras (texto presente, números e glossário).
              </p>

              <div className="actions">
                <button
                  type="button"
                  onClick={handleSave}
                  disabled={saveState.status === 'saving'}
                >
                  {saveState.status === 'saving' ? 'A guardar…' : 'Guardar'}
                </button>

                <button
                  type="button"
                  onClick={verifyTranslation}
                  disabled={check.status === 'loading'}
                >
                  {check.status === 'loading' ? 'A verificar…' : 'Verificar'}
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
                    ? <p>Nenhum problema detetado pelas regras de verificação (texto presente, números e glossário em conformidade).</p>
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

      <footer>Projeto académico · Mestrado em Engenharia Informática · Universidade do Minho</footer>
    </div>
  );
}
