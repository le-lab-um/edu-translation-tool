/**
 * Funções para comunicar com o backend via fetch.
 * Aplica um limite de 10 segundos à verificação, leitura e gravação de segmentos.
 */

import type { Glossary } from './exercise';

/** Categorias atualmente suportadas pelo motor determinístico. */
const ISSUE_CATEGORIES = [
  'empty_translation',
  'numeric_mismatch',
  'terminology',
  'placeholder_mismatch',
  'inline_tag_mismatch',
] as const;

export type IssueCategory = (typeof ISSUE_CATEGORIES)[number];

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
  return (
    typeof v.category === 'string' &&
    ISSUE_CATEGORIES.includes(v.category as IssueCategory) &&
    typeof v.explanation === 'string' &&
    typeof v.hint === 'string'
  );
}

/** O prazo inclui os cabeçalhos e a leitura do corpo, em todas as operações. */
async function requestJson(
  url: string,
  options: RequestInit = {},
  timeoutMs: number = REQUEST_TIMEOUT_MS
): Promise<unknown> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
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

// ---------------------------------------------------------------------------
// Pistas híbridas (regras + LLM local), memória de tradução e registos
// ---------------------------------------------------------------------------

/** O modelo local é mais lento do que as regras: prazo maior só para as pistas. */
export const HINT_TIMEOUT_MS = 40_000;

export type LlmStatus = 'ok' | 'disabled' | 'unavailable' | 'timeout' | 'invalid' | 'skipped';

export type HintIssue = Issue & { source: 'rules' | 'llm' };

export type HintResult = {
  issues: HintIssue[];
  llmStatus: LlmStatus;
  sanitized: number;
  elapsedMs: number;
};

const LLM_STATUSES: LlmStatus[] = ['ok', 'disabled', 'unavailable', 'timeout', 'invalid', 'skipped'];

export async function requestHint(
  target: string,
  source: string,
  glossary: Glossary,
  context: string
): Promise<HintResult> {
  const data = (await requestJson(
    '/api/hint',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ target, source, glossary, context }),
    },
    HINT_TIMEOUT_MS
  )) as Record<string, unknown> | null;
  if (
    typeof data !== 'object' || data === null || !Array.isArray(data.issues) ||
    !data.issues.every((i) => isIssue(i) && ((i as HintIssue).source === 'rules' || (i as HintIssue).source === 'llm')) ||
    !LLM_STATUSES.includes(data.llm_status as LlmStatus)
  ) {
    throw new Error('A API devolveu uma resposta inválida.');
  }
  return {
    issues: data.issues as HintIssue[],
    llmStatus: data.llm_status as LlmStatus,
    sanitized: typeof data.sanitized === 'number' ? data.sanitized : 0,
    elapsedMs: typeof data.elapsed_ms === 'number' ? data.elapsed_ms : 0,
  };
}

export type MemoryMatch = { source: string; target: string; score: number };

export async function searchMemory(source: string): Promise<MemoryMatch[]> {
  const data = (await requestJson('/api/memory/search', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source }),
  })) as { matches?: unknown } | null;
  const matches = data?.matches;
  if (!Array.isArray(matches) || !matches.every((m) =>
    typeof m?.source === 'string' && typeof m?.target === 'string' && typeof m?.score === 'number')) {
    throw new Error('A API devolveu uma resposta inválida.');
  }
  return matches as MemoryMatch[];
}

export async function saveMemory(source: string, target: string): Promise<void> {
  await requestJson('/api/memory', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ source, target }),
  });
}

export type EventType =
  | 'session_started' | 'segment_saved' | 'check_run'
  | 'hint_requested' | 'hint_shown' | 'memory_suggestion_used';

const SESSION_KEY = 'ett.session.v1';

/** Identificador anónimo da sessão; fica em memória se o localStorage não estiver disponível. */
let fallbackSession = '';
export function getSessionId(): string {
  try {
    let id = localStorage.getItem(SESSION_KEY);
    if (!id) {
      id = crypto.randomUUID();
      localStorage.setItem(SESSION_KEY, id);
    }
    return id;
  } catch {
    fallbackSession ||= `anon-${Math.random().toString(36).slice(2, 12)}`;
    return fallbackSession;
  }
}

/** Os registos nunca bloqueiam nem interrompem o exercício: falhas são ignoradas. */
export async function logEvent(
  type: EventType,
  segmentId?: string,
  payload: Record<string, unknown> = {}
): Promise<void> {
  try {
    await requestJson('/api/events', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ session_id: getSessionId(), type, segment_id: segmentId ?? null, payload }),
    });
  } catch {
    // Sem registo, a aplicação continua a funcionar.
  }
}

export const EVENTS_EXPORT_URL = (format: 'json' | 'csv') => `/api/events/export?format=${format}`;
