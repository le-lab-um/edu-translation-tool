# Calibração da avaliação das pistas

O conjunto de calibração tem oito traduções sintéticas de seis originais. Inclui dois controlos com traduções aceitáveis e casos de significado, números e glossário. As categorias esperadas são propostas a rever pelos dois autores. Os originais e as variantes deste conjunto ficam reservados ao desenvolvimento e à calibração.

## Recolher as respostas

Na raiz do repositório, com as dependências do backend instaladas no ambiente virtual e o Ollama local a correr com o Qwen instalado:

```sh
.venv/bin/python -m experiments.evaluation.run --output output/calibracao-local.json
```

Usar um nome de ficheiro novo em cada execução. O script reutiliza o [prompt v3 da aplicação](../../backend/prompts/hint-v3.txt), o cliente Ollama, as regras e a fusão. Por tradução, regista os alertas das regras, os alertas validados do modelo antes da fusão e o feedback final. Uma chamada ao modelo alimenta as duas versões do feedback. As categorias esperadas e as notas de anotação ficam no relatório e fora do pedido ao modelo. O relatório também regista a versão do Ollama, o digest do modelo, os parâmetros, os hashes do conjunto e do prompt, a latência e as falhas. A recolha corre sem o servidor FastAPI e sem consultar a base de dados da aplicação.

## Grelha de anotação

A anotação parte de uma proposta inicial e é revista em conjunto pelos dois autores, com acesso ao original, à tradução, ao contexto e ao glossário. Uma linha representa um alerta (explicação e pista) numa versão do feedback, ou um caso sem alerta. Anota-se separadamente a versão do modelo e a versão apresentada ao aluno. As linhas estão baralhadas e a versão fica na chave (`anotacao-chave.csv`), que não é dada a quem prepara a proposta inicial no conjunto de teste.

| Critério | Como registar |
| --- | --- |
| Correção | `sim` se identifica uma discrepância real, `não` se assinala uma tradução aceitável ou descreve incorretamente o problema. |
| Fundamentação | `sim` se a explicação é sustentada pelo original, tradução, contexto ou glossário, `parcial` se é vaga, `não` se inventa ou contradiz informação. |
| Clareza | `sim` se a explicação e a pergunta se entendem à primeira leitura, `parcial` se exigem interpretação, `não` se são confusas. |
| Utilidade | `sim` se orienta para uma comparação concreta, `parcial` se apenas pede uma revisão geral, `não` se aponta para o problema errado ou deixa o aluno sem ação. |
| Revelação | `nenhuma` se orienta a revisão, `parcial` se fornece um equivalente, valor ou interpretação que resolve parte do problema, `total` se entrega a correção suficiente para substituir a tradução ou o trecho em causa. |

Campos a guardar por linha: caso, categoria emitida, versão do texto, os cinco juízos e uma nota com a evidência. Usar `incerto` quando houver uma ambiguidade concreta e explicar qual. Registar num campo separado o problema omitido se o caso não produzir alerta. Registar falhas do modelo por caso. Os autores revêem a proposta em conjunto e alteram diretamente `anotacao-folha.csv`. As alterações ficam no histórico do Git: o primeiro commit do ficheiro é a proposta inicial. Não há anotação independente nem medida de concordância entre anotadores.

### Ficheiros

- **Gerar a folha:** `.venv/bin/python -m experiments.evaluation.make_sheet experiments/evaluation/calibration-2026-11-14.json --out output/anotacao` cria `output/anotacao-folha.csv` e `output/anotacao-chave.csv`.
- **`anotacao-folha.csv`:** uma linha por alerta (ou caso sem alerta), com os cinco juízos, uma nota e o problema omitido. Separador `;` e UTF-8 com BOM, para abrir no Excel em português.
- **`anotacao-chave.csv`:** liga cada `row_id` ao caso e à versão (`modelo`, `apresentada`, `modelo=apresentada`, `regra` ou `sem_alerta`).
- **Valores aceites:** `sim`, `parcial`, `não` ou `incerto` para fundamentação, clareza e utilidade; `sim`, `não` ou `incerto` para correção; `nenhuma`, `parcial` ou `total` para revelação.

## Primeira passagem com o Qwen real

A execução de 14 de novembro devolveu respostas válidas nos oito casos. O [relatório](calibration-2026-11-14.json) contém o texto suficiente para aplicar a grelha. Observações iniciais para discutir em conjunto:

- **cal-01, proibição traduzida como permissão.** O Qwen assinalou a contradição e devolveu uma pergunta de revisão. A escolha entre proibição e recomendação é menos precisa do que a diferença observada entre proibição e permissão.
- **cal-02, tradução aceitável.** O Qwen assinalou um problema de sentido. O filtro generalizou o texto, deixando o falso alerta visível.
- **cal-04, falso cognato.** O modelo classificou o caso como terminologia, embora o glossário estivesse vazio, e sugeriu «apresentação». A resposta passou pelo filtro. É um caso para decidir o grau de revelação após ler o alerta completo.
- **cal-06 e cal-07, números.** Num valor alterado, a regra teve prioridade. Na troca de unidade com o mesmo valor, a regra ficou em silêncio e o filtro generalizou a sugestão do modelo.

Depois de calibrar a grelha, fixar os critérios de anotação. O conjunto de teste está em `test.json` (ver abaixo). Reservar as métricas para a execução de teste após a revisão das categorias de referência.

## Conjunto de teste

`test.json` tem 40 casos de 21 originais, todos diferentes dos usados no desenvolvimento, na calibração, nos prompts, no editor e na demonstração. Dezanove casos são traduções aceitáveis, para contar falsos alertas. Cada caso tem `analysis_scope`, `expected_categories` (vazio se a tradução é aceitável) e `annotation_note` (a evidência). Apenas `input` chega aos métodos.

| `analysis_scope` | Casos | Conteúdo |
| --- | --- | --- |
| `rq1_main` | 18 | Tradução vazia (2), números em algarismos (8) e glossário (8), com controlos aceitáveis. É a análise principal da RQ1. |
| `rq2_meaning` | 12 | Significado e contexto: modalidade, negação, expressão idiomática, falso cognato, papéis e tempo. Só entra na RQ2 e na contagem de falsos alertas. |
| `robustness` | 10 | Análise complementar: unidade, número acrescentado, hora, intervalo e valor por extenso. Fica fora dos agregados da análise principal. |

Antes de recolher as respostas:

1. **Verificar repetições:** `.venv/bin/python -m experiments.evaluation.check_overlap` procura cada original (e cada termo de glossário) nos ficheiros do projeto e termina com erro se encontrar coincidências ou originais muito parecidos. Repetir depois de qualquer alteração ao conjunto.
2. **Rever as categorias de referência** em conjunto, sem consultar as saídas dos métodos. Quando estiverem fixadas, mudar `annotation_status` para `reviewed` e fazer commit. O hash do ficheiro fica registado no relatório.
3. **Não alterar** o prompt, o filtro nem o conjunto entre a revisão e a execução. Nenhum caso é excluído em função do resultado.

Recolher as respostas (uma só vez por configuração, com o Ollama a correr):

```sh
.venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --output output/teste-AAAA-MM-DD.json
```

Antes do primeiro caso faz um pedido de aquecimento (`--no-warmup` desativa-o) e, por caso, uma única chamada ao modelo. Nas traduções vazias a chamada é experimental: o resultado do modelo serve só para a condição «LLM isolado» e o híbrido devolve apenas o alerta da regra. O relatório regista, além do que já guardava na calibração, a revisão do código (e se havia alterações por commitar), as versões do Python e das dependências, o aquecimento, o número de tentativas e a resposta completa do Ollama por caso (tempos e contagem de tokens incluídos). Para anotar as pistas: `make_sheet` aceita o relatório de teste.

## Métricas de deteção (RQ1)

`metrics.py` lê um relatório, ou dois para comparar o v3 com o v4, e calcula VP, FP e FN por categoria e a micro-média para Regras, LLM isolado e Híbrido. A unidade é o par caso-categoria, e a referência é `expected_categories`.

```sh
.venv/bin/python -m experiments.evaluation.metrics output/teste-v3-AAAA-MM-DD.json output/teste-v4-AAAA-MM-DD.json --json output/metricas.json
```

- **Análise principal:** âmbito `rq1_main` e as categorias `empty_translation`, `numeric_mismatch` e `terminology`.
- **Robustez:** o âmbito `robustness` sai numa tabela à parte.
- **Significado e contexto:** os alertas `meaning_context` são descritos em separado (RQ2) e não entram na micro-média.
- **Casos com a mesma base:** os três métodos usam os mesmos casos, os que têm `llm_status` igual a `ok` em todos os relatórios. Os casos excluídos são listados.
- **Métricas indefinidas:** com denominador nulo, a métrica aparece como `indef.`.
- **Falsos alertas:** conta também os casos aceitáveis com pelo menos um alerta.
- **Aviso de comparação:** avisa se os relatórios diferem no conjunto, no modelo, na versão do Ollama ou nos parâmetros.

Com `--scope all` analisa todos os casos (útil para os conjuntos de desenvolvimento e diagnóstico, que não têm `rq1_main`).

## Resumo da RQ2

`rq2.py` lê a folha revista e a chave e resume, por prompt, os alertas do modelo em duas versões: a do modelo (antes da fusão) e a apresentada ao aluno (depois do filtro). Para cada versão conta os critérios, a revelação (`parcial` e `total` à parte), as linhas com `incerto` e as etiquetas das notas. As linhas das regras e os casos sem alerta ficam de fora. Só se corre depois da revisão, porque abre a chave.

```sh
.venv/bin/python -m experiments.evaluation.rq2 experiments/evaluation/anotacao-teste-folha.csv experiments/evaluation/anotacao-teste-chave.csv --json experiments/evaluation/rq2-teste-2026-11-25.json
```

## Diagnóstico e prompt v4

`diagnostico.json` tem 20 casos de 10 originais, todos de significado e contexto: tempo e advérbios, falsos cognatos, negação, modalidade, quantificadores, expressão idiomática e condição. Faz parte do desenvolvimento: as suas respostas podem orientar a revisão do prompt e nunca entram no teste. Verificar com `check_overlap --cases experiments/evaluation/diagnostico.json`, que também compara com o teste.

1. **Diagnóstico com o v3.** Recolher as respostas no desenvolvimento, na calibração e no diagnóstico:

   ```sh
   .venv/bin/python -m experiments.evaluation.run --cases data/development.json --output output/dev-v3-AAAA-MM-DD.json
   .venv/bin/python -m experiments.evaluation.run --output output/cal-v3-AAAA-MM-DD.json
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/diagnostico.json --output output/diag-v3-AAAA-MM-DD.json
   ```

   Gerar uma folha de anotação por relatório com `make_sheet`, anotar e listar os padrões de falha (falsos alertas, omissões, categoria errada, pista que não é pergunta, revelação).
2. **Escrever o v4** em `backend/prompts/hint-v4.txt`, só a partir desses padrões. Os exemplos do prompt não podem coincidir com o teste (o `check_overlap` do teste lê os prompts).
3. **Comparar no teste**, na mesma sessão e com a mesma versão do Ollama:

   ```sh
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --output output/teste-v3-AAAA-MM-DD.json
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --prompt backend/prompts/hint-v4.txt --output output/teste-v4-AAAA-MM-DD.json
   ```

   `--prompt` só muda o prompt: modelo, parâmetros e filtro mantêm-se. A aplicação continua a usar `hint-v3.txt` até se alterar `PROMPT_PATH` em `backend/llm.py`. Se o filtro também for alterado, os resultados passam a comparar configurações completas e isso tem de ficar escrito.

### Estado

- **Recolhas v3 de 2026-11-23** (Ollama 0.40.13): `desenvolvimento-v3-2026-11-23.json`, `calibration-2026-11-23.json` e `diagnostico-v3-2026-11-23.json`. A calibração repete os 8 casos de 14 de novembro com as mesmas respostas do modelo antes e depois da fusão.
- **Anotação proposta do diagnóstico:** `anotacao-diagnostico-folha.csv` e `anotacao-diagnostico-chave.csv` (23 linhas), revista pelos autores. Nas notas, as etiquetas `[binária]`, `[afirmação]`, `[inventa]` e `[língua]` marcam a pista com duas hipóteses, a pista que não é pergunta, a explicação que inventa factos e os erros de língua.
- **Recolhas de 2026-11-24** (Ollama 0.14.3, outro Mac, mesmo digest do modelo): `diagnostico-v4-2026-11-24.json`, `diagnostico-v4-ajustado-2026-11-24.json` e, para comparar na mesma máquina, `diagnostico-v3-2026-11-24.json`. O v3 repetiu 14 das 20 respostas da recolha de 23 de novembro (diferem `diag-05`, `-06`, `-10`, `-13`, `-14` e `-20`), com a mesma deteção (9 VP, 3 FP, 1 FN). As corridas do teste fazem-se todas na mesma máquina e com a mesma versão do Ollama.
- **Diagnóstico do v4 (desenvolvimento, não é resultado).** Três versões do prompt, todas com a mesma deteção que o v3 (9 VP; 3 FP em `diag-05`, `-13` e `-17`; 1 FN em `diag-16`):
  1. *Rascunho* (`diagnostico-v4-2026-11-24.json`): nos 12 alertas do modelo, nenhuma pista com duas hipóteses (v3: 8), todas perguntas (v3: 10), 2 revelações parciais e nenhuma total (v3: 4 e 3), 2 explicações que inventam factos (v3: 4), 3 com erros de língua (v3: 2) e 1 intervenção do filtro (v3: 3).
  2. *Ajustado* (`diagnostico-v4-ajustado-2026-11-24.json`, versão atual de `hint-v4.txt`): pede para confirmar a diferença antes de assinalar, proíbe citar palavras inglesas ou repetir a palavra errada, limita as referências ao sujeito e acrescenta dois exemplos aceitáveis. Resultado: sem erros de língua nem palavras inglesas, nenhuma intervenção do filtro, 2 revelações parciais e 1 total (`diag-08`, sem aspas, por isso o filtro não atua) e 3 explicações que inventam factos.
  3. Uma terceira variante (proibir na explicação a palavra certa e explicar que um pronome omitido não muda o sujeito) não melhorou e foi descartada.

  Os falsos alertas em traduções aceitáveis não mudaram com nenhuma versão: o prompt sozinho não os resolve com este modelo. Proposta de anotação do v4 ajustado: `anotacao-diagnostico-v4-folha.csv` e `anotacao-diagnostico-v4-chave.csv` (20 linhas), revista pelos autores.
- **Prompt v4 (congelado):** `backend/prompts/hint-v4.txt`, versão ajustada, SHA-256 `19f81d40d19663c7e25e7bf2b1a4e670a2402ca5cb132210f2ed9a0cb7416c36`. Não se altera mais antes das recolhas do teste. Muda só o prompt. Os exemplos não coincidem com os do teste nem do diagnóstico (`check_overlap`).
- **Conjunto de teste revisto** (2026-11-25): os 40 casos de `test.json` foram revistos pelos autores sem alterações às categorias de referência; `annotation_status` passou a `reviewed`.
- **Recolhas finais do teste (2026-11-25):** `teste-v3-2026-11-25.json` e `teste-v4-2026-11-25.json`, uma a seguir à outra, no mesmo Mac (Apple M4, 16 GB, Ollama 0.14.3, digest `0edcdef34593`), no commit `7668938` sem alterações por gravar. 40 casos, todas as chamadas válidas. Métricas em `metricas-teste-2026-11-25.json`.
- **RQ1 (âmbito `rq1_main`, 18 casos, micro-média):** Regras 10/0/0 (VP/FP/FN) nas duas versões. LLM isolado: v3 6/2/4 (P 75,0 %, R 60,0 %, F1 66,7 %); v4 6/1/4 (P 85,7 %, R 60,0 %, F1 70,6 %). Híbrido: v3 10/2/0 (F1 90,9 %); v4 10/1/0 (F1 95,2 %). O LLM não assinalou nenhum dos 4 erros de glossário. Robustez (10 casos, igual nas duas versões): Regras 3/2/2, LLM isolado 4/0/1, Híbrido 4/2/1.
- **RQ2 (teste):** `anotacao-teste-folha.csv` junta as linhas da v3 e da v4 baralhadas (105 linhas, 76 alertas); a versão e o prompt estão só em `anotacao-teste-chave.csv`. Proposta inicial preparada sem abrir a chave e revista pelos autores (4 linhas alteradas). Limitação: a proposta foi feita depois de calcular as métricas da RQ1, que permitem deduzir a versão de algumas linhas (por exemplo, o falso alerta de glossário em `test-09`).
- **RQ2 (teste, depois da revisão):** resultado em `rq2-teste-2026-11-25.json`, sem linhas `incerto`.
  - **Versão do modelo:**
    - v3: 20 alertas, com revelação nenhuma em 5, parcial em 4 e total em 11 (55,0 %);
    - v4: 19 alertas, com revelação nenhuma em 18, parcial em 1 e total em 0;
    - pistas com duas hipóteses: 7 na v3 e 0 na v4;
    - pistas que afirmam o original: 5 na v3 e 0 na v4.
  - **Versão apresentada ao aluno:**
    - v3: 11 alertas, com revelação parcial em 2 e total em 3;
    - v4: 10 alertas, todos sem revelação.
    - Há menos alertas apresentados do que do modelo porque, nas categorias que as regras cobrem, prevalece o alerta da regra.
  - **Outros critérios (versão do modelo):** a correção fica igual (85,0 % na v3 e 84,2 % na v4) e a clareza sobe de 45,0 % para 68,4 % de `sim`.
