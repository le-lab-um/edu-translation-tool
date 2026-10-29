# Educational Translation Tool

Protótipo académico para apoiar a prática reflexiva de tradução de inglês para português europeu. Combina um editor, verificações por regras e, futuramente, pistas de um modelo de linguagem local. O projeto inclui um artigo académico, com entrega a **30 de novembro de 2026**.

O objetivo é disponibilizar a ferramenta como open source. A licença do repositório ainda está por escolher pelos autores.

## Estado atual — 29 de outubro de 2026

- **Editor React:** permite escrever/colar texto, carregar `.txt` até 200 KiB (204 800 bytes) ou escolher um exemplo. Cada linha não vazia constitui um segmento, até 200 por exercício; não há segmentação automática por frases.
- **Contexto e glossário:** o contexto é apresentado ao aluno. O glossário usa uma entrada por linha: `folder = pasta | diretório`. Entradas inválidas ou repetidas impedem o início até serem corrigidas.
- **Persistência SQLite:** guarda a tradução ao clicar em **Guardar**, ao mudar de segmento ou ao regressar à configuração do exercício. Recupera o texto guardado ao abrir um segmento. Guarda apenas a versão atual, sem histórico.
- **Proteção durante pedidos:** a edição aguarda a recuperação do segmento e fica bloqueada durante a gravação. Uma gravação não confirmada impede a navegação e mantém o texto no ecrã. Há mensagens de erro, nova tentativa de leitura e limite de 10 segundos em todos os pedidos da API. Verificações antigas não substituem resultados associados a uma edição posterior.
- **Aviso de alterações por guardar:** o navegador pode pedir confirmação ao fechar/recarregar. Não existe gravação contínua a cada tecla. O `localStorage` guarda apenas o original, contexto, glossário e posição; a tradução só fica persistida após gravação confirmada na API.
- **Três regras determinísticas:** tradução vazia, números do original em falta/alterados e termos prescritos ausentes. Os alertas são mensagens fixas escritas em código; ainda não são produzidos pelo LLM.
- **Piloto Ollama preservado:** duas versões do prompt e três execuções sobre dez exemplos de desenvolvimento. Não está integrado no editor e não constitui avaliação final.

A base do editor está implementada. Memória de tradução, comparação justificada, histórico de eventos/versões, exportação e integração do LLM continuam por implementar.

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
| `backend/database.py`, `models.py`, `__init__.py` | Ligação SQLite, tabela de segmentos e pacote Python. |
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

Ausência de alertas **não certifica a qualidade da tradução**. Os três códigos são categorias operacionais do protótipo, não uma implementação integral de MQM.

`GET /api/segments/{id}` recupera uma tradução (vazia se o ID não existe); `PUT /api/segments/{id}` recebe `{"target": "..."}` e guarda o texto exato.

### Limitação importante da persistência

O identificador é um hash FNV-1a de 32 bits do original, após remover espaços nas extremidades. **Textos iguais partilham a mesma tradução**, mesmo em exercícios, contextos ou posições diferentes. Também são possíveis colisões entre textos distintos. A base atual não separa utilizadores/projetos e não é uma memória de tradução com pesquisa por similaridade.

Esta revisão conserva os IDs para manter acesso às traduções existentes. Antes de usar exercícios independentes ou contextos diferentes, deve introduzir-se identidade de exercício/segmento e decidir como recuperar os registos antigos. Utilizar, por agora, uma instância do editor: não há resolução de escritas concorrentes entre separadores. Um timeout do cliente não prova que o servidor tenha cancelado uma gravação.

## Executar localmente

Usar Python 3.11 e uma versão de Node compatível com `frontend/package.json` (20.19+, 22.12+ ou 24+). São necessários **dois terminais**. Ollama não é necessário para usar o editor atual.

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

Estado verificado nesta revisão: **35 testes backend + 21 frontend = 56**, e build de produção concluído. Os testes de frontend simulam a rede e verificam funções; não constituem uma suite automática de interação com o editor. O repositório ainda não tem um workflow para executar estes testes no GitHub Actions; os checks do Pages referem-se à página estática.

Percurso de verificação no navegador:

1. Escolher «Ficheiros e pastas», começar e esperar pela recuperação da tradução.
2. Escrever `Guarde o ficheiro no arquivo.` e verificar: deve surgir terminologia. Trocar `arquivo` por `pasta`: o alerta deve desaparecer.
3. Navegar para o segundo segmento e voltar: a tradução deve ter sido guardada. Guardar explicitamente antes de fechar o último segmento.
4. Escolher «Preço e desconto»: `1 000,50 €` preserva o primeiro valor; `100,50 €` deve gerar alerta.
5. Com a API desligada, tentar guardar: manter o texto e impedir a navegação. Voltar a ligar a API e repetir. Falhar a recuperação inicial deve mostrar erro e botão de nova tentativa, sem permitir sobrescrever uma tradução desconhecida.
6. Confirmar rejeição de `.txt` acima de 200 KiB, mais de 200 segmentos e glossário inválido/repetido.

## Próximos passos, por incrementos

1. **Fechar a preparação do workshop:** apresentar o estado real, distinguir objetivos de funcionalidades e alinhar o âmbito de histórico/exportação/comparação. A licença também requer decisão conjunta.
2. **Corrigir a identidade dos exercícios:** separar segmentos iguais em contextos diferentes, com testes de reabertura e preservação dos registos existentes. É o próximo incremento de implementação recomendado.
3. **Fixar dados e contrato experimental:** rever as anotações, harmonizar o formato do glossário do conjunto com o da API, definir categorias comparáveis e reservar originais distintos para teste. O piloto v2 também compara unidades, ao contrário da regra atual: alinhar esse âmbito antes de comparar os métodos.
4. **Integrar um adaptador Ollama mínimo:** um segmento de cada vez, JSON validado, pista a pedido e tratamento de falhas, sem produzir resultados sobre aprendizagem. Depois definir a fusão de alertas com origem e deduplicação; não presumir que a combinação melhora os resultados.
5. **Executar a avaliação interna e consolidar o artigo:** deteção por regras/LLM/híbrido e apreciação independente das pistas pelos autores. Memória de tradução, comparação crítica e instrumentação devem ser priorizadas com o orientador; avaliação com estudantes fica para trabalho futuro.

O README acompanha a implementação. O artigo é consolidado em marcos de revisão; os relatórios do piloto permanecem históricos.
