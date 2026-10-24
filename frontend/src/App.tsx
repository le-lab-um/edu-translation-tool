import { useRef, useState } from 'react';
import { checkTranslation, CheckTimeoutError } from './api';
import type { Issue } from './api';

// Original e contexto de dev-001 em data/development.json.
// Não importamos o conjunto anotado nem a tradução de referência para a interface.
const exercise = {
  source: 'Read the instructions before you start.',
  context: 'Instrução apresentada antes de um exercício educativo.',
};

type CheckState =
  | { status: 'idle' | 'loading' | 'error' | 'timeout' }
  | { status: 'success'; issues: Issue[] };

/** Editor de um segmento. A tradução existe apenas no estado desta página. */
export default function App() {
  const [translation, setTranslation] = useState('');
  const [check, setCheck] = useState<CheckState>({ status: 'idle' });
  const requestVersion = useRef(0);

  function updateTranslation(value: string) {
    // Uma edição invalida o resultado e qualquer pedido ainda em curso.
    requestVersion.current += 1;
    setTranslation(value);
    setCheck({ status: 'idle' });
  }

  async function verifyTranslation() {
    const version = ++requestVersion.current;
    setCheck({ status: 'loading' });

    try {
      const issues = await checkTranslation(translation);
      // Só o pedido mais recente, sem edições posteriores, pode atualizar o ecrã.
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

        <section className="verification" aria-labelledby="verification-heading">
          <h2 id="verification-heading">Verificação</h2>
          <p id="verification-note">Nesta versão, verifica-se apenas se a tradução está vazia.</p>
          <button
            type="button"
            onClick={verifyTranslation}
            disabled={check.status === 'loading'}
          >
            {check.status === 'loading' ? 'A verificar…' : 'Verificar'}
          </button>

          <div role="status" aria-live="polite">
            {check.status === 'loading' && <p>A aguardar o resultado da verificação.</p>}
            {check.status === 'success' && (
              check.issues.length === 0
                ? <p>Não foi detetada uma tradução vazia. Isto não avalia a qualidade da tradução.</p>
                : <ul className="issues">
                    {check.issues.map((issue, index) => (
                      <li key={index}>
                        <p>{issue.explanation}</p>
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
