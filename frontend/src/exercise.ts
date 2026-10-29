/**
 * Lógica do exercício: divisão do texto original em segmentos,
 * leitura do glossário escrito pelo utilizador e exemplos prontos a usar.
 * São funções puras (sem React nem rede), por isso são fáceis de testar.
 */

/** Tamanho máximo de um ficheiro de texto carregado (200 KB). */
export const MAX_UPLOAD_BYTES = 200 * 1024;

/** Número máximo de segmentos por exercício. */
export const MAX_SEGMENTS = 200;

export type GlossaryEntry = { target: string; variants?: string[] };
export type Glossary = Record<string, GlossaryEntry>;
export type Segment = { id: string; source: string };

/**
 * Identificador estável de um segmento, derivado do próprio texto (hash FNV-1a de 32 bits).
 * Assim, voltar a colar o mesmo texto recupera a tradução já guardada na base de dados.
 * Duas linhas idênticas partilham o mesmo identificador (e, por isso, a mesma tradução).
 */
export function segmentId(source: string): string {
  let hash = 0x811c9dc5;
  for (let i = 0; i < source.length; i += 1) {
    hash ^= source.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return `custom-${(hash >>> 0).toString(16).padStart(8, '0')}`;
}

/** Divide o texto em segmentos: uma linha (ou parágrafo) não vazia por segmento. */
export function buildSegments(text: string): Segment[] {
  return text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((source) => ({ id: segmentId(source), source }));
}

/**
 * Lê o glossário no formato «termo = equivalente | variante | outra variante»
 * (uma entrada por linha). O primeiro equivalente é o termo prescrito e os restantes
 * são variantes aceites, tal como o motor de regras do backend espera.
 */
export function parseGlossary(text: string): { glossary: Glossary; invalidLines: string[] } {
  const glossary: Glossary = {};
  const invalidLines: string[] = [];

  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;

    const separator = line.indexOf('=');
    const term = separator > 0 ? line.slice(0, separator).trim() : '';
    const targets =
      separator > 0
        ? line
            .slice(separator + 1)
            .split('|')
            .map((part) => part.trim())
            .filter((part) => part.length > 0)
        : [];

    if (!term || targets.length === 0) {
      invalidLines.push(line);
      continue;
    }

    const [target, ...variants] = targets;
    glossary[term] = variants.length > 0 ? { target, variants } : { target };
  }

  return { glossary, invalidLines };
}

export type Example = {
  id: string;
  label: string;
  sourceText: string;
  context: string;
  glossaryText: string;
};

/** Exemplos que preenchem o formulário; servem para demonstrar cada regra do motor de QA. */
export const EXAMPLES: Example[] = [
  {
    id: 'instructions',
    label: 'Instruções',
    sourceText: 'Read the instructions before you start.',
    context: 'Instrução apresentada antes de um exercício educativo.',
    glossaryText: 'instructions = instruções\nstart = começar',
  },
  {
    id: 'numbers',
    label: 'Preço e desconto',
    sourceText: 'The total is €1,000.50.\nA 15% discount applies.',
    context:
      'Resumo de uma compra. No original, a vírgula separa milhares e o ponto separa a parte decimal.',
    glossaryText: '',
  },
  {
    id: 'files',
    label: 'Ficheiros e pastas',
    sourceText: 'Save the file in the folder.\nOpen the file.',
    context: 'Instruções de uma aplicação de gestão de documentos.',
    glossaryText: 'file = ficheiro\nfolder = pasta | diretório',
  },
];
