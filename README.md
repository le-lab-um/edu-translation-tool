# Educational Translation Tool

Projeto desenvolvido no âmbito do Mestrado em Engenharia Informática da Universidade do Minho.

---

## Visão Geral
Este projeto tem como propósito desenvolver e avaliar uma aplicação web educativa para apoio à prática de tradução de textos curtos, inicialmente de inglês para português europeu (EN–PT-PT). A ferramenta pretende apoiar a revisão e a justificação das escolhas do estudante, combinando funcionalidades de tradução assistida por computador (CAT), verificações por regras e pistas geradas por um modelo de linguagem local.

## Objetivos Centrais
* **Ensino e Apoio Pedagógico:** Fornecer pistas orientadoras e explicações em vez de apresentar apenas traduções prontas.
* **Reflexão e Julgamento Crítico:** Apoiar o utilizador na compreensão dos problemas identificados e na justificação fundamentada das suas escolhas.
* **Acompanhamento do Processo:** Registar revisões e decisões para permitir a análise e reflexão sobre a evolução do trabalho.
* **Ferramenta Aberta e Acessível:** Desenvolver a solução como software de código aberto (*open-source*), acompanhada de documentação clara e reproduzível.

## Estado Atual

O repositório contém:

* [Artigo em desenvolvimento](paper/main.typ), com revisão do estado da arte, comparação documental de seis ferramentas, objetivos, arquitetura proposta e protocolo de avaliação interna. As secções de implementação e resultados ainda estão por desenvolver.
* [Dez exemplos de desenvolvimento](data/development.json), sintéticos e com anotações propostas ainda sujeitas a revisão pelos autores. Abrangem traduções vazias, diferenças numéricas e cumprimento do glossário, incluindo casos sem erros.
* [Página de apresentação](docs/index.html), estática; ainda não é o editor de tradução.
* [Primeira regra determinística](backend/rules.py), que deteta traduções vazias ou compostas apenas por espaços em branco, com [testes automatizados](tests/test_rules.py).
* [Editor mínimo](frontend/src/App.tsx) em React e TypeScript, que apresenta um original em inglês, o contexto e um campo para escrever a tradução em português europeu.
* [API local](backend/main.py) com um endpoint que recebe a tradução e executa a regra de tradução vazia.
* [Testes do cliente HTTP](frontend/src/api.test.ts), incluindo cancelamento por tempo limite e recuperação numa nova tentativa.

Foi realizada uma experiência preliminar com Ollama e o modelo `qwen3:4b-instruct-2507-q4_K_M`, num MacBook M5 com 16 GB de memória. Foram comparadas duas versões do prompt nos exemplos de desenvolvimento. As respostas revelaram falsos alertas, omissões e explicações incorretas; esta experiência serve para orientar o desenvolvimento e não constitui a avaliação final.

O editor permite trabalhar num único segmento e executar a regra de tradução vazia através do botão **Verificar**, ligado à API local. A tradução mantém-se apenas em memória. A persistência, as regras numéricas e terminológicas e a integração com o modelo serão desenvolvidas em incrementos seguintes.

## Executar o Editor

Requisitos: Node.js `20.19+` na série 20, `22.12+` na série 22, ou `24+`, e npm. Estas versões satisfazem os requisitos do Vite e do Vitest. Para usar **Verificar**, iniciar também a API Python conforme a secção seguinte, num terminal separado. Ollama não é necessário.

Na raiz do repositório:

```sh
cd frontend
npm ci
npm run dev
```

Abrir o endereço local indicado no terminal. Para terminar o servidor, usar `Ctrl+C`. O ficheiro `package-lock.json` fixa as versões instaladas; deve acompanhar o código no Git.

O original e o contexto reproduzem os dados de entrada de `dev-001`. A interface não importa o conjunto anotado nem apresenta a tradução de referência. O campo começa vazio e aceita edição livre. **Ao recarregar ou fechar a página, a tradução perde-se.**

A implementação está concentrada nos seguintes ficheiros:

* `frontend/src/App.tsx`: exercício, tradução e estado da verificação (inicial, em curso, resultado, erro ou tempo limite). Um contador identifica o pedido atual; edições e novos pedidos invalidam respostas anteriores, mesmo que o texto volte ao valor original.
* `frontend/src/api.ts`: pedido HTTP, cancelamento ao fim de 10 segundos e validação do formato da resposta, sem replicar a regra Python.
* `frontend/src/api.test.ts`: testes automatizados do pedido HTTP com Vitest, sem contactar a API.
* `frontend/src/main.tsx`: montagem da aplicação React.
* `frontend/src/styles.css`: apresentação e adaptação a ecrãs estreitos, usando fontes do sistema.
* `frontend/vite.config.ts`: encaminhamento de `/api` para `http://127.0.0.1:8000`. Reiniciar o servidor Vite se já estava aberto antes desta configuração.

O botão envia o conteúdo exato do campo, incluindo espaços, para `POST /api/check`. Durante o pedido, mostra **A verificar…** e fica desativado. O campo continua editável: uma alteração remove o resultado e permite uma nova verificação. Respostas de pedidos anteriores são ignoradas.

Um resultado vazio significa apenas que não foi detetada uma tradução vazia. Falhas de rede, respostas HTTP de erro ou respostas num formato inesperado apresentam uma mensagem e permitem tentar novamente, mantendo o texto introduzido.

Cada verificação tem um **tempo limite de 10 segundos**, que abrange a espera pela resposta e a leitura do JSON. Ao atingir esse prazo, o navegador cancela o pedido através de `AbortController`; o editor apresenta uma mensagem específica e permite tentar novamente, sem apagar a tradução. Não há repetição automática. Tal como os outros resultados, o tempo limite de um pedido anterior é ignorado se o texto tiver sido editado ou uma nova verificação tiver começado.

React e React DOM apresentam a interface; TypeScript verifica os tipos; Vite e o respetivo plugin React permitem desenvolver e compilar. Vitest é uma dependência de desenvolvimento usada apenas nos testes. Não são utilizadas bibliotecas adicionais de interface ou de gestão de estado.

Para verificar os tipos e gerar a versão de produção, dentro de `frontend/`:

```sh
npm run build
npm run preview
```

`npm run preview` serve localmente a versão compilada e utiliza o mesmo encaminhamento para a API, que também precisa de estar em execução. Este encaminhamento é uma configuração dos servidores locais do Vite; não acompanha os ficheiros estáticos numa publicação. A pasta gerada `frontend/dist/` e as dependências `frontend/node_modules/` são ignoradas pelo Git.

Verificação manual:

1. Com a API e o editor em execução, verificar o campo vazio ou apenas com espaços: deve aparecer um alerta e uma pista.
2. Escrever texto: o resultado anterior deve desaparecer. Verificar novamente: deve aparecer a mensagem de ausência de tradução vazia.
3. Parar a API e verificar: deve surgir uma mensagem de falha, mantendo o texto. Reiniciar a API e repetir o pedido para confirmar a recuperação.
4. Para testar respostas atrasadas, configurar uma ligação com latência superior a 10 segundos nas ferramentas de desenvolvimento do navegador e verificar: deve aparecer a mensagem de tempo limite, mantendo o texto e permitindo uma nova tentativa. Repor a ligação normal e verificar novamente. Repetir com uma edição durante a espera: o resultado ou erro antigo não deve aparecer.
5. Confirmar que o original não é editável, usar o campo e o botão com teclado, escrever e colar acentos e quebras de linha e verificar a apresentação num ecrã estreito.

## Executar a API

Usar Python 3.11 ou posterior. No equipamento de desenvolvimento, `python3` aponta para Python 3.9; por isso, o ambiente virtual é criado explicitamente com `python3.11`. Na raiz do repositório:

```sh
python3.11 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements.txt
.venv/bin/python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```

O ambiente `.venv/` é local e ignorado pelo Git. FastAPI define o endpoint, Pydantic valida os dados e Uvicorn serve a aplicação. Os testes usam o cliente fornecido por Starlette, a base do FastAPI, com HTTPX2. As versões destes pacotes estão fixadas em `backend/requirements.txt`; as restantes dependências transitivas são resolvidas pelo pip. Não é necessário iniciar Ollama.

Com o servidor em execução, abrir `http://127.0.0.1:8000/docs` para consultar a documentação interativa. Para terminar o servidor, usar `Ctrl+C`.

O endpoint **`POST /api/check`** recebe apenas um campo obrigatório `target`, do tipo texto. Cadeias vazias e espaços em branco são aceites: representam traduções a verificar, não pedidos inválidos. A API chama a função existente em `backend/rules.py`, sem duplicar a lógica, guardar o texto ou contactar o modelo.

Exemplo, noutro terminal:

```sh
curl --fail-with-body http://127.0.0.1:8000/api/check \
  -H 'Content-Type: application/json' \
  -d '{"target": ""}'
```

Resposta HTTP 200:

```json
{
  "issues": [
    {
      "category": "empty_translation",
      "explanation": "O segmento ainda não contém uma tradução com texto.",
      "hint": "Como traduzirias este segmento para português europeu?"
    }
  ]
}
```

Uma tradução com conteúdo, como `{"target": "Abra o FICHEIRO."}`, devolve `{"issues": []}`. Isto indica apenas ausência de tradução vazia; não certifica a qualidade da tradução. Campo ausente, valores que não sejam texto (incluindo `null`), campos adicionais e JSON malformado devolvem HTTP 422 com o detalhe da validação.

## Executar os Testes

Depois de instalar as dependências da API, executar na raiz do repositório:

```sh
.venv/bin/python -m unittest discover -s tests -v
```

Os testes da regra usam `unittest`, da biblioteca padrão. Os testes da API usam também o `TestClient` do FastAPI e HTTPX2 para executar pedidos em memória, sem servidor HTTP nem Ollama. Verificam respostas válidas, traduções vazias e rejeição de pedidos inválidos.

A regra devolve um alerta `empty_translation` quando `str.strip()` remove todo o conteúdo; caso contrário, devolve uma lista vazia. Usa os campos `category`, `explanation` e `hint`, também usados na experiência com o modelo. Texto incorreto, números ou pontuação isolada não são classificados como tradução vazia.

Os testes incluem espaços, tabulações, quebras de linha, espaços Unicode e texto efetivo, incluindo maiúsculas, além dos dez exemplos de desenvolvimento apenas para a categoria `empty_translation`. Esta verificação não avalia as outras categorias nem substitui a avaliação final.

Depois de instalar as dependências do editor com `npm ci`, executar dentro de `frontend/`:

```sh
npm test
```

Os testes do cliente HTTP usam Vitest com pedidos simulados e relógio controlado: não precisam da API, de Ollama ou de esperar 10 segundos reais. Cobrem pedidos sem resposta, leitura demorada do JSON, respostas válidas, falhas de rede e HTTP, limpeza do temporizador e uma nova tentativa após tempo limite. São testes da função `checkTranslation`; o comportamento visual do editor continua a ter a verificação manual descrita acima.

## Próximos Passos

1. **Guardar e recuperar a tradução de um segmento:** começar pela persistência local na API com SQLite e SQLAlchemy, com testes de gravação e recuperação; ligar depois o editor, num incremento separado. O objetivo é deixar de perder o texto ao recarregar a página.
2. **Alargar as verificações por regras:** implementar números e terminologia em passos separados, revendo os exemplos e as anotações antes de os usar como referência.
3. **Integrar o modelo local:** retomar os resultados da experiência preliminar quando o fluxo de edição, persistência e regras estiver estável.

Antes de automatizar novas experiências com Ollama, ajustar o script para terminar com um código de erro quando existirem falhas nos pedidos. Os testes automáticos do fluxo completo no navegador e a execução dos testes em CI podem ser acrescentados em incrementos próprios.

O README acompanha o estado da implementação, as instruções de execução e os próximos passos. O artigo será atualizado em momentos de consolidação da arquitetura, da implementação ou da avaliação, sem exigir uma alteração por cada incremento de código.

## Solução Prevista

1. **CAT básico:** editor segmentado, glossário e memória de tradução leve.
2. **Verificações por regras:** deteção de traduções vazias, alterações de valores numéricos e incumprimento dos equivalentes definidos no glossário.
3. **Feedback local:** pistas e explicações a pedido, usando um LLM executado localmente, sem APIs pagas.

Estão também previstos exercícios de comparação justificada entre traduções e registo de versões e decisões, com exportação de dados estruturados.

| Componente | Tecnologia prevista |
| --- | --- |
| Interface | React, TypeScript e Vite |
| API e validação | Python, FastAPI e Pydantic |
| Persistência | SQLite e SQLAlchemy |
| Regras e similaridade textual | Python e RapidFuzz |
| Execução do modelo local | Ollama |

Estas tecnologias descrevem a arquitetura proposta. O editor já comunica com a API para executar a primeira regra. A disponibilização como software open source é um objetivo do projeto; a licença do repositório ainda está por definir.

## Avaliação Prevista

* Comparar regras, LLM isolado e abordagem híbrida na deteção das categorias comuns, utilizando precisão, recall e F1.
* Avaliar internamente a correção, fundamentação, clareza e utilidade das pistas, incluindo a frequência com que revelam a solução.

A avaliação será realizada pelos autores, sem participantes externos. Não permitirá concluir sobre ganhos de aprendizagem ou comportamento de estudantes. Os exemplos usados para ajustar prompts e regras ficarão separados do conjunto de teste final, mantendo variantes do mesmo original no mesmo conjunto.

O trabalho culmina na entrega do protótipo e do artigo académico, com prazo de entrega a **30 de novembro de 2026**.

## Equipa
* Diogo Pinto (PG61515)
* Mariana Pinto (PG61534)
