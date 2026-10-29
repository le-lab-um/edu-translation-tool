/**
 * Testes unitários do cliente da API no frontend.
 * Testa os tempos limite de 10s, erros de rede e se os dados são enviados como esperado.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { checkTranslation, CheckTimeoutError, getSegment, saveSegment, RequestTimeoutError } from './api';

// Simula uma operação de rede que só termina quando o pedido é cancelado.
function waitForAbort(signal: AbortSignal): Promise<never> {
  signal.throwIfAborted();
  return new Promise((_resolve, reject) => {
    signal.addEventListener('abort', () => reject(signal.reason), { once: true });
  });
}

describe('checkTranslation', () => {
  const fetchMock = vi.fn<typeof fetch>();

  beforeEach(() => {
    vi.useFakeTimers();
    fetchMock.mockReset();
    vi.stubGlobal('fetch', fetchMock);
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    vi.useRealTimers();
  });

  it('cancela um pedido sem resposta ao fim de 10 segundos', async () => {
    fetchMock.mockImplementation((_url, options) => waitForAbort(options!.signal!));

    const result = checkTranslation('Tradução em curso.');
    const rejection = expect(result).rejects.toBeInstanceOf(CheckTimeoutError);
    const signal = fetchMock.mock.calls[0][1]!.signal!;

    await vi.advanceTimersByTimeAsync(9_999);
    expect(signal.aborted).toBe(false);

    await vi.advanceTimersByTimeAsync(1);
    await rejection;
    expect(signal.aborted).toBe(true);
    expect(vi.getTimerCount()).toBe(0);
  });

  it('inclui a leitura do JSON no mesmo prazo de 10 segundos', async () => {
    fetchMock.mockImplementation(async (_url, options) => {
      // Os cabeçalhos chegam aos 4 segundos, mas o corpo continua por receber.
      await new Promise((resolve) => setTimeout(resolve, 4_000));
      const response = new Response();
      response.json = () => waitForAbort(options!.signal!);
      return response;
    });

    const result = checkTranslation('Texto.');
    const rejection = expect(result).rejects.toBeInstanceOf(CheckTimeoutError);
    const signal = fetchMock.mock.calls[0][1]!.signal!;

    await vi.advanceTimersByTimeAsync(9_999);
    expect(signal.aborted).toBe(false);

    await vi.advanceTimersByTimeAsync(1);
    await rejection;
    expect(signal.aborted).toBe(true);
    expect(vi.getTimerCount()).toBe(0);
  });

  it('mantém o texto enviado e remove o temporizador após uma resposta válida', async () => {
    fetchMock.mockResolvedValue(Response.json({ issues: [] }));

    await expect(checkTranslation(' Tradução com acentos.\n')).resolves.toEqual([]);
    expect(fetchMock).toHaveBeenCalledWith('/api/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        target: ' Tradução com acentos.\n',
        source: '',
        glossary: {},
      }),
      signal: expect.any(AbortSignal),
    });
    expect(vi.getTimerCount()).toBe(0);

    await vi.advanceTimersByTimeAsync(10_000);
    expect(fetchMock.mock.calls[0][1]!.signal!.aborted).toBe(false);
  });

  it('preserva uma falha de rede e remove o temporizador', async () => {
    const error = new TypeError('Falha de rede.');
    fetchMock.mockRejectedValue(error);

    await expect(checkTranslation('Texto.')).rejects.toBe(error);
    expect(vi.getTimerCount()).toBe(0);
  });

  it('preserva uma falha HTTP e remove o temporizador', async () => {
    fetchMock.mockResolvedValue(new Response(null, { status: 503 }));

    await expect(checkTranslation('Texto.')).rejects.toThrow('HTTP 503');
    expect(vi.getTimerCount()).toBe(0);
  });

  it('permite uma nova tentativa depois de um tempo limite', async () => {
    fetchMock.mockImplementationOnce((_url, options) => waitForAbort(options!.signal!));

    const firstAttempt = checkTranslation('Texto.');
    const rejection = expect(firstAttempt).rejects.toBeInstanceOf(CheckTimeoutError);
    await vi.advanceTimersByTimeAsync(10_000);
    await rejection;

    fetchMock.mockResolvedValueOnce(Response.json({ issues: [] }));
    await expect(checkTranslation('Texto.')).resolves.toEqual([]);

    const firstSignal = fetchMock.mock.calls[0][1]!.signal!;
    const secondSignal = fetchMock.mock.calls[1][1]!.signal!;
    expect(secondSignal).not.toBe(firstSignal);
    expect(secondSignal.aborted).toBe(false);
    expect(vi.getTimerCount()).toBe(0);
  });

  it.each(['get', 'save'])('limita também a operação %s a 10 segundos', async (operation) => {
    fetchMock.mockImplementation((_url, options) => waitForAbort(options!.signal!));
    const result = operation === 'get' ? getSegment('one') : saveSegment('one', 'Texto');
    const rejection = expect(result).rejects.toBeInstanceOf(RequestTimeoutError);
    await vi.advanceTimersByTimeAsync(10_000);
    await rejection;
    expect(vi.getTimerCount()).toBe(0);
  });

  it('valida a identidade e o texto do segmento recebido', async () => {
    for (const data of [{ id: 'outro', target: '' }, { id: 'one', target: null }, {}]) {
      fetchMock.mockResolvedValueOnce(Response.json(data));
      await expect(getSegment('one')).rejects.toThrow('segmento inválido');
    }
  });

  it('preserva o texto e só aceita confirmação da mesma tradução', async () => {
    const target = ' Tradução\ncom acentos.\t';
    fetchMock.mockResolvedValueOnce(Response.json({ id: 'one', target }));
    await expect(saveSegment('one', target)).resolves.toBeUndefined();
    expect(JSON.parse(fetchMock.mock.calls[0][1]!.body as string)).toEqual({ target });
    fetchMock.mockResolvedValueOnce(Response.json({ id: 'one', target: 'Outra' }));
    await expect(saveSegment('one', target)).rejects.toThrow('não confirmou');
  });

  it('não aceita alertas com categoria ou estrutura desconhecida', async () => {
    fetchMock.mockResolvedValueOnce(Response.json({ issues: [{ category: 'unknown' }] }));
    await expect(checkTranslation('Texto')).rejects.toThrow('resposta inválida');
  });
});
