/**
 * Funções para comunicar com o backend via fetch.
 * Aplica um limite de 10 segundos à verificação, leitura e gravação de segmentos.
 */

import type { Glossary } from './exercise';

/** Categorias atualmente suportadas pelo motor determinístico. */
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

const REQUEST_TIMEOUT_MS = 10_000;

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

/** O prazo inclui os cabeçalhos e a leitura do corpo, em todas as operações. */
async function requestJson(url: string, options: RequestInit = {}): Promise<unknown> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const response = await fetch(url, { ...options, signal: controller.signal });
    if (!response.ok) throw new Error(`O pedido falhou: HTTP ${response.status}.`);
    return await response.json();
  } catch (error) {
    if (controller.signal.aborted) throw new RequestTimeoutError();
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

export class RequestTimeoutError extends Error {
  constructor() {
    super('O pedido excedeu o tempo limite de 10 segundos.');
    this.name = 'RequestTimeoutError';
  }
}

/** Envia apenas os dados do exercício, sem anotações ou resultados esperados. */
export async function checkTranslation(
  target: string,
  source: string = '',
  glossary: Glossary = {}
): Promise<Issue[]> {
  try {
    const data = await requestJson('/api/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ target, source, glossary }),
    });
    if (typeof data !== 'object' || data === null || !('issues' in data) ||
        !Array.isArray(data.issues) || !data.issues.every(isIssue)) {
      throw new Error('A API devolveu uma resposta inválida.');
    }
    return data.issues;
  } catch (error) {
    if (error instanceof RequestTimeoutError) throw new CheckTimeoutError();
    throw error;
  }
}

/** Rejeita respostas inesperadas para não substituir uma tradução por dados inválidos. */
function readSegment(data: unknown, id: string): SegmentResponse {
  if (typeof data !== 'object' || data === null ||
      !('id' in data) || data.id !== id || !('target' in data) || typeof data.target !== 'string') {
    throw new Error('A API devolveu um segmento inválido.');
  }
  return { id, target: data.target };
}

export async function getSegment(id: string): Promise<string> {
  const data = await requestJson(`/api/segments/${encodeURIComponent(id)}`);
  return readSegment(data, id).target;
}

export async function saveSegment(id: string, target: string): Promise<void> {
  const data = await requestJson(`/api/segments/${encodeURIComponent(id)}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ target }),
  });
  if (readSegment(data, id).target !== target) {
    throw new Error('A API não confirmou o texto enviado.');
  }
}
