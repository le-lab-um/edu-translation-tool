// Artigo de investigação em desenvolvimento. Estado documental de 22/11/2026.
#import "@preview/tracl:0.8.1": *
#import "@preview/pergamon:0.7.1": *

// Marcador de pendências a confirmar pelos autores. Remover antes da versão final.
#let todo(body) = text(fill: rgb("#c00000"), weight: "bold")[\[TODO: #body\]]

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
Apresenta-se a Educational Translation Tool, uma aplicação web educativa para a prática de tradução de inglês para português europeu. O protótipo combina um editor segmentado com persistência e memória de tradução, cinco verificações determinísticas e pistas a pedido geradas por um modelo Qwen executado localmente através de Ollama. A revisão documental de sete ferramentas fundamenta o desenho do feedback orientado à revisão pelo aluno. A fusão preserva a origem dos alertas e inclui um filtro heurístico de possível revelação da solução. Foram verificados 96 testes automáticos e realizadas experiências exploratórias com o modelo real. Estas evidenciam tanto deteções úteis como falsos alertas, omissões e pistas que fornecem a correção. Define-se um protocolo interno para comparar regras, modelo e abordagem híbrida nas categorias comuns e apreciar a qualidade e a revelação das pistas. A avaliação final está em preparação. A eficácia pedagógica junto de estudantes permanece uma questão para investigação futura.
]

= Introdução

As ferramentas de tradução assistida por computador, habitualmente designadas CAT (_Computer-Assisted Translation_), organizam o trabalho em torno da edição segmentada, memórias de tradução e recursos terminológicos #cite("rws-studio", "memoq-pro", "omegat"). Na formação em tradução, interessa também desenvolver a capacidade de avaliar propostas e justificar escolhas. O estudo exploratório de #citet("dogru2026") ilustra como tarefas de comparação e pós-edição podem tornar observável esse julgamento avaliativo.

Um sistema que identifica um problema pode apoiar a revisão, mas a forma do feedback condiciona a tarefa que fica para o aluno. Indicar um equivalente ou reescrever a tradução permite resolver imediatamente o trecho em causa. Uma pista pode orientar a comparação entre original e tradução. A dificuldade consiste em produzir informação suficientemente específica para ajudar e, simultaneamente, controlar a revelação da resposta.

A Educational Translation Tool explora este equilíbrio em textos curtos de inglês para português europeu (EN–PT-PT). O aluno escreve a tradução e pode usar recursos CAT, executar verificações explícitas ou pedir uma pista a um modelo local. A contribuição do trabalho reúne uma implementação inspecionável, a identificação da origem dos alertas e um protocolo para avaliar separadamente deteção e qualidade do feedback. O desenvolvimento prevê a distribuição sob uma licença de código aberto, cuja escolha ainda está pendente.

O estudo compreende a caracterização do protótipo, a análise das evidências exploratórias e a definição de um protocolo de avaliação da deteção e do feedback. A comparação experimental final encontra-se em preparação. Os ensaios apresentados sustentam a identificação de limitações e a operacionalização dos critérios de avaliação.

== Conceitos e Âmbito

Um *segmento* é a unidade de trabalho do editor. No protótipo, corresponde a uma linha não vazia do original e à tradução escrita pelo aluno. O *glossário* define os equivalentes aceites num exercício, e a *memória de tradução* recupera pares original–tradução guardados anteriormente a partir da semelhança entre os originais.

O termo _scaffolding_ designa o apoio do tutor à resolução de uma tarefa pelo aprendente #cite("wood1976"). Neste projeto, orienta o desenho de *pistas pedagógicas* a pedido que procuram localizar um problema e suscitar uma revisão. A implementação atual produz uma explicação e uma pista por alerta. A adaptação progressiva ao conhecimento do aluno ou a sucessivas tentativas permanece por desenvolver.

Por *QA determinístico* entendem-se verificações automáticas com condições escritas explicitamente em código, como comparar números ou marcadores. A distinção entre QA formal e avaliação linguística humana é documentada em ferramentas como o memoQ #cite("memoq-qa"). Um *LLM local* é, neste estudo, o modelo executado no computador que aloja o backend. A *abordagem híbrida* combina os alertas das regras e do modelo. Chamamos *falso alerta* à identificação de um problema ausente e *revelação* ao fornecimento, na explicação ou pista, de conteúdo suficiente para corrigir parte ou a totalidade do trecho em análise.

== Objetivos e Perguntas de Investigação

O objetivo geral é desenvolver e avaliar um protótipo que apoie a revisão de traduções EN–PT-PT mediante verificações formais e pistas a pedido. Os objetivos pedagógicos orientam o desenho da ferramenta. Os seus efeitos na aprendizagem exigirão avaliação posterior com estudantes.

Os objetivos pedagógicos são apoiar o julgamento avaliativo por meio de pistas (*OP1*), permitir a comparação justificada entre alternativas antes de consultar comentários de referência (*OP2*) e tornar observáveis as ações de revisão (*OP3*). OP1 é concretizado numa primeira versão do feedback. OP2 permanece previsto, e OP3 dispõe de eventos exportáveis, estando pendentes as versões sucessivas e as justificações do aluno.

Os objetivos de engenharia abrangem o editor CAT com memória e glossário (*OE1*), as cinco regras determinísticas (*OE2*), a integração do modelo local e a fusão dos alertas (*OE3*) e a instrumentação com exportação (*OE4*). Os componentes de histórico de versões previstos em OE4 ainda não estão implementados.

A avaliação interna tem dois objetivos. *OA1* consiste em comparar a deteção das regras, do modelo e do híbrido sobre exemplos anotados. *OA2* consiste em apreciar a correção, fundamentação, clareza, utilidade para orientar a revisão e revelação da solução nas explicações e pistas. Estes objetivos correspondem às perguntas seguintes.

- *RQ1 — Deteção comparada.* Que diferenças de precisão, recall e F1 existem entre regras determinísticas, modelo local isolado e abordagem híbrida na deteção de problemas de tradução vazia, preservação de valores numéricos e cumprimento do glossário, face a anotações de referência definidas pelos autores num conjunto EN–PT-PT?
- *RQ2 — Qualidade do feedback.* Como são apreciadas internamente as explicações e pistas do modelo e do híbrido quanto à correção, fundamentação, clareza e utilidade, e com que frequência revelam a solução?

RQ1 avalia a deteção produzida por OE2 e OE3. RQ2 aprecia o feedback associado a OP1 e OE3. OE1, OE4 e as partes implementadas de OP3 são sujeitos a verificação funcional. A comparação crítica prevista em OP2 constitui uma extensão do protótipo. A avaliação interna incide sobre os exemplos e o feedback, sem medir ganhos de aprendizagem ou autonomia.

= Estado da Arte

== Critérios da Revisão Documental

Realizou-se uma revisão documental orientada ao desenho do protótipo, com sete sistemas selecionados por representarem CAT profissionais, alternativas abertas, plataformas educativas ou avaliação de tradução. Consultaram-se documentação oficial, repositórios e artigos científicos. A análise considera acesso ao código, QA por regras, feedback por LLM, instrumentação e enquadramento educativo.

A seleção procura referências funcionais e pedagógicas relevantes e não constitui uma revisão sistemática da literatura. As características resultam das fontes citadas. Para as ferramentas externas, a análise é documental, sem comparação de desempenho por execução independente. A indicação «ND» na tabela significa que a característica não foi documentada nas fontes analisadas. Os conteúdos online podem evoluir, pelo que se registam datas de consulta nas referências.

== Ferramentas de Apoio à Tradução

*Trados Studio* reúne memórias, terminologia e QA #cite("rws-studio", "rws-qa"). O Smart Review usa um LLM para classificar segmentos, explicar a avaliação e sugerir intervenções, incluindo equivalentes para termos incorretos #cite("rws-smart"). É uma referência para revisão assistida por IA, com um grau de explicitação que pode fornecer a correção de um exercício.

*memoQ* combina recursos CAT, verificações formais automáticas e avaliação linguística humana configurável #cite("memoq-pro", "memoq-qa", "memoq-lqa"). O histórico e a comparação de versões apoiam a inspeção das alterações #cite("memoq-history"). O programa universitário documenta a utilização educativa de uma plataforma comercial #cite("memoq-university").

*OmegaT* é uma alternativa aberta para desktop com memórias TMX, glossários e verificações através de _Check Issues_, incluindo etiquetas, terminologia e integração com LanguageTool #cite("omegat", "omegat-manual"). Oferece uma referência de núcleo CAT inspecionável.

*Open TLC* disponibiliza um CAT web sob MPL-2.0 para tradutores, docentes e estudantes. Usa IndexedDB para guardar os projetos no navegador e inclui memórias e glossários #cite("opentlc"). O seu desenho mostra a viabilidade de um ambiente CAT web com persistência local.

*postedit.me* centra-se na formação em pós-edição e na avaliação dos textos produzidos por estudantes #cite("lefer2024"). O artigo descreve anotações de erros, análise das intervenções e tipologias TAS e MTPEAS, com disponibilização gratuita às universidades para ensino e investigação interna, mediante um acordo de licença.

*MATEO* fornece uma interface web para avaliar tradução automática com métricas como BLEU, chrF, TER e COMET #cite("vanroy2023"). Apoia a comparação de sistemas e a literacia avaliativa. As pontuações agregadas constituem um recurso distinto da orientação localizada que uma pista procura fornecer ao aluno.

*LoopCAT* apresenta um ambiente CAT aberto sob Apache-2.0, com armazenamento local, memórias, terminologia, QA e histórico por segmento #cite("loopcat2026", "loopcat-repo"). A documentação inclui revisão por IA e ligações opcionais a modelos locais ou externos #cite("loopcat-repo"). A proposta educativa abrange operação, avaliação e intervenção na ferramenta. A pré-publicação distingue as capacidades implementadas dos benefícios pedagógicos por estudar.

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

O conceito de scaffolding #cite("wood1976") fundamenta o apoio que preserva uma parte da resolução para o aluno. Em tradução, a tipologia MQM (_Multidimensional Quality Metrics_) organiza categorias de problemas como exatidão, terminologia, convenções linguísticas e estilo #cite("mqm"). A seleção de categorias deste protótipo é operacional e inspirada nesse enquadramento. O sistema ainda não implementa um modelo completo de avaliação MQM com severidades e ponderações.

O GEMBA-MQM usa GPT-4 para localizar possíveis erros sem exigir tradução humana de referência e discute a dependência de um modelo proprietário #cite("kocmi2023"). #citet("qian2026") estudam GPT5 como parceiro de revisão com prompts inspirados em MQM e documentam tanto aproximação a juízos humanos como avaliações incorretas. Estes estudos sustentam a relevância de apreciar o conteúdo do feedback para além de contar alertas. O desempenho observado nesses modelos exige verificação própria quando se passa para um modelo local de menor dimensão.

O estudo de #citet("dogru2026") examina justificações em tarefas de comparação e pós-edição. O Translog-II #cite("carl2012") fornece uma referência de registo da atividade de escrita e tradução para investigação empírica. No presente protótipo, a instrumentação limita-se a eventos discretos, como guardar ou pedir uma pista. A captura contínua de edições e a reconstrução do raciocínio exigiriam dados adicionais.

A @tab-ferramentas mostra componentes que já existem em diferentes ferramentas. O recorte deste projeto é a articulação de regras explícitas, pistas do modelo com controlo de possível revelação e exportação do processo numa aplicação EN–PT-PT inspecionável. A comparação documental permite justificar estas escolhas e situar referências próximas, em particular LoopCAT. A contribuição é avaliada no protótipo desenvolvido e não depende de afirmar exclusividade funcional relativamente a todos os sistemas existentes.

= Arquitetura e Implementação

== Componentes e Percurso de Utilização

A aplicação organiza-se em três níveis. O *nível 1* contém o editor segmentado, o glossário, a persistência e a memória de tradução. O *nível 2* executa verificações determinísticas. O *nível 3* consulta o modelo local e funde o feedback. Uma camada transversal recebe eventos e permite exportá-los. A interface foi desenvolvida em React 19, TypeScript e Vite, e o backend usa FastAPI, Pydantic e SQLAlchemy sobre SQLite.

O aluno carrega o original, fornece opcionalmente contexto e glossário e escreve a tradução de cada segmento. «Guardar» persiste o texto. «Verificar» invoca as regras, e «Pedir pista» combina as regras com o modelo sobre o texto atual, incluindo alterações ainda por guardar. As duas operações de revisão usam o mesmo motor determinístico. O contexto é enviado apenas ao modelo.

O backend conserva funções separadas para regras, pesquisa de memória, adaptação ao Ollama e fusão. Esta organização permite executar verificações sem a interface e substituir a rede por respostas simuladas nos testes. A configuração estudada usa Ollama em _localhost_ e o modelo `qwen3:4b-instruct-2507-q4_K_M`, com cerca de quatro mil milhões de parâmetros e quantização Q4_K_M #cite("qwen-ollama"). O endereço e o modelo são configuráveis. As observações deste artigo dizem respeito às execuções locais descritas.

== Editor e Persistência

O editor aceita texto escrito ou colado, um ficheiro `.txt` até 200 KiB ou exemplos incorporados. Cada linha não vazia corresponde a um segmento, até 200 por exercício. A configuração e a posição são recuperáveis através de `localStorage`, enquanto a tradução atual é lida e guardada pela API no SQLite. O glossário é definido por exercício, admite vários equivalentes aceites e é validado antes de iniciar a tarefa.

A tabela `segments` guarda o identificador, a tradução atual e a data de atualização. A interface espera pela leitura antes de permitir editar e bloqueia a edição durante uma gravação. A navegação após alterações depende da confirmação da escrita. Um contador impede que resultados de verificação anteriores a uma nova edição substituam o feedback atual. Os pedidos de leitura, gravação e verificação têm um prazo de 10 segundos no cliente. Uma falha mantém o texto no editor, embora o fim da espera no cliente não prove que o servidor cancelou a operação.

O identificador atual deriva de um hash FNV-1a de 32 bits do original após remover espaços nas extremidades. Textos iguais partilham a tradução e podem existir colisões entre textos distintos. A persistência não separa exercícios ou utilizadores, e o controlo das operações aplica-se a uma instância do editor. A identidade por ocorrência e a resolução de escritas concorrentes permanecem por implementar.

== Cinco Verificações Determinísticas

O endpoint `POST /api/check` recebe original, tradução e glossário e devolve alertas com categoria, explicação e pista. As verificações são implementadas em Python com expressões regulares, aritmética decimal e contagem de ocorrências.

1. *Tradução vazia.* A ausência de conteúdo depois de retirar espaços gera `empty_translation` e termina a verificação do segmento, evitando alertas derivados da falta de uma tradução.
2. *Números.* A regra `numeric_mismatch` identifica valores do original que faltam ou ocorrem menos vezes na tradução. Usa `Decimal`, normaliza separadores en-US no original e PT-PT na tradução e conserva sinais e repetições. Assim, `1,000.50` e `1 000,50` são equivalentes. Unidades, datas e intervalos não são interpretados: apenas se comparam os valores que contêm. Um número do original escrito por extenso na tradução é assinalado como valor em falta.
3. *Terminologia.* A regra `terminology` exige pelo menos um equivalente aceite quando o termo do glossário aparece como palavra ou expressão completa no original. Ignora maiúsculas e minúsculas. Flexões têm de constar das variantes prescritas.
4. *Marcadores.* A regra `placeholder_mismatch` compara nomes e contagens de marcadores como `{name}`. Permite reorganizar a frase preservando os tokens. Formatos como `{{name}}`, `{0}` e `%s` ficam fora do padrão suportado.
5. *Etiquetas.* A regra `inline_tag_mismatch` compara as contagens de etiquetas simples `b`, `i`, `em`, `strong` e `u`, sem atributos. Deteta tokens ausentes ou adicionais. A ordem e o aninhamento exigiriam uma análise estrutural adicional.

As duas verificações técnicas seguem o princípio de preservação formal documentado em ferramentas CAT #cite("memoq-qa"). As mensagens dirigem o aluno para a comparação dos elementos. A ausência de alertas indica apenas que os critérios implementados foram satisfeitos naquele segmento.

== Memória de Tradução

Uma gravação confirmada de tradução com conteúdo é seguida de uma tentativa de guardar o par original–tradução na tabela `memory_entries`. Uma restrição de unicidade evita pares idênticos. Esta operação é separada da gravação do segmento, permitindo continuar a tarefa mesmo se a atualização da memória falhar.

Ao abrir um segmento, `POST /api/memory/search` compara o seu original com os originais da memória. O código normaliza maiúsculas e espaços e aplica `fuzz.ratio`, que calcula similaridade Indel normalizada #cite("rapidfuzz-ratio"). Devolve até três pares com pontuação arredondada de pelo menos 70 numa escala de 0 a 100. A sugestão preenche o campo apenas depois de o aluno selecionar «Usar».

Por exemplo, `The total is €1,000.50 today.` recupera o par de `The total is €1,000.50.` com pontuação 88. A tradução anterior ainda exige adaptação a _today_. A semelhança caracteriza os originais e pode permanecer elevada perante alterações numéricas importantes. O limiar é uma escolha inicial de implementação, ainda por calibrar. A memória atual é partilhada pela instância local e pode conter várias traduções do mesmo original.

== Pistas do Modelo e Fusão Híbrida

O endpoint `POST /api/hint` executa as regras e, se a tradução contiver texto, consulta o modelo. O adaptador envia o original, a tradução atual, o contexto e o glossário, sem histórico de conversa ou de tentativas do aluno. O prompt versionado `hint-v3.txt` apresenta esses conteúdos como dados e pede uma explicação e uma pergunta de revisão em PT-PT.

O modelo pode emitir `empty_translation`, `numeric_mismatch`, `terminology` e `meaning_context`. Esta última categoria abrange alterações de significado ou intenção, incluindo negação, falsos cognatos, expressões idiomáticas e força de instruções. As categorias de marcadores e etiquetas são exclusivas das regras. O prompt pede que se aceitem paráfrases válidas e que se evitem interpretações especulativas quando falta contexto. O treino e os pesos do Qwen permanecem os do modelo distribuído. O trabalho realizado modifica as instruções de inferência e o tratamento da saída.

A geração usa temperatura 0, semente 42, contexto de 4096 tokens e limite de 768 tokens de saída. Solicita-se um esquema JSON com uma lista de alertas, cada um com `category`, `explanation` e `hint`. O adaptador valida estrutura, categorias e campos textuais preenchidos. Uma resposta estruturalmente válida pode ainda conter um falso alerta, uma categoria semanticamente inadequada ou uma correção explícita.

A fusão conserva os alertas das regras e acrescenta, no máximo, uma sugestão do modelo por categoria ainda não presente. A origem é mostrada como «Regra» ou «Sugestão do modelo local». Nos alertas do modelo retidos, um filtro procura determinados tipos de aspas, equivalentes do glossário e dígitos do original em alertas numéricos. Quando deteta um sinal, substitui explicação e pista por mensagens genéricas da categoria e incrementa `sanitized`. Esta heurística pode generalizar texto útil e deixar passar correções por extenso.

Perante indisponibilidade, timeout ou resposta inválida reconhecidos pelo adaptador, a API devolve o feedback determinístico e o estado do modelo. O prazo HTTPX predefinido é de 30 segundos por operação de rede. O cliente da interface espera até 40 segundos pelo pedido de pista. Uma nova edição invalida o resultado anterior no ecrã.

== Instrumentação e Dados Guardados

A tabela `events` regista início de exercício, gravação, verificação, pedido e apresentação de pistas e utilização da memória. O editor envia um identificador persistente do navegador, o segmento quando aplicável e metadados como contagens por origem, latência e generalizações. A interface omite o texto das traduções e pistas nesses eventos. Os textos traduzidos permanecem nas tabelas de segmentos e memória. A API de eventos aceita um campo adicional genérico, truncado acima de 2000 caracteres, pelo que a ausência de texto nos registos depende do cliente e não é garantida pelo servidor.

As exportações JSON e CSV contêm os eventos da instância e ficam acessíveis no rodapé. O resumo agrega contagens. Uma falha no envio de eventos permite continuar o exercício, podendo deixar lacunas nos registos. A análise textual da RQ2 usa relatórios de recolha próprios com as explicações e pistas.

A configuração atual destina-se à execução local. A API tem CORS permissivo e os endpoints, incluindo exportação, estão disponíveis sem autenticação. O isolamento por utilizador, o controlo de acesso e uma política de conservação de dados exigem trabalho adicional antes de uma utilização partilhada.

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
