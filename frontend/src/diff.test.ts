/**
 * Testes da comparação palavra a palavra entre versões.
 */

import { describe, expect, it } from 'vitest';
import { diffWords, tokenize } from './diff';

const join = (parts: { text: string }[]) => parts.map((p) => p.text).join('');

describe('diffWords', () => {
  it('marca a palavra trocada como removida e acrescentada', () => {
    expect(diffWords('Abra o ficheiro.', 'Abre o ficheiro.')).toEqual([
      { kind: 'removed', text: 'Abra' },
      { kind: 'added', text: 'Abre' },
      { kind: 'same', text: ' o ficheiro.' },
    ]);
  });

  it('deteta palavras acrescentadas no meio e no fim', () => {
    const parts = diffWords('Guarde o ficheiro.', 'Guarde já o ficheiro na pasta.');
    expect(parts.filter((p) => p.kind === 'added').map((p) => p.text.trim())).toEqual(['já', 'ficheiro na pasta.']);
    expect(parts.filter((p) => p.kind === 'removed').map((p) => p.text.trim())).toEqual(['ficheiro.']);
  });

  it('textos iguais ficam numa só parte', () => {
    expect(diffWords('Igual.', 'Igual.')).toEqual([{ kind: 'same', text: 'Igual.' }]);
  });

  it('lida com versões vazias', () => {
    expect(diffWords('', 'Novo texto')).toEqual([{ kind: 'added', text: 'Novo texto' }]);
    expect(diffWords('Antigo', '')).toEqual([{ kind: 'removed', text: 'Antigo' }]);
    expect(diffWords('', '')).toEqual([]);
  });

  it('reconstrói as duas versões a partir das partes', () => {
    const before = 'Clique em Guardar\nantes de sair.';
    const after = 'Clique  em «Guardar» antes de sair.';
    const parts = diffWords(before, after);
    const words = (text: string) => text.split(/\s+/).filter(Boolean);
    expect(words(join(parts.filter((p) => p.kind !== 'added')))).toEqual(words(before));
    expect(join(parts.filter((p) => p.kind !== 'removed'))).toBe(after);
  });
});

describe('tokenize', () => {
  it('mantém os espaços junto da palavra seguinte', () => {
    expect(tokenize(' Olá  mundo ')).toEqual([' Olá', '  mundo', ' ']);
  });
});
