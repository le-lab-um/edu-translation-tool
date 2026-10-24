import { useState } from 'react';

// Original e contexto de dev-001 em data/development.json.
// Não importamos o conjunto anotado nem a tradução de referência para a interface.
const exercise = {
  source: 'Read the instructions before you start.',
  context: 'Instrução apresentada antes de um exercício educativo.',
};

/** Editor de um segmento. A tradução existe apenas no estado desta página. */
export default function App() {
  const [translation, setTranslation] = useState('');

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
              onChange={(event) => setTranslation(event.target.value)}
              aria-describedby="storage-note"
              placeholder="Escreva aqui a sua tradução…"
            />
          </section>
        </div>

      </main>

      <footer>Projeto académico · Mestrado em Engenharia Informática · Universidade do Minho</footer>
    </div>
  );
}
