/** Formato devolvido pela única regra atualmente disponível na API. */
export type Issue = {
  category: 'empty_translation';
  explanation: string;
  hint: string;
};

function isIssue(value: unknown): value is Issue {
  return typeof value === 'object' && value !== null
    && 'category' in value && value.category === 'empty_translation'
    && 'explanation' in value && typeof value.explanation === 'string'
    && 'hint' in value && typeof value.hint === 'string';
}

/** Envia o texto sem alterações. A deteção continua exclusivamente no backend. */
export async function checkTranslation(target: string): Promise<Issue[]> {
  const response = await fetch('/api/check', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ target }),
  });

  if (!response.ok) {
    throw new Error(`A verificação falhou: HTTP ${response.status}.`);
  }

  // Os tipos TypeScript não validam JSON recebido pela rede.
  const data: unknown = await response.json();
  if (typeof data !== 'object' || data === null
    || !('issues' in data) || !Array.isArray(data.issues)
    || !data.issues.every(isIssue)) {
    throw new Error('A API devolveu uma resposta inválida.');
  }

  return data.issues;
}
