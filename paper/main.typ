// Documento: Artigo / Proposta de Investigação (ACL Style via Tracl)
#import "@preview/tracl:0.8.1": *
#import "@preview/pergamon:0.7.1": *

#show: doc => acl(
  doc,
  anonymous: false,
  title: [
    Ferramentas de apoio à tradução e feedback pedagógico:\
    Estado da arte e enquadramento de uma aplicação educativa
  ],
  authors: make-authors(
    (
      name: "Diogo Pinto (PG61515) e Mariana Pinto (PG61534)",
      affiliation: [
        Universidade do Minho\
        Mestrado em Engenharia Informática
      ],
    ),
  ),
)

#show regex("https?://[^\s)\]]+"): it => link(it.text)[#it]
#show "Abstract": [Resumo]
#show "References": [Referências]

#let referencias = ```bib
@misc{rws-studio,
  author = {{RWS}},
  title = {{Trados Studio}},
  url = {https://www.trados.com/product/studio/},
  note = {Documentação oficial. Consultado em 12 de outubro de 2026}
}

@misc{rws-qa,
  author = {{RWS}},
  title = {{eLearning for Trados Studio: Level 2 — QA check and term verifier}},
  url = {https://www.trados.com/training/eLearning-trados-studio-level-2-qa-checker-and-term-verifier/},
  note = {Documentação oficial. Consultado em 12 de outubro de 2026}
}

@misc{rws-smart,
  author = {{RWS}},
  title = {{Learn about Smart Review}},
  url = {https://www.trados.com/product/features/smart-review/},
  note = {Documentação oficial. Consultado em 12 de outubro de 2026}
}

@misc{memoq-pro,
  author = {{memoQ}},
  title = {{memoQ translator pro}},
  url = {https://www.memoq.com/product/memoq-translator-pro/},
  note = {Documentação oficial. Consultado em 12 de outubro de 2026}
}

@misc{memoq-qa,
  author = {{memoQ}},
  title = {{Quality Assurance (QA) warnings}},
  url = {https://docs.memoq.com/current/en/Concepts/concepts-quality-assurance-qa-warnings.html},
  note = {Manual em linha, versão 12.5. Consultado em 12 de outubro de 2026}
}

@misc{memoq-lqa,
  author = {{memoQ}},
  title = {{Linguistic Quality Assurance (LQA) models}},
  url = {https://docs.memoq.com/current/en/Concepts/concepts-linguistic-quality-assurance.html},
  note = {Manual em linha, versão 12.5. Consultado em 12 de outubro de 2026}
}

@misc{memoq-history,
  author = {{memoQ}},
  title = {{History and reports}},
  url = {https://docs.memoq.com/current/en/Workspace/history-reports.html},
  note = {Manual em linha, versão 12.5. Consultado em 12 de outubro de 2026}
}

@misc{memoq-ai,
  author = {{memoQ}},
  title = {{AI Translation}},
  url = {https://www.memoq.com/product/ai-translation/},
  note = {Documentação oficial. Consultado em 12 de outubro de 2026}
}

@misc{memoq-university,
  author = {{memoQ}},
  title = {{University Program}},
  url = {https://www.memoq.com/services/programs/university-program/},
  note = {Condições do programa educativo. Consultado em 12 de outubro de 2026}
}

@misc{omegat,
  author = {{OmegaT Project}},
  title = {{OmegaT: The Free Translation Memory Tool}},
  url = {https://omegat.org/},
  note = {Página oficial. Consultado em 12 de outubro de 2026}
}

@misc{omegat-manual,
  author = {{OmegaT Project}},
  title = {{OmegaT 6.1.0 User Manual: Chapter 4 — Menus}},
  url = {https://omegat.sourceforge.io/manual-standard/en/chapter.menus.html},
  note = {Manual oficial, secção Tools / Check Issues. Consultado em 12 de outubro de 2026}
}

@misc{opentlc,
  author = {{KlinsBt}},
  title = {{Open Translation Client (Open TLC)}},
  url = {https://github.com/KlinsBt/open-translation-client},
  note = {Repositório oficial e README, ramo main. Consultado em 12 de outubro de 2026}
}

@inproceedings{lefer2024,
  author = {Lefer, Marie-Aude and Bodart, Romane and Piette, Justine and Obrusník, Adam},
  title = {{MTPE quality evaluation in translator education: the postedit.me app}},
  booktitle = {Proceedings of the 25th Annual Conference of the European Association for Machine Translation (Volume 2)},
  year = {2024},
  pages = {23--24},
  address = {Sheffield, UK},
  publisher = {European Association for Machine Translation},
  url = {https://aclanthology.org/2024.eamt-2.12/}
}

@inproceedings{vanroy2023,
  author = {Vanroy, Bram and Tezcan, Arda and Macken, Lieve},
  title = {{MATEO: MAchine Translation Evaluation Online}},
  booktitle = {Proceedings of the 24th Annual Conference of the European Association for Machine Translation},
  year = {2023},
  pages = {499--500},
  address = {Tampere, Finland},
  publisher = {European Association for Machine Translation},
  url = {https://aclanthology.org/2023.eamt-1.52/}
}

@misc{mqm,
  author = {{MQM Council}},
  title = {{The MQM Error Typology}},
  url = {https://www.themqm.org/mqm-pillars/typology/},
  note = {Tipologia oficial MQM 2.0. Consultado em 12 de outubro de 2026}
}

@inproceedings{kocmi2023,
  author = {Kocmi, Tom and Federmann, Christian},
  title = {{GEMBA-MQM: Detecting Translation Quality Error Spans with GPT-4}},
  booktitle = {Proceedings of the Eighth Conference on Machine Translation},
  year = {2023},
  pages = {768--775},
  address = {Singapore},
  publisher = {Association for Computational Linguistics},
  doi = {10.18653/v1/2023.wmt-1.64},
  url = {https://aclanthology.org/2023.wmt-1.64/}
}

@inproceedings{dogru2026,
  author = {Doğru, Gokhan},
  title = {{Evaluative Judgement in Teaching AI-based Translation: A Class-room Case Study of AI-Mediated Translation and Post-Editing}},
  booktitle = {Proceedings of the 1st International Workshop on Teaching AI-Based Translation and Technologies (TAITT 2026)},
  year = {2026},
  pages = {36--48},
  address = {Tilburg, the Netherlands},
  publisher = {European Association for Machine Translation},
  url = {https://aclanthology.org/2026.taitt-1.5/}
}

@inproceedings{qian2026,
  author = {Qian, Ming and Yang, Luyi},
  title = {{LLMs as Translator Training Partners: A Multi-Agent Approach}},
  booktitle = {Proceedings of the 17th Conference of the Association for Machine Translation in the Americas (Volume 1: Research Track)},
  year = {2026},
  pages = {42--79},
  address = {Québec City, Canada},
  publisher = {Association for Machine Translation in the Americas},
  url = {https://aclanthology.org/2026.amta-research.4/}
}
```

#add-bib-resource(referencias.text)

#abstract[
Este trabalho apresenta uma revisão crítica de ferramentas CAT e investigações sobre feedback pedagógico na formação em tradução, fundamentando a proposta de uma aplicação web educativa open source. Analisam-se Trados Studio, memoQ, OmegaT, Open TLC, postedit.me e MATEO sob dimensões funcionais e pedagógicas. A partir desta análise, delimita-se uma arquitetura conceptual em três níveis (CAT básico, verificações por regras e LLM local) focada no treino reflexivo e na justificação de decisões. Esta versão consolida o estado da arte e a estrutura formal do estudo, propondo uma avaliação interna da deteção de problemas e da qualidade das pistas, sem participantes externos nem medição de ganhos de aprendizagem.
]

= Introdução

As ferramentas de tradução assistida por computador, habitualmente designadas por CAT (Computer-Assisted Translation), estruturam o fluxo de trabalho em torno de memórias de tradução, glossários e edição segmentada #cite("rws-studio", "memoq-pro", "omegat"). No ensino de tradução, contudo, a meta pedagógica prioritária reside no desenvolvimento da autonomia crítica e na capacidade de justificar escolhas linguísticas, e não unicamente na aceleração da produção #cite("dogru2026"). Neste projeto, privilegiam-se pistas e explicações a pedido para incentivar a revisão fundamentada antes do acesso a uma solução de referência.

Este projeto propõe uma plataforma web educativa orientada a textos curtos (inicialmente no par inglês para português europeu) concebida para apoiar o treino reflexivo da tradução.

== Objetivos do Projeto

O objetivo geral passa por desenvolver e avaliar um protótipo de aplicação web educativa para apoiar a prática de tradução de textos curtos de inglês para português europeu, combinando edição segmentada, recursos terminológicos, verificações de qualidade e feedback pedagógico que incentive a revisão e a justificação das escolhas.

Com vista a responder aos desafios identificados, o projeto estabelece objetivos estruturados em três dimensões:

\

#underline[Objetivos Pedagógicos (Aprendizagem e Reflexão):]

- OP1 (Julgamento Avaliativo): Apoiar a identificação de problemas sem entregar a solução pronta, recorrendo a pistas pedagógicas e explicações a pedido (scaffolding).

- OP2 (Tomada de Decisão Crítica): Desenvolver módulos de comparação crítica entre versões alternativas de tradução, exigindo a seleção e justificação explícita antes do acesso a comentários de referência.

- OP3 (Visibilidade do Processo): Registar a sequência temporal de edições, consultas e respostas ao feedback, permitindo ao estudante e docente reconstituir a lógica de revisão.

#underline[Objetivos de Engenharia (Artefacto de Software):]

- OE1 (Plataforma CAT Web Modular): Desenvolver uma aplicação web de código aberto com editor segmentado, memória de tradução leve e glossário interativo.

- OE2 (Verificações por regras): Implementar verificações de segmentos sem tradução, inconsistências numéricas e incumprimento de equivalentes definidos no glossário.

- OE3 (Assistência por modelo local): Integrar e avaliar um modelo de linguagem executado localmente para identificar possíveis problemas e produzir pistas e explicações a pedido, processando os textos localmente e sem recorrer a APIs pagas.

- OE4 (Rastreabilidade e Instrumentação): Criar mecanismos de exportação de dados estruturados (JSON/CSV) com o histórico de eventos e versões.

#underline[Objetivos de Avaliação:]

- OA1 (Avaliação da deteção): Comparar regras determinísticas, modelo de linguagem e abordagem híbrida num conjunto anotado EN–PT-PT, utilizando precisão, recall e F1 nas categorias de problemas comparáveis.
- OA2 (Avaliação do feedback): Avaliar internamente, pelos autores e com critérios explícitos, a correção, fundamentação, clareza e utilidade das pistas para orientar a revisão, incluindo a frequência de revelação da solução.

== Perguntas de Investigação

O estudo visa responder a duas questões centrais através de uma avaliação interna:

- RQ1 (Eficácia Comparada): Quais as diferenças em termos de precisão, recall e F1 na deteção de problemas entre regras determinísticas, LLM local isolado e abordagem híbrida, nas categorias comparáveis de um conjunto anotado EN–PT-PT?

- RQ2 (Qualidade do Feedback): Como são avaliadas internamente a correção, a fundamentação, a clareza e a utilidade das pistas geradas pelo modelo local para orientar a revisão, e com que frequência estas revelam a solução?

A comparação crítica e o registo de revisões integram o protótipo, mas a análise do comportamento de estudantes e dos efeitos na aprendizagem fica reservada para trabalho futuro com participantes externos.

= Estado da Arte

== Análise de Ferramentas Existentes

A investigação documental analisou seis sistemas com recurso a fontes oficiais e literatura científica:

Trados Studio: Referência industrial com memórias, bases terminológicas e verificações de QA #cite("rws-studio", "rws-qa"). O recurso Smart Review utiliza modelos de linguagem para explicar avaliações de segmentos #cite("rws-smart"). Nas fontes consultadas, não foi identificado um percurso específico de treino reflexivo com escolha e justificação antes do comentário de referência; esta ausência de documentação não demonstra ausência da funcionalidade.

memoQ: Disponibiliza memórias e LiveDocs, distinguindo verificações formais automáticas (QA) de avaliação linguística humana (LQA) com tipologias configuráveis #cite("memoq-pro", "memoq-qa", "memoq-lqa"). Mantém histórico de versões detalhado #cite("memoq-history"). O programa académico apoia instituições, mas o núcleo permanece proprietário e focado na produção #cite("memoq-university", "memoq-ai").

OmegaT: Ferramenta de código aberto sob GPL-3.0 #cite("omegat"). Integra memórias TMX, glossários e verificação de inconsistências via Check Issues e LanguageTool #cite("omegat-manual"). Constitui a referência de núcleo CAT aberto para desktop.

Open TLC: Ferramenta web aberta (MPL-2.0) com armazenamento local via IndexedDB e suporte a memórias e glossários para estudantes e tradutores #cite("opentlc"). Nas fontes consultadas, não foram identificados módulos de feedback pedagógico por IA ou comparação justificada; esta observação documental não equivale a uma verificação exaustiva das funcionalidades.

postedit.me: Plataforma educativa orientada à pós-edição de tradução automática #cite("lefer2024"). Permite ao docente anotar erros e analisar as intervenções dos estudantes com base nas tipologias TAS e MTPEAS. Demonstra a relevância de analisar o processo de edição, exigindo contudo anotações docentes prévias.

MATEO: Interface web aberta (GPLv3) com métricas de avaliação automática (BLEU, chrF, TER, COMET) #cite("vanroy2023"). Fomenta a literacia em tradução automática, embora métricas globais não indiquem diretamente pistas didáticas para correção no segmento.

#figure(
caption: [Comparação documental das plataformas analisadas (ND: Não Documentado nas fontes consultadas).],
kind: table,
supplement: [Tabela],
{
set text(size: 7.0pt)
set par(justify: false, leading: 0.42em)

table(
  columns: (1.1fr, 1.3fr, 1.6fr, 1.3fr, 1.5fr),
  inset: (x: 2.5pt, y: 4pt),
  stroke: (x: none, y: 0.4pt + luma(70%)),
  align: (col, row) => center + horizon,

  table.header(
    [*Ferramenta*],
    [*Acesso*],
    [*Apoio e revisão*],
    [*Dimensão educativa*],
    [*Comparação e registo*]
  ),

  [Trados], [Comercial], [CAT, QA e explicações com Smart Review], [Percurso reflexivo: ND], [Revisão IA documentada; percurso: ND],
  [memoQ], [Comercial; programa condicionado], [CAT, QA, LQA humana e recursos de IA], [Programa universitário], [Histórico e diferenças entre versões],
  [OmegaT], [Gratuito; GPL-3.0], [CAT e verificações de qualidade], [Percurso pedagógico: ND], [Dados do projeto; justificação: ND],
  [Open TLC], [Gratuito; MPL-2.0], [CAT web; memórias e terminologia], [Orientado a estudantes e docentes], [Projetos locais; decisões: ND],
  [postedit.me], [Gratuito sob licença académica], [Anotação e avaliação de pós-edição], [Tarefas, feedback docente e métricas], [Diferenças, anotações e estatísticas],
  [MATEO], [Código aberto; GPLv3], [Métricas de avaliação de tradução], [Literacia avaliativa em TA], [Comparação de pontuações e exportação],
)
}
)

== Investigação sobre Avaliação e Feedback

A tipologia MQM (Multidimensional Quality Metrics) oferece uma classificação padronizada de falhas (exatidão, terminologia, convenções linguísticas e estilo) #cite("mqm"), servindo de base taxonómica para categorizar alertas no projeto.

Na avaliação com LLMs, o trabalho de Kocmi e Federmann #cite("kocmi2023") apresenta o GEMBA-MQM, que utiliza GPT-4 para identificar trechos com possíveis erros sem exigir uma tradução humana de referência, e assinala limitações associadas à dependência de um modelo proprietário. O estudo de Qian e Yang #cite("qian2026") analisa GPT5 como parceiro de revisão, salientando a necessidade de apreciação humana perante juízos incorretos. Estes resultados não estabelecem o desempenho do modelo local a selecionar neste projeto. O estudo de caso exploratório de Doğru #cite("dogru2026") analisa as justificações dos estudantes em tarefas de comparação e pós-edição, fornecendo evidência sobre a manifestação do julgamento avaliativo nesse contexto, sem demonstrar, por si só, um aumento causal da autonomia.

= Arquitetura da Solução

A solução organiza-se conceptualmente em três níveis complementares, materializada numa aplicação web com frontend desacoplado e API de serviços:

#figure(
rect(width: 100%, inset: 10pt, stroke: 0.4pt + gray)[
#set text(size: 8.5pt)
#align(center)[#underline[Arquitetura Conceptual em 3 Níveis]]

- Nível 1 (CAT Básico): Editor por segmentos, memória de tradução leve (similaridade via RapidFuzz) e glossário.
- Nível 2 (QA Determinístico): Motor de regras locais para deteção de segmentos sem tradução, inconsistências numéricas e incumprimento da terminologia prescrita.
- Nível 3 (Assistência Inteligente): LLM local acedido pelo backend para geração de explicações pedagógicas e pistas a pedido.
- Camada de Instrumentação: Módulo de captura de eventos, versões de segmentos e justificações para exportação.
],
caption: [Organização dos componentes e níveis funcionais da plataforma.],
)

== Stack Prevista

#h(1.2cm)

*Frontend:* React com TypeScript e Vite, assegurando reatividade na edição segmentada e modularidade de componentes.

*Backend & API:* Python com FastAPI e Pydantic para validação de esquemas de dados e orquestração de rotinas linguísticas.

*Persistência:* SQLite via SQLAlchemy para armazenamento local de projetos, segmentos e revisões. A associação dos dados às respetivas sessões será assegurada pela lógica da aplicação.

*Processamento e LLM:* Regras em Python nativo e RapidFuzz; execução de um modelo de linguagem local através de Ollama, acedido por um adaptador no backend, sem recurso a APIs pagas. O modelo e a quantização serão selecionados após uma experiência de viabilidade num Mac com chip Apple M5 e 16 GB de memória unificada.

= Implementação do Protótipo



// TODO: Documentar a implementação do editor por segmentos e do mecanismo de auto-save.
// TODO: Descrever a integração do adaptador local para LLM via Ollama.
// TODO: Detalhar a persistência das sessões e o pipeline de fusão entre regras e modelo.
TODO

= Protocolo de Avaliação Experimental

A avaliação planeada será interna, conduzida pelos dois autores, sem recrutamento de participantes externos. Abrangerá a correção funcional do protótipo, a deteção de problemas de tradução e a apreciação das pistas. O protocolo será fixado antes da execução sobre o conjunto de teste.

== Conjunto de Dados (EN–PT-PT)

Será preparado um conjunto de segmentos com contexto, traduções aceitáveis e traduções com problemas nas categorias selecionadas. As anotações indicarão a presença ou ausência de problema, a categoria e a evidência, admitindo variantes legítimas de tradução. A dimensão e a distribuição por categoria serão definidas antes da avaliação final.

Os conjuntos de desenvolvimento e teste serão separados por documento ou original, mantendo variantes relacionadas no mesmo conjunto. Os exemplos usados para selecionar o modelo ou ajustar regras e prompts pertencerão exclusivamente ao desenvolvimento. Os autores anotarão independentemente uma parte do conjunto e registarão as divergências antes da sua resolução; as anotações de referência serão fixadas antes da execução final.

== Desenho dos Testes Técnicos

Para responder à RQ1, os três métodos receberão os mesmos segmentos, contexto e glossário. A abordagem híbrida combinará os alertas das regras e do modelo, preservando a origem e eliminando duplicados segundo critérios previamente definidos. A comparação direta abrangerá apenas as categorias suportadas pelos três métodos; eventuais categorias adicionais serão analisadas separadamente.

A unidade de avaliação será o par segmento–categoria, contado uma única vez por método. Serão reportados verdadeiros positivos, falsos positivos, falsos negativos, precisão, recall e F1 por categoria, bem como falsos alertas em traduções aceitáveis. Métricas com denominador nulo serão identificadas como indefinidas. Serão também registadas a latência, as falhas de execução e as respostas que não cumpram o esquema esperado.

Os testes funcionais verificarão a gravação e recuperação de traduções, a coerência das revisões e exportações e o comportamento perante indisponibilidade do modelo ou respostas associadas a uma revisão anterior. Modelo, quantização, versões das ferramentas, prompt, parâmetros de geração e equipamento serão registados para permitir a reprodução das experiências.

== Apreciação Interna das Pistas

Para responder à RQ2, os dois autores apreciarão independentemente uma amostra de pistas segundo uma grelha com critérios de correção, fundamentação no texto, clareza, utilidade para orientar a revisão e revelação da solução. A grelha e o critério de seleção da amostra serão definidos antes da avaliação. Serão registadas concordâncias, divergências e exemplos de explicações incorretas ou não sustentadas pelo texto. Esta apreciação não mede a utilidade percebida por estudantes nem ganhos de aprendizagem.

= Resultados e Discussão


// TODO: Inserir tabela comparativa com os valores de Precision, Recall e F1 para Regras, LLM e Abordagem Híbrida.
// TODO: Apresentar a apreciação interna das pistas, incluindo explicações incorretas ou não sustentadas e revelação da solução.
// TODO: Reportar a latência do LLM local no equipamento utilizado, sem inferir satisfação de utilizadores.

= Ameaças à Validade e Limitações

Os autores participarão no desenvolvimento, na preparação dos dados e na avaliação, o que introduz risco de enviesamento. A anotação independente de parte dos exemplos e o registo de divergências ajudam a explicitar esse risco, mas não substituem validação externa especializada. Serão descritas as competências linguísticas dos avaliadores e as limitações daí decorrentes.

O conjunto delimitado EN–PT-PT, os tipos de texto selecionados e a configuração de um único modelo local limitarão a generalização dos resultados. A avaliação interna permitirá caracterizar o protótipo e o feedback nos exemplos estudados, mas não demonstrará a sua eficácia pedagógica, a usabilidade junto do público-alvo ou efeitos na autonomia dos estudantes.

= Conclusão

// TODO: Sintetizar as conclusões obtidas face às perguntas de investigação RQ1 e RQ2.
// TODO: Propor avaliação futura com estudantes para estudar padrões de decisão, usabilidade e efeitos na aprendizagem.

#print-acl-bibliography()
