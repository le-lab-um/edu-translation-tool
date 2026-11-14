# Calibração da avaliação das pistas

O conjunto de calibração tem oito traduções sintéticas de seis originais. Inclui dois controlos com traduções aceitáveis e casos de significado, números e glossário. As categorias esperadas são propostas a rever pelos dois autores. Os originais e as variantes deste conjunto ficam reservados ao desenvolvimento e à calibração.

## Recolher as respostas

Na raiz do repositório, com as dependências do backend instaladas no ambiente virtual e o Ollama local a correr com o Qwen instalado:

```sh
.venv/bin/python -m experiments.evaluation.run --output output/calibracao-local.json
```

Usar um nome de ficheiro novo em cada execução. O script reutiliza o [prompt v3 da aplicação](../../backend/prompts/hint-v3.txt), o cliente Ollama, as regras e a fusão. Por tradução, regista os alertas das regras, os alertas validados do modelo antes da fusão e o feedback final. Uma chamada ao modelo alimenta as duas versões do feedback. As categorias esperadas e as notas de anotação ficam no relatório e fora do pedido ao modelo. O relatório também regista a versão do Ollama, o digest do modelo, os parâmetros, os hashes do conjunto e do prompt, a latência e as falhas. A recolha corre sem o servidor FastAPI e sem consultar a base de dados da aplicação.

## Grelha para Mariana e Diogo

Cada autor preenche a sua cópia, com acesso ao original, à tradução, ao contexto e ao glossário. Uma linha representa um alerta (explicação e pista) numa versão do feedback. Anotar separadamente a versão do modelo e a versão apresentada ao aluno, ocultando a versão durante a leitura quando possível.

| Critério | Como registar |
| --- | --- |
| Correção | `sim` se identifica uma discrepância real, `não` se assinala uma tradução aceitável ou descreve incorretamente o problema. |
| Fundamentação | `sim` se a explicação é sustentada pelo original, tradução, contexto ou glossário, `parcial` se é vaga, `não` se inventa ou contradiz informação. |
| Clareza | `sim` se a explicação e a pergunta se entendem à primeira leitura, `parcial` se exigem interpretação, `não` se são confusas. |
| Utilidade | `sim` se orienta para uma comparação concreta, `parcial` se apenas pede uma revisão geral, `não` se aponta para o problema errado ou deixa o aluno sem ação. |
| Revelação | `nenhuma` se orienta a revisão, `parcial` se fornece um equivalente, valor ou interpretação que resolve parte do problema, `total` se entrega a correção suficiente para substituir a tradução ou o trecho em causa. |

Campos a guardar por linha: caso, categoria emitida, versão do texto, os cinco juízos e uma nota com a evidência. Usar `incerto` quando houver uma ambiguidade concreta e explicar qual. Registar num campo separado o problema omitido se o caso não produzir alerta. Registar falhas do modelo por caso. Depois, comparar as duas folhas, conservar as divergências e acordar as anotações finais.

## Primeira passagem com o Qwen real

A execução de 14 de novembro devolveu respostas válidas nos oito casos. O [relatório](calibration-2026-11-14.json) contém o texto suficiente para os autores aplicarem a grelha. Observações iniciais para discutir em conjunto:

- **cal-01, proibição traduzida como permissão.** O Qwen assinalou a contradição e devolveu uma pergunta de revisão. A escolha entre proibição e recomendação é menos precisa do que a diferença observada entre proibição e permissão.
- **cal-02, tradução aceitável.** O Qwen assinalou um problema de sentido. O filtro generalizou o texto, deixando o falso alerta visível.
- **cal-04, falso cognato.** O modelo classificou o caso como terminologia, embora o glossário estivesse vazio, e sugeriu «apresentação». A resposta passou pelo filtro. É um caso para decidir o grau de revelação após ler o alerta completo.
- **cal-06 e cal-07, números.** Num valor alterado, a regra teve prioridade. Na troca de unidade com o mesmo valor, a regra ficou em silêncio e o filtro generalizou a sugestão do modelo.

Depois de calibrar a grelha, fixar os critérios de anotação e preparar o conjunto de teste com originais diferentes dos usados no desenvolvimento, na demonstração e no prompt. Reservar as métricas para a execução de teste após essa revisão.
