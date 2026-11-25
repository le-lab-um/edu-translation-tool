# Educational Translation Tool

Aplicação web educativa para praticar tradução de inglês para português europeu (EN → PT-PT). O aluno traduz texto segmentado, usa memória de tradução e glossário, corre verificações por regras e pede pistas a um modelo de linguagem local. As pistas procuram orientar a revisão sem entregar a solução.

Projeto de Diogo Pinto (PG61515) e Mariana Pinto (PG61534), Mestrado em Engenharia Informática da Universidade do Minho. O artigo que descreve a ferramenta e a sua avaliação está em [`paper/main.typ`](paper/main.typ). A página de apresentação está em [`docs/`](docs/index.html), publicada em <https://le-lab-um.github.io/edu-translation-tool/>.

## Funcionalidades

- **Editor segmentado:** escrever ou colar texto, carregar um `.txt` até 200 KiB ou escolher um exemplo. Cada linha não vazia é um segmento, até 200 por exercício. O contexto é mostrado ao aluno, e o glossário usa uma entrada por linha (`folder = pasta | diretório`).
- **Persistência:** a tradução é guardada em SQLite ao clicar em **Guardar**, ao mudar de segmento ou ao voltar à configuração, e é recuperada ao reabrir o segmento. Uma gravação falhada mantém o texto no ecrã e impede a navegação.
- **Memória de tradução:** cada tradução confirmada é guardada como par original/tradução. Ao abrir um segmento, surgem sugestões de segmentos parecidos (RapidFuzz, limiar 70 %) com o botão **Usar**.
- **Cinco regras determinísticas** (botão **Verificar**): tradução vazia, números alterados ou em falta, termos do glossário em falta, marcadores (`{name}`) e etiquetas de formatação (`<b>`, `<i>`, …).
- **Pistas híbridas** (botão **Pedir pista**): junta as regras com um Qwen local (`qwen3:4b-instruct-2507-q4_K_M`, via Ollama). O modelo acrescenta a categoria **Significado e contexto**. Cada alerta indica a origem («Regra» ou «Sugestão do modelo local»). As regras têm prioridade em categorias repetidas, e um filtro heurístico generaliza as pistas que parecem revelar a solução. Se o Ollama falhar, a aplicação devolve só as regras.
- **Registos:** a interface regista eventos de uso (início, gravação, verificação, pistas, memória), sem o texto da tradução, exportáveis em JSON e CSV.

## Resultados da avaliação

Avaliámos a ferramenta em 40 casos de teste (21 originais) que não foram usados no desenvolvimento, com dois prompts: o v3, usado pela aplicação, e o v4, revisto depois de uma fase de diagnóstico.

| Método (âmbito principal, 18 casos) | VP/FP/FN v3 | F1 v3 | VP/FP/FN v4 | F1 v4 |
| --- | --- | --- | --- | --- |
| Regras | 10/0/0 | 100 % | 10/0/0 | 100 % |
| LLM isolado | 6/2/4 | 66,7 % | 6/1/4 | 70,6 % |
| Híbrido | 10/2/0 | 90,9 % | 10/1/0 | 95,2 % |

- **Deteção (RQ1):** as regras detetam tudo no seu âmbito. O modelo isolado não assinala nenhum dos erros de glossário, mas complementa as regras em unidades e números acrescentados. O híbrido mantém o recall das regras.
- **Qualidade das pistas (RQ2):** com o v3, 15 das 20 pistas do modelo revelavam parte ou toda a correção. Com o v4, só 1 de 19 o fazia, com a mesma correção e mais clareza. Nenhuma pista mostrada ao aluno com o v4 revelava a solução.

Os resultados completos e a discussão estão na secção 5 do artigo.

## Estrutura do repositório

| Local | Conteúdo |
| --- | --- |
| `frontend/` | Interface em React 19 + TypeScript + Vite. `src/App.tsx` (editor), `src/exercise.ts` (segmentação e glossário), `src/api.ts` (cliente HTTP) e testes Vitest. |
| `backend/` | API em FastAPI. `main.py` (endpoints), `rules.py` (regras), `llm.py` (adaptador Ollama), `hybrid.py` (fusão e filtro), `translation_memory.py`, `database.py` e `models.py` (SQLite). |
| `backend/prompts/` | `hint-v3.txt` (prompt da aplicação) e `hint-v4.txt` (prompt revisto e avaliado). |
| `tests/` | Testes do backend: regras, API, persistência, memória e registos, fusão e cálculo das métricas. |
| `data/development.json` | Dez exemplos de desenvolvimento usados no piloto. |
| `experiments/ollama-pilot/` | Piloto de 23 de outubro com os prompts v1 e v2 (script, prompts, relatórios e notas). |
| `experiments/evaluation/` | Conjuntos de casos, scripts, relatórios e folhas de anotação da avaliação (ver abaixo). |
| `paper/` | Artigo em Typst e figuras. |
| `docs/` | Página estática de apresentação (GitHub Pages). |

## Executar localmente

Requisitos: Python 3.11 ou posterior, Node 20.19+ (ou 22.12+, 24+) e, para as pistas do modelo, o [Ollama](https://ollama.com) com o Qwen:

```bash
ollama pull qwen3:4b-instruct-2507-q4_K_M
```

Backend, na raiz do repositório:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements.txt
.venv/bin/python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```

Frontend, noutro terminal:

```bash
cd frontend
npm ci
npm run dev
```

Abrir o endereço indicado pelo Vite (normalmente `http://localhost:5173`). A documentação da API fica em `http://127.0.0.1:8000/docs` e a base de dados em `data/app.db`, fora do Git. Sem o Ollama, **Pedir pista** devolve só as regras.

Variáveis de ambiente do modelo: `OLLAMA_URL` (por omissão `http://localhost:11434`), `OLLAMA_MODEL`, `OLLAMA_TIMEOUT` (30 s) e `LLM_ENABLED=0` para o desligar.

## Testes

```bash
.venv/bin/python -m unittest discover -s tests
```

```bash
cd frontend && npm test && npm run build
```

São 79 testes no backend e 26 no frontend. A integração com o Ollama é testada com um servidor simulado (`httpx.MockTransport`), sem precisar do modelo.

## API

| Endpoint | Função |
| --- | --- |
| `POST /api/check` | Corre as regras sobre `source`, `target` e `glossary`. Devolve `issues` com `category`, `explanation` e `hint`. |
| `POST /api/hint` | Como `/api/check`, mais `context`. Junta as regras e o modelo e devolve também `source` por alerta, `llm_status`, `sanitized` e `elapsed_ms`. |
| `GET` · `PUT /api/segments/{id}` | Recuperar e guardar a tradução de um segmento. |
| `POST /api/memory` · `POST /api/memory/search` | Guardar um par e procurar segmentos parecidos. |
| `POST /api/events` · `GET /api/events/export` · `GET /api/events/summary` | Registar eventos, exportá-los (JSON ou CSV) e resumi-los. |

O glossário segue o formato `{"folder": {"target": "pasta", "variants": ["diretório"]}}`.

Limites das regras:
- **Números:** compara valores do original com convenções EN e PT-PT (`1,000.50` = `1 000,50`). Não interpreta unidades, números por extenso, horas ou intervalos, nem assinala números acrescentados.
- **Glossário:** procura termos completos, sem distinguir maiúsculas.
- **Marcadores e etiquetas:** comparam nomes e contagens, sem analisar posição nem aninhamento.

A ausência de alertas não certifica a qualidade da tradução.

## Avaliação

Todos os comandos correm na raiz do repositório, com o Ollama ativo. Os relatórios novos ficam em `output/`, fora do Git.

### Conjuntos de casos

| Ficheiro | Casos | Uso |
| --- | --- | --- |
| `data/development.json` | 10 | Piloto com os prompts v1 e v2 (desenvolvimento). |
| `experiments/evaluation/calibration.json` | 8 | Calibração da grelha de anotação (desenvolvimento). |
| `experiments/evaluation/diagnostico.json` | 20 | Diagnóstico do v3 e afinação do v4, só significado e contexto (desenvolvimento). |
| `experiments/evaluation/test.json` | 40 | Teste final: 18 casos no âmbito principal da RQ1, 12 de significado e contexto e 10 de robustez. Referência revista pelos autores. |

Cada caso tem `input` (original, tradução, contexto e glossário), `expected_categories` (vazio se a tradução é aceitável), `analysis_scope` e `annotation_note`. Só o `input` chega aos métodos.

### Passos

1. **Verificar que o teste não se repete noutros ficheiros nem nos prompts:**

   ```bash
   .venv/bin/python -m experiments.evaluation.check_overlap
   ```

2. **Recolher as respostas,** com o v3 e com o v4, uma a seguir à outra, na mesma máquina:

   ```bash
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --output output/teste-v3.json
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --prompt backend/prompts/hint-v4.txt --output output/teste-v4.json
   ```

   Cada relatório guarda, por caso, os alertas das regras, os do modelo antes da fusão e os do híbrido, bem como a resposta completa do Ollama. Regista também a versão do código, o hash do conjunto e do prompt, o modelo e o seu digest e a versão do Ollama. Nas traduções vazias, a chamada ao modelo serve só para o LLM isolado.

3. **RQ1, métricas de deteção:**

   ```bash
   .venv/bin/python -m experiments.evaluation.metrics output/teste-v3.json output/teste-v4.json
   ```

   Conta VP, FP e FN por par caso-categoria para Regras, LLM isolado e Híbrido. A análise principal usa o âmbito `rq1_main` e as categorias tradução vazia, números e glossário. A robustez e o significado e contexto saem à parte.

4. **RQ2, folha de anotação:**

   ```bash
   .venv/bin/python -m experiments.evaluation.make_sheet output/teste-v3.json output/teste-v4.json --out output/anotacao-teste
   ```

   Junta as pistas das duas versões baralhadas numa folha (`-folha.csv`). A versão de cada linha fica só na chave (`-chave.csv`), que não se abre durante a anotação.

5. **RQ2, resumo, depois de a folha estar revista:**

   ```bash
   .venv/bin/python -m experiments.evaluation.rq2 output/anotacao-teste-folha.csv output/anotacao-teste-chave.csv
   ```

### Grelha de anotação

Cada linha da folha é um par explicação-pista. Usa-se `incerto` quando há uma ambiguidade concreta.

| Critério | Valores |
| --- | --- |
| Correção | `sim` se identifica uma discrepância real; `não` se assinala uma tradução aceitável ou descreve mal o problema. |
| Fundamentação | `sim` se se apoia no original, na tradução, no contexto ou no glossário; `parcial` se é vaga; `não` se inventa ou contradiz. |
| Clareza | `sim` se se entende à primeira leitura; `parcial` se exige interpretação; `não` se é confusa. |
| Utilidade | `sim` se orienta para uma comparação concreta; `parcial` se só pede uma revisão geral; `não` se aponta para o problema errado. |
| Revelação | `nenhuma` se só orienta; `parcial` se dá um equivalente, valor ou interpretação que resolve parte do problema; `total` se dá a correção. |

Nas notas, as etiquetas `[binária]`, `[afirmação]`, `[inventa]` e `[língua]` marcam, respetivamente, a pergunta com duas hipóteses, a pista que afirma o que diz o original, a explicação que inventa factos e os erros de língua. A primeira versão de cada folha no histórico do Git é a proposta inicial; os commits seguintes são a revisão por consenso dos dois autores.

### Ficheiros em `experiments/evaluation/`

| Ficheiro | Conteúdo |
| --- | --- |
| `run.py`, `check_overlap.py`, `make_sheet.py`, `metrics.py`, `rq2.py` | Scripts dos passos acima. |
| `calibration-2026-11-14.json`, `calibration-2026-11-23.json` | Recolhas de calibração com o v3. A segunda repete as respostas da primeira noutra versão do Ollama. |
| `anotacao-folha.csv`, `anotacao-chave.csv` | Anotação da calibração. |
| `desenvolvimento-v3-2026-11-23.json` | Recolha com o v3 nos exemplos de desenvolvimento. |
| `diagnostico-v3-2026-11-23.json`, `anotacao-diagnostico-*.csv` | Diagnóstico do v3 e a sua anotação revista. |
| `diagnostico-v3-2026-11-24.json` | Repetição do v3 no diagnóstico na máquina das recolhas finais: 14 de 20 respostas iguais, com a mesma deteção. |
| `diagnostico-v4-2026-11-24.json`, `diagnostico-v4-ajustado-2026-11-24.json`, `anotacao-diagnostico-v4-*.csv` | Diagnóstico do rascunho e da versão final do v4, e a anotação desta última. |
| `teste-v3-2026-11-25.json`, `teste-v4-2026-11-25.json` | Recolhas finais no teste (MacBook Air M4, 16 GB, macOS 15.5, Ollama 0.14.3). |
| `metricas-teste-2026-11-25.json` | Resultados da RQ1. |
| `anotacao-teste-folha.csv`, `anotacao-teste-chave.csv`, `rq2-teste-2026-11-25.json` | Anotação revista da RQ2 e o seu resumo. |

Os CSV usam `;` e UTF-8 com BOM, para abrir no Excel em português. Os relatórios guardam o commit em que foram feitos; o hash de `test.json` registado nas recolhas finais corresponde ao ficheiro no commit `7668938`, antes de uma alteração posterior ao campo descritivo `provenance`.

## Limitações

- **Identidade dos segmentos:** a tradução é associada ao texto do original, por isso segmentos iguais partilham a tradução, mesmo em exercícios diferentes. A memória e os registos são partilhados por toda a instância.
- **Uso local:** sem autenticação, com CORS permissivo e exportação aberta.
- **Funcionalidades por implementar:** histórico de versões, justificações do aluno e uma vista cronológica dos registos.
- **Avaliação:** é interna, em conjuntos pequenos e sintéticos, e não mede efeitos na aprendizagem.
