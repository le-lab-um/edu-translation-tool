/**
 * Testes unitários da lógica do exercício:
 * segmentação do texto, identificadores estáveis e leitura do glossário.
 */

import { describe, expect, it } from 'vitest';
import {
  EXAMPLES, EXERCISE_ID_PATTERN, buildSegments, newExerciseId, occurrenceId, parseGlossary, segmentId,
} from './exercise';

describe('buildSegments', () => {
  it('cria um segmento por linha não vazia, sem espaços nas pontas', () => {
    const segments = buildSegments('  Open the file.  \n\n\nSave the file.\r\nClose it.\n');
    expect(segments.map((s) => s.source)).toEqual(['Open the file.', 'Save the file.', 'Close it.']);
  });

  it('devolve lista vazia para texto vazio ou só com espaços', () => {
    expect(buildSegments('')).toEqual([]);
    expect(buildSegments('  \n \t \n')).toEqual([]);
  });

  it('também reconhece quebras de linha CR isoladas', () => {
    expect(buildSegments('One\rTwo').map((s) => s.source)).toEqual(['One', 'Two']);
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

describe('identidade por ocorrência', () => {
  it('dá identidade própria a linhas iguais no mesmo exercício', () => {
    const ids = buildSegments('Open the file.\nClose it.\nOpen the file.', 'e0123456789ab').map((s) => s.id);
    expect(new Set(ids).size).toBe(3);
    expect(ids[0]).toBe(occurrenceId('e0123456789ab', 'Open the file.', 1));
    expect(ids[2]).toBe(occurrenceId('e0123456789ab', 'Open the file.', 2));
  });

  it('separa o mesmo texto em exercícios diferentes', () => {
    const [a] = buildSegments('Open the file.', 'e000000000001');
    const [b] = buildSegments('Open the file.', 'e000000000002');
    expect(a.id).not.toBe(b.id);
  });

  it('mantém o identificador quando outras linhas mudam', () => {
    const before = buildSegments('Intro.\nOpen the file.', 'e0123456789ab');
    const after = buildSegments('New intro.\nOpen the file.', 'e0123456789ab');
    expect(after[1].id).toBe(before[1].id);
  });

  it('sem exercício usa o identificador antigo, para exercícios anteriores', () => {
    expect(buildSegments('Open the file.')[0].id).toBe(segmentId('Open the file.'));
  });

  it('cria identificadores de exercício válidos e curtos', () => {
    const id = newExerciseId();
    expect(id).toMatch(EXERCISE_ID_PATTERN);
    expect(newExerciseId()).not.toBe(id);
    expect(occurrenceId(id, 'x'.repeat(5000), 200).length).toBeLessThanOrEqual(50);
  });
});

describe('parseGlossary', () => {
  it('assinala duplicados sem substituir silenciosamente o primeiro equivalente', () => {
    const { glossary, invalidLines } = parseGlossary('file = ficheiro\nFILE = arquivo');
    expect(glossary.file.target).toBe('ficheiro');
    expect(invalidLines).toEqual(['FILE = arquivo']);
  });

  it('aceita nomes de propriedades especiais como termos normais', () => {
    const { glossary } = parseGlossary('__proto__ = protótipo\nconstructor = construtor');
    expect(Object.keys(glossary)).toEqual(['__proto__', 'constructor']);
    expect(JSON.parse(JSON.stringify(glossary)).__proto__.target).toBe('protótipo');
  });
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
