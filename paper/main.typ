// Versão preliminar para revisão: secções 1 a 3. Estado documental de 23/11/2026.
#import "@preview/tracl:0.8.1": *
#import "@preview/pergamon:0.7.1": *

#set text(lang: "pt", region: "PT")
#set page(footer: context align(center)[#text(size: 9pt)[#counter(page).display("1")]])

#show: doc => acl(
  doc,
  anonymous: false,
  title: [
    Ferramenta educativa de tradução open source
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

#let todo(body) = highlight(
  fill: rgb("#fef3c7"),
  extent: 1pt,
  radius: 2pt,
)[#text(size: 8.5pt, fill: rgb("#92400e"))[\[#strong[TODO:] #body\]]]

#show regex("https?://[^\s)\]]+"): it => link(it.text)[#it]
#show "Abstract": [Resumo]
#show "References": [Referências]

#let referencias = ```bib
@misc{rws-studio,
  author = {{RWS}},
  title = {{Trados Studio}},
  url = {https://www.trados.com/product/studio/},
  note = {Documentação oficial. Consultado em 22/11/2026}
}

@misc{rws-qa,
  author = {{RWS}},
  title = {{eLearning for Trados Studio: Level 2 — QA check and term verifier}},
  url = {https://www.trados.com/training/eLearning-trados-studio-level-2-qa-checker-and-term-verifier/},
  note = {Curso oficial de formação (eLearning). Consultado em 22/11/2026}
}

@misc{rws-smart,
  author = {{RWS}},
  title = {{Learn about Smart Review}},
  url = {https://www.trados.com/product/features/smart-review/},
  note = {Documentação oficial. Consultado em 22/11/2026}
}

@misc{memoq-pro,
  author = {{memoQ}},
  title = {{memoQ translator pro}},
  url = {https://www.memoq.com/product/memoq-translator-pro/},
  note = {Documentação oficial. Consultado em 22/11/2026}
}

@misc{memoq-qa,
  author = {{memoQ}},
  title = {{Quality Assurance (QA) warnings}},
  url = {https://docs.memoq.com/12-5/en/Concepts/concepts-quality-assurance-qa-warnings.html},
  note = {Manual em linha, versão 12.5. Consultado em 22/11/2026}
}

@misc{memoq-lqa,
  author = {{memoQ}},
  title = {{Linguistic Quality Assurance (LQA) models}},
  url = {https://docs.memoq.com/current/en/Concepts/concepts-linguistic-quality-assurance.html},
  note = {Manual em linha, versão 12.6. Consultado em 22/11/2026}
}

@misc{memoq-history,
  author = {{memoQ}},
  title = {{History and reports}},
  url = {https://docs.memoq.com/12-5/en/Workspace/history-reports.html},
  note = {Manual em linha, versão 12.5. Consultado em 22/11/2026}
}

@misc{memoq-university,
  author = {{memoQ}},
  title = {{University Program}},
  url = {https://www.memoq.com/services/programs/university-program/},
  note = {Condições do programa educativo. Consultado em 22/11/2026}
}

@misc{omegat,
  author = {{OmegaT Project}},
  title = {{OmegaT: The Free Translation Memory Tool}},
  url = {https://omegat.org/},
  note = {Página oficial. Consultado em 22/11/2026}
}

@misc{omegat-manual,
  author = {{OmegaT Project}},
  title = {{OmegaT 6.1.0 User Manual: Chapter 4 — Menus}},
  url = {https://omegat.sourceforge.io/manual-standard/en/chapter.menus.html},
  note = {Manual oficial, secção Tools / Check Issues. Consultado em 22/11/2026}
}

@misc{opentlc,
  author = {{KlinsBt}},
  title = {{Open Translation Client (Open TLC)}},
  url = {https://github.com/KlinsBt/open-translation-client},
  note = {Repositório oficial e README, ramo main. Consultado em 22/11/2026}
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
  note = {Tipologia oficial MQM. Consultado em 22/11/2026}
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
  author = {Dogru, Gokhan},
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
  author = {Dogru, Gokhan and Martín Mor, Adrià},
  title = {{From Tool Use to Technological Agency: LoopCAT as a Local-First, Open-Source Tool for Translation Technology Education}},
  year = {2026},
  howpublished = {Pré-publicação arXiv:2609.00344},
  url = {https://arxiv.org/abs/2609.00344v1},
  note = {Versão v1. Consultado em 22/11/2026}
}

@misc{loopcat-repo,
  author = {Dogru, Gokhan},
  title = {{LoopCAT: repositório e documentação}},
  url = {https://github.com/gokhandogru/LoopCAT},
  note = {Repositório público e README consultados em 22/11/2026. Revisão documental, sem execução independente}
}

@inproceedings{carl2012,
  author = {Carl, Michael},
  title = {{Translog-II: a Program for Recording User Activity Data for Empirical Reading and Writing Research}},
  booktitle = {Proceedings of the Eighth International Conference on Language Resources and Evaluation (LREC'12)},
  year = {2012},
  pages = {4108--4112},
  address = {Istanbul, Turkey},
  publisher = {European Language Resources Association (ELRA)},
  url = {https://aclanthology.org/L12-1352/}
}

@misc{rapidfuzz-ratio,
  author = {{RapidFuzz Contributors}},
  title = {{RapidFuzz: fuzz.ratio}},
  url = {https://rapidfuzz.github.io/RapidFuzz/Usage/fuzz.html},
  note = {Documentação da similaridade Indel normalizada. Consultado em 22/11/2026}
}

@misc{qwen-ollama,
  author = {{Ollama}},
  title = {{Qwen3: 4b-instruct-2507-q4\_K\_M}},
  url = {https://ollama.com/library/qwen3:4b-instruct-2507-q4_K_M},
  note = {Ficha do modelo. Consultado em 22/11/2026}
}

```

#add-bib-resource(referencias.text)

#abstract[
Apresenta-se a Educational Translation Tool, uma aplicação web educativa para a prática de tradução de inglês para português europeu. O protótipo combina um editor segmentado com persistência e memória de tradução, cinco verificações determinísticas e pistas a pedido geradas por um modelo Qwen executado localmente através de Ollama. O desenho do feedback orientado à revisão pelo aluno é fundamentado numa revisão documental de sete ferramentas, enquanto a fusão dos alertas preserva a sua origem e inclui um filtro heurístico de possível revelação da solução. A verificação funcional abrangeu 96 testes automáticos e foi complementada por experiências exploratórias com o modelo real, nas quais se observaram deteções úteis, falsos alertas, omissões e pistas que fornecem a correção. Estas observações sustentam a definição de um protocolo interno para comparar regras, modelo e abordagem híbrida nas categorias comuns e apreciar a qualidade e a revelação das pistas. A avaliação final encontra-se em preparação, permanecendo o estudo da eficácia pedagógica junto de estudantes como uma questão para investigação futura.
]

= Introdução

As ferramentas de tradução assistida por computador, habitualmente designadas CAT (_Computer-Assisted Translation_), organizam o trabalho em torno da edição segmentada, das memórias de tradução e dos recursos terminológicos #cite("rws-studio", "memoq-pro", "omegat"). Na formação em tradução, a utilização destes recursos articula-se com a necessidade de desenvolver a capacidade de avaliar propostas e justificar escolhas. O estudo exploratório de #citet("dogru2026") ilustra esta dimensão ao mostrar como tarefas de comparação e pós-edição podem tornar observável o julgamento avaliativo dos estudantes.

O feedback produzido por uma ferramenta influencia, contudo, o trabalho de revisão que permanece a cargo do aluno. Quando o sistema indica um equivalente ou reescreve a tradução, pode resolver imediatamente o trecho em causa; uma pista, por sua vez, pode orientar a comparação entre o original e a tradução, deixando a reformulação ao aluno. O desafio consiste, por isso, em produzir informação suficientemente específica para apoiar a revisão e, simultaneamente, controlar a revelação da resposta.

A Educational Translation Tool explora este equilíbrio em textos curtos de inglês para português europeu (EN–PT-PT), através de um percurso em que o aluno escreve a tradução, utiliza recursos CAT, executa verificações explícitas e solicita pistas a um modelo local. A contribuição do trabalho reúne uma implementação inspecionável, a identificação da origem dos alertas e um protocolo para avaliar separadamente a deteção de problemas e a qualidade do feedback.

Neste enquadramento, o estudo compreende a caracterização do protótipo e a análise das evidências exploratórias que sustentam a definição dos critérios de avaliação. A comparação experimental final encontra-se em preparação, pelo que os ensaios realizados permitem, nesta fase, identificar limitações e orientar a avaliação da deteção e do feedback.

== Conceitos e Âmbito

No editor, um *segmento* constitui a unidade de trabalho e corresponde a uma linha não vazia do original e à tradução escrita pelo aluno. O apoio à tradução é complementado por um *glossário*, que define os equivalentes aceites num exercício, e por uma *memória de tradução*, que recupera pares original–tradução guardados anteriormente a partir da semelhança entre os originais.

O desenho das *pistas pedagógicas* inspira-se no conceito de _scaffolding_, entendido como o apoio do tutor à resolução de uma tarefa pelo aprendente #cite("wood1976"). Neste projeto, as pistas são solicitadas pelo aluno e procuram localizar um problema e suscitar a revisão da tradução. Cada alerta contém uma explicação e uma pista; quando é gerado pelo modelo, considera o original, a tradução atual, o contexto e o glossário, sem recorrer a um perfil do aluno ou ao histórico das suas tentativas.

As verificações de *QA determinístico* correspondem a condições escritas explicitamente em código, como a comparação de números ou marcadores. Esta dimensão formal distingue-se da avaliação linguística humana, conforme documentado em ferramentas como o memoQ #cite("memoq-qa"), e é complementada pelo *LLM local*, executado no computador que aloja o backend. A *abordagem híbrida* combina os alertas das regras e do modelo, preservando a origem de cada um. Para apreciar o seu comportamento, considera-se *falso alerta* a identificação de um problema ausente e *revelação* o fornecimento, na explicação ou na pista, de conteúdo suficiente para corrigir parte ou a totalidade do trecho em análise.

== Objetivos e Perguntas de Investigação

O objetivo geral consiste em desenvolver e avaliar um protótipo que apoie a revisão de traduções EN–PT-PT mediante verificações formais e pistas a pedido. Os objetivos pedagógicos orientam o desenho da ferramenta, enquanto a avaliação interna incide sobre o seu funcionamento e o feedback produzido. A apreciação dos efeitos na aprendizagem exigirá um estudo posterior com estudantes.

Os objetivos pedagógicos são apoiar o julgamento avaliativo por meio de pistas (*OP1*) e tornar observáveis as ações de revisão através do seu registo e consulta (*OP2*). OP1 encontra expressão nas explicações e pistas apresentadas ao aluno, enquanto OP2 é apoiado pelos eventos de utilização já recolhidos e exportáveis. Está prevista a organização desses eventos num histórico simples e cronológico, que permita consultar as ações realizadas durante o exercício.

Os objetivos de engenharia abrangem o editor CAT com memória e glossário (*OE1*), as cinco regras determinísticas (*OE2*), a integração do modelo local e a fusão dos alertas (*OE3*) e a instrumentação com exportação e histórico simples de ações (*OE4*). Neste último objetivo, o registo e a exportação encontram-se implementados, permanecendo prevista a extensão para consulta cronológica dos eventos.

A avaliação interna tem dois objetivos complementares: *OA1* compara a deteção das regras, do modelo e do híbrido sobre exemplos anotados; *OA2* aprecia a correção, a fundamentação, a clareza, a utilidade para orientar a revisão e a revelação da solução nas explicações e pistas. Estes objetivos traduzem-se nas seguintes perguntas de investigação:

- *RQ1 — Deteção comparada.* Que diferenças de precisão, recall e F1 existem entre regras determinísticas, modelo local isolado e abordagem híbrida na deteção de problemas de tradução vazia, preservação de valores numéricos e cumprimento do glossário, face a anotações de referência definidas pelos autores num conjunto EN–PT-PT?
- *RQ2 — Qualidade do feedback.* Como são apreciadas internamente as explicações e pistas do modelo e do híbrido quanto à correção, fundamentação, clareza e utilidade, e com que frequência revelam a solução?

A RQ1 incide na deteção produzida por OE2 e OE3, enquanto a RQ2 aprecia o feedback associado a OP1 e OE3. As funcionalidades de OE1, OE4 e as componentes implementadas de OP2 são sujeitas a verificação funcional. Deste modo, a avaliação interna caracteriza a deteção e o feedback nos exemplos estudados, sem medir ganhos de aprendizagem ou autonomia.

= Estado da Arte

== Critérios da Revisão Documental

A revisão documental foi orientada ao desenho do protótipo e abrangeu sete sistemas, selecionados por representarem CAT profissionais, alternativas abertas, plataformas educativas ou ferramentas de avaliação de tradução. A consulta de documentação oficial, repositórios e artigos científicos permitiu analisar o acesso ao código, o QA por regras, o feedback por LLM, a instrumentação e o enquadramento educativo de cada sistema.

A seleção procura reunir referências funcionais e pedagógicas relevantes, sem constituir uma revisão sistemática da literatura ou uma comparação de desempenho por execução independente das ferramentas. As características apresentadas resultam das fontes citadas, sendo a indicação «ND» utilizada quando uma característica não foi documentada nas fontes analisadas. Como os conteúdos online podem evoluir, as referências incluem as respetivas datas de consulta.

== Ferramentas de Apoio à Tradução

Entre os CAT profissionais, o *Trados Studio* reúne memórias, terminologia e QA #cite("rws-studio", "rws-qa"), acrescentando, através do Smart Review, a utilização de um LLM para classificar segmentos, explicar a avaliação e sugerir intervenções, incluindo equivalentes para termos incorretos #cite("rws-smart"). Constitui, assim, uma referência para revisão assistida por IA, embora o grau de explicitação do feedback possa fornecer a correção de um exercício.

O *memoQ* combina igualmente recursos CAT e verificações formais automáticas, distinguindo-os da avaliação linguística humana configurável #cite("memoq-pro", "memoq-qa", "memoq-lqa"). O histórico e a comparação de versões apoiam a inspeção das alterações #cite("memoq-history"), enquanto o programa universitário documenta a utilização educativa de uma plataforma comercial #cite("memoq-university").

Como alternativa aberta para desktop, o *OmegaT* disponibiliza memórias TMX, glossários e verificações através de _Check Issues_, incluindo etiquetas, terminologia e integração com LanguageTool #cite("omegat", "omegat-manual"). Estas funcionalidades oferecem uma referência de núcleo CAT inspecionável. No contexto web, o *Open TLC* disponibiliza um CAT sob MPL-2.0 para tradutores, docentes e estudantes, com memórias, glossários e persistência dos projetos no navegador através de IndexedDB #cite("opentlc"). O seu desenho evidencia a viabilidade de um ambiente CAT web com persistência local.

Nas ferramentas com enfoque educativo, o *postedit.me* centra-se na formação em pós-edição e na avaliação dos textos produzidos por estudantes #cite("lefer2024"). O artigo descreve anotações de erros, análise das intervenções e tipologias TAS e MTPEAS, com disponibilização gratuita às universidades para ensino e investigação interna mediante um acordo de licença.

O *MATEO*, por sua vez, fornece uma interface web para avaliar tradução automática com métricas como BLEU, chrF, TER e COMET #cite("vanroy2023"). A comparação de sistemas e a apresentação de pontuações agregadas apoiam a literacia avaliativa, constituindo um recurso distinto da orientação localizada que uma pista procura fornecer ao aluno.

O *LoopCAT* aproxima várias destas componentes num ambiente CAT aberto sob Apache-2.0, com armazenamento local, memórias, terminologia, QA e histórico por segmento #cite("loopcat2026", "loopcat-repo"). A documentação inclui revisão por IA e ligações opcionais a modelos locais ou externos #cite("loopcat-repo"), enquadrando a ferramenta numa proposta educativa que abrange operação, avaliação e intervenção no sistema. A pré-publicação distingue, contudo, as capacidades implementadas dos benefícios pedagógicos ainda por estudar.

#figure(
  {
    set text(size: 8pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (1fr, 1fr, 1fr, 1.25fr, 1.3fr, 1.5fr),
      inset: 5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: left + horizon,
      table.header([*Sistema*], [*Código aberto*], [*QA por regras*], [*Feedback por LLM*], [*Registo documentado*], [*Enquadramento educativo*]),
      [Trados], [Não], [Sim], [Smart Review], [ND nesta revisão], [Uso profissional],
      [memoQ], [Não], [Sim], [ND nesta revisão], [Histórico e versões], [Programa universitário],
      [OmegaT], [Sim], [Sim], [ND nesta revisão], [Dados do projeto], [ND nesta revisão],
      [Open TLC], [Sim], [ND nesta revisão], [ND nesta revisão], [Projetos no navegador], [Estudantes e docentes],
      [postedit.me], [Não (licença institucional)], [ND nesta revisão], [ND nesta revisão], [Edições e anotações], [Formação em pós-edição],
      [MATEO], [Sim], [ND nesta revisão], [ND nesta revisão], [Resultados e exportação], [Literacia avaliativa],
      [LoopCAT], [Sim], [Sim], [Opcional], [Histórico por segmento], [Tecnologias de tradução],
    )
  },
  kind: table,
  supplement: [Tabela],
  caption: [Síntese documental das sete ferramentas a partir das fontes citadas. ND indica informação não documentada na revisão. Projetos guardados, resultados exportados e histórico de revisões representam formas distintas de registo.],
  placement: top,
  scope: "parent",
) <tab-ferramentas>

== Feedback Pedagógico e Posicionamento

O conceito de scaffolding #cite("wood1976") fundamenta o apoio que preserva uma parte da resolução para o aluno. Na análise da tradução, a tipologia MQM (_Multidimensional Quality Metrics_) organiza categorias de problemas como exatidão, terminologia, convenções linguísticas e estilo #cite("mqm"), oferecendo um enquadramento para a seleção operacional das categorias deste protótipo. Os alertas são apresentados por categoria, explicação e pista, sem atribuição de severidades ou cálculo de uma pontuação global de qualidade.

A utilização de modelos de linguagem na avaliação de tradução é ilustrada pelo GEMBA-MQM, que usa GPT-4 para localizar possíveis erros sem exigir tradução humana de referência e discute a dependência de um modelo proprietário #cite("kocmi2023"). Por sua vez, #citet("qian2026") estudam GPT5 como parceiro de revisão com prompts inspirados em MQM, documentando tanto aproximações a juízos humanos como avaliações incorretas. Estes trabalhos sustentam a relevância de apreciar o conteúdo do feedback para além de contar alertas; a transferência desta abordagem para um modelo local de menor dimensão exige, por isso, uma verificação própria do seu desempenho.

O estudo de #citet("dogru2026") examina justificações em tarefas de comparação e pós-edição, enquanto o Translog-II #cite("carl2012") fornece uma referência de registo da atividade de escrita e tradução para investigação empírica. No presente protótipo, a instrumentação centra-se em eventos discretos, como guardar uma tradução, executar uma verificação ou pedir uma pista. Esses dados permitem caracterizar a utilização das funcionalidades, sem conservar a sequência completa das edições do texto; a sua organização cronológica servirá de base ao histórico simples previsto.

A @tab-ferramentas sintetiza componentes que já existem em diferentes sistemas e permite situar as escolhas de implementação, em particular face a uma referência próxima como o LoopCAT. O recorte deste projeto consiste na articulação de regras explícitas, pistas do modelo com controlo de possível revelação e registo exportável das ações numa aplicação EN–PT-PT inspecionável. A contribuição é, assim, apreciada no protótipo desenvolvido, sem pressupor exclusividade funcional relativamente a todos os sistemas existentes.

= Arquitetura e Implementação

== Componentes e Percurso de Utilização

A aplicação organiza-se em três níveis articulados: o *nível 1* reúne o editor segmentado, o glossário, a persistência e a memória de tradução; o *nível 2* executa verificações determinísticas; e o *nível 3* consulta o modelo local e funde o feedback. Uma camada transversal recebe os eventos de utilização e permite exportá-los. A interface foi desenvolvida em React 19, TypeScript e Vite, comunicando com um backend que utiliza FastAPI, Pydantic e SQLAlchemy sobre SQLite.

O percurso inicia-se com o carregamento do original e o fornecimento opcional de contexto e glossário, após o que o aluno escreve a tradução de cada segmento. A ação «Guardar» persiste o texto, enquanto «Verificar» aplica as regras e «Pedir pista» combina essas mesmas regras com o modelo. As duas operações de revisão incidem sobre o texto atual, incluindo alterações ainda por guardar, mas apenas o modelo recebe o contexto como dado adicional.

No backend, as regras, a pesquisa de memória, a adaptação ao Ollama e a fusão são mantidas em funções separadas. Esta organização permite executar as verificações sem a interface e substituir a rede por respostas simuladas nos testes. A configuração estudada utiliza Ollama em _localhost_ e o modelo `qwen3:4b-instruct-2507-q4_K_M`, com cerca de quatro mil milhões de parâmetros e quantização Q4_K_M #cite("qwen-ollama"). Embora o endereço e o modelo sejam configuráveis, as observações do artigo dizem respeito às execuções locais descritas.

== Editor e Persistência

O editor aceita texto escrito ou colado, ficheiros `.txt` até 200 KiB e exemplos incorporados, dividindo o original em linhas não vazias que correspondem a segmentos, até ao limite de 200 por exercício. A configuração e a posição no exercício são recuperáveis através de `localStorage`, enquanto a tradução atual é lida e guardada pela API no SQLite. O glossário é definido para o exercício e admite vários equivalentes aceites, sendo validado antes de iniciar a tarefa.

A tabela `segments` conserva o identificador, a tradução atual e a data de atualização. Para proteger a edição, a interface aguarda a leitura antes de disponibilizar o campo de tradução e bloqueia-o durante a gravação, permitindo navegar após alterações apenas quando a escrita é confirmada. Um contador de pedidos impede ainda que resultados de verificação anteriores a uma nova edição substituam o feedback atual. Os pedidos de leitura, gravação e verificação têm um prazo de 10 segundos no cliente; em caso de falha, o texto permanece no editor, embora o fim da espera não comprove que o servidor cancelou a operação.

Na versão atual, o identificador deriva de um hash FNV-1a de 32 bits do original após remover espaços nas extremidades. Como depende apenas do texto, ocorrências iguais partilham a tradução guardada, mesmo quando pertencem a exercícios ou contextos diferentes, sendo também possíveis colisões entre originais distintos. Está prevista a atribuição de uma identidade própria a cada ocorrência dentro do respetivo exercício, de modo a preservar a independência das traduções. A persistência também não separa os dados por utilizador, e o controlo das operações aplica-se a uma instância do editor, o que limita a utilização concorrente.

== Cinco Verificações Determinísticas

O endpoint `POST /api/check` recebe o original, a tradução e o glossário e devolve alertas com categoria, explicação e pista. As cinco verificações são implementadas em Python com expressões regulares, aritmética decimal e contagem de ocorrências:

1. *Tradução vazia.* A ausência de conteúdo depois de retirar espaços gera `empty_translation` e termina a verificação do segmento, evitando alertas derivados da falta de uma tradução.
2. *Números.* A regra `numeric_mismatch` identifica valores do original que faltam ou ocorrem menos vezes na tradução. Utiliza `Decimal` e normaliza os separadores en-US no original e PT-PT na tradução, conservando sinais e repetições, pelo que `1,000.50` e `1 000,50` são considerados equivalentes. Unidades, datas e intervalos não são interpretados, sendo comparados apenas os valores que contêm; um número do original escrito por extenso na tradução é assinalado como valor em falta.
3. *Terminologia.* Quando um termo do glossário aparece como palavra ou expressão completa no original, a regra `terminology` exige pelo menos um equivalente aceite na tradução. A comparação ignora diferenças entre maiúsculas e minúsculas, mas as flexões têm de constar das variantes prescritas.
4. *Marcadores.* A regra `placeholder_mismatch` compara nomes e contagens de marcadores como `{name}`, permitindo reorganizar a frase desde que os tokens sejam preservados. Formatos como `{{name}}`, `{0}` e `%s` ficam fora do padrão suportado.
5. *Etiquetas.* A regra `inline_tag_mismatch` compara as contagens de etiquetas simples `b`, `i`, `em`, `strong` e `u`, sem atributos, detetando tokens ausentes ou adicionais. A comparação limita-se à presença e à contagem desses tokens, sem validar a ordem ou o aninhamento.

As duas verificações técnicas seguem o princípio de preservação formal documentado em ferramentas CAT #cite("memoq-qa"), apresentando mensagens que dirigem o aluno para a comparação dos elementos. A ausência de alertas indica apenas que os critérios implementados foram satisfeitos naquele segmento.

== Memória de Tradução

Depois de confirmar a gravação de uma tradução com conteúdo, a aplicação tenta guardar o par original–tradução na tabela `memory_entries`, onde uma restrição de unicidade evita a repetição de pares idênticos. Esta operação decorre separadamente da gravação do segmento, permitindo continuar a tarefa mesmo quando a atualização da memória falha.

Ao abrir um segmento, o endpoint `POST /api/memory/search` compara o seu original com os originais já guardados. Para esse efeito, o código normaliza maiúsculas e espaços e aplica `fuzz.ratio`, que calcula a similaridade Indel normalizada #cite("rapidfuzz-ratio"). A pesquisa devolve até três pares com pontuação arredondada de pelo menos 70 numa escala de 0 a 100, mas a tradução sugerida só preenche o campo de edição quando o aluno seleciona «Usar».

Por exemplo, `The total is €1,000.50 today.` recupera o par de `The total is €1,000.50.` com pontuação 88, embora a tradução anterior ainda exija adaptação a _today_. A pontuação caracteriza, portanto, a semelhança entre os originais, que pode permanecer elevada mesmo perante alterações numéricas importantes. O limiar foi adotado como configuração inicial e permanece por calibrar experimentalmente. A memória é partilhada pela instância local e pode conter várias traduções do mesmo original.

== Pistas do Modelo e Fusão Híbrida

O endpoint `POST /api/hint` começa por executar as regras e consulta o modelo quando a tradução contém texto. O adaptador envia o original, a tradução atual, o contexto e o glossário, sem histórico de conversa ou de tentativas do aluno. Estes conteúdos são apresentados como dados no prompt versionado `hint-v3.txt`, que pede uma explicação e uma pergunta de revisão em português europeu.

O modelo pode emitir as categorias `empty_translation`, `numeric_mismatch`, `terminology` e `meaning_context`, ficando os marcadores e as etiquetas reservados às regras. A categoria `meaning_context` abrange alterações de significado ou intenção, incluindo negação, falsos cognatos, expressões idiomáticas e força de instruções. Para orientar essa análise, o prompt pede que se aceitem paráfrases válidas e que se evitem interpretações especulativas quando falta contexto. O trabalho realizado incide nas instruções de inferência e no tratamento da saída, mantendo o treino e os pesos do Qwen tal como são distribuídos.

A geração utiliza temperatura 0, semente 42, contexto de 4096 tokens e limite de 768 tokens de saída. É solicitado um esquema JSON com uma lista de alertas, cada um com `category`, `explanation` e `hint`, cabendo ao adaptador validar a estrutura, as categorias e o preenchimento dos campos textuais. Esta validação garante o contrato de dados, mas uma resposta estruturalmente válida pode ainda conter um falso alerta, uma categoria semanticamente inadequada ou uma correção explícita.

A fusão conserva os alertas das regras e acrescenta, no máximo, uma sugestão do modelo por categoria ainda não presente, identificando cada origem como «Regra» ou «Sugestão do modelo local». Nos alertas do modelo retidos, um filtro procura determinados tipos de aspas, equivalentes do glossário e dígitos do original em alertas numéricos. Quando encontra um desses sinais, substitui a explicação e a pista por mensagens genéricas da categoria e incrementa `sanitized`. Por depender destes padrões, a heurística pode tanto generalizar texto útil como deixar passar correções por extenso.

Quando o adaptador reconhece indisponibilidade, timeout ou resposta inválida, a API devolve o feedback determinístico e o estado do modelo, permitindo manter as verificações por regras. O prazo HTTPX predefinido é de 30 segundos por operação de rede, enquanto o cliente da interface espera até 40 segundos pelo pedido de pista. Uma nova edição invalida o resultado anterior no ecrã, preservando a associação entre o feedback e o texto revisto.

== Instrumentação e Dados Guardados

A tabela `events` regista o início do exercício, a gravação, a verificação, o pedido e a apresentação de pistas e a utilização da memória. Para cada evento, o editor envia um identificador persistente do navegador, o segmento quando aplicável e metadados como contagens por origem, latência e generalizações. A interface omite o texto das traduções e pistas nesses eventos, embora os textos traduzidos permaneçam nas tabelas de segmentos e memória. A API de eventos aceita também um campo adicional genérico, truncado acima de 2000 caracteres, pelo que a ausência de texto nos registos depende do cliente e não é garantida pelo servidor.

Os eventos da instância podem ser exportados em JSON e CSV através dos acessos no rodapé, e um resumo disponibiliza contagens agregadas. Está prevista a sua apresentação cronológica num histórico simples de ações, construído a partir dos registos já recolhidos e destinado a facilitar a consulta do percurso de utilização. Esta extensão centra-se nas ações registadas, enquanto a análise textual da RQ2 utiliza relatórios de recolha próprios com as explicações e pistas. O exercício pode prosseguir mesmo quando o envio de um evento falha, pelo que os registos podem apresentar lacunas.

A configuração atual destina-se à execução local, com CORS permissivo e endpoints disponíveis sem autenticação, incluindo os de exportação. Estas condições limitam a utilização partilhada, para a qual será necessário definir o isolamento por utilizador, o controlo de acesso e uma política de conservação dos dados.

= Protocolo de Avaliação

A avaliação será interna e conduzida pelos dois autores. RQ1 incide na deteção por categoria e RQ2 na qualidade do feedback produzido. O protocolo seguinte orienta a execução final. A dimensão do conjunto, as anotações de referência e a configuração experimental serão fixadas antes dessa execução.

== Dados e Anotação de Referência <sec-dados>

Serão preparados originais curtos com contexto e glossário quando pertinentes, traduções aceitáveis e variantes com problemas. Cada caso terá identificador, grupo de original ou documento, dados de entrada e anotações de presença ou ausência de problema, categoria, âmbito da análise e evidência. A referência admite alternativas legítimas e distingue cumprimento do glossário de preferências estilísticas. Está prevista a construção de casos sintéticos, sem recolha de traduções junto de estudantes. #todo[origem dos casos de teste: quem os redige e com que procedimento] #todo[competências linguísticas dos avaliadores]

A partição será feita por original ou documento, mantendo variantes relacionadas no mesmo conjunto. Os exemplos do piloto, da calibração, dos prompts e das demonstrações ficam reservados ao desenvolvimento. O conjunto de teste deverá incluir traduções aceitáveis para medir falsos alertas e casos com problemas nas categorias selecionadas. Serão publicados a dimensão efetiva e o número de casos por categoria e por grupo.

As anotações de referência serão revistas e fixadas por consenso entre os dois autores, com base no original, na tradução, no contexto e no glossário de cada caso. Esta fase antecede a consulta das saídas dos métodos e estabelece a presença ou ausência dos problemas avaliados. Após a recolha das respostas, será realizada a apreciação das explicações e pistas. A participação dos autores na construção e avaliação do sistema constitui uma limitação à independência dos juízos.

== Comparação da Deteção — RQ1

Serão executados três métodos. *Regras* aplica apenas o motor determinístico. *LLM isolado* usa os alertas validados do modelo antes da fusão e do filtro. *Híbrido* aplica a política da aplicação às regras e à mesma resposta do modelo. Uma única geração por caso não vazio e configuração alimenta os dois últimos métodos, evitando que diferenças entre gerações sejam confundidas com o efeito da fusão. Nas traduções vazias, a condição híbrida devolve apenas o alerta determinístico, enquanto a geração experimental é usada exclusivamente na condição LLM isolado.

A análise principal da RQ1 abrange tradução vazia, preservação de valores numéricos do original escritos em algarismos e cumprimento do glossário. Serão incluídos controlos aceitáveis e variantes com problemas nessas categorias. Os critérios de inclusão, a pertença de cada caso ao âmbito da análise e as anotações de referência serão fixados antes da consulta das respostas dos métodos. A referência será determinada pela análise dos textos e dos critérios do exercício, sem usar as saídas das regras como verdade de referência.

As diferenças de âmbito serão examinadas numa análise complementar de robustez, com exemplos de trocas de unidade, números exclusivamente acrescentados, datas, intervalos e valores escritos por extenso. Para estes casos serão apresentados a anotação humana e os alertas de cada método, identificando falsos alertas e omissões face aos fenómenos estudados. Por exemplo, a tradução aceitável de um algarismo por um número por extenso pode gerar um falso alerta da regra. Estes comportamentos serão relatados juntamente com as limitações da análise principal. As contagens de casos incluídos em cada análise serão publicadas, e os casos não serão excluídos em função do resultado observado.

Os marcadores e etiquetas terão verificação funcional própria. Os alertas de significado e contexto serão apresentados separadamente e incluídos na RQ2. Os agregados da análise principal e as contagens e observações da análise complementar serão apresentados separadamente, preservando a distinção entre os respetivos âmbitos.

A análise principal incide em fenómenos explicitamente cobertos pelas regras, cuja implementação será avaliada face à referência anotada, admitindo erros de deteção e falsos alertas. As divergências relativamente à referência serão documentadas caso a caso. Na mesma amostra, com as mesmas categorias e anotações, a fusão conserva todos os alertas das regras. Nestas condições, o recall do híbrido é igual ou superior ao das regras. A precisão e o F1 dependerão dos verdadeiros e falsos positivos acrescentados pelo modelo, pelo que serão determinados experimentalmente.

Na avaliação do modelo isolado, será realizada uma chamada experimental também nas traduções vazias. Este procedimento será distinguido do comportamento operacional da aplicação, que devolve diretamente o alerta determinístico. #todo[o coletor atual omite a chamada em traduções vazias; implementar a chamada no modo experimental antes da execução final]

A unidade de contagem é o par caso–categoria, com categorias repetidas reduzidas a uma ocorrência. Um verdadeiro positivo (VP) corresponde a uma categoria esperada e emitida, um falso positivo (FP) a uma categoria emitida mas ausente na referência e um falso negativo (FN) a uma categoria esperada e omitida. Uma categoria errada pode produzir simultaneamente FP e FN.

#block(breakable: false)[
As métricas de deteção são definidas por

$ "Precisão" = "VP" / ("VP" + "FP") $

$ "Recall" = "VP" / ("VP" + "FN") $

$ "F1" = (2 "VP") / (2 "VP" + "FP" + "FN") $
]

Serão reportados resultados por categoria e agregação micro, com numeradores, denominadores e métricas indefinidas quando o denominador for nulo. Serão também contados os casos aceitáveis com pelo menos um falso alerta.

As falhas do modelo serão reportadas por estado e número de tentativas. A comparação da deteção usará o mesmo subconjunto de chamadas válidas para os três métodos, explicitando quantos casos foram excluídos. Em complemento, será descrito o comportamento operacional do híbrido em todos os casos, incluindo o recurso às regras quando o modelo falha.

== Apreciação do Feedback — RQ2

A grelha incide sobre cada par explicação–pista. *Correção* indica se identifica uma discrepância real. *Fundamentação* avalia o suporte no original, tradução, contexto e glossário. *Clareza* aprecia a compreensão da mensagem. *Utilidade* indica se orienta para uma comparação concreta que possa apoiar a revisão. Para estes critérios registam-se os valores definidos na grelha, incluindo «parcial» quando aplicável e «incerto» com justificação.

A *revelação* tem três níveis. «Nenhuma» corresponde a orientação que deixa a reformulação ao aluno. «Parcial» indica que é fornecido um equivalente, valor ou interpretação que resolve parte do problema. «Total» corresponde a uma correção suficiente para substituir o trecho em causa, mesmo que o trecho seja uma única palavra. Esta apreciação inclui a explicação e a pista, porque ambas ficam visíveis ao aluno.

A proposta inicial #todo[indicar quem prepara a proposta inicial e com que procedimento] será revista caso a caso pelos dois autores, que decidirão por consenso e registarão alterações e evidências. As linhas de anotação serão baralhadas, com a versão do feedback numa chave separada. Esta ocultação reduz pistas sobre a condição experimental, mas a redação genérica pode permitir reconhecê-la. O procedimento não inclui dupla anotação independente nem permite calcular concordância entre anotadores.

Serão distinguidos alertas originais do modelo, alertas retidos sem alteração, alertas generalizados e alertas do modelo descartados pela prioridade das regras. Textos idênticos antes e depois da fusão podem ser anotados uma vez e associados às duas condições pela chave. Os alertas determinísticos serão identificados à parte na análise do feedback final. Casos sem alerta ou com falha de execução serão contabilizados separadamente, evitando atribuir-lhes valores de qualidade textual.

A comparação do filtro incidirá prioritariamente nos alertas retidos, emparelhando o texto antes e depois da generalização. Serão ainda descritos o feedback total mostrado pelo híbrido e os alertas eliminados pela fusão. A taxa de revelação usará o número de textos avaliados como denominador, apresentando separadamente revelações parciais e totais e o número de casos incertos. O contador `sanitized` descreve intervenções do filtro. A classificação humana determina a revelação observada.

== Aperfeiçoamento das Instruções e Avaliação Comparativa

O aperfeiçoamento do feedback será organizado em duas fases. A primeira corresponde à análise de diagnóstico da configuração inicial, com o prompt v3, sobre exemplos de desenvolvimento e calibração. As respostas serão apreciadas segundo a grelha definida para a RQ2, permitindo identificar padrões de falsos alertas, omissões, explicações inadequadas e revelação da solução. Esta análise fundamentará a revisão das instruções de geração e, quando pertinente, dos mecanismos de filtragem.

A segunda fase consiste na avaliação comparativa das configurações. A versão revista do prompt, designada v4, será fixada após a análise de diagnóstico. Ambas as configurações serão executadas sobre o mesmo conjunto de teste, constituído por originais e documentos excluídos das fases de desenvolvimento, demonstração e calibração. Os exemplos cujas respostas tenham sido consultadas para orientar alterações serão mantidos no conjunto de desenvolvimento. Este procedimento permite apreciar as diferenças de desempenho e de qualidade do feedback em condições comparáveis.

Na comparação do efeito do prompt, manter-se-ão constantes o modelo, os parâmetros de geração e o filtro. Caso sejam introduzidas alterações simultâneas no filtro, estas serão documentadas e os resultados serão interpretados como comparação entre configurações completas do sistema. As revisões do prompt atuam sobre as instruções de inferência do Qwen, preservando os pesos do modelo distribuído.

== Condições de Reprodutibilidade

Os relatórios de recolha registam os hashes dos dados e do prompt, a identificação e o digest do modelo, a versão do Ollama, os parâmetros de geração, o prazo de rede e o sistema operativo, bem como o estado e a duração de cada chamada ao modelo. Para a execução final está previsto acrescentar a revisão do código, as versões das dependências e a resposta completa do Ollama, incluindo os tempos de carregamento e o número de tokens gerados quando disponibilizados pelo serviço. #todo[implementar no coletor o registo da revisão do código, das versões das dependências e da resposta completa do Ollama] As características do equipamento são indicadas pelos autores. #todo[equipamento usado na execução final] As anotações de referência são utilizadas apenas no cálculo dos resultados e na apreciação posterior, permanecendo excluídas dos pedidos ao modelo.

O coletor mede o tempo decorrido entre o início da revisão pelo cliente Ollama e o seu retorno ou falha. Este intervalo abrange o pedido ao serviço, a receção da resposta e a validação efetuada pelo adaptador. As regras e a fusão são executadas fora dessa medição e sem o servidor FastAPI. A latência do endpoint híbrido fica fora da medição atual. Nas recolhas existentes, não foi registado um procedimento de aquecimento. #todo[definir, implementar e descrever o procedimento de aquecimento da execução final, ou documentar a sua ausência] A temperatura 0 e a semente fixa permitem controlar parâmetros da geração, embora a reprodução dependa também do ambiente de execução.

= Evidências Preliminares e Discussão

Os resultados disponíveis provêm da verificação funcional, de um piloto de viabilidade e da calibração da grelha. Os exemplos já influenciaram o desenvolvimento e ficam excluídos do teste final. Nesta versão, as evidências permitem caracterizar comportamentos concretos, enquanto as respostas quantitativas finais a RQ1 e RQ2 permanecem por completar.

== Verificação Funcional

Foram verificados 70 testes de backend e 26 de frontend, totalizando 96, bem como a compilação de produção da interface. Os testes abrangem regras, contratos da API, persistência com SQLite em memória, pesquisa difusa, registos e exportação, validação de respostas, fusão e falhas de rede simuladas. A integração automática com Ollama usa `httpx.MockTransport`. O gerador de folhas de anotação foi adicionalmente executado sobre a recolha de calibração, produzindo 11 linhas para oito casos.

Estes controlos verificam comportamentos de software e contratos de dados. A adequação linguística das pistas exige apreciação do modelo real, como a que está prevista no protocolo.

== Piloto de Viabilidade com Prompts v1 e v2

O piloto de 23 de outubro usou dez casos sintéticos de desenvolvimento, derivados de seis originais e construídos para desenvolvimento do protótipo. Os casos incluem traduções aceitáveis e variantes destinadas a testar a deteção de tradução vazia, alterações numéricas e incumprimento do glossário. A execução utilizou o Qwen de 4 mil milhões de parâmetros, em Q4_K_M, com parâmetros de geração fixos. Os relatórios históricos conservam respostas, tempos e metadados. A @tab-piloto apresenta as contagens recalculadas por par caso–categoria a partir desses ficheiros. As anotações iniciais do conjunto ainda estão assinaladas como pendentes de revisão.

#figure(
  {
    set text(size: 8.5pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (1.5fr, 0.5fr, 0.5fr, 0.5fr, 1fr, 1fr, 1fr, 1fr),
      inset: 5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: center + horizon,
      table.header([*Execução*], [*VP*], [*FP*], [*FN*], [*Precisão*], [*Recall*], [*F1*], [*Tempo médio (s)*]),
      [v1, primeira], [5], [2], [0], [71,4 %], [100 %], [83,3 %], [2,43],
      [v1, repetição], [5], [2], [0], [71,4 %], [100 %], [83,3 %], [2,37],
      [v2], [4], [1], [1], [80 %], [80 %], [80 %], [1,48],
    )
  },
  kind: table,
  supplement: [Tabela],
  caption: [Piloto exploratório sobre dez exemplos de desenvolvimento. As métricas são micro e dependem das anotações provisórias. Os tempos médios descrevem execuções não controladas quanto ao carregamento e cache do modelo.],
  placement: top,
  scope: "parent",
) <tab-piloto>

A versão v2 eliminou um falso alerta, mas omitiu um problema antes detetado. Assim, as contagens ilustram uma troca entre falsos positivos e omissões. Foram observadas explicações incorretas mesmo quando a categoria coincidia com a referência e pistas que indicavam equivalentes aceites. As duas execuções v1 produziram os mesmos textos no ambiente do piloto. Estes dados sustentaram a continuidade do desenvolvimento, sem estabelecer superioridade numa avaliação independente.

== Calibração do Feedback com o Prompt v3

A recolha de 14 de novembro contém oito traduções sintéticas de seis originais, das quais duas são aceitáveis e servem de controlo. Os exemplos foram construídos durante o desenvolvimento para calibrar a apreciação das pistas. Abrangem alterações de modalidade, expressões idiomáticas, falsos cognatos, convenções e valores numéricos, unidades e cumprimento do glossário. As oito chamadas produziram respostas válidas. O relatório regista Ollama 0.14.3, o digest do Qwen e o hash do prompt v3 e conserva os alertas antes e depois da fusão. As categorias esperadas do conjunto e os juízos das folhas de anotação constituem propostas iniciais #todo[indicar quem preparou cada proposta de calibração e com que procedimento], que aguardam revisão por consenso.

Em `Do not bypass the safety check.` traduzido por «Podes ignorar a verificação de segurança.», o Qwen emitiu um alerta de significado. A pergunta «A instrução é uma proibição ou uma recomendação?» orienta para a modalidade, embora o contraste com a tradução seja proibição–permissão. Na variante aceitável «Não saltes a verificação de segurança.», o modelo também levantou um alerta. O filtro generalizou o texto, preservando o falso alerta.

Em `She gave a lecture on the results.` traduzido por «Deu uma leitura sobre os resultados.», o Qwen classificou o problema como terminologia apesar do glossário vazio e indicou «apresentação» na pista. A resposta passou pelo filtro porque as aspas simples só são procuradas em alertas de `meaning_context`, e o adaptador não verifica a coerência entre a categoria e o glossário. Uma categoria errada pode, assim, impedir a aplicação de uma das heurísticas de controlo de revelação. O caso mostra ainda uma discrepância entre identificar um problema plausível, atribuir a categoria operacional correta e preservar o trabalho de reformulação do aluno.

Na troca de `80 °C` por `80 °F`, a regra numérica manteve-se silenciosa porque o valor 80 foi preservado. O modelo assinalou a unidade e o filtro generalizou o feedback. Este caso fundamenta a separação de âmbitos prevista na RQ1. No exemplo da expressão _broke the ice_, a ausência de alerta é registada, mas a aceitabilidade da tradução «partiu o gelo» está assinalada para discussão e exige resolver a anotação antes de calcular métricas.

Os registos permitem observar falhas e preparar a grelha. A proposta de anotação ainda não permite publicar uma taxa final de revelação. A avaliação de uma pista também pode divergir entre critérios, como no caso de uma mensagem clara que fornece a correção ou de uma mensagem genérica que preserva o falso alerta.

== Síntese das Evidências Disponíveis

Os ensaios evidenciam que a deteção, a fundamentação do alerta e a preservação do trabalho do aluno constituem dimensões distintas. Uma categoria esperada pode acompanhar uma explicação incorreta, e a generalização pode manter um falso alerta. Estas observações fundamentam a articulação das métricas da RQ1 com a apreciação textual da RQ2. A avaliação comparativa encontra-se em preparação e incidirá sobre as configurações fixadas e o conjunto de teste definido no protocolo.

= Ameaças à Validade e Limitações

*Referência e anotação.* Os autores desenvolvem o sistema, preparam os exemplos e decidem as anotações por consenso, o que introduz enviesamento. A proposta inicial e as alterações ficam registadas, mas a ausência de anotação independente limita a apreciação da fiabilidade dos juízos. O contacto prévio com as respostas do sistema pode influenciar os juízos. No conjunto de teste final, a fixação da referência antes da consulta das respostas e o registo de evidência textual destinam-se a reduzir esta influência. Os juízos provisórios de desenvolvimento e calibração permanecem sujeitos a revisão.

*Dados e generalização.* Os dez casos do piloto e os oito de calibração são pequenos conjuntos sintéticos. A exposição prévia a estes exemplos impede usá-los como teste final. Uma avaliação delimitada a EN–PT-PT, textos curtos e uma configuração local caracteriza esse recorte. A caracterização do conjunto de teste e dos avaliadores será concluída na #ref(<sec-dados>, supplement: [secção]), antes da execução final.

*Âmbito das verificações.* A regra numérica procura valores do original ausentes ou com ocorrências em falta, pode ser ambígua em sequências como «5 100» e não interpreta unidades ou números por extenso. A terminologia depende de correspondências e variantes explícitas. As etiquetas são comparadas por contagem, sem análise do aninhamento. O modelo pode errar nas categorias e na avaliação de paráfrases.

*Revelação e utilidade.* O filtro depende de padrões e pode tanto deixar passar uma correção lexical como generalizar uma explicação adequada. A forma interrogativa pedida no prompt não garante que o feedback preserve a resolução para o aluno. A apreciação dos autores sobre utilidade é interna. A observação de alunos a rever e justificar escolhas será necessária para estudar efeitos pedagógicos.

*Operação e reprodutibilidade.* O estado atual da persistência associa segmentos pelo original e partilha memória e exportações na instância. CORS permissivo e falta de autenticação limitam a utilização partilhada. As latências exploratórias dependem do equipamento, da versão do Ollama, do carregamento e do comprimento da saída. As versões do piloto e da calibração diferem, pelo que os seus tempos não permitem comparar os prompts em condições controladas.

= Conclusão e Trabalho Futuro

A Educational Translation Tool concretiza um percurso de escrita, verificação, reutilização e revisão por pistas numa aplicação EN–PT-PT com componentes inspecionáveis. As cinco regras e a memória fornecem apoio formal e reutilização explícita. A integração com o Qwen acrescenta alertas de significado, e a fusão identifica a origem de cada alerta.

Os ensaios exploratórios identificaram comportamentos úteis, falsos alertas e pistas que entregam uma correção. Estas observações motivam a avaliação separada de deteção e conteúdo pedagógico. As perguntas RQ1 e RQ2 serão respondidas após a execução do teste e a revisão das anotações segundo o protocolo apresentado.

A conclusão do trabalho inclui consolidar essa avaliação, corrigir a identidade dos segmentos e documentar as condições de utilização. O histórico de versões, as justificações do aluno e a comparação crítica, necessários para OP2 e para completar OP3, permanecem por implementar. A distribuição requer ainda escolher a licença do projeto. Uma avaliação futura com estudantes poderá estudar como as pistas influenciam a revisão, a tomada de decisão e a aprendizagem.

#print-acl-bibliography()
