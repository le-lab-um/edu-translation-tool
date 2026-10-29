# Experiência preliminar com Ollama — 23 de outubro de 2026

Esta experiência verifica a viabilidade inicial de obter alertas e pistas em JSON com um modelo local. Usa apenas os dez exemplos de `data/development.json`, cujas anotações estão pendentes de revisão pelos autores. Não é a avaliação final nem demonstra eficácia pedagógica.

## Material preservado

* `run.py`: script Python com biblioteca padrão, adaptado dos scripts temporários para escolher o prompt através de `--prompt`. A construção dos pedidos, validação e recolha de resultados mantêm-se.
* `prompt-v1.txt` e `prompt-v2.txt`: textos exatos dos dois prompts usados. A segunda versão explicita as definições das categorias e aplica a restrição de revelar soluções tanto à explicação como à pista.
* `v1-run1.json`, `v1-run2.json` e `v2-run1.json`: cópias integrais dos relatórios originais, incluindo respostas, tempos, configuração, metadados do modelo e hash do conjunto. Os caminhos absolutos nos metadados referem-se à execução original.

Os relatórios provêm, respetivamente, de `translation-ollama-results-x7uk5n4t.json`, `translation-ollama-results-b54nfjkn.json` e `translation-ollama-results-e42m7hd1.json`. Não foram gerados novamente ao integrar a experiência no repositório.

## Repetir a experiência

Requisitos: Python 3.9 ou posterior, Ollama em execução no endereço local `http://localhost:11434` e o modelo abaixo instalado. Não são necessárias bibliotecas Python adicionais.

Na raiz do repositório:

```sh
ollama pull qwen3:4b-instruct-2507-q4_K_M
python3 experiments/ollama-pilot/run.py data/development.json --prompt v1
python3 experiments/ollama-pilot/run.py data/development.json --prompt v2
```

Cada execução cria um novo relatório num ficheiro temporário e imprime o caminho. Guardar uma execução adicional exige copiar esse ficheiro para um nome novo; os três relatórios históricos não são substituídos. As chamadas não partilham histórico de conversa. Só os dados de entrada e os metadados linguísticos são enviados ao modelo; as anotações esperadas são usadas depois para comparação.

Configuração original: MacBook M5 com 16 GB (informação fornecida pelo autor), Ollama `0.40.8`, modelo `qwen3:4b-instruct-2507-q4_K_M`, quantização `Q4_K_M`, temperatura `0`, seed `42`, contexto `4096`, máximo de saída `768` tokens e `keep_alive` de `10m`. O esquema JSON é enviado no campo `format`.

Digest do modelo original: `0edcdef34593eac1aa2be9c7d06c432dcf81945adca5eca2f27662c18f168ba0`. A etiqueta do modelo pode mudar; comparar o digest e as versões nos relatórios antes de atribuir diferenças ao prompt. A mesma configuração não garante respostas idênticas em todos os ambientes.

## Observações

Contagem por par **segmento/categoria**, com categorias repetidas reduzidas a uma ocorrência: TP é um alerta esperado e obtido; FP é um alerta não esperado; FN é um alerta esperado mas omitido. Precisão = TP/(TP+FP), recall = TP/(TP+FN) e F1 = 2TP/(2TP+FP+FN), agregados sobre todas as categorias (micro).

| Execução | Categorias coincidentes por segmento | TP | FP | FN | Precisão | Recall | F1 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| v1 — primeira | 8/10 | 5 | 2 | 0 | 71,4% | 100% | 83,3% |
| v1 — repetição | 8/10 | 5 | 2 | 0 | 71,4% | 100% | 83,3% |
| v2 | 8/10 | 4 | 1 | 1 | 80% | 80% | 80% |

As três execuções devolveram dez respostas concluídas e válidas segundo a validação de estrutura do script. O estado `ok` indica essa validade, não a correção linguística. Os textos das respostas das duas execuções v1 coincidiram.

* **dev-004:** ambas as versões assinalaram incorretamente a adaptação de `€1,000.50` para `1 000,50 €` como alteração de valor.
* **dev-010:** v1 classificou uma tradução com conteúdo como vazia; v2 deixou de emitir esse alerta.
* **dev-008:** v1 detetou o incumprimento do glossário, mas revelou os equivalentes aceites; v2 omitiu o problema.
* **dev-005:** a categoria correta não assegura uma explicação correta. Em v2, a explicação altera a representação do número original e atribui separadores inexistentes à tradução.
* Há revelação de soluções e formulações pouco adequadas a PT-PT. A qualidade das pistas requer apreciação humana separada da deteção.

Os tempos médios observados por caso foram aproximadamente 2,43 s, 2,37 s e 1,48 s, respetivamente. São medições exploratórias, afetadas pelo carregamento, cache e comprimento das respostas; não constituem uma comparação controlada de desempenho.

A segunda versão não demonstrou uma melhoria global: eliminou um falso alerta, mas introduziu uma omissão. Estes exemplos já foram usados para ajustar o prompt e não podem integrar o teste final. Ainda não foram avaliadas regras nem a abordagem híbrida.

## Próximo incremento previsto na data da experiência

Nota de manutenção (29/10/2026): este incremento já foi realizado. O estado atual e a sequência de trabalho estão no README principal; os resultados históricos abaixo não foram alterados.

Implementar isoladamente a regra de tradução vazia, com testes para texto vazio, espaços, tabulações, quebras de linha e texto efetivo, incluindo maiúsculas. Depois iniciar um editor mínimo para introduzir e rever uma tradução por segmento. A comparação com regras e a avaliação do feedback serão desenvolvidas gradualmente.
