/**
 * Testes da identidade persistente dos segmentos: reconciliação quando o texto original muda,
 * gravação e leitura no localStorage, migração dos formatos anteriores e integração com a
 * leitura e gravação de traduções, justificações e versões (backend simulado em memória).
 */

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { getSegment, getVersions, saveSegment } from './api';
import { occurrenceId, reconcileSegments, segmentId, splitLines } from './exercise';
import type { Segment } from './exercise';
import { STORAGE_KEY, loadStoredExercise, segmentsForStart, storeExercise } from './storage';

const EX = 'e0123456789ab';
const OTHER = 'e000000000001';

/** Identificadores novos previsíveis, para comparar resultados. */
function counter(prefix = EX) {
  let n = 0;
  return () => `${prefix}-new${(n += 1)}`;
}

function reconcile(previous: Segment[], text: string) {
  return reconcileSegments(previous, splitLines(text), counter());
}

const seg = (id: string, source: string): Segment => ({ id: `${EX}-${id}`, source });

describe('reconcileSegments', () => {
  it('alterar a 1.ª de duas linhas iguais mantém a identidade da 2.ª', () => {
    const before = [seg('a1', 'A'), seg('a2', 'A')];
    const after = reconcile(before, 'B\nA');
    expect(after.map((s) => s.id)).toEqual([`${EX}-new1`, `${EX}-a2`]);
  });

  it('alterar a última de duas linhas iguais mantém a identidade da 1.ª', () => {
    const after = reconcile([seg('a1', 'A'), seg('a2', 'A')], 'A\nB');
    expect(after.map((s) => s.id)).toEqual([`${EX}-a1`, `${EX}-new1`]);
  });

  it('inserir uma linha antes de duas iguais mantém as duas', () => {
    const after = reconcile([seg('a1', 'A'), seg('a2', 'A')], 'C\nA\nA');
    expect(after.map((s) => s.id)).toEqual([`${EX}-new1`, `${EX}-a1`, `${EX}-a2`]);
  });

  it('remover uma ocorrência repetida mantém a 1.ª quando não há contexto, e a certa quando há', () => {
    expect(reconcile([seg('a1', 'A'), seg('a2', 'A')], 'A').map((s) => s.id)).toEqual([`${EX}-a1`]);
    const withContext = [seg('x', 'X'), seg('a1', 'A'), seg('y', 'Y'), seg('a2', 'A')];
    expect(reconcile(withContext, 'X\nY\nA').map((s) => s.id)).toEqual([`${EX}-x`, `${EX}-y`, `${EX}-a2`]);
  });

  it('alterar uma linha intermédia não muda a identidade das restantes', () => {
    const after = reconcile([seg('a', 'A'), seg('b', 'B'), seg('c', 'C')], 'A\nX\nC');
    expect(after.map((s) => s.id)).toEqual([`${EX}-a`, `${EX}-new1`, `${EX}-c`]);
  });

  it('uma linha alterada nunca herda o identificador de outra', () => {
    const before = [seg('a1', 'A'), seg('a2', 'A')];
    const after = reconcile(before, 'A changed\nA changed');
    expect(after.every((s) => !before.some((b) => b.id === s.id))).toBe(true);
  });

  it('é determinística e preserva tudo quando o texto não muda', () => {
    const before = [seg('a1', 'A'), seg('b', 'B'), seg('a2', 'A')];
    expect(reconcile(before, 'A\nB\nA')).toEqual(before);
    expect(reconcile(before, 'B\nA\nA')).toEqual(reconcile(before, 'B\nA\nA'));
  });
});

describe('segmentsForStart', () => {
  it('cria identificadores novos e únicos, com o prefixo do exercício e até 50 caracteres', () => {
    const list = segmentsForStart(EX, [], 'A\nA\nB');
    expect(new Set(list.map((s) => s.id)).size).toBe(3);
    expect(list.every((s) => s.id.startsWith(`${EX}-`) && s.id.length <= 50)).toBe(true);
  });

  it('separa exercícios diferentes, mesmo com o mesmo texto', () => {
    const a = segmentsForStart(EX, [], 'A');
    const b = segmentsForStart(OTHER, [], 'A');
    expect(a[0].id).not.toBe(b[0].id);
    // Segmentos de outro exercício nunca são reaproveitados.
    expect(segmentsForStart(EX, b, 'A')[0].id.startsWith(`${EX}-`)).toBe(true);
  });
});

describe('armazenamento no localStorage', () => {
  function memoryStorage(initial: Record<string, string> = {}) {
    const data = new Map(Object.entries(initial));
    return {
      getItem: (key: string) => data.get(key) ?? null,
      setItem: (key: string, value: string) => void data.set(key, value),
    };
  }
  const draft = { context: '', glossaryText: '' };

  it('mantém os identificadores depois de recarregar a página', () => {
    const storage = memoryStorage();
    const segments = segmentsForStart(EX, [], 'A\nA');
    storeExercise(storage, { ...draft, sourceText: 'A\nA', started: true, index: 1, exerciseId: EX, segments });
    const loaded = loadStoredExercise(storage);
    expect(loaded?.segments).toEqual(segments);
    expect(loaded?.index).toBe(1);
  });

  it('migra exercícios da versão anterior para os identificadores que já estão na base de dados', () => {
    const storage = memoryStorage({
      [STORAGE_KEY]: JSON.stringify({ ...draft, sourceText: 'A\nA', started: true, index: 0, exerciseId: EX }),
    });
    expect(loadStoredExercise(storage)?.segments.map((s) => s.id))
      .toEqual([occurrenceId(EX, 'A', 1), occurrenceId(EX, 'A', 2)]);
  });

  it('mantém os identificadores derivados do texto nos exercícios sem identificador de exercício', () => {
    const storage = memoryStorage({
      [STORAGE_KEY]: JSON.stringify({ ...draft, sourceText: 'A\nB', started: true, index: 0 }),
    });
    const loaded = loadStoredExercise(storage);
    expect(loaded?.exerciseId).toBe('');
    expect(loaded?.segments.map((s) => s.id)).toEqual([segmentId('A'), segmentId('B')]);
  });

  it('rejeita listas inválidas e reconcilia uma lista que não corresponde ao texto em curso', () => {
    const bad = memoryStorage({
      [STORAGE_KEY]: JSON.stringify({
        ...draft, sourceText: 'A', started: true, index: 0, exerciseId: EX, segments: [{ id: 'outro-1', source: 'A' }],
      }),
    });
    expect(loadStoredExercise(bad)?.segments.map((s) => s.id)).toEqual([occurrenceId(EX, 'A', 1)]);
    const stale = memoryStorage({
      [STORAGE_KEY]: JSON.stringify({
        ...draft, sourceText: 'B\nA', started: true, index: 0, exerciseId: EX,
        segments: [seg('a1', 'A'), seg('a2', 'A')],
      }),
    });
    const loaded = loadStoredExercise(stale)!.segments;
    expect(loaded[1].id).toBe(`${EX}-a2`);
    expect(loaded[0].id).not.toBe(`${EX}-a1`);
  });
});

/** Backend simulado com a mesma semântica de /api/segments: versão nova só quando algo muda. */
function fakeBackend() {
  const segments = new Map<string, { target: string; justification: string }>();
  const versions = new Map<string, { number: number; target: string; justification: string; created_at: string }[]>();
  return vi.fn(async (url: string | URL | Request, options?: RequestInit) => {
    const path = String(url);
    const versionsMatch = path.match(/^\/api\/segments\/([^/]+)\/versions$/);
    if (versionsMatch) {
      const id = decodeURIComponent(versionsMatch[1]);
      return Response.json({ id, versions: versions.get(id) ?? [] });
    }
    const id = decodeURIComponent(path.replace('/api/segments/', ''));
    if (options?.method === 'PUT') {
      const body = JSON.parse(options.body as string) as { target: string; justification: string };
      const current = segments.get(id);
      if (!current || current.target !== body.target || current.justification !== body.justification) {
        const list = versions.get(id) ?? [];
        list.push({ number: list.length + 1, ...body, created_at: '2026-11-26T10:00:00' });
        versions.set(id, list);
      }
      segments.set(id, body);
      return Response.json({ id, ...body });
    }
    return Response.json({ id, ...(segments.get(id) ?? { target: '', justification: '' }) });
  });
}

describe('integração: tradução, justificação e histórico seguem a ocorrência', () => {
  beforeEach(() => vi.stubGlobal('fetch', fakeBackend()));
  afterEach(() => vi.unstubAllGlobals());

  it('cenário real: alterar a 1.ª de duas linhas iguais preserva a 2.ª ocorrência', async () => {
    const original = segmentsForStart(EX, [], 'You must restart your computer.\nYou must restart your computer.');
    await saveSegment(original[0].id, 'Tens de reiniciar o computador.', 'JUSTIFICAÇÃO PRIMEIRA');
    await saveSegment(original[1].id, 'É obrigatório reiniciar o computador.', 'JUSTIFICAÇÃO SEGUNDA');

    const edited = segmentsForStart(EX, original, 'You may restart your computer.\nYou must restart your computer.');
    expect(edited[1].id).toBe(original[1].id);
    await expect(getSegment(edited[1].id)).resolves.toEqual({
      target: 'É obrigatório reiniciar o computador.', justification: 'JUSTIFICAÇÃO SEGUNDA',
    });
    expect((await getVersions(edited[1].id)).map((v) => v.target)).toEqual(['É obrigatório reiniciar o computador.']);
    // A linha alterada começa vazia, sem herdar a tradução nem o histórico da 1.ª ocorrência.
    await expect(getSegment(edited[0].id)).resolves.toEqual({ target: '', justification: '' });
    expect(await getVersions(edited[0].id)).toEqual([]);
    // O registo da linha alterada continua na base de dados, como histórico.
    await expect(getSegment(original[0].id)).resolves.toMatchObject({ target: 'Tens de reiniciar o computador.' });
  });

  it('a gravação seguinte fica na ocorrência certa e acrescenta uma versão', async () => {
    const original = segmentsForStart(EX, [], 'A\nA');
    await saveSegment(original[1].id, 'Segunda', 'J2');
    const edited = segmentsForStart(EX, original, 'B\nA');
    await saveSegment(edited[1].id, 'Segunda revista', 'J2 revista');
    expect((await getVersions(original[1].id)).map((v) => v.justification)).toEqual(['J2', 'J2 revista']);
    await expect(getSegment(original[0].id)).resolves.toEqual({ target: '', justification: '' });
  });

  it('exercício da versão anterior: depois da migração, editar mantém os dados da 2.ª ocorrência', async () => {
    await saveSegment(occurrenceId(EX, 'A', 1), 'Primeira', 'J1');
    await saveSegment(occurrenceId(EX, 'A', 2), 'Segunda', 'J2');
    const storage = new Map([[STORAGE_KEY, JSON.stringify({
      sourceText: 'A\nA', context: '', glossaryText: '', started: true, index: 0, exerciseId: EX,
    })]]);
    const migrated = loadStoredExercise({ getItem: (k) => storage.get(k) ?? null })!.segments;
    const edited = segmentsForStart(EX, migrated, 'B\nA');
    await expect(getSegment(edited[1].id)).resolves.toEqual({ target: 'Segunda', justification: 'J2' });
  });
});
