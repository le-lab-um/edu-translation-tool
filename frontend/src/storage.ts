/**
 * Exercício guardado no localStorage do browser: texto, contexto, glossário, posição,
 * identificador do exercício e lista persistente dos segmentos ({id, source}).
 * Inclui a migração dos formatos anteriores, sem perder o acesso às traduções já guardadas.
 */

import {
  EXERCISE_ID_PATTERN, MAX_SEGMENTS, buildSegments, newSegmentId, reconcileSegments, splitLines,
} from './exercise';
import type { Segment } from './exercise';

export const STORAGE_KEY = 'ett.exercise.v1';

export type Draft = { sourceText: string; context: string; glossaryText: string };

/**
 * exerciseId vazio: exercício começado antes de existir identificador de exercício
 * (segmentos «custom-…», derivados só do texto).
 * segments: lista do último início do exercício; enquanto o texto é editado na configuração,
 * pode diferir do texto, e é reconciliada quando o exercício recomeça.
 */
export type StoredExercise = Draft & {
  started: boolean;
  index: number;
  exerciseId: string;
  segments: Segment[];
};

function validSegments(value: unknown, exerciseId: string): Segment[] | null {
  if (!Array.isArray(value) || value.length > MAX_SEGMENTS) return null;
  const prefix = exerciseId ? `${exerciseId}-` : 'custom-';
  const ids = new Set<string>();
  for (const item of value) {
    if (typeof item !== 'object' || item === null) return null;
    const { id, source } = item as Record<string, unknown>;
    if (typeof id !== 'string' || typeof source !== 'string' || id.length > 50 || !id.startsWith(prefix)) return null;
    if (exerciseId && ids.has(id)) return null;
    ids.add(id);
  }
  return value.map((item) => ({ id: item.id, source: item.source }));
}

/**
 * Lê e valida o exercício guardado. Formatos anteriores:
 * - com exerciseId e sem lista: a lista é gerada com o identificador por ocorrência dessa versão,
 *   que corresponde exatamente aos registos já guardados na base de dados;
 * - sem exerciseId: mantém os identificadores derivados do texto («custom-…»).
 * Uma lista inválida é reconstruída da mesma forma; uma lista que não corresponde ao texto de um
 * exercício em curso é reconciliada com ele.
 */
export function loadStoredExercise(storage: Pick<Storage, 'getItem'> | null): StoredExercise | null {
  try {
    const raw = storage?.getItem(STORAGE_KEY);
    if (!raw) return null;
    const data = JSON.parse(raw) as Record<string, unknown>;
    if (typeof data.sourceText !== 'string' || typeof data.context !== 'string' || typeof data.glossaryText !== 'string') {
      return null;
    }
    const exerciseId = typeof data.exerciseId === 'string' && EXERCISE_ID_PATTERN.test(data.exerciseId)
      ? data.exerciseId : '';
    const started = data.started === true;
    let segments = validSegments(data.segments, exerciseId);
    if (!segments) segments = started ? buildSegments(data.sourceText, exerciseId || undefined) : [];
    if (started) {
      const lines = splitLines(data.sourceText);
      const matches = segments.length === lines.length && segments.every((s, k) => s.source === lines[k]);
      if (!matches) {
        segments = exerciseId
          ? reconcileSegments(segments, lines, (taken) => newSegmentId(exerciseId, taken))
          : buildSegments(data.sourceText);
      }
    }
    return {
      sourceText: data.sourceText,
      context: data.context,
      glossaryText: data.glossaryText,
      started,
      index: typeof data.index === 'number' && Number.isInteger(data.index) && data.index >= 0 ? data.index : 0,
      exerciseId,
      segments,
    };
  } catch {
    return null;
  }
}

export function storeExercise(storage: Pick<Storage, 'setItem'> | null, exercise: StoredExercise): void {
  try {
    storage?.setItem(STORAGE_KEY, JSON.stringify(exercise));
  } catch {
    // Sem armazenamento local, o exercício só dura até fechar a página.
  }
}

/** O localStorage do browser, ou null se não estiver disponível (modo privado, por exemplo). */
export function browserStorage(): Storage | null {
  try {
    return typeof localStorage === 'undefined' ? null : localStorage;
  } catch {
    return null;
  }
}

/**
 * Segmentos ao (re)começar um exercício. Num exercício novo, todos os identificadores são novos;
 * num exercício existente, a lista anterior é reconciliada com o texto atual.
 */
export function segmentsForStart(exerciseId: string, previous: readonly Segment[], text: string): Segment[] {
  const lines = splitLines(text);
  const own = previous.filter((s) => s.id.startsWith(`${exerciseId}-`));
  return reconcileSegments(own, lines, (taken) => newSegmentId(exerciseId, taken));
}
