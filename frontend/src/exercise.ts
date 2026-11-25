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

/** Hash FNV-1a de 32 bits do texto, em 8 dígitos hexadecimais. */
function textHash(source: string): string {
  let hash = 0x811c9dc5;
  for (let i = 0; i < source.length; i += 1) {
    hash ^= source.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return (hash >>> 0).toString(16).padStart(8, '0');
}

/**
 * Identificador antigo, derivado só do texto. Mantém-se para os exercícios começados antes
 * da identidade por ocorrência: aí, linhas idênticas partilham a mesma tradução.
 */
export function segmentId(source: string): string {
  return `custom-${textHash(source)}`;
}

/** Formato do identificador de um exercício: «e» seguido de 12 dígitos hexadecimais. */
export const EXERCISE_ID_PATTERN = /^e[0-9a-f]{12}$/;

/** Cria o identificador aleatório de um novo exercício. */
export function newExerciseId(): string {
  const bytes = new Uint8Array(6);
  try {
    crypto.getRandomValues(bytes);
  } catch {
    for (let i = 0; i < bytes.length; i += 1) bytes[i] = Math.floor(Math.random() * 256);
  }
  return `e${Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('')}`;
}

/**
 * Identificador de uma ocorrência dentro de um exercício: exercício, texto e número da ocorrência.
 * Linhas iguais no mesmo exercício (1.ª, 2.ª, … ocorrência) e em exercícios diferentes ficam
 * com traduções independentes. Editar outras linhas do texto original não muda o identificador.
 */
export function occurrenceId(exerciseId: string, source: string, occurrence: number): string {
  return `${exerciseId}-${textHash(source)}-${occurrence}`;
}

/**
 * Divide o texto em segmentos: uma linha (ou parágrafo) não vazia por segmento.
 * Com um identificador de exercício, cada ocorrência tem identidade própria; sem ele, usa o
 * identificador antigo, derivado só do texto.
 */
export function buildSegments(text: string, exerciseId?: string): Segment[] {
  const seen = new Map<string, number>();
  return text
    .split(/\r\n|\r|\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((source) => {
      if (!exerciseId) return { id: segmentId(source), source };
      const occurrence = (seen.get(source) ?? 0) + 1;
      seen.set(source, occurrence);
      return { id: occurrenceId(exerciseId, source, occurrence), source };
    });
}

/**
 * Lê o glossário no formato «termo = equivalente | variante | outra variante»
 * (uma entrada por linha). O primeiro equivalente é o termo prescrito e os restantes
 * são variantes aceites, tal como o motor de regras do backend espera.
 */
export function parseGlossary(text: string): { glossary: Glossary; invalidLines: string[] } {
  const glossary: Glossary = Object.create(null);
  const seenTerms = new Set<string>();
  const invalidLines: string[] = [];

  for (const rawLine of text.split(/\r\n|\r|\n/)) {
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

    if (!term || targets.length === 0 || seenTerms.has(term.toLowerCase())) {
      invalidLines.push(line);
      continue;
    }

    seenTerms.add(term.toLowerCase());
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
