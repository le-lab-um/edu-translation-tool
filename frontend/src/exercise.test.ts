/**
 * Testes unitários da lógica do exercício:
 * segmentação do texto, identificadores estáveis e leitura do glossário.
 */

import { describe, expect, it } from 'vitest';
import { EXAMPLES, buildSegments, parseGlossary, segmentId } from './exercise';

describe('buildSegments', () => {
  it('cria um segmento por linha não vazia, sem espaços nas pontas', () => {
    const segments = buildSegments('  Open the file.  \n\n\nSave the file.\r\nClose it.\n');
    expect(segments.map((s) => s.source)).toEqual(['Open the file.', 'Save the file.', 'Close it.']);
  });

  it('devolve lista vazia para texto vazio ou só com espaços', () => {
    expect(buildSegments('')).toEqual([]);
    expect(buildSegments('  \n \t \n')).toEqual([]);
  });
});

describe('segmentId', () => {
  it('é estável para o mesmo texto e diferente para textos diferentes', () => {
    expect(segmentId('Open the file.')).toBe(segmentId('Open the file.'));
    expect(segmentId('Open the file.')).not.toBe(segmentId('Open the folder.'));
  });

  it('cabe no limite de 50 caracteres da coluna id', () => {
    expect(segmentId('x'.repeat(5000)).length).toBeLessThanOrEqual(50);
  });
});

describe('parseGlossary', () => {
  it('lê o termo prescrito e as variantes aceites', () => {
    const { glossary, invalidLines } = parseGlossary('file = ficheiro\nfolder = pasta | diretório');
    expect(glossary).toEqual({
      file: { target: 'ficheiro' },
      folder: { target: 'pasta', variants: ['diretório'] },
    });
    expect(invalidLines).toEqual([]);
  });

  it('ignora linhas vazias e assinala as linhas inválidas', () => {
    const { glossary, invalidLines } = parseGlossary('file = ficheiro\n\nsem separador\n= vazio\nfolder =  | ');
    expect(Object.keys(glossary)).toEqual(['file']);
    expect(invalidLines).toEqual(['sem separador', '= vazio', 'folder =  |']);
  });
});

describe('EXAMPLES', () => {
  it('têm texto original e glossários válidos', () => {
    for (const example of EXAMPLES) {
      expect(buildSegments(example.sourceText).length).toBeGreaterThan(0);
      expect(parseGlossary(example.glossaryText).invalidLines).toEqual([]);
    }
  });
});
