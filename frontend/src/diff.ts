/**
 * Comparação palavra a palavra entre duas versões de uma tradução.
 * Usa a maior subsequência comum de palavras e ignora diferenças só de espaços. As partes iguais
 * usam os espaços da versão nova, por isso juntar as partes reconstrói exatamente a versão nova.
 */

export type DiffPart = { kind: 'same' | 'added' | 'removed'; text: string };

/** Divide o texto em palavras, cada uma com o espaço que a antecede. */
export function tokenize(text: string): string[] {
  return text.match(/\s*\S+|\s+$/g) ?? [];
}

/** Partes iguais, removidas (só na versão antiga) e acrescentadas (só na versão nova). */
export function diffWords(before: string, after: string): DiffPart[] {
  const a = tokenize(before);
  const b = tokenize(after);
  // lcs[i][j]: comprimento da maior subsequência comum de a[i..] e b[j..], comparando sem espaços.
  const lcs = Array.from({ length: a.length + 1 }, () => new Array<number>(b.length + 1).fill(0));
  for (let i = a.length - 1; i >= 0; i -= 1) {
    for (let j = b.length - 1; j >= 0; j -= 1) {
      lcs[i][j] = a[i].trim() === b[j].trim()
        ? lcs[i + 1][j + 1] + 1
        : Math.max(lcs[i + 1][j], lcs[i][j + 1]);
    }
  }

  const parts: DiffPart[] = [];
  const push = (kind: DiffPart['kind'], text: string) => {
    const last = parts[parts.length - 1];
    if (last && last.kind === kind) last.text += text;
    else parts.push({ kind, text });
  };
  let i = 0;
  let j = 0;
  while (i < a.length && j < b.length) {
    if (a[i].trim() === b[j].trim()) {
      push('same', b[j]);
      i += 1;
      j += 1;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      push('removed', a[i]);
      i += 1;
    } else {
      push('added', b[j]);
      j += 1;
    }
  }
  while (i < a.length) push('removed', a[i++]);
  while (j < b.length) push('added', b[j++]);
  return parts;
}
