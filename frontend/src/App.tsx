/**
 * Componente principal do editor de tradução.
 * Mostra o original em inglês, o contexto e o campo de texto.
 * Permite guardar o trabalho na base de dados e verificar as regras.
 */

import { useEffect, useRef, useState } from 'react';
import { checkTranslation, CheckTimeoutError, getSegment, saveSegment } from './api';
import type { Issue } from './api';

// Identificador do segmento e dados de dev-001
const SEGMENT_ID = 'dev-001';
const exercise = {
  source: 'Read the instructions before you start.',
  context: 'Instrução apresentada antes de um exercício educativo.',
  glossary: {
    'instructions': { target: 'instruções' },
    'start': { target: 'começar' }
  }
};

type CheckState =
  | { status: 'idle' | 'loading' | 'error' | 'timeout' }
  | { status: 'success'; issues: Issue[] };

type SaveState =
  | { status: 'idle' | 'saving' | 'success' | 'error' };

/** Editor de um segmento com verificação e persistência local. */
export default function App() {
  const [translation, setTranslation] = useState('');
  const [check, setCheck] = useState<CheckState>({ status: 'idle' });
  const [saveState, setSaveState] = useState<SaveState>({ status: 'idle' });
  const requestVersion = useRef(0);
  const saveVersion = useRef(0);

  // Carrega o texto persistido na base de dados ao abrir o ecrã
  useEffect(() => {
    let isMounted = true;
    getSegment(SEGMENT_ID)
      .then((savedText) => {
        if (isMounted && savedText) {
          setTranslation(savedText);
        }
      })
      .catch(() => {
        // Falhas silenciosas no carregamento inicial mantêm o campo editável
      });

    return () => {
      isMounted = false;
    };
  }, []);

  function updateTranslation(value: string) {
    // Uma edição invalida o resultado e qualquer pedido de verificação ou estado de gravação
    requestVersion.current += 1;
    setTranslation(value);
    setCheck({ status: 'idle' });
    if (saveState.status !== 'idle') {
      setSaveState({ status: 'idle' });
    }
  }

  async function handleSave() {
    const currentSaveVersion = ++saveVersion.current;
    setSaveState({ status: 'saving' });

    try {
      await saveSegment(SEGMENT_ID, translation);
      if (currentSaveVersion === saveVersion.current) {
        setSaveState({ status: 'success' });
      }
    } catch {
      if (currentSaveVersion === saveVersion.current) {
        setSaveState({ status: 'error' });
      }
    }
  }

  async function verifyTranslation() {
    const version = ++requestVersion.current;
    setCheck({ status: 'loading' });

    try {
      const issues = await checkTranslation(translation, exercise.source, exercise.glossary);
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

  return (
    <div className="app">
      <header className="page-header">
        <p className="brand">Educational Translation Tool</p>
        <p className="language-pair">Inglês → Português europeu</p>
      </header>

      <main>
        <p className="eyebrow">Prática de tradução · Segmento 1</p>
        <h1>Traduzir um segmento</h1>
        <p className="introduction">
          Leia o original, considere o contexto e escreva a sua tradução.
        </p>

        <section className="context" aria-labelledby="context-heading">
          <h2 id="context-heading">Contexto</h2>
          <p>{exercise.context}</p>
        </section>

        <div className="editor">
          <section className="panel" aria-labelledby="source-heading">
            <h2 id="source-heading">Original <span>Inglês</span></h2>
            <p className="source-text" lang="en">{exercise.source}</p>
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
          <p id="verification-note">Pode guardar a sua tradução ou verificar se o segmento está vazio.</p>

          <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center', marginBottom: '1rem' }}>
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
                <span style={{ color: '#2e7d32', fontSize: '0.9rem' }}>Tradução guardada.</span>
              )}
              {saveState.status === 'error' && (
                <span style={{ color: '#c62828', fontSize: '0.9rem' }}>Falha ao guardar. Tente novamente.</span>
              )}
            </div>
          </div>

          <div role="status" aria-live="polite">
            {check.status === 'loading' && <p>A aguardar o resultado da verificação.</p>}
            {check.status === 'success' && (
              check.issues.length === 0
                ? <p>Nenhum problema detetado pelas regras de verificação (texto presente, números e glossário em conformidade).</p>
                : <ul className="issues">
                    {check.issues.map((issue, index) => (
                      <li key={index}>
                        <p><strong>[{issue.category}]</strong> {issue.explanation}</p>
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
      </main>

      <footer>Projeto académico · Mestrado em Engenharia Informática · Universidade do Minho</footer>
    </div>
  );
}