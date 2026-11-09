# Educational Translation Tool

Protótipo académico para apoiar a prática reflexiva de tradução de inglês para português europeu. Combina um editor com memória de tradução, verificações por regras e uma primeira integração de pistas híbridas com um modelo de linguagem local. O projeto inclui um artigo académico, com entrega a **30 de novembro de 2026**.

O objetivo é disponibilizar a ferramenta como open source. A licença do repositório ainda está por escolher pelos autores.

## Estado para a reunião de 10 de novembro de 2026

- **Editor React:** permite escrever/colar texto, carregar `.txt` até 200 KiB (204 800 bytes) ou escolher um exemplo. Cada linha não vazia constitui um segmento, até 200 por exercício; não há segmentação automática por frases.
- **Contexto e glossário:** o contexto é apresentado ao aluno. O glossário usa uma entrada por linha: `folder = pasta | diretório`. Entradas inválidas ou repetidas impedem o início até serem corrigidas.
- **Persistência SQLite:** guarda a tradução ao clicar em **Guardar**, ao mudar de segmento ou ao regressar à configuração do exercício. Recupera o texto guardado ao abrir um segmento. Guarda apenas a versão atual, sem histórico.
- **Proteção durante pedidos:** a edição aguarda a recuperação do segmento e fica bloqueada durante a gravação. Uma gravação não confirmada impede a navegação e mantém o texto no ecrã. Há mensagens de erro e nova tentativa de leitura. O cliente dá 40 segundos a «Pedir pista» e 10 segundos aos restantes pedidos JSON. Verificações antigas não substituem resultados associados a uma edição posterior.
- **Aviso de alterações por guardar:** o navegador pode pedir confirmação ao fechar ou recarregar. Para recuperar o exercício, o `localStorage` guarda o original, o contexto, o glossário, o estado de arranque e a posição. A tradução é persistida pela API nas operações de gravação.
- **Cinco regras determinísticas:** tradução vazia, números do original em falta ou alterados, termos prescritos ausentes, marcadores nomeados e etiquetas de formatação. As duas últimas foram acrescentadas depois do ensaio de 9 de novembro. **Verificar** corre as regras e devolve mensagens definidas em código.
- **Pistas híbridas (nível 3, versão inicial):** o botão **Pedir pista** chama `POST /api/hint`, que combina as regras com o modelo local servido pelo Ollama. Cada alerta mostra a origem («Regra» ou «Sugestão do modelo local»). As regras têm prioridade e o modelo só acrescenta categorias que as regras não detetaram. Um filtro heurístico pode generalizar a explicação e a pista quando encontra padrões suspeitos, como equivalentes do glossário, certas aspas ou, nos alertas numéricos, dígitos do original. Para as falhas do Ollama que o adaptador reconhece, o endpoint devolve só as regras e indica o estado do modelo.
- **Memória de tradução (nível 1):** após confirmar uma tradução não vazia, o editor tenta guardar o par original/tradução. A memória é partilhada pela instância local. Ao abrir um segmento, aparecem sugestões de segmentos parecidos (RapidFuzz, limiar 70 %) com o botão **Usar**.
- **Registos e exportação:** a interface envia eventos de início de exercício, gravação, verificação, pistas e uso da memória, com um ID persistente do browser e metadados, sem texto da tradução. A API aceita dados adicionais no `payload` e permite exportar sem autenticação. O rodapé dá acesso ao JSON e ao CSV. O resumo devolve o total de eventos, o total de identificadores distintos e contagens por tipo.
- **Piloto Ollama preservado:** duas versões do prompt e três execuções sobre dez exemplos de desenvolvimento (`experiments/ollama-pilot`). O prompt v2 foi copiado para `backend/prompts/hint-v2.txt`. Não constitui avaliação final.

Ainda por implementar: histórico de versões, justificações do aluno, comparação crítica, avaliação comparativa regras/LLM/híbrido e identidade de exercício (ver limitação abaixo).

## Arquitetura e ficheiros

| Local | Função |
| --- | --- |
| `frontend/src/App.tsx` | Formulário do exercício, edição, navegação e estados de leitura/gravação/verificação. |
| `frontend/src/exercise.ts` | Segmentação por linhas, identificadores, leitura do glossário e exemplos. |
| `frontend/src/api.ts` | Cliente HTTP, validação das respostas e tempos limite. |
| `frontend/src/*.test.ts` | Testes da lógica do exercício e do cliente HTTP com rede simulada. |
| `frontend/src/styles.css`, `main.tsx`, `index.html` | Apresentação visual e arranque do React. |
| `frontend/package.json`, `package-lock.json` | Dependências e comandos; o lockfile fixa a instalação feita com `npm ci`. |
| `frontend/tsconfig.json`, `vite.config.ts` | TypeScript e servidor de desenvolvimento; `/api` é encaminhado para a porta 8000. |
| `backend/main.py` | API FastAPI, validação Pydantic e endpoints. |
| `backend/rules.py` | Regras em Python, independentes da interface e do LLM. |
| `backend/llm.py`, `backend/prompts/hint-v2.txt` | Adaptador Ollama: pedido com esquema JSON, validação da resposta, erros tipificados. |
| `backend/hybrid.py` | Fusão regras + LLM, deduplicação por categoria e filtro anti-solução. |
| `backend/translation_memory.py` | Pesquisa difusa de segmentos parecidos (RapidFuzz). |
| `backend/database.py`, `models.py`, `__init__.py` | Ligação SQLite, tabelas (segmentos, memória, eventos) e pacote Python. |
| `backend/requirements.txt` | Dependências Python com versões mínimas; ainda não é um lockfile. |
| `tests/` | Testes das regras, API e persistência; esta última usa SQLite em memória. |
| `data/development.json` | Dez exemplos sintéticos, com anotações pendentes de revisão pelos autores. |
| `experiments/ollama-pilot/` | Script, prompts, notas e relatórios históricos do piloto. |
| `paper/main.typ` | Artigo Typst: enquadramento, proposta, implementação e protocolo previsto. |
| `docs/` | Página estática de apresentação no GitHub Pages; não executa o editor nem a API. |
| `.gitignore` | Exclui ambientes, dependências, builds e base de dados local. |

## Contrato e limites das regras

`POST /api/check` recebe:

```json
{
  "source": "Save the file in the folder.",
  "target": "Guarde o ficheiro no diretório.",
  "glossary": {
    "file": {"target": "ficheiro"},
    "folder": {"target": "pasta", "variants": ["diretório"]}
  }
}
```

A resposta contém `issues`, com `category`, `explanation` e `hint`. O glossário exige objetos neste formato, com textos não vazios; estruturas inválidas produzem HTTP 422. O campo `context` ainda não é enviado a estas regras.

- **`empty_translation`:** ausência de texto após remover espaços. Quando ocorre, não se executam as outras regras.
- **`numeric_mismatch`:** compara valores em convenções EN no original e PT-PT na tradução, usando `Decimal`, sinais e contagem de ocorrências. `1,000.50` e `1 000,50` são equivalentes; `0.125` e `125` não são. Só procura valores do original ausentes/alterados; não assinala valores exclusivamente acrescentados. Não interpreta unidades, números por extenso, datas ou intervalos; sequências como `5 100` são ambíguas.
- **`terminology`:** procura termos completos, ignorando maiúsculas/minúsculas; basta um equivalente aceite. Flexões têm de ser indicadas nas variantes. É uma verificação de cumprimento do glossário do exercício, não um juízo geral de correção linguística.
- **`placeholder_mismatch`:** compara nomes e contagens dos marcadores simples entre chavetas, como `{name}` e `{file_name}`. A ordem pode mudar. Chavetas duplas, índices como `{0}` e formatos como `%s` ficam fora desta regra.
- **`inline_tag_mismatch`:** compara o número de ocorrências de cada etiqueta simples de abertura e fecho (`b`, `i`, `em`, `strong`, `u`, sem atributos), ignorando maiúsculas e ordem. A regra cobre a preservação desses tokens, deixando a posição, o aninhamento e os restantes formatos de marcação fora do âmbito.

Ausência de alertas **não certifica a qualidade da tradução**. Os dois alertas técnicos aparecem em **Verificar** e em **Pedir pista** com origem «Regra» neste último. O prompt do modelo e a comparação RQ1 mantêm as três categorias iniciais em comum.

### Novos endpoints (8 nov.)

| Endpoint | Função |
| --- | --- |
| `POST /api/hint` | Como `/api/check`, mais `context` opcional. Devolve `issues` (com `source`: `rules` ou `llm`), `llm_status` (`ok`, `skipped`, `disabled`, `unavailable`, `timeout`, `invalid`), `sanitized` e `elapsed_ms`. |
| `POST /api/memory` · `POST /api/memory/search` | Guardar um par; procurar segmentos parecidos (`threshold` 0–100, `limit` 1–10). |
| `POST /api/events` | Registar um evento (`session_id`, `type`, `segment_id`, `payload`). |
| `GET /api/events/export?format=json\|csv` · `GET /api/events/summary` | Exportação e resumo agregado. |

Configuração do modelo local por variáveis de ambiente: `OLLAMA_URL` (por omissão `http://localhost:11434`), `OLLAMA_MODEL` (`qwen3:4b-instruct-2507-q4_K_M`), `OLLAMA_TIMEOUT` (30 s por operação de rede no cliente HTTPX) e `LLM_ENABLED=0` para desligar.

`GET /api/segments/{id}` recupera uma tradução (vazia se o ID não existe); `PUT /api/segments/{id}` recebe `{"target": "..."}` e guarda o texto exato.

### Limitação importante da persistência

O identificador é um hash FNV-1a de 32 bits do original, após remover espaços nas extremidades. **Textos iguais partilham a mesma tradução**, mesmo em exercícios, contextos ou posições diferentes. Também são possíveis colisões entre textos distintos. A recuperação da tradução por ID é separada da pesquisa de sugestões por similaridade. A base atual é partilhada pela instância e não separa utilizadores ou projetos.

Esta revisão conserva os IDs para manter acesso às traduções existentes. Antes de usar exercícios independentes ou contextos diferentes, deve introduzir-se identidade de exercício/segmento e decidir como recuperar os registos antigos. Utilizar, por agora, uma instância do editor: não há resolução de escritas concorrentes entre separadores. Um timeout do cliente não prova que o servidor tenha cancelado uma gravação.

## Executar localmente

Usar Python 3.11 ou posterior e uma versão de Node compatível com `frontend/package.json` (20.19+, 22.12+ ou 24+). São necessários **dois terminais**. O Ollama é opcional. Para usar o modelo, abrir a aplicação Ollama ou iniciar `ollama serve` num terminal e, com o serviço a correr, executar `ollama pull qwen3:4b-instruct-2507-q4_K_M` noutro terminal.

Terminal 1, na raiz do repositório, preparação inicial:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements.txt
```

Iniciar a API:

```bash
.venv/bin/python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```

A documentação está em `http://127.0.0.1:8000/docs`. Um GET a `/` devolve 404 porque essa rota não foi criada. A base local fica em `data/app.db`, excluída do Git.

Terminal 2, a partir da raiz:

```bash
cd frontend
npm ci
npm run dev
```

Abrir o endereço indicado pelo Vite, normalmente `http://localhost:5173`. Manter o mesmo endereço/porta ao regressar, porque o armazenamento do browser é separado por origem. Para parar cada servidor: `Ctrl+C`.

## Verificação

Na raiz:

```bash
.venv/bin/python -m unittest discover -s tests -v
```

Dentro de `frontend/`:

```bash
npm test
npm run build
```

Estado verificado para a reunião: **67 testes backend + 26 frontend = 93**, e build de produção concluído. Os testes do adaptador simulam respostas do Ollama com `httpx.MockTransport`. No ensaio manual de 9 de novembro, anterior às duas regras técnicas, o Qwen real respondeu pelo editor. No exemplo `5 kg` → `5 lb`, o botão «Verificar» não gerou alertas e «Pedir pista» apresentou uma sugestão generalizada. Este ensaio verifica o percurso integrado num caso de demonstração. A avaliação comparativa e a apreciação sistemática das pistas estão por fazer. Os checks do Pages referem-se à página estática.

Percurso de verificação no navegador:

1. Escolher «Ficheiros e pastas», começar e esperar pela recuperação da tradução.
2. Escrever `Guarde o ficheiro no arquivo.` e verificar: deve surgir terminologia. Trocar `arquivo` por `pasta`: o alerta deve desaparecer.
3. Navegar para o segundo segmento e voltar: a tradução deve ter sido guardada. Guardar explicitamente antes de fechar o último segmento.
4. Escolher «Preço e desconto». No primeiro segmento, `100,50 €` deve gerar um alerta e `1 000,50 €` preserva o valor. No segundo, escrever `Aplica-se um desconto de 50%.` e clicar em «Pedir pista» para mostrar um alerta de regra. `Aplica-se uma redução de 15%.` preserva a percentagem e, neste exercício sem glossário, não gera um alerta determinístico.
5. Com a API desligada, tentar guardar: manter o texto e impedir a navegação. Voltar a ligar a API e repetir. Falhar a recuperação inicial deve mostrar erro e botão de nova tentativa, sem permitir sobrescrever uma tradução desconhecida.
6. Confirmar rejeição de `.txt` acima de 200 KiB, mais de 200 segmentos e glossário inválido/repetido.
7. Num exercício sem glossário, usar o original `Hello {name}, select <b>Save</b>.` e a tradução `Olá, selecione Guardar.`. «Verificar» deve apresentar Marcadores e Etiquetas de formatação. Com `Olá {name}, selecione <b>Guardar</b>.`, ambos os alertas devem desaparecer.

## Próximos passos, por incrementos

1. **Alargar a verificação com o modelo real:** após o ensaio manual do editor, correr os exemplos de `data/development.json`, medir latência e anotar falsos alertas e pistas que revelem a solução.
2. **Corrigir a identidade dos exercícios:** separar segmentos iguais em contextos diferentes, com testes de reabertura e preservação dos registos existentes.
3. **Fixar dados e contrato experimental:** rever anotações, harmonizar o glossário do conjunto com o da API, reservar originais distintos para teste e alinhar o âmbito de unidades entre piloto e regra numérica.
4. **Executar a avaliação interna** (regras / LLM / híbrido) e apreciar independentemente os textos das explicações e pistas. Calcular a taxa de revelação (RQ2) a partir dessa anotação humana. Os contadores de generalização descrevem intervenções do filtro.
5. **Histórico de versões, justificações e comparação crítica**, e consolidar o artigo (prazo: 30 de novembro).

O README acompanha a implementação. O artigo é consolidado em marcos de revisão; os relatórios do piloto permanecem históricos.
