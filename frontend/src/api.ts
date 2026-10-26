/**
 * Funções para comunicar com o backend via fetch.
 * Trata da verificação de tradução com limite de 10 segundos
 * e das chamadas para ler e guardar segmentos na base de dados.
 */

/** Categorias suportadas pelo motor de QA determinístico e LLM */
export type IssueCategory = 'empty_translation' | 'numeric_mismatch' | 'terminology';

export type Issue = {
  category: IssueCategory;
  explanation: string;
  hint: string;
};

export type SegmentResponse = {
  id: string;
  target: string;
};

const CHECK_TIMEOUT_MS = 10_000;

export class CheckTimeoutError extends Error {
  constructor() {
    super('A verificação excedeu o tempo limite.');
    this.name = 'CheckTimeoutError';
  }
}

function isIssue(value: unknown): value is Issue {
  if (typeof value !== 'object' || value === null) return false;
  const v = value as Record<string, unknown>;
  const validCategories: IssueCategory[] = ['empty_translation', 'numeric_mismatch', 'terminology'];
  return (
    typeof v.category === 'string' &&
    validCategories.includes(v.category as IssueCategory) &&
    typeof v.explanation === 'string' &&
    typeof v.hint === 'string'
  );
}

/** Envia o texto a verificar juntamente com o original e o glossário do exercício. */
export async function checkTranslation(
  target: string,
  source: string = '',
  glossary: Record<string, unknown> = {}
): Promise<Issue[]> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), CHECK_TIMEOUT_MS);

  try {
    const response = await fetch('/api/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ target, source, glossary }),
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(`A verificação falhou: HTTP ${response.status}.`);
    }

    const data: unknown = await response.json();
    if (
      typeof data !== 'object' ||
      data === null ||
      !('issues' in data) ||
      !Array.isArray((data as any).issues) ||
      !(data as any).issues.every(isIssue)
    ) {
      throw new Error('A API devolveu uma resposta inválida.');
    }

    return (data as { issues: Issue[] }).issues;
  } catch (error) {
    if (controller.signal.aborted) {
      throw new CheckTimeoutError();
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

export async function getSegment(id: string): Promise<string> {
  const response = await fetch(`/api/segments/${encodeURIComponent(id)}`);
  if (!response.ok) {
    throw new Error(`Falha ao obter segmento: HTTP ${response.status}.`);
  }
  const data: SegmentResponse = await response.json();
  return data.target;
}

export async function saveSegment(id: string, target: string): Promise<void> {
  const response = await fetch(`/api/segments/${encodeURIComponent(id)}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ target }),
  });
  if (!response.ok) {
    throw new Error(`Falha ao guardar segmento: HTTP ${response.status}.`);
  }
}