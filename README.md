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

Foi realizada uma experiência preliminar com Ollama e o modelo `qwen3:4b-instruct-2507-q4_K_M`, num MacBook M5 com 16 GB de memória. Foram comparadas duas versões do prompt nos exemplos de desenvolvimento. As respostas revelaram falsos alertas, omissões e explicações incorretas; esta experiência serve para orientar o desenvolvimento e não constitui a avaliação final.

O editor, a API, a persistência e o motor de regras ainda não estão implementados. O protótipo será desenvolvido incrementalmente, com alterações pequenas e verificáveis.

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

Estas tecnologias descrevem a arquitetura proposta; ainda não existe uma aplicação integrada para instalar ou executar. A disponibilização como software open source é um objetivo do projeto; a licença do repositório ainda está por definir.

## Avaliação Prevista

* Comparar regras, LLM isolado e abordagem híbrida na deteção das categorias comuns, utilizando precisão, recall e F1.
* Avaliar internamente a correção, fundamentação, clareza e utilidade das pistas, incluindo a frequência com que revelam a solução.

A avaliação será realizada pelos autores, sem participantes externos. Não permitirá concluir sobre ganhos de aprendizagem ou comportamento de estudantes. Os exemplos usados para ajustar prompts e regras ficarão separados do conjunto de teste final, mantendo variantes do mesmo original no mesmo conjunto.

O trabalho culmina na entrega do protótipo e do artigo académico, com prazo de entrega a **30 de novembro de 2026**.

## Equipa
* Diogo Pinto (PG61515)
* Mariana Pinto (PG61534)
