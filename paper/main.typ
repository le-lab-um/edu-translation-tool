#import "@preview/tracl:0.8.1": *
#import "@preview/pergamon:0.7.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set text(lang: "en", region: "US")
#set page(footer: context align(center)[#text(size: 9pt)[#counter(page).display("1")]])

#show: doc => acl(
  doc,
  anonymous: false,
  title: [
    Educational Translation Tool
  ],
  authors: make-authors(
    (
      name: "Diogo Pinto (PG61515) and Mariana Pinto (PG61534)",
      affiliation: [
        University of Minho\
        MSc in Informatics Engineering
      ],
    ),
  ),
)

// Colors shared by the architecture diagrams (one per level of the application).
#let c-l1 = rgb("#dbeafe")  // level 1: CAT core
#let c-l2 = rgb("#dcfce7")  // level 2: deterministic checks
#let c-l3 = rgb("#ffedd5")  // level 3: local model and merging
#let c-x = rgb("#f1f5f9")   // cross-cutting instrumentation
#let c-ext = rgb("#ede9fe") // storage and external services
#let diamond = fletcher.shapes.diamond

// Only peer-reviewed papers and preprints go in the bibliography.
// Official documentation, product pages and repositories are given as footnotes.
#let referencias = ```bib
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
  howpublished = {arXiv preprint arXiv:2609.00344},
  url = {https://arxiv.org/abs/2609.00344v1},
  note = {Version 1}
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
```

#add-bib-resource(referencias.text)

#abstract[
We present the Educational Translation Tool, an educational web application for practicing translation from English into European Portuguese. The prototype combines a segmented editor with persistence, version history, student justifications and translation memory, five deterministic checks and on-demand hints generated by a Qwen model run locally through Ollama. The feedback design, which aims to keep revision in the student's hands, is grounded in a document-based review of seven tools; when rule and model issues are merged, each keeps its origin, and a heuristic filter limits possible solution disclosure. Functional verification comprised 119 automated tests. Exploratory runs with the real model revealed useful detections, false alarms and hints that give away the correction, and informed a revised prompt. On 40 held-out cases, the rules detected every problem in their scope, the model alone missed all glossary violations, and the hybrid approach reached an F1 of 95.2% in the main scope. The revised prompt barely changed detection but reduced the hints that disclose the correction from 15 of 20 to 1 of 19. The pedagogical effectiveness of the tool with students remains a question for future research.
]

= Introduction

Computer-assisted translation (CAT) tools such as Trados Studio, memoQ and OmegaT organize work around segmented editing, translation memories and terminology resources.#footnote[Trados Studio: #link("https://www.trados.com/product/studio/")\; memoQ translator pro: #link("https://www.memoq.com/product/memoq-translator-pro/")\; OmegaT: #link("https://omegat.org/"). All URLs in this paper were accessed on 22 November 2026.] <fn-cat> In translator education, the use of these resources goes hand in hand with the need to develop the ability to assess proposals and justify choices. The exploratory study by #citet("dogru2026") illustrates this dimension by showing how comparison and post-editing tasks can make students' evaluative judgement observable.

The feedback produced by a tool, however, shapes the revision work that remains the student's responsibility. When the system points to an equivalent or rewrites the translation, it may immediately resolve the passage in question; a hint, in contrast, can guide the comparison between source and translation while leaving the reformulation to the student. The challenge is therefore to produce information specific enough to support revision while controlling how much of the answer is disclosed.

The Educational Translation Tool explores this balance for short texts translated from English into European Portuguese (EN–PT-PT), through a workflow in which the student writes the translation, uses CAT resources, runs explicit checks and requests hints from a local model. Our contribution combines an inspectable implementation,#footnote[Source code, case sets, prompts, collection reports and annotation sheets: #link("https://github.com/le-lab-um/edu-translation-tool").] <fn-repo> the identification of the origin of each issue and a protocol that evaluates problem detection and feedback quality separately.

This paper characterizes the prototype, describes the evaluation protocol and reports an internal evaluation on 40 held-out cases, which compares rules, model and hybrid approach and two versions of the prompt.

== Concepts and Scope

In the editor, a *segment* is the unit of work and corresponds to a non-empty line of the source text together with the translation written by the student. Translation support is complemented by a *glossary*, which defines the accepted equivalents in an exercise, and by a *translation memory*, which retrieves previously saved source–target pairs based on the similarity between source texts.

The design of the *pedagogical hints* draws on the concept of _scaffolding_, understood as the tutor's support for the learner's resolution of a task #cite("wood1976"). In this project, hints are requested by the student and aim to locate a problem and prompt the revision of the translation. Each issue contains an explanation and a hint; when generated by the model, it takes into account the source, the current translation, the context and the glossary, without relying on a student profile or on the history of previous attempts.

*Deterministic QA* checks correspond to conditions written explicitly in code, such as comparing numbers or placeholders. This formal dimension is distinct from human linguistic assessment, as documented in tools such as memoQ,#footnote[memoQ, _Quality Assurance (QA) warnings_, online manual v12.5: #link("https://docs.memoq.com/12-5/en/Concepts/concepts-quality-assurance-qa-warnings.html").] <fn-memoq-qa> and is complemented by the *local LLM*, which runs on the computer that hosts the backend. The *hybrid approach* combines the issues raised by the rules and by the model while preserving the origin of each one. To assess its behavior, we define a *false alarm* as the identification of a problem that is not present, and *disclosure* as the provision, in the explanation or in the hint, of enough content to correct part or all of the passage under analysis.

== Objectives and Research Questions

Our overall objective is to develop and evaluate a prototype that supports the revision of EN–PT-PT translations through formal checks and on-demand hints. The pedagogical objectives guide the design of the tool, whereas the internal evaluation addresses its operation and the feedback it produces. Assessing the effects on learning will require a subsequent study with students.

The pedagogical objectives are to support evaluative judgement through hints (*PO1*) and to make revision actions observable by logging them so that they can be inspected (*PO2*). PO1 is expressed in the explanations and hints shown to the student and in the justification the student can write for each translation. PO2 is supported by the version history of each segment and by the usage events, which are collected and exportable. We plan to organize these events into a simple chronological history in which the actions performed during the exercise can be reviewed.

The engineering objectives cover the CAT editor with memory and glossary (*EO1*), the five deterministic rules (*EO2*), the integration of the local model and the merging of issues (*EO3*) and instrumentation with export and a simple action history (*EO4*). For EO4, logging and export are implemented, while chronological viewing of the events is still planned.

The internal evaluation has two complementary objectives: *EV1* compares the detection of the rules, the model and the hybrid approach on annotated examples; *EV2* assesses the correctness, grounding, clarity, usefulness for guiding revision and solution disclosure of the explanations and hints. These objectives translate into the following research questions:

- *RQ1 — Comparative detection.* What differences in precision, recall and F1 exist between deterministic rules, the local model alone and the hybrid approach in detecting empty translations, non-preserved numeric values and glossary non-compliance, against reference annotations defined by the authors on an EN–PT-PT set?
- *RQ2 — Feedback quality.* How are the explanations and hints of the model and of the hybrid approach internally assessed in terms of correctness, grounding, clarity and usefulness, and how often do they disclose the solution?

RQ1 addresses the detection produced by EO2 and EO3, while RQ2 assesses the feedback associated with PO1 and EO3. The features of EO1, EO4 and the implemented components of PO2 are subject to functional verification. The internal evaluation thus characterizes detection and feedback on the examples studied, without measuring learning gains or autonomy.

= Related Work

== Review Criteria

Our document-based review was oriented toward the design of the prototype and covered seven systems, selected because they represent professional CAT tools, open alternatives, educational platforms or translation evaluation tools. Drawing on official documentation, repositories and scientific articles, we analyzed for each system access to the source code, rule-based QA, LLM-based feedback, instrumentation and educational framing.

The selection seeks to gather relevant functional and pedagogical references; it is neither a systematic literature review nor a performance comparison based on running the tools ourselves. The characteristics presented derive from the sources cited, with "ND" used when a characteristic was not documented in the sources analyzed. Peer-reviewed work is listed in the references, while official documentation, product pages and repositories are given in footnotes; since online content may change, all of them were accessed on the same date.

== Translation Support Tools

Among professional CAT tools, *Trados Studio* brings together memories, terminology and QA checks,#footnote[RWS, _eLearning for Trados Studio: Level 2 — QA check and term verifier_: #link("https://www.trados.com/training/eLearning-trados-studio-level-2-qa-checker-and-term-verifier/").] and adds, through Smart Review, the use of an LLM to classify segments, explain the assessment and suggest interventions, including equivalents for incorrect terms.#footnote[RWS, _Learn about Smart Review_: #link("https://www.trados.com/product/features/smart-review/").] It is thus a reference for AI-assisted revision, although the explicitness of its feedback may give away the answer to an exercise.

*memoQ* likewise combines CAT resources with automatic formal checks,#footnote(<fn-memoq-qa>) distinguishing them from configurable human linguistic quality assurance (LQA).#footnote[memoQ, _Linguistic Quality Assurance (LQA) models_, online manual v12.6: #link("https://docs.memoq.com/current/en/Concepts/concepts-linguistic-quality-assurance.html").] History and version comparison support the inspection of changes,#footnote[memoQ, _History and reports_, online manual v12.5: #link("https://docs.memoq.com/12-5/en/Workspace/history-reports.html").] while its university program documents the educational use of a commercial platform.#footnote[memoQ, _University Program_: #link("https://www.memoq.com/services/programs/university-program/").]

As an open desktop alternative, *OmegaT* provides TMX memories, glossaries and checks through _Check Issues_, including tags, terminology and LanguageTool integration.#footnote[OmegaT 6.1.0 User Manual, Chapter 4 (Tools › Check Issues): #link("https://omegat.sourceforge.io/manual-standard/en/chapter.menus.html").] These features offer a reference for an inspectable CAT core. In the web context, *Open TLC* provides a CAT tool under MPL-2.0 for translators, teachers and students, with memories, glossaries and in-browser project persistence through IndexedDB.#footnote[Open Translation Client (Open TLC), official repository and README, branch `main`: #link("https://github.com/KlinsBt/open-translation-client").] Its design shows the feasibility of a web CAT environment with local persistence.

Among tools with an educational focus, *postedit.me* centers on post-editing training and on the assessment of texts produced by students #cite("lefer2024"). The paper describes error annotation, the analysis of interventions and the TAS and MTPEAS typologies; the tool is available free of charge to universities for teaching and internal research under a license agreement.

*MATEO*, in turn, provides a web interface for evaluating machine translation with metrics such as BLEU, chrF, TER and COMET #cite("vanroy2023"). By comparing systems and presenting aggregate scores, it supports evaluation literacy, which is a different kind of support from the localized guidance that a hint seeks to give the student.

*LoopCAT* brings several of these components together in an open CAT environment under Apache-2.0, with local storage, memories, terminology, QA and per-segment history #cite("loopcat2026").#footnote[LoopCAT public repository and README: #link("https://github.com/gokhandogru/LoopCAT"). Reviewed from its documentation only, without running the tool.] <fn-loopcat> Its documentation includes AI review and optional connections to local or external models,#footnote(<fn-loopcat>) and the authors frame the tool within an educational proposal that covers operating, evaluating and intervening in the system. The preprint nevertheless distinguishes the implemented capabilities from the pedagogical benefits that have yet to be studied.

#figure(
  {
    set text(size: 8pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (1fr, 1fr, 1fr, 1fr, 1.3fr, 1.5fr),
      inset: 5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: left + horizon,
      table.header([*System*], [*Open source*], [*Rule-based QA*], [*LLM feedback*], [*Documented logging*], [*Educational framing*]),
      [Trados], [No], [Yes], [Smart Review], [ND], [Professional use],
      [memoQ], [No], [Yes], [ND], [History and versions], [University program],
      [OmegaT], [Yes], [Yes], [ND], [Project data], [ND],
      [Open TLC], [Yes], [ND], [ND], [In-browser projects], [Students and teachers],
      [postedit.me], [No (institutional license)], [ND], [ND], [Edits and annotations], [Post-editing training],
      [MATEO], [Yes], [ND], [ND], [Results and export], [Evaluation literacy],
      [LoopCAT], [Yes], [Yes], [Optional], [Per-segment history], [Translation technology],
    )
  },
  kind: table,
  caption: [Summary of the seven tools based on the sources cited. ND: not documented in the sources reviewed. Saved projects, exported results and revision histories are distinct forms of logging.],
  placement: top,
  scope: "parent",
) <tab-tools>

== Pedagogical Feedback and Positioning

The concept of scaffolding #cite("wood1976") underpins support that leaves part of the resolution to the student. For translation analysis, the MQM (_Multidimensional Quality Metrics_) typology organizes problem categories such as accuracy, terminology, linguistic conventions and style,#footnote[MQM Council, _The MQM Error Typology_: #link("https://www.themqm.org/mqm-pillars/typology/").] providing a framework for the operational selection of categories in this prototype. Issues are presented by category, explanation and hint, without severity levels or an overall quality score.

The use of language models in translation evaluation is illustrated by GEMBA-MQM, which uses GPT-4 to locate likely errors without requiring a human reference translation and discusses the dependence on a proprietary model #cite("kocmi2023"). #citet("qian2026"), in turn, study GPT-5 as a revision partner with MQM-inspired prompts, documenting both agreement with human judgements and incorrect assessments. These works show the importance of assessing the content of the feedback rather than only counting issues; transferring this approach to a smaller local model therefore requires verifying its performance separately.

The study by #citet("dogru2026") examines justifications in comparison and post-editing tasks, while Translog-II #cite("carl2012") provides a reference for logging reading and writing activity for empirical research. In our prototype, instrumentation focuses on discrete events, such as saving a translation, running a check or requesting a hint. Each save that changes a translation or its justification is also kept as a version, so the saved states of a segment can be reviewed, although edits between saves are not recorded. Ordering the events chronologically will form the basis of the planned simple history.

@tab-tools summarizes components that already exist in different systems and helps position our implementation choices, in particular relative to a close reference such as LoopCAT. What this project adds is the combination of explicit rules, model hints with control of possible disclosure and exportable logging of actions in an inspectable EN–PT-PT application. We therefore assess the contribution within the prototype developed, without claiming that this combination is unique among existing systems.

= Architecture and Implementation

== Components and Usage Workflow

The application is organized into three interrelated levels (@fig-architecture): *level 1* comprises the segmented editor, the glossary, persistence and the translation memory; *level 2* runs deterministic checks; and *level 3* queries the local model and merges the feedback. A cross-cutting layer receives usage events and allows them to be exported. The interface was developed with React 19, TypeScript and Vite and communicates with a backend that uses FastAPI, Pydantic and SQLAlchemy on top of SQLite.

@fig-architecture shows how these levels map onto the running system. The student works in the web interface, and each action is handled by a backend service. Level 1 (blue) saves and reloads translations and suggests matches from the translation memory. Level 2 (green) runs the rule checks when the student selects _Verificar_ (Check). Level 3 (orange) produces hints when the student selects _Pedir pista_ (Ask for a hint): the hint service reuses the rule checks and adds a review by a language model. A logging service (gray) records the student's actions across all levels. The database and the model (purple) run on the same computer as the backend, so no text is sent to external services.

#figure(
  {
    set text(size: 7.5pt)
    set par(justify: false, leading: 0.45em)
    diagram(
      spacing: (14mm, 6mm),
      node-stroke: 0.5pt + luma(45%),
      node-corner-radius: 2pt,
      node-inset: 4.5pt,
      edge-stroke: 0.6pt + luma(35%),
      mark-scale: 70%,

      // Student side
      node((0, 2), align(center)[*Web interface* \ (student's browser) \ \ exercise setup: source text, \ context and glossary \ \ segment editor with the \ actions _Save_, _Check_ \ and _Ask for a hint_], width: 36mm, name: <client>),

      // Backend services
      node((1, 0), [*Translation storage* \ saves each segment with its justification \ and keeps its version history], fill: c-l1, width: 52mm, name: <store>),
      node((1, 1), [*Translation memory* \ suggests translations of similar segments], fill: c-l1, width: 52mm, name: <tm>),
      node((1, 2), [*Usage logging* \ records each action; export as JSON or CSV], fill: c-x, width: 52mm, name: <log>),
      node((1, 3), [*Rule checks* \ five deterministic checks (empty translation, \ numbers, glossary, placeholders, tags)], fill: c-l2, width: 52mm, name: <rules>),
      node((1, 4.7), [*Hint service* \ runs the rule checks, asks the local model, \ merges both and filters revealing hints], fill: c-l3, width: 52mm, name: <hint>),

      // Data and model, both on the same computer
      node((2, 1), [*Local database* \ (SQLite) \ translations, versions, \ memory and usage events], fill: c-ext, width: 34mm, name: <db>),
      node((2, 4.7), [*Local language model* \ Qwen3 4B, \ served by Ollama], fill: c-ext, width: 34mm, name: <llm>),

      edge(<client>, (0, 0), <store>, "-|>"),
      edge(<client>, <tm>, "-|>"),
      edge(<client>, <log>, "-|>"),
      edge(<client>, <rules>, "-|>"),
      edge(<client>, (0, 4.7), <hint>, "-|>"),
      edge(<store>, <db>, "-|>"),
      edge(<tm>, <db>, "-|>"),
      edge(<log>, <db>, "-|>"),
      edge(<hint>, <rules>, "-|>", [reuses], label-side: left, label-size: 6.5pt),
      edge(<hint>, <llm>, "<|-|>"),
    )
  },
  caption: [Overview of the architecture.],
  placement: top,
  scope: "parent",
) <fig-architecture>

The workflow starts with loading the source text and optionally providing context and a glossary, after which the student writes the translation of each segment. The _Guardar_ (Save) action persists the text, _Verificar_ (Check) applies the rules, and _Pedir pista_ (Ask for a hint) combines the same rules with the model. Both revision operations act on the current text, including unsaved changes, but only the model receives the context as additional input. Alongside each translation, the student can write an optional justification of their choices, and the editor lists the saved versions of the segment, any of which can be brought back into the editor. @fig-editor shows the editor after a hint request. The exercise context states that restarting is mandatory, but the translation turns the obligation into a permission (_Podes reiniciar_, 'You may restart') and changes the number of updates. The number rule flags the missing value, while the model adds a meaning issue; because the model's original wording revealed the solution, the disclosure filter described in @sec-hints replaced it with the generic message shown.

#figure(
  {
    set text(size: 8pt)
    let shot(path) = box(stroke: 0.4pt + luma(80%), image(path, width: 100%))
    grid(
      columns: (auto, 1fr),
      column-gutter: 6pt,
      row-gutter: 6pt,
      align: (right + top, left),
      [(a)], shot("figures/editor-segment.png"),
      [(b)], shot("figures/editor-hint.png"),
    )
  },
  caption: [The editor after a hint request: (a) source segment and student translation; (b) actions and issues, each labeled with its origin.],
  placement: top,
  scope: "parent",
) <fig-editor>

In the backend, the rules, memory search, Ollama adapter and merging are kept in separate functions. This organization allows the checks to run without the interface and lets tests replace the network with simulated responses. The configuration studied uses Ollama on _localhost_ and the model `qwen3:4b-instruct-2507-q4_K_M`, with about four billion parameters and Q4\_K\_M quantization.#footnote[Ollama model card, _Qwen3: 4b-instruct-2507-q4\_K\_M_: #link("https://ollama.com/library/qwen3:4b-instruct-2507-q4_K_M").] Although the endpoint and the model are configurable, the observations in this paper refer to the local runs described.

== Editor and Persistence

The editor accepts typed or pasted text, `.txt` files up to 200 KiB and built-in examples, splitting the source into non-empty lines that correspond to segments, up to a limit of 200 per exercise. The configuration and the position in the exercise can be restored through `localStorage`, while the current translation is read and saved by the API in SQLite. The glossary is defined per exercise, accepts several equivalents per term and is validated before the task starts.

The `segments` table stores the identifier, the current translation, the student's justification and the update timestamp. The `segment_versions` table keeps the saved states: each save that changes the translation or the justification adds a numbered version, and saving unchanged text adds none. To protect editing, the interface waits for the read to complete before enabling the translation field and locks it while saving, allowing navigation after changes only once the write is confirmed. A request counter also prevents check results that predate a new edit from replacing the current feedback. Read, save and check requests have a 10-second client-side timeout; on failure, the text remains in the editor, although the end of the wait does not prove that the server has cancelled the operation.

Each segment is identified by its occurrence within the exercise. The identifier combines a random exercise identifier, created when the exercise starts, a 32-bit FNV-1a hash of the source after trimming leading and trailing whitespace and the occurrence number of that source in the exercise. Identical lines in the same exercise and the same text in different exercises therefore keep independent translations, and editing other lines of the source keeps the identifiers of the unchanged ones. Choosing an example, loading a file or starting a new exercise creates a new exercise identifier. Exercises started before this scheme keep the earlier identifiers, derived only from the text. Persistence does not separate data by user, and operation control applies to a single editor instance, which limits concurrent use.

== Five Deterministic Checks

The `POST /api/check` endpoint receives the source, the translation and the glossary and returns issues with a category, an explanation and a hint. The five checks are implemented in Python using regular expressions, decimal arithmetic and occurrence counting:

1. *Empty translation.* The absence of content after stripping whitespace raises `empty_translation` and ends the check for the segment, avoiding issues that merely follow from the lack of a translation.
2. *Numbers.* The `numeric_mismatch` rule identifies source values that are missing or occur fewer times in the translation. It uses `Decimal` and normalizes en-US separators in the source and PT-PT separators in the translation, preserving signs and repetitions, so that `1,000.50` and `1 000,50` are treated as equivalent. Units, dates and ranges are not interpreted, and only the values they contain are compared; a source number written out in words in the translation is flagged as a missing value.
3. *Terminology.* When a glossary term appears as a whole word or phrase in the source, the `terminology` rule requires at least one accepted equivalent in the translation. Matching is case-insensitive, but inflected forms must be listed among the prescribed variants.
4. *Placeholders.* The `placeholder_mismatch` rule compares the names and counts of placeholders such as `{name}`, allowing the sentence to be reordered as long as the tokens are preserved. Formats such as `{{name}}`, `{0}` and `%s` fall outside the supported pattern.
5. *Inline tags.* The `inline_tag_mismatch` rule compares the counts of the simple tags `b`, `i`, `em`, `strong` and `u`, without attributes, detecting missing or extra tokens. The comparison is limited to the presence and number of these tokens and does not validate their order or nesting.

The two technical checks follow the principle of formal preservation documented in CAT tools,#footnote(<fn-memoq-qa>) with messages that direct the student to compare the elements. The absence of issues only indicates that the implemented criteria were met for that segment.

== Translation Memory

Once the save of a non-empty translation is confirmed, the application attempts to store the source–target pair in the `memory_entries` table, where a uniqueness constraint prevents duplicate pairs. This operation runs separately from saving the segment, so that the task can continue even when the memory update fails.

When a segment is opened, the `POST /api/memory/search` endpoint compares its source with the sources already stored. To this end, the code normalizes case and whitespace and applies `fuzz.ratio`, which computes the normalized Indel similarity.#footnote[RapidFuzz documentation, _fuzz.ratio_: #link("https://rapidfuzz.github.io/RapidFuzz/Usage/fuzz.html").] The search returns up to three pairs with a rounded score of at least 70 on a 0–100 scale, but the suggested translation only fills the editing field when the student selects _Usar_ (Use).

For example, `The total is €1,000.50 today.` retrieves the pair for `The total is €1,000.50.` with a score of 88, although the earlier translation still has to be adapted to include _today_. The score therefore characterizes the similarity between source texts, which may remain high even when numbers change significantly. The threshold was adopted as an initial setting and has yet to be calibrated experimentally. The memory is shared by the local instance and may contain several translations of the same source.

== Model Hints and Hybrid Merging <sec-hints>

The `POST /api/hint` endpoint first runs the rules and queries the model when the translation contains text (@fig-hint). The adapter sends the source, the current translation, the context and the glossary, without conversation history or the student's previous attempts. These contents are presented as data in a versioned prompt, which requests an explanation and a revision question in European Portuguese. The application used prompt v3 until the evaluation and now uses prompt v4 (@sec-diagnostic).

As @fig-hint shows, the rule checks always run, so their issues reach the student even when the model is not called or fails. The model's issues are then merged with the rule issues, and any model issue that appears to reveal the solution has its explanation and hint replaced with a generic message. A model issue is treated as revealing when it contains quoted text, a glossary equivalent or, for numbers, a value from the source text.

#figure(
  {
    set text(size: 7pt)
    show raw: set text(size: 6.6pt)
    set par(justify: false, leading: 0.45em)
    diagram(
      spacing: (5mm, 5mm),
      node-stroke: 0.5pt + luma(45%),
      node-corner-radius: 2pt,
      node-inset: 3.5pt,
      edge-stroke: 0.6pt + luma(35%),
      mark-scale: 70%,

      node((0, 0), [*Student asks for a hint* \ source, translation, \ context, glossary], width: 40mm, name: <req>),
      node((0, 1), [Run the five deterministic checks], fill: c-l2, width: 40mm, name: <rules>),
      node((0, 2), [Empty \ translation?], shape: diamond, name: <empty>),
      node((1, 2), [Model is \ not called], width: 26mm, name: <skip>),
      node((0, 3), [Local model reviews \ the translation and returns \ a structured answer], fill: c-l3, width: 40mm, name: <llm>),
      node((0, 4), [Valid \ answer?], shape: diamond, name: <valid>),
      node((1, 4), [No model issues \ (model off, \ unavailable or \ invalid answer)], width: 26mm, name: <fail>),
      node((0, 5), [*Merge*: keep all rule issues; \ add at most one model issue \ per category not yet present], fill: c-l3, width: 40mm, name: <merge>),
      node((0, 6), [Reveals the \ solution?], shape: diamond, name: <signal>),
      node((1, 6), [Replace with a \ generic explanation \ and hint], width: 26mm, name: <generic>),
      node((0, 7), [*Issues shown to the student*, \ each labeled _Rule_ or \ _Local model suggestion_], width: 40mm, name: <resp>),

      edge(<req>, <rules>, "-|>"),
      edge(<rules>, <empty>, "-|>"),
      edge(<empty>, <skip>, "-|>", [yes], label-size: 6pt),
      edge(<empty>, <llm>, "-|>", [no], label-size: 6pt),
      edge(<skip>, <fail>, "-|>"),
      edge(<llm>, <valid>, "-|>"),
      edge(<valid>, <fail>, "-|>", [no], label-size: 6pt),
      edge(<valid>, <merge>, "-|>", [yes], label-size: 6pt),
      edge(<fail>, <merge>, "-|>"),
      edge(<merge>, <signal>, "-|>"),
      edge(<signal>, <generic>, "-|>", [yes], label-size: 6pt),
      edge(<signal>, <resp>, "-|>", [no], label-size: 6pt),
      edge(<generic>, <resp>, "-|>"),
    )
  },
  caption: [Processing of a hint request.],
  placement: top,
) <fig-hint>

The model may emit the categories `empty_translation`, `numeric_mismatch`, `terminology` and `meaning_context`, while placeholders and tags are reserved for the rules. The `meaning_context` category covers changes in meaning or intent, including negation, false friends, idioms and the force of instructions. To guide this analysis, the prompt asks the model to accept valid paraphrases and to avoid speculative interpretations when context is missing. Our work focuses on the inference instructions and output handling, using the model's weights as distributed, without fine-tuning.

Generation uses temperature 0, seed 42, a 4096-token context and a limit of 768 output tokens. A JSON schema is requested with a list of issues, each with `category`, `explanation` and `hint`, and the adapter validates the structure, the categories and that the text fields are filled in. This validation guarantees the data contract, but a structurally valid response may still contain a false alarm, a semantically inappropriate category or an explicit correction.

The merge keeps the rule issues and adds at most one model suggestion per category not yet present, labeling each origin as _Regra_ (Rule) or _Sugestão do modelo local_ (Local model suggestion). In the retained model issues, a filter looks for certain types of quotation marks, glossary equivalents and, in numeric issues, digits from the source. When it finds one of these signals, it replaces the explanation and the hint with a generic message for the category and increments the `sanitized` counter; we refer to such issues as _generalized_. Because it depends on these patterns, the heuristic may both generalize useful text and let through corrections written out in words.

When the adapter recognizes unavailability, a timeout or an invalid response, the API returns the deterministic feedback and the model status, so that the rule-based checks remain available. The default HTTPX timeout is 30 seconds per network operation, while the interface client waits up to 40 seconds for the hint request. A new edit invalidates the previous result on screen, preserving the association between the feedback and the revised text.

== Instrumentation and Stored Data

The `events` table records when an exercise starts, when a translation is saved or checked, when a hint is requested or displayed, when the memory is used and when an earlier version is brought back. For each event, the editor sends a persistent browser identifier, the segment when applicable and metadata such as counts by origin, latency and the number of generalized issues. The interface omits the text of translations and hints from these events, although translated texts and justifications remain in the segment, version and memory tables. The events API also accepts a generic additional field, truncated above 2000 characters, so the absence of text in the logs depends on the client and is not guaranteed by the server.

The instance's events can be exported as JSON and CSV through links in the footer, and a summary provides aggregate counts. We plan to present them chronologically in a simple action history, built from the logs already collected, so that the usage path is easier to inspect. This extension focuses on logged actions, whereas the textual analysis for RQ2 relies on dedicated collection reports containing the explanations and hints. The exercise can continue even when sending an event fails, so the logs may contain gaps.

The current configuration is intended for local execution, with permissive CORS and endpoints available without authentication, including the export endpoints. These conditions limit shared use, which will require per-user isolation, access control and a data retention policy.

= Evaluation Protocol

We, the two authors, conducted the evaluation internally. RQ1 addresses detection per category and RQ2 the quality of the feedback produced. We fixed the test set, the reference annotations and the experimental configuration before the final run.

@fig-evaluation summarizes this design. A single model generation per case feeds both the LLM-only and the hybrid conditions, so that differences between them reflect the merge and the filter rather than variation between generations. Detection by the three methods is scored against the reference annotation (RQ1), and the explanations and hints of the model and of the hybrid approach are assessed with the grid (RQ2).

#figure(
  {
    set text(size: 7pt)
    show raw: set text(size: 6.6pt)
    set par(justify: false, leading: 0.45em)
    diagram(
      spacing: (5mm, 5mm),
      node-stroke: 0.5pt + luma(45%),
      node-corner-radius: 2pt,
      node-inset: 3.5pt,
      edge-stroke: 0.6pt + luma(35%),
      mark-scale: 70%,

      node((1, 0), [*Held-out* \ *test case*], width: 22mm, name: <case>),
      node((2, 1), [One Qwen \ generation \ per case], fill: c-l3, width: 22mm, name: <gen>),
      node((0, 2), [*Rules*], fill: c-l2, width: 22mm, name: <rules>),
      node((1, 2), [*Hybrid* \ merge + filter], fill: c-l3, width: 22mm, name: <hyb>),
      node((2, 2), [*LLM-only* \ validated, \ before merge], fill: c-l3, width: 22mm, name: <llm>),
      node((0, 3), [*Reference* \ annotation, \ fixed before \ outputs], width: 22mm, name: <ref>),
      node((1, 3), [*RQ1* \ precision, \ recall, F1], fill: c-x, width: 22mm, name: <rq1>),
      node((2, 3), [*RQ2* grid \ correctness, \ grounding, \ clarity, \ usefulness, \ disclosure], fill: c-x, width: 22mm, name: <rq2>),

      edge(<case>, <rules>, "-|>"),
      edge(<case>, <gen>, "-|>"),
      edge(<rules>, <hyb>, "-|>"),
      edge(<gen>, <hyb>, "-|>"),
      edge(<gen>, <llm>, "-|>"),
      edge(<rules>, <rq1>, "-|>"),
      edge(<hyb>, <rq1>, "-|>"),
      edge(<llm>, <rq1>, "-|>"),
      edge(<ref>, <rq1>, "-|>"),
      edge(<hyb>, <rq2>, "-|>"),
      edge(<llm>, <rq2>, "-|>"),
    )
  },
  caption: [Evaluation design.],
  placement: top,
) <fig-evaluation>

== Data and Reference Annotation <sec-data>

We prepared short source texts, with context and glossary where relevant, along with acceptable translations and variants containing problems. Each case has an identifier, a source group, input data and annotations of the presence or absence of a problem, its category, its scope for the analysis and its evidence. The reference admits legitimate alternatives and distinguishes glossary compliance from stylistic preferences. All cases are synthetic; no translations were collected from students. Both authors, who prepared and annotated the cases, are native speakers of European Portuguese and fluent in English.

We split the data by source, keeping related variants in the same set. Examples from the pilot, calibration, diagnostic analysis, prompts and demonstrations are reserved for development, and an automated check confirms that no test source appears in those files or in the prompts. The test set contains 40 cases from 21 sources. The main RQ1 scope has 18 cases: 8 acceptable translations and 10 with problems (2 empty translations, 4 changed numeric values and 4 glossary violations). A further 12 cases (6 acceptable) target meaning and context, and 10 cases (5 acceptable) form the robustness scope.

The two authors reviewed the reference annotations and fixed them by consensus, based on the source, the translation, the context and the glossary of each case. This review took place before any output of the methods on the test set was collected, and it left the proposed reference unchanged. Once the responses were collected, we assessed the explanations and hints. Because the authors both build and evaluate the system, the independence of the judgements is limited.

== Detection Comparison — RQ1

We ran three methods. *Rules* applies only the deterministic engine. *LLM-only* uses the model's validated issues before merging and filtering. *Hybrid* applies the application's policy to the rules and to the same model response. A single generation per non-empty case and configuration feeds the latter two methods, so that differences between generations are not confused with the effect of merging. For empty translations, the hybrid condition returns only the deterministic issue, while the experimental generation is used only in the LLM-only condition.

The main RQ1 analysis covers empty translations, the preservation of source numeric values written as digits and glossary compliance. It includes acceptable controls and variants with problems in these categories. We fixed the inclusion criteria, the scope assigned to each case and the reference annotations before examining the methods' responses. The reference was determined by analyzing the texts and the exercise criteria, without using the outputs of the rules as ground truth.

We examine differences in scope in a complementary robustness analysis, with unit swaps, numbers added only in the translation, times, ranges and values written out in words. For these cases, we report the issues raised by each method against the human annotation, identifying false alarms and omissions with respect to the phenomena studied. For example, an acceptable translation of a numeral as a number written in words may trigger a false alarm from the rule. We report the number of cases included in each analysis, and no case was excluded based on the observed result.

Placeholders and tags are covered by functional verification. Meaning and context issues are presented separately and included in RQ2. The aggregates of the main analysis and those of the robustness analysis are reported separately, preserving the distinction between their scopes.

The main analysis addresses phenomena explicitly covered by the rules, whose implementation is evaluated against the annotated reference, allowing for detection errors and false alarms. On the same sample, with the same categories and annotations, the merge keeps all rule issues. Under these conditions, the recall of the hybrid approach is equal to or higher than that of the rules, while its precision and F1 depend on the true and false positives added by the model.

In the evaluation of the model alone, an experimental call is also made for empty translations. This procedure differs from the operational behavior of the application, which directly returns the deterministic issue. The experimental collector also calls the model for these translations and records the result before merging, whereas, in the hybrid condition, the report keeps only the rule issue.

The counting unit is the case–category pair, with repeated categories reduced to a single occurrence. A true positive (TP) is an expected category that is emitted; a false positive (FP) is a category that is emitted but absent from the reference; a false negative (FN) is an expected category that is omitted. A wrong category may produce both an FP and an FN.

#block(breakable: false)[
The detection metrics are defined as

$ "Precision" = "TP" / ("TP" + "FP") $

$ "Recall" = "TP" / ("TP" + "FN") $

$ "F1" = (2 "TP") / (2 "TP" + "FP" + "FN") $
]

Results are reported per category and micro-averaged, with numerators and denominators, and metrics are reported as undefined when the denominator is zero. Acceptable cases with at least one false alarm are also counted.

Model failures are reported by status and number of attempts, and the detection comparison uses the same subset of valid calls for the three methods. In the final run every call returned a valid response, so no case was excluded.

== Feedback Assessment — RQ2

The grid applies to each explanation–hint pair. *Correctness* indicates whether it identifies a real discrepancy. *Grounding* assesses its support in the source, translation, context and glossary. *Clarity* assesses how understandable the message is. *Usefulness* indicates whether it guides the student toward a concrete comparison that can support revision. For these criteria, the values defined in the grid are recorded, including "partial" where applicable and "uncertain" with a justification.

*Disclosure* has three levels. "None" corresponds to guidance that leaves the reformulation to the student. "Partial" indicates that an equivalent, value or interpretation is provided that solves part of the problem. "Full" corresponds to a correction sufficient to replace the passage in question, even if the passage is a single word. This assessment covers both the explanation and the hint, because both are visible to the student.

We prepared an initial proposal of the judgements from the shuffled sheet, without access to the key, and then reviewed it row by row, deciding by consensus and recording the changes in the version history. The annotation rows of both prompt versions are shuffled together, with the version kept in a separate key. This blinding reduces cues about the experimental condition, but the generic wording may still allow it to be recognized. The procedure does not include independent double annotation and does not allow inter-annotator agreement to be computed.

We distinguish original model issues, issues retained unchanged, generalized issues and model issues discarded because of rule priority. Texts that are identical before and after merging are annotated once and linked to both conditions through the key. Deterministic issues are identified separately, and cases without issues are counted separately, so that no textual quality values are assigned to them.

We report the feedback in two views: the issues returned by the model and the issues shown to the student by the hybrid approach, after merging and filtering. The disclosure rate uses the number of texts assessed as the denominator, reporting partial and full disclosures separately along with the number of uncertain cases. The `sanitized` counter describes filter interventions; human classification determines the observed disclosure.

== Prompt Refinement and Comparative Evaluation

We refined the feedback in two phases. The first was a diagnostic analysis of the initial configuration, with prompt v3, on development examples. Assessing the responses with the RQ2 grid revealed patterns of false alarms, omissions, inadequate explanations and solution disclosure (@sec-diagnostic). This analysis informed the revision of the generation instructions; the filter was not changed.

The second phase was the comparative evaluation of the configurations. The revised prompt, called v4, was fixed after the diagnostic analysis and its hash recorded. Both configurations were then run, one after the other, on the same test set, whose sources were excluded from the development, demonstration and calibration phases. Examples whose responses were examined to guide changes were kept in the development set.

When comparing the effect of the prompt, we kept the model, the generation parameters and the filter constant. Prompt revisions act only on the inference instructions; the model's weights remain as distributed.

== Reproducibility Conditions

The collection reports record the hashes of the data and of the prompt, the model identifier and digest, the Ollama version, the generation parameters, the network timeout and the operating system, as well as the status and duration of each call to the model. They also record the code revision and whether there were uncommitted changes, the Python and dependency versions, the status and duration of the warm-up and the full Ollama response, including load, prompt-evaluation and generation times and token counts, as provided by the service. The final runs were made on a MacBook Air with an Apple M4 chip (10 cores) and 16 GB of memory, running macOS 15.5 and Ollama 0.14.3. Reference annotations are used only to compute results and in the subsequent assessment, and are excluded from the requests sent to the model. The case sets, prompts, collection reports, annotation sheets and the scripts that compute the results are available in the project repository.#footnote(<fn-repo>)

The collector measures the time elapsed between the start of the review by the Ollama client and its return or failure. This interval covers the request to the service, the reception of the response and the validation performed by the adapter. Rules and merging run outside this measurement and without the FastAPI server, so the latency of the hybrid endpoint is not measured. Collections prior to this version of the collector did not record a warm-up procedure. The current collector makes a warm-up call before the first case, with a fixed example that does not belong to any case set, and records its status and duration separately, so it does not count toward case timings. Temperature 0 and a fixed seed control the generation parameters, although reproduction also depends on the execution environment.

= Results and Discussion

We first report the evidence gathered during development: functional verification, a feasibility pilot, the calibration of the grid and the diagnostic analysis that led to prompt v4. These examples influenced development and are excluded from the test. We then answer RQ1 and RQ2 on the test set.

== Functional Verification

A total of 119 tests were run, 86 for the backend and 33 for the frontend, together with the production build of the interface. The tests cover rules, API contracts, persistence, version history and justifications with in-memory SQLite, segment identity, fuzzy search, logging and export, response validation, merging, simulated network failures and the scripts that compute the evaluation results. Automated integration with Ollama uses `httpx.MockTransport`.

These controls verify software behavior and data contracts. The linguistic adequacy of the hints requires an assessment of the real model, as planned in the protocol.

== Feasibility Pilot with Prompts v1 and v2

The 23 October pilot used ten synthetic development cases, derived from six sources and built for the development of the prototype. The cases include acceptable translations and variants designed to test the detection of empty translations, numeric changes and glossary non-compliance. The run used the 4-billion-parameter Qwen model in Q4\_K\_M with fixed generation parameters. The historical reports keep responses, timings and metadata. @tab-pilot presents the counts recomputed per case–category pair from these files. The initial annotations of the set are still marked as pending review.

#figure(
  {
    set text(size: 8.5pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (1.5fr, 0.5fr, 0.5fr, 0.5fr, 1fr, 1fr, 1fr, 1fr),
      inset: 5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: center + horizon,
      table.header([*Run*], [*TP*], [*FP*], [*FN*], [*Precision*], [*Recall*], [*F1*], [*Mean time (s)*]),
      [v1, first], [5], [2], [0], [71.4%], [100%], [83.3%], [2.43],
      [v1, repeat], [5], [2], [0], [71.4%], [100%], [83.3%], [2.37],
      [v2], [4], [1], [1], [80%], [80%], [80%], [1.48],
    )
  },
  kind: table,
  caption: [Exploratory pilot on ten development examples. Metrics are micro-averaged and depend on the provisional annotations. Mean times describe runs that were not controlled for model loading and caching.],
  placement: top,
  scope: "parent",
) <tab-pilot>

Version v2 eliminated one false alarm but missed a problem that had previously been detected. The counts thus illustrate a trade-off between false positives and omissions. Incorrect explanations were observed even when the category matched the reference, as well as hints that stated accepted equivalents. The two v1 runs produced the same texts in the pilot environment. These data supported the continuation of development, without establishing superiority in an independent evaluation.

== Feedback Calibration with Prompt v3

The 14 November collection contains eight synthetic translations of six sources, two of which are acceptable and serve as controls. The examples were built during development to calibrate the assessment of hints. They cover changes in modality, idioms, false friends, numeric conventions and values, units and glossary compliance. All eight calls produced valid responses. The report records Ollama 0.14.3, the Qwen digest and the hash of prompt v3, and keeps the issues before and after merging. Because the set served only to prepare the grid, the expected categories and the judgements in its annotation sheet remain provisional.

For `Do not bypass the safety check.` translated as _Podes ignorar a verificação de segurança._ ('You may skip the safety check.'), Qwen raised a meaning issue. Its question _A instrução é uma proibição ou uma recomendação?_ ('Is the instruction a prohibition or a recommendation?') points toward modality, although the contrast with the translation is one of prohibition versus permission. For the acceptable variant _Não saltes a verificação de segurança._ ('Do not skip the safety check.'), the model also raised an issue. The filter generalized the text, preserving the false alarm.

For `She gave a lecture on the results.` translated as _Deu uma leitura sobre os resultados._ (a false-friend rendering, literally 'gave a reading'), Qwen classified the problem as terminology despite the empty glossary and suggested _apresentação_ ('presentation') in the hint. The response passed through the filter because single quotes are only searched for in `meaning_context` issues, and the adapter does not check the consistency between the category and the glossary. A wrong category can thus prevent one of the disclosure-control heuristics from being applied. The case also shows a gap between identifying a plausible problem, assigning the correct operational category and preserving the student's reformulation work.

When `80 °C` was replaced by `80 °F`, the numeric rule remained silent because the value 80 was preserved. The model flagged the unit and the filter generalized the feedback. This case supports the separation of scopes planned for RQ1. For the idiom _broke the ice_, no issue was raised, but the acceptability of the translation _partiu o gelo_ is flagged for discussion, and the annotation must be resolved before computing metrics.

The logs reveal failures and help us prepare the grid. The annotation proposal does not yet allow a final disclosure rate to be reported. The assessment of a hint may also diverge across criteria, as in the case of a clear message that provides the correction or a generic message that preserves a false alarm.

== Diagnostic Analysis and Prompt v4 <sec-diagnostic>

The diagnostic set contains 20 development cases from ten sources, all about meaning and context: tense and time adverbs, frequency, false friends, negation, modality, quantifiers, order, an idiom and a condition. Half are acceptable. With prompt v3, the model produced 9 TP, 3 FP and 1 FN; the omission was the loss of _só_ ('only'). Of its 12 issues, 7 disclosed part or all of the correction (4 partially and 3 fully), 8 hints were questions with two options of which one was the right reading, 2 hints were statements, 4 explanations invented facts and 2 contained language errors.

Prompt v4 asks for a single short open question, with no alternatives and no claim about what the source says, and for an explanation that only locates the type of difference without inventing people or facts. It also widens the guidance on meaning and context, forbids the glossary category when the glossary is empty and adds acceptable examples. After a first run on the diagnostic set, we adjusted it: the model must confirm that a reader would understand something different before raising an issue, must not quote English words or repeat the wrong word and must not mention the subject unless it changes. A further variant did not improve the results and was discarded.

On the diagnostic set, the adjusted v4 kept the same detection (9 TP, 3 FP, 1 FN) but produced no two-option questions, no statements and no language errors; 2 issues disclosed part of the correction and 1 disclosed all of it, and 3 explanations still invented facts. The false alarms on acceptable translations did not change with any version of the prompt. These runs belong to development and are not results.

== Detection on the Test Set — RQ1

Both configurations ran on the 40 test cases, one after the other, with every call returning a valid response; the mean time per model call was 1.36~s with v3 and 1.13~s with v4. @tab-rq1 shows the main analysis. The rules detected the ten problems without false alarms. The model alone found the two empty translations and the four numeric changes but none of the four glossary violations, even though the glossary was part of its input. It also raised a numeric false alarm on an acceptable price written in Portuguese format (_1 250 €_) with both prompts and, with v3 only, a glossary false alarm on an accepted variant. The hybrid approach kept the recall of the rules; its precision is limited by the false alarms of the model, which are shown to the student.

#figure(
  {
    set text(size: 8.5pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (1.3fr, 0.7fr, 0.45fr, 0.45fr, 0.45fr, 0.9fr, 0.9fr, 0.9fr, 1.1fr),
      inset: 5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: center + horizon,
      table.header([*Method*], [*Prompt*], [*TP*], [*FP*], [*FN*], [*Precision*], [*Recall*], [*F1*], [*Acceptable with alarm*]),
      [Rules], [—], [10], [0], [0], [100%], [100%], [100%], [0/8],
      [LLM-only], [v3], [6], [2], [4], [75.0%], [60.0%], [66.7%], [2/8],
      [LLM-only], [v4], [6], [1], [4], [85.7%], [60.0%], [70.6%], [1/8],
      [Hybrid], [v3], [10], [2], [0], [83.3%], [100%], [90.9%], [2/8],
      [Hybrid], [v4], [10], [1], [0], [90.9%], [100%], [95.2%], [1/8],
    )
  },
  kind: table,
  caption: [Detection in the main scope of the test set (18 cases, 10 expected case–category pairs). Metrics are micro-averaged over empty translations, numeric values and glossary compliance.],
  placement: top,
  scope: "parent",
) <tab-rq1>

The robustness scope gave the same results with both prompts. The rules reached 3 TP, 2 FP and 2 FN: they raised false alarms on a time written as _9h30_ and on a number written in words, and they missed a change of unit (_m_ to _km_) and a telephone number added in the translation. The model alone reached 4 TP, 0 FP and 1 FN, and the hybrid approach 4 TP, 2 FP and 1 FN. In this scope the model complements the rules, which do not interpret units or added numbers.

For meaning and context, the model produced 6 TP, 2 FP and 0 FN with both prompts. One false alarm concerns an acceptable translation of _late_ as _fora de prazo_; the other is the added telephone number, which the model reported as a meaning issue rather than a numeric one.

== Feedback Quality on the Test Set — RQ2

@tab-rq2 summarizes the reviewed annotation of the model's issues, both as returned by the model and as shown to the student after merging and filtering. Fewer issues are shown than returned because, in the categories covered by the rules, the rule issue takes priority. No row was marked as uncertain.

#figure(
  {
    set text(size: 8.5pt)
    set par(justify: false, leading: 0.5em)
    table(
      columns: (2.2fr, 1fr, 1fr, 1fr, 1fr),
      inset: 4.5pt,
      stroke: (x: none, y: 0.4pt + luma(75%)),
      align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
      table.header([], table.cell(colspan: 2)[*Returned by the model*], table.cell(colspan: 2)[*Shown to the student*]),
      [], [*v3*], [*v4*], [*v3*], [*v4*],
      [Issues assessed], [20], [19], [11], [10],
      [Disclosure: none], [5], [18], [6], [10],
      [Disclosure: partial], [4], [1], [2], [0],
      [Disclosure: full], [11], [0], [3], [0],
      [Correct], [17], [16], [8], [8],
      [Grounded], [15], [13], [4], [5],
      [Clear], [9], [13], [8], [6],
      [Useful], [14], [15], [3], [4],
      [Two-option question], [7], [0], [4], [0],
      [Hint states the source], [5], [0], [2], [0],
      [Invented explanation], [2], [2], [1], [1],
    )
  },
  kind: table,
  caption: [Assessment of the model's issues on the test set. "Correct", "Grounded", "Clear" and "Useful" count the issues judged "yes".],
  placement: top,
) <tab-rq2>

With v3, 15 of the 20 issues returned by the model disclosed part or all of the correction, 11 of them fully. Full disclosures usually stated what the source says, for example the original value or unit, or offered two options of which one was the right reading. With v4, 18 of the 19 issues disclosed nothing. Correctness hardly changed (17 and 16 issues), while clarity improved (9 and 13 issues judged clear). In the feedback shown to the student, v3 still disclosed part or all of the correction in 5 of 11 issues, and v4 in none.

The filter generalized 5 issues with v3 and 2 with v4, because v4 rarely quotes words. Generalized issues keep the category but lose the link to the passage, which explains why few of the issues shown were judged fully useful with either prompt.

== Discussion

The results separate two properties of the feedback. Detection depends mainly on the method: the rules are exact within their scope but fail on formats and phenomena they do not model, and the model adds meaning issues, units and added numbers but misses glossary violations and raises false alarms. The prompt barely changes detection, but it controls how the feedback is phrased: v4 nearly eliminated disclosure without reducing correctness. The hybrid approach combines the recall of the rules with the model's coverage, at the cost of showing the model's false alarms. The false alarms on acceptable translations resisted every prompt revision, which suggests that they depend on the model rather than on the instructions. These conclusions rest on a small synthetic set, in which a difference of one case changes the metrics noticeably.

= Threats to Validity and Limitations

*Reference and annotation.* We develop the system and decide the annotations by consensus, which introduces bias. The initial proposals and their review are recorded, but the lack of independent annotation limits the assessment of the reliability of the judgements. The reference of the test set was fixed before the responses were collected. The RQ1 metrics were computed before the RQ2 proposal was prepared, which may reveal the prompt version of a few rows, and the style of v3 can also be recognized. The development and calibration judgements remain provisional.

*Data and generalization.* All sets are small and synthetic. The main RQ1 scope has 18 cases and only 2 empty translations, so a single case changes the metrics considerably. An evaluation restricted to EN–PT-PT, short texts, one model and a local configuration characterizes only that scope.

*Scope of the checks.* The numeric rule looks for source values that are absent or have missing occurrences, may be ambiguous in sequences such as "5 100" and does not interpret units or numbers written in words. Terminology depends on explicit matches and variants. Tags are compared by count, without analyzing nesting. The model may err in its categories and in assessing paraphrases.

*Disclosure and usefulness.* The filter depends on patterns and may both let a lexical correction through and replace an appropriate explanation with a generic message. The interrogative form requested in the prompt does not guarantee that the feedback leaves the resolution to the student. Our assessment of usefulness is internal. Observing students as they revise and justify their choices will be necessary to study pedagogical effects.

*Operation and reproducibility.* Persistence does not separate users, and memory and exports are shared across the instance. Permissive CORS and the lack of authentication limit shared use. Latencies and responses depend on the hardware, the Ollama version, model loading and output length. The development runs used two computers and two Ollama versions; on the final computer, v3 reproduced 14 of the 20 diagnostic responses with the same detection. For this reason, both prompts were compared on the test set in the same session and environment.

= Conclusion and Future Work

The Educational Translation Tool implements a workflow of writing, checking, reuse and hint-based revision in an EN–PT-PT application with inspectable components. The five rules and the memory provide formal support and explicit reuse. The integration with Qwen adds meaning issues, and the merge identifies the origin of each issue.

On 40 held-out cases, the rules detected every problem in their scope, while the model alone missed all glossary violations and raised false alarms; the hybrid approach kept full recall in the main scope, with an F1 of 95.2% using prompt v4. The revised prompt barely changed detection but reduced the issues that disclosed the correction from 15 of 20 to 1 of 19, and none of the feedback shown to the student disclosed it. False alarms on acceptable translations remain the main weakness of the model.

The editor also keeps the version history of each segment and the student's justifications, and gives each occurrence of a segment its own identity. Future work includes evaluating other local models and documenting the conditions of use. Critical comparison, which is needed to fully address PO2, and a chronological view of the logged events remain to be implemented. A future evaluation with students could study how hints influence revision, decision-making and learning.

#print-acl-bibliography()
