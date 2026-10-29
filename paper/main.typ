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

@article{wood1976,
  author = {Wood, David and Bruner, Jerome S. and Ross, Gail},
  title = {{The Role of Tutoring in Problem Solving}},
  journal = {Journal of Child Psychology and Psychiatry},
  year = {1976},
  volume = {17},
  number = {2},
  pages = {89--100},
  doi = {10.1111/j.1469-7610.1976.tb00381.x}
}

@misc{loopcat2026,
  author = {Doğru, Gokhan and Martín Mor, Adrià},
  title = {{From Tool Use to Technological Agency: LoopCAT as a Local-First, Open-Source Tool for Translation Technology Education}},
  year = {2026},
  howpublished = {Pré-publicação arXiv:2609.00344},
  url = {https://arxiv.org/abs/2609.00344},
  note = {Descreve uma versão de desenvolvimento de 31 de agosto de 2026. Consultado em 28 de outubro de 2026}
}

@inproceedings{carl2012,
  author = {Carl, Michael},
  title = {{Translog-II: a Program for Recording User Activity Data for Empirical Reading and Writing Research}},
  booktitle = {Proceedings of the Eighth International Conference on Language Resources and Evaluation (LREC'12)},
  year = {2012},
  address = {Istanbul, Turkey},
  publisher = {European Language Resources Association (ELRA)},
  url = {https://aclanthology.org/L12-1352/}
}
```

#add-bib-resource(referencias.text)

#abstract[
Este trabalho apresenta uma revisão crítica de ferramentas CAT e investigações sobre feedback pedagógico na formação em tradução, fundamentando a proposta de uma aplicação web educativa open source. Analisam-se Trados Studio, memoQ, OmegaT, Open TLC, postedit.me, MATEO e LoopCAT sob dimensões funcionais e pedagógicas. A partir desta análise, delimita-se uma arquitetura conceptual em três níveis (CAT básico, verificações por regras e LLM local) focada no treino reflexivo e na justificação de decisões. Esta versão consolida o estado da arte e a estrutura formal do estudo, propondo uma avaliação interna da deteção de problemas e da qualidade das pistas, sem participantes externos nem medição de ganhos de aprendizagem.
]

= Introdução

As ferramentas de tradução assistida por computador, habitualmente designadas por CAT (Computer-Assisted Translation), estruturam o fluxo de trabalho em torno de memórias de tradução, glossários e edição segmentada #cite("rws-studio", "memoq-pro", "omegat"). No ensino de tradução, contudo, a meta pedagógica prioritária reside no desenvolvimento da autonomia crítica e na capacidade de justificar escolhas linguísticas, e não unicamente na aceleração da produção #cite("dogru2026"). Neste projeto, privilegiam-se pistas e explicações a pedido para incentivar a revisão fundamentada antes do acesso a uma solução de referência.

Este projeto propõe uma plataforma web educativa orientada a textos curtos (inicialmente no par inglês para português europeu) concebida para apoiar o treino reflexivo da tradução.

== Conceitos e Terminologia

Para evitar termos sem definição, a Tabela 1 fixa o significado com que os principais conceitos são usados neste trabalho.

#figure(
caption: [Conceitos usados neste trabalho e significado adotado.],
kind: table,
supplement: [Tabela],
{
set text(size: 7.5pt)
set par(justify: false, leading: 0.45em)

table(
  columns: (0.9fr, 2.6fr),
  inset: (x: 3pt, y: 4pt),
  stroke: (x: none, y: 0.4pt + luma(70%)),
  align: (col, row) => if col == 0 { left + horizon } else { left + horizon },

  table.header([*Termo*], [*Significado neste trabalho*]),

  [Segmento], [Unidade de trabalho do editor: uma frase ou parágrafo curto do original com a respetiva tradução.],
  [Scaffolding], [Apoio temporário e graduado que orienta o aprendente sem resolver a tarefa por ele #cite("wood1976"). Aqui, concretiza-se em pistas a pedido que não revelam a tradução.],
  [Pista pedagógica], [Mensagem que indica onde e porquê pode existir um problema, sem apresentar a correção.],
  [Regras determinísticas], [Verificações escritas explicitamente em código (expressões regulares e comparações), sem aprendizagem automática: a mesma entrada produz sempre o mesmo alerta e cada alerta é explicável pela regra que o gerou.],
  [QA (garantia de qualidade)], [Verificações automáticas de aspetos formais, como números e terminologia, distintas da avaliação linguística feita por pessoas (LQA) #cite("memoq-qa", "memoq-lqa").],
  [Glossário], [Lista, definida para cada exercício, de termos do original e dos equivalentes aceites em português europeu.],
  [LLM local], [Modelo de linguagem de grande dimensão, de pesos abertos, executado no computador do utilizador, sem enviar os textos para serviços externos.],
  [Alucinação], [Alerta ou explicação gerada pelo modelo que não é sustentada pelo texto original nem pela tradução.],
  [Abordagem híbrida], [Combinação dos alertas das regras e do modelo, preservando a origem e eliminando duplicados.],
  [Precisão, recall e F1], [Precisão = VP/(VP+FP); recall = VP/(VP+FN); F1 = 2VP/(2VP+FP+FN), com VP, FP e FN os verdadeiros positivos, falsos positivos e falsos negativos.],
  [MQM], [Tipologia padronizada de erros de tradução (Multidimensional Quality Metrics) #cite("mqm").],
)
}
)

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

- OA1 (Avaliação da deteção): Construir e anotar um conjunto EN–PT-PT e executar sobre ele as regras determinísticas, o modelo de linguagem e a abordagem híbrida, medindo precisão, recall e F1 nas categorias comparáveis.
- OA2 (Avaliação do feedback): Definir uma grelha de apreciação e aplicá-la, pelos autores, a uma amostra de pistas, registando correção, fundamentação, clareza, utilidade e revelação da solução.

== Perguntas de Investigação

O estudo visa responder a duas questões centrais através de uma avaliação interna:

- RQ1 (Eficácia Comparada): Quais as diferenças em termos de precisão, recall e F1 na deteção de problemas entre regras determinísticas, LLM local isolado e abordagem híbrida, nas categorias comparáveis de um conjunto anotado EN–PT-PT?

- RQ2 (Qualidade do Feedback): Como são avaliadas internamente a correção, a fundamentação, a clareza e a utilidade das pistas geradas pelo modelo local para orientar a revisão, e com que frequência estas revelam a solução?

== Relação entre Objetivos e Perguntas de Investigação

As perguntas definem o que se pretende saber; os objetivos de engenharia e pedagógicos (OE, OP) definem o que é construído, e os objetivos de avaliação (OA) definem o que é feito para responder. A Tabela 2 associa cada pergunta aos objetivos que produzem o objeto avaliado e aos que o medem.

#figure(
caption: [Ligação entre perguntas de investigação e objetivos.],
kind: table,
supplement: [Tabela],
{
set text(size: 7.5pt)
set par(justify: false, leading: 0.45em)

table(
  columns: (0.5fr, 1.2fr, 0.8fr, 1.7fr),
  inset: (x: 3pt, y: 4pt),
  stroke: (x: none, y: 0.4pt + luma(70%)),
  align: left + horizon,

  table.header([*Pergunta*], [*Objetivos que produzem o objeto avaliado*], [*Objetivo que o mede*], [*Evidência produzida*]),

  [RQ1], [OE2 (regras), OE3 (modelo local; abordagem híbrida)], [OA1], [VP, FP, FN, precisão, recall e F1 por categoria; falsos alertas; latência e falhas],
  [RQ2], [OP1 (pistas sem solução), OE3 (modelo local)], [OA2], [Grelha de apreciação; frequência de revelação da solução; exemplos de explicações incorretas],
  [Sem RQ], [OE1 (plataforma), OE4 (instrumentação), OP3 (visibilidade do processo), OP2 (comparação crítica)], [Testes funcionais], [Testes automáticos; comportamento de estudantes reservado para trabalho futuro],
)
}
)

Os objetivos OE1, OE4, OP2 e OP3 caracterizam o protótipo, mas não correspondem a nenhuma pergunta: são verificados apenas funcionalmente. A análise do comportamento de estudantes e dos efeitos na aprendizagem fica reservada para trabalho futuro com participantes externos.

= Estado da Arte

== Análise de Ferramentas Existentes

A investigação documental analisou sete sistemas com recurso a fontes oficiais e literatura científica:

Trados Studio: Referência industrial com memórias, bases terminológicas e verificações de QA #cite("rws-studio", "rws-qa"). O recurso Smart Review utiliza modelos de linguagem para explicar avaliações de segmentos #cite("rws-smart"): segundo a descrição oficial, atribui a cada segmento uma classificação qualitativa acompanhada de explicação e pode sugerir correções, como a substituição de um termo incorreto. Uma correção sugerida é precisamente o que o scaffolding procura evitar numa primeira fase. Nas fontes consultadas, não foi identificado um percurso específico de treino reflexivo com escolha e justificação antes do comentário de referência; esta ausência de documentação não demonstra ausência da funcionalidade.

memoQ: Disponibiliza memórias e LiveDocs, distinguindo verificações formais automáticas (QA) de avaliação linguística humana (LQA) com tipologias configuráveis #cite("memoq-pro", "memoq-qa", "memoq-lqa"). Mantém histórico de versões detalhado #cite("memoq-history"). O programa académico apoia instituições, mas o núcleo permanece proprietário e focado na produção #cite("memoq-university", "memoq-ai").

OmegaT: Ferramenta de código aberto sob GPL-3.0 #cite("omegat"). Integra memórias TMX, glossários e verificação de inconsistências via Check Issues e LanguageTool #cite("omegat-manual"). Constitui a referência de núcleo CAT aberto para desktop.

Open TLC: Ferramenta web aberta (MPL-2.0) com armazenamento local via IndexedDB e suporte a memórias e glossários para estudantes e tradutores #cite("opentlc"). Nas fontes consultadas, não foram identificados módulos de feedback pedagógico por IA ou comparação justificada; esta observação documental não equivale a uma verificação exaustiva das funcionalidades.

postedit.me: Plataforma educativa orientada à pós-edição de tradução automática #cite("lefer2024"). Permite ao docente anotar erros e analisar as intervenções dos estudantes com base nas tipologias TAS e MTPEAS. Demonstra a relevância de analisar o processo de edição, exigindo contudo anotações docentes prévias.

MATEO: Interface web aberta (GPLv3) com métricas de avaliação automática (BLEU, chrF, TER, COMET) #cite("vanroy2023"). Fomenta a literacia em tradução automática, embora métricas globais não indiquem diretamente pistas didáticas para correção no segmento.

LoopCAT: Ambiente CAT _local-first_ sob licença Apache-2.0, concebido para o ensino de tecnologias de tradução #cite("loopcat2026"). Oferece edição bilingue, memórias, terminologia, verificações de QA, revisão e exportação XLIFF, com projetos guardados no browser (IndexedDB); modelos de linguagem locais (por exemplo, via Ollama) são opcionais. Organiza as atividades didáticas em quatro formas de participação (operar, avaliar, inspecionar e configurar, intervir) e mantém um histórico de versões por segmento. É o trabalho mais próximo do nosso, mas a pré-publicação não descreve pistas graduais que evitem revelar a solução nem reporta evidência de aprendizagem, e indicava, à data de 31 de agosto de 2026, que o repositório ainda não era público; a comparação baseia-se, por isso, apenas nessa descrição.

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

== Síntese Comparativa e Lacuna

A Tabela 4 compara as ferramentas segundo os critérios que orientam o projeto. Cada ferramenta cumpre alguns deles, mas as fontes consultadas não documentam, em nenhuma, a combinação de verificações por regras explícitas, pistas graduais que não revelam a solução e registo do processo orientado ao aprendente. A contribuição proposta é essa combinação numa aplicação web aberta e a sua avaliação técnica interna, e não a novidade de cada componente isolado.

#figure(
caption: [Critérios do projeto por ferramenta (classificação dos autores a partir das fontes citadas; ND: não documentado nas fontes consultadas, o que não demonstra ausência).],
kind: table,
supplement: [Tabela],
{
set text(size: 6.5pt)
set par(justify: false, leading: 0.4em)

table(
  columns: (1.0fr, 0.9fr, 0.9fr, 0.9fr, 1.0fr, 0.9fr, 1.0fr),
  inset: (x: 2pt, y: 3.5pt),
  stroke: (x: none, y: 0.4pt + luma(70%)),
  align: (col, row) => if col == 0 { left + horizon } else { center + horizon },

  table.header([*Ferramenta*], [*Código aberto*], [*QA por regras*], [*Feedback por LLM*], [*Pistas sem solução*], [*Registo do processo*], [*Foco educativo*]),

  [Trados], [Não], [Sim], [Sim (Smart Review)], [Não (sugere correções)], [ND], [Não],
  [memoQ], [Não], [Sim (QA e LQA)], [ND], [ND], [Sim (histórico)], [Parcial (programa universitário)],
  [OmegaT], [Sim], [Sim], [ND], [ND], [ND], [ND],
  [Open TLC], [Sim], [ND], [Não], [Não], [ND], [Sim (estudantes)],
  [postedit.me], [ND], [ND], [ND], [Não (feedback docente)], [Sim], [Sim],
  [MATEO], [Sim], [Não (métricas)], [Não], [Não], [Parcial], [Parcial (literacia avaliativa)],
  [LoopCAT], [Sim], [Sim], [Opcional (local)], [ND], [Parcial (histórico)], [Sim],
)
}
)

== Investigação sobre Avaliação e Feedback

O conceito de scaffolding #cite("wood1976") sustenta a opção por pistas graduais em vez de soluções prontas. Quanto ao registo do processo, ferramentas de investigação como o Translog-II #cite("carl2012") registam a atividade do utilizador durante a escrita e a tradução para fins de análise empírica; não se destinam a devolver feedback ao aprendente, mas motivam a camada de instrumentação prevista (OP3).

A tipologia MQM (Multidimensional Quality Metrics) oferece uma classificação padronizada de falhas (exatidão, terminologia, convenções linguísticas e estilo) #cite("mqm"), servindo de base taxonómica para categorizar alertas no projeto.

Na avaliação com LLMs, o trabalho de Kocmi e Federmann #cite("kocmi2023") apresenta o GEMBA-MQM, que utiliza GPT-4 para identificar trechos com possíveis erros sem exigir uma tradução humana de referência, e assinala limitações associadas à dependência de um modelo proprietário. O estudo de Qian e Yang #cite("qian2026") analisa GPT5 como parceiro de revisão, salientando a necessidade de apreciação humana perante juízos incorretos. // TODO verificar esta descrição no texto do artigo (não foi possível abrir a página na revisão automática). Estes resultados não estabelecem o desempenho do modelo local a selecionar neste projeto. O estudo de caso exploratório de Doğru #cite("dogru2026") analisa as justificações dos estudantes em tarefas de comparação e pós-edição, fornecendo evidência sobre a manifestação do julgamento avaliativo nesse contexto, sem demonstrar, por si só, um aumento causal da autonomia.

= Arquitetura da Solução

A solução organiza-se conceptualmente em três níveis complementares, materializada numa aplicação web com frontend desacoplado e API de serviços:

#figure(
rect(width: 100%, inset: 10pt, stroke: 0.4pt + gray)[
#set text(size: 8.5pt)
#align(center)[#underline[Arquitetura Conceptual em 3 Níveis]]

- Nível 1 (CAT Básico): Editor por segmentos com entrada de texto ou ficheiro, persistência e glossário (implementado); memória de tradução leve, com similaridade via RapidFuzz (prevista).
- Nível 2 (QA Determinístico): Motor de regras locais para deteção de segmentos sem tradução, inconsistências numéricas e incumprimento da terminologia prescrita (implementado).
- Nível 3 (Assistência Inteligente): LLM local acedido pelo backend para geração de explicações pedagógicas e pistas a pedido (previsto; experiência preliminar realizada).
- Camada de Instrumentação: Módulo de captura de eventos, versões de segmentos e justificações para exportação, e módulo de comparação crítica entre versões (previstos).
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



A implementação do protótipo concretizou os dois primeiros níveis da arquitetura através de uma aplicação web desacoplada (frontend e API).

== Editor Segmentado e Persistência (Nível 1)

O frontend foi desenvolvido em React 19 com TypeScript e Vite. O aluno cola ou escreve o texto original em inglês, carrega um ficheiro de texto (até 200 KB) ou parte de um exemplo; cada linha ou parágrafo torna-se um segmento, com navegação entre segmentos. A interface apresenta o original, o contexto e o glossário opcional do exercício, e um campo de edição para português europeu. A tradução é guardada através dos endpoints `GET` e `PUT /api/segments/{id}`; o identificador de cada segmento deriva de um resumo (hash) do seu texto, pelo que voltar a carregar o mesmo texto recupera a tradução já guardada. A camada de armazenamento usa SQLAlchemy 2.0 sobre SQLite, preservando o texto exato (quebras de linha e Unicode) com comportamento idempotente. Ao mudar de segmento, a tradução ainda não guardada é gravada automaticamente.

Dois mecanismos protegem o trabalho do aluno face à latência da rede:
- *Controlo de concorrência e versões:* referências atómicas (`requestVersion` e `saveVersion`) impedem que respostas desfasadas sobreponham revisões mais recentes.
- *Gestão de tempo limite:* o cliente HTTP aplica um limite de 10 segundos com `AbortController`, cancelando pedidos pendentes e mostrando mensagens de erro que não apagam o texto.

== Motor de Verificação Determinística (Nível 2)

No backend (FastAPI, com validação de tipos via Pydantic v2), o ficheiro `backend/rules.py` implementa três regras determinísticas independentes, executadas por ordem de prioridade:
1. *Tradução vazia (`empty_translation`):* verifica se existe texto depois de remover espaços; se estiver vazia, não são avaliadas as restantes regras.
2. *Discrepâncias numéricas (`numeric_mismatch`):* extrai os números do original e da tradução com expressões regulares e normaliza separadores de milhares e decimais, para comparar o valor e não a sua representação (por exemplo, `1,000.50` e `1 000,50` são equivalentes). Um espaço só é tratado como separador de milhares quando é seguido de três dígitos.
3. *Conformidade terminológica (`terminology`):* para cada termo do glossário que ocorra no original como palavra completa, exige que a tradução contenha o equivalente prescrito ou uma variante aceite, sem distinguir maiúsculas de minúsculas. A correspondência começa numa fronteira de palavra e aceita formas que comecem pelo equivalente, o que permite algumas flexões.

O sistema é coberto por 35 testes automáticos: 22 no backend (com SQLite em memória) e 13 no frontend (Vitest), que verificam os limites de tempo, a gestão de erros, a segmentação do texto e a leitura do glossário.

== Experiência Preliminar com o Modelo Local (Nível 3)

Antes de integrar o modelo, foi feita uma experiência exploratória de viabilidade com o modelo qwen3 de 4 mil milhões de parâmetros (quantização Q4_K_M), servido por Ollama, sobre 10 exemplos de desenvolvimento, sintéticos, preparados com assistência de uma ferramenta de IA generativa e com anotações ainda por rever pelos autores. Com um primeiro prompt, o modelo obteve precisão de 71,4 %, recall de 100 % e F1 de 83,3 %; com um segundo prompt, 80 %, 80 % e 80 %, respetivamente, contando pares segmento–categoria. O tempo médio foi de cerca de 1,5 a 2,4 segundos por caso num MacBook com chip M5 e 16 GB. Observaram-se falsos alertas (a adaptação de `€1,000.50` para `1 000,50 €` foi assinalada como alteração de valor), revelação dos equivalentes aceites e explicações incorretas. Como estes exemplos já serviram para ajustar os prompts, não integram o conjunto de teste final e os valores não constituem resultados da avaliação.

// TODO: Descrever a integração do adaptador local para LLM no backend e o pipeline de fusão entre regras e modelo.

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

As regras têm limites conhecidos. A verificação numérica só deteta números do original que faltam na tradução, não números acrescentados, e é ambígua perante sequências como "5 100". A terminologia só é verificada quando o termo do glossário surge no original como palavra completa, pelo que variações do original (como o plural) não são cobertas, e a correspondência por prefixo pode aceitar palavras que apenas começam pelo equivalente. O conjunto de desenvolvimento é pequeno (10 casos) e sintético.

Os autores participarão no desenvolvimento, na preparação dos dados e na avaliação, o que introduz risco de enviesamento. A anotação independente de parte dos exemplos e o registo de divergências ajudam a explicitar esse risco, mas não substituem validação externa especializada. Serão descritas as competências linguísticas dos avaliadores e as limitações daí decorrentes.

O conjunto delimitado EN–PT-PT, os tipos de texto selecionados e a configuração de um único modelo local limitarão a generalização dos resultados. A avaliação interna permitirá caracterizar o protótipo e o feedback nos exemplos estudados, mas não demonstrará a sua eficácia pedagógica, a usabilidade junto do público-alvo ou efeitos na autonomia dos estudantes.

= Conclusão

// TODO: Sintetizar as conclusões obtidas face às perguntas de investigação RQ1 e RQ2.
// TODO: Propor avaliação futura com estudantes para estudar padrões de decisão, usabilidade e efeitos na aprendizagem.

#print-acl-bibliography()
