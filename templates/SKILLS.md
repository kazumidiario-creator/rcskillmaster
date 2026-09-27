# Skills: guia para o agente

Você (Claude Code ou Codex) lê este arquivo para decidir QUAL skill invocar, QUANDO e o que ela NÃO faz. Não é documento para humanos. As instruções do projeto (AGENTS.md, CLAUDE.md) e o pedido do usuário prevalecem sobre qualquer skill. Como se invoca uma skill explicitamente: no Claude Code, `/nome [pedido]` ou a ferramenta Skill; no Codex, a menção `$nome [pedido]` ou o seletor `/skills` (não existe `/skill:nome` no Codex); o Codex ignora `disable-model-invocation` do frontmatter e usa `agents/openai.yaml` com `policy.allow_implicit_invocation: false` para o mesmo efeito.

## Protocolo de escolha (siga nesta ordem, a cada pedido)

1. Classifique o pedido em uma destas naturezas antes de responder qualquer coisa: **construir/mudar comportamento**, **corrigir falha**, **auditar/entender**, **delegar ordem fechada**, **vender/converter**, **interface**, **vault**, **navegador/automação**, **texto/estilo**. Um pedido pode ter duas naturezas; processe a de processo primeiro.
2. Aplique a skill de PROCESSO da natureza (tabela abaixo). Ela dita o fluxo; só depois carregue a skill de DOMÍNIO que traz conhecimento.
3. Se duas skills parecem servir, consulte "Pares confundíveis" e escolha pela diferença decisiva. Nunca carregue as duas por precaução.
4. Se nenhuma serve, trabalhe sem skill. Não force uma skill de vizinhança. Se a lacuna se repete, `find-skills` procura pronta e `writing-skills` cria nova.
5. Anuncie a skill escolhida em uma linha ("Usando X para Y") e siga o SKILL.md dela, não a lembrança que você tem dele.

| Natureza do pedido | Processo obrigatório | Domínio típico |
|---|---|---|
| Construir ou mudar comportamento | `brainstorming` → `writing-plans` → `subagent-driven-development` ou `executing-plans`; `test-driven-development` em cada tarefa; `verification-before-completion` antes de dizer pronto; `finishing-a-development-branch` no fim | a família do assunto |
| Corrigir falha, teste vermelho, comportamento estranho | `systematic-debugging` ANTES de qualquer correção; depois `test-driven-development` para o teste de regressão | nenhum |
| Auditar código contra documento que manda | `spec-to-code-compliance` (só por ordem explícita do usuário; não vendorada neste pacote: instale de upstream ou apague esta linha) | nenhum |
| Entender área desconhecida do código | `zoom-out` (só por invocação explícita: `/zoom-out` no Claude Code, `$zoom-out` no Codex) ou leitura direta | nenhum |
| Estressar plano ou design que o usuário já tem | `grill-me`; se for para atualizar `CONTEXT.md`/ADR, `grill-with-docs` | nenhum |
| Gerir issues, PRD, tickets | `to-prd` → `to-issues` → `triage`, depois de `setup-matt-pocock-skills` | nenhum |
| Delegar a subagente ou outro agente | skills de despacho do seu ambiente, se houver | nenhum |
| Vender, converter, reter, precificar | nenhum obrigatório | `offers`, `pricing`, `paywalls`, `signup`, `onboarding`, `churn-prevention`, `emails`, `cro`, `ab-testing`, `analytics`, `customer-research`, `marketing-psychology` |
| Interface visível | `brainstorming` se for novo | `impeccable` (craft/audit) ou `ui-ux-pro-max` (catálogo) |
| Notas do vault | proposta antes de escrever | `obsidian-markdown`, `obsidian-bases`, `obsidian-cli`, `json-canvas` |
| Navegador, perfil, janela, workers Orca | autorização do usuário | `adspower-browser` (não vendorada neste pacote), `computer-use`, `orca-cli`, `orchestration` |
| Texto do usuário soando IA | só por pedido explícito | `humanizer` |
| Usuário pediu respostas curtas | | `caveman` (não vendorada neste pacote: instale de upstream ou apague esta linha) |

Regras que valem sempre:

- Skill não substitui as instruções do projeto. Segredos, escopo, commit e push seguem AGENTS.md/CLAUDE.md mesmo que a skill peça diferente.
- Skill de processo com "Lei de Ferro" (`test-driven-development`, `systematic-debugging`, `verification-before-completion`) não tem exceção por urgência. A exceção só existe se o usuário a declarar.
- `spec-to-code-compliance` custa um agente por requisito mais dois por divergência. Só com ordem explícita, `limit 10` na primeira rodada, um diretório e um documento por vez, resultado guardado num diretório de saída fora do controle de versão. Se você a rodar no Codex, trate o resultado como sequencial até provar que o orquestrador multiagente funciona ali. Cada `contradicted` ou `absent` vira decisão do usuário: corrigir código ou corrigir documento.
- Agente delegado (subagente ou outro CLI) nunca recebe segredo nem material sensível do projeto: credenciais, dados de conta, voz ou identidade de marca ficam com o coordenador.
- Skills de marketing leem `.agents/product-marketing.md` ou `.claude/product-marketing.md` do projeto antes de perguntar, se existir.
- Podem estar ausentes na sua instalação, embora citadas por algumas fichas: `copywriting`, `popups`, `cold-email`, `launch`, `audit-context-building`, `diagnose`, `tdd`, `write-a-skill`. Não as invoque sem confirmar que existem; use a alternativa indicada na ficha.

## Fichas por família

Formato: GATILHO (o que na conversa ou no estado dispara), ENTREGA (o que a skill produz ou impõe), NÃO USE (vizinho confundível ou exclusão declarada).

### Processo (superpowers)
Governam COMO trabalhar. Entram antes de qualquer skill de domínio.

#### `using-superpowers`
GATILHO: início de qualquer conversa; antes de QUALQUER resposta ou ação, inclusive perguntas de esclarecimento ou exploração do código; antes de entrar em plan mode sem ter feito brainstorming.
ENTREGA: se há 1% de chance de uma skill se aplicar, invoque-a; anuncie "Using [skill] to [purpose]"; skills de processo (`brainstorming`, `systematic-debugging`) antes das de implementação; instruções do usuário (CLAUDE.md, AGENTS.md) prevalecem sobre skills.
NÃO USE: ignore se despachado como subagente para tarefa específica (`SUBAGENT-STOP`).

#### `brainstorming`
GATILHO: OBRIGATÓRIA antes de qualquer trabalho criativo: criar feature, componente, funcionalidade nova ou modificar comportamento. Classifique em voz alta spike / bounded / architectural antes da primeira pergunta.
ENTREGA: HARD-GATE: nenhuma implementação, código ou scaffold até apresentar a intenção e o parceiro aprovar; spike → recomendação; bounded → design curto no chat; architectural → perguntas, 2-3 abordagens, spec em `docs/superpowers/specs/`, depois `writing-plans`.
NÃO USE: quando o usuário já tem plano/design pronto e quer só ser interrogado (é `grill-me`); quando já existe plano escrito para executar (`executing-plans`/`subagent-driven-development`).

#### `writing-plans`
GATILHO: há spec ou requisitos para tarefa multi-etapas, antes de tocar código; saída natural do caminho architectural do `brainstorming`.
ENTREGA: plano em `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` com header obrigatório (Goal, Architecture, Tech Stack, Spec, Global Constraints), mapa de arquivos, tarefas bite-sized (teste falhando → rodar → implementar → rodar → commit) com Interfaces Consumes/Produces.
NÃO USE: executar o plano (é `subagent-driven-development` ou `executing-plans`); spec que cobre subsistemas independentes deve virar planos separados.

#### `executing-plans`
GATILHO: existe plano de implementação escrito para executar em sessão separada, com checkpoints de revisão; sem subagentes disponíveis.
ENTREGA: anuncia "I'm using the executing-plans skill", garante worktree (`using-git-worktrees`), revisa o plano criticamente, executa cada tarefa com verificações, para em bloqueio, fecha com `finishing-a-development-branch`.
NÃO USE: quando há subagentes disponíveis (use `subagent-driven-development`); nunca implemente em main/master sem consentimento explícito.

#### `subagent-driven-development`
GATILHO: executar plano de implementação com tarefas majoritariamente independentes, ficando na sessão atual, com subagentes disponíveis.
ENTREGA: subagente implementador fresco por tarefa, revisão de tarefa (spec + qualidade) após cada uma, até 5 rodadas de correção, revisão final ampla, ledger com `Ruling:` para decisões; execução contínua sem "should I continue?"; fecha com `finishing-a-development-branch`.
NÃO USE: sem plano ou tarefas fortemente acopladas (brainstorm/manual); sessão paralela (é `executing-plans`); para só quatro motivos: operação destrutiva, ação sensível de segurança, efeito fora do worktree (merge/push/publish), plano irremediavelmente quebrado.

#### `dispatching-parallel-agents`
GATILHO: 2+ tarefas independentes sem estado compartilhado nem dependência sequencial; 3+ arquivos de teste falhando por causas distintas; subsistemas quebrados de forma independente.
ENTREGA: um agente por domínio de problema, prompts focados e autossuficientes, todos despachados na mesma resposta; depois revisão, integração e suíte completa.
NÃO USE: falhas relacionadas (consertar uma pode consertar outras), necessidade de estado global, agentes que se interfeririam; para executar um plano por tarefas, é `subagent-driven-development`.

#### `using-git-worktrees`
GATILHO: iniciar trabalho de feature que precisa de isolamento do workspace atual, ou antes de executar plano de implementação.
ENTREGA: detecta isolamento existente (`GIT_DIR != GIT_COMMON`, guarda de submódulo), pede consentimento, prefere ferramenta nativa (`EnterWorktree`, `/worktree`), fallback `git worktree add` em `.worktrees/` ignorado pelo git, roda setup do projeto.
NÃO USE: já dentro de worktree (não crie outro); usuário recusou (trabalhe no lugar); worktrees geridos pelo Orca (é `orca-cli`).

#### `test-driven-development`
GATILHO: implementar qualquer feature, bugfix, refactor ou mudança de comportamento, antes de escrever código de produção.
ENTREGA: Lei de Ferro "nenhum código de produção sem teste falhando primeiro"; ciclo RED (ver falhar) → GREEN (mínimo) → REFACTOR; código escrito antes do teste é apagado.
NÃO USE: exceções só com aval do parceiro: protótipos descartáveis, código gerado, arquivos de configuração; para investigar a causa do bug primeiro, é `systematic-debugging`.

#### `systematic-debugging`
GATILHO: qualquer bug, falha de teste, comportamento inesperado, problema de performance, falha de build ou integração, ANTES de propor correção; especialmente sob pressão de tempo ou depois de tentativas falhas.
ENTREGA: Lei de Ferro "sem correção sem investigação de causa raiz"; 4 fases começando por ler erros, reproduzir, checar mudanças recentes, instrumentar fronteiras de componentes e traçar fluxo de dados até a origem.
NÃO USE: não pular por parecer simples ou urgente; escrever o teste de regressão depois é `test-driven-development`; verificar que a correção passou é `verification-before-completion`.

#### `verification-before-completion`
GATILHO: prestes a afirmar que algo está completo, corrigido ou passando; antes de commit, PR, mudar de tarefa ou delegar; qualquer palavra de sucesso/satisfação ("Done!", "should work").
ENTREGA: Lei de Ferro "sem alegação de conclusão sem evidência fresca de verificação": identificar o comando que prova, rodar completo, ler saída e exit code, só então afirmar com evidência; relatório de agente não é evidência, cheque o diff.
NÃO USE: não substitua por "linter passou", "estou confiante" ou run anterior; investigar a causa de uma falha é `systematic-debugging`.

#### `requesting-code-review`
GATILHO: ao completar tarefa, implementar feature grande, antes de merge; obrigatório após cada tarefa em subagent-driven development.
ENTREGA: captura BASE_SHA/HEAD_SHA e despacha subagente `general-purpose` com o template `code-reviewer.md` (contexto curado, nunca o histórico da sessão); corrige Critical/Important antes de seguir.
NÃO USE: revisar o diff inline você mesmo (queima contexto do coordenador); reagir ao feedback recebido (é `receiving-code-review`).

#### `receiving-code-review`
GATILHO: ao receber feedback de code review, antes de implementar sugestões, especialmente se o feedback parece obscuro ou tecnicamente questionável.
ENTREGA: padrão READ → UNDERSTAND → VERIFY → EVALUATE → RESPOND → IMPLEMENT; proibido "You're absolutely right!"/"Great point!"; pergunte antes se algum item está obscuro; pushback técnico quando errado; checagem YAGNI.
NÃO USE: para pedir revisão (é `requesting-code-review`); não implemente parcialmente itens que entendeu deixando dúvidas para depois.

#### `finishing-a-development-branch`
GATILHO: implementação concluída e todos os testes passando; é preciso decidir como integrar o trabalho.
ENTREGA: roda a suíte completa, detecta ambiente (repo normal / worktree / detached HEAD), confirma branch base e apresenta exatamente o menu (merge local / push + PR / manter branch); a decisão é do parceiro humano.
NÃO USE: com testes falhando (relate e pare); antes da revisão final de código (é `requesting-code-review`); descartar trabalho só a pedido explícito.

#### `writing-skills`
GATILHO: criar skill nova, editar skill existente ou verificar que uma skill funciona antes de publicar.
ENTREGA: TDD aplicado a documentação: cenário de pressão com subagente (RED, baseline sem skill) → escrever SKILL.md → verificar conformidade (GREEN) → fechar brechas; frontmatter `name` + `description` ("Use when…", só gatilhos, sem resumir o processo, < 1024 chars).
NÃO USE: soluções únicas, práticas padrão já documentadas, convenções de projeto (vão no arquivo de instruções), restrições mecânicas automatizáveis; descobrir/instalar skills prontas é `find-skills`.

### Engenharia e auditoria
Interrogar planos, mapear código, auditar spec, gerir issues.

#### `spec-to-code-compliance`
(Não vendorada neste pacote: instale de upstream, ver MANIFEST.md. Sem ela instalada, apague esta ficha.)
GATILHO: comparar implementação contra whitepaper, spec de protocolo ou documento de design: quais requisitos valem, quais o código contradiz, quais estão ausentes e o que o código faz sem documento.
ENTREGA: não checa inline: roda `/spec-to-code-compliance:spec-compliance <path>` (um agente por requisito, refutação independente), gera `spec-compliance/REPORT.md` com verdicts implemented/partial/contradicted/stronger-than-spec/absent/undecidable; para um requisito só, agente `spec-compliance-checker`.
NÃO USE: código sem documentação de comportamento pretendido (`audit-context-building` pode não estar instalada; use `code-review` ou leitura direta); caça a bugs em geral; escrever/melhorar documentação.

#### `grill-me`
GATILHO: usuário quer estressar um plano/design, ser "grilled", ou menciona "grill me".
ENTREGA: entrevista implacável, uma pergunta por vez, descendo cada ramo da árvore de decisão com resposta recomendada; se a pergunta se responde pelo código, explora o código em vez de perguntar.
NÃO USE: quando o objetivo é também atualizar `CONTEXT.md`/ADRs e desafiar terminologia do domínio (é `grill-with-docs`); ideia ainda sem plano (é `brainstorming`).

#### `grill-with-docs`
GATILHO: usuário quer estressar o plano contra a linguagem do projeto e decisões documentadas (`CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`); chamado também pelo passo "Grill" do `triage`.
ENTREGA: mesma entrevista do `grill-me` mais: confronta termos com o glossário, propõe termo canônico, cruza com o código, atualiza `CONTEXT.md` inline e oferece ADR só se irreversível + surpreendente + trade-off real.
NÃO USE: grilling sem tocar em documentação (é `grill-me`); não crie ADR fora dos três critérios.

#### `zoom-out`
GATILHO: só por invocação explícita `/zoom-out` (`disable-model-invocation: true`), quando o usuário não conhece uma área do código e quer visão de nível mais alto.
ENTREGA: mapa dos módulos e chamadores relevantes um nível de abstração acima, no vocabulário do glossário de domínio do projeto.
NÃO USE: leitura detalhada de um arquivo específico ou debugging (é `systematic-debugging`).

#### `triage`
GATILHO: usuário quer criar issue, triar issues, revisar bugs/feature requests recebidos, preparar issue para agente AFK ou gerir fluxo de issues; `/triage` com pedido em linguagem natural ("show me anything that needs my attention", "move #42 to ready-for-agent").
ENTREGA: máquina de estados `needs-triage → needs-info | ready-for-agent | ready-for-human | wontfix` mais categoria bug/enhancement; todo comentário começa com "> *This was generated by AI during triage.*"; reproduz bugs, chama `/grill-with-docs` se precisar, escreve agent brief.
NÃO USE: quebrar plano em issues (é `to-issues`); labels reais vêm do `/setup-matt-pocock-skills`; em conflito de estado, pergunte ao mantenedor antes.

#### `to-issues`
GATILHO: usuário quer converter plano, spec ou PRD em issues, criar tickets de implementação ou quebrar trabalho em issues no tracker do projeto.
ENTREGA: fatias verticais tracer-bullet (HITL/AFK, "Blocked by", user stories), aprovação da granularidade pelo usuário, publicação em ordem de dependência com label `needs-triage`; exige `/setup-matt-pocock-skills` feito.
NÃO USE: gerar o PRD a partir da conversa (é `to-prd`); processar issues existentes (é `triage`); não feche nem altere a issue pai.

#### `to-prd`
GATILHO: usuário quer criar um PRD a partir do contexto atual da conversa.
ENTREGA: sem entrevistar: sintetiza problema, solução, lista LONGA de user stories, decisões de implementação (módulos profundos), decisões de teste, fora de escopo; confirma módulos com o usuário e publica no tracker com `needs-triage`.
NÃO USE: quebrar em tickets (é `to-issues`); explorar a ideia com perguntas (é `brainstorming`); não inclua caminhos de arquivo nem snippets.

#### `setup-matt-pocock-skills`
GATILHO: só por invocação explícita `/setup-matt-pocock-skills` (`disable-model-invocation: true`); rodar antes do primeiro uso de `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`, ou quando essas skills parecem sem contexto de tracker/labels/docs.
ENTREGA: bloco `## Agent skills` em CLAUDE.md/AGENTS.md e `docs/agents/{issue-tracker,triage-labels,domain}.md`, decidido com o usuário seção a seção (tracker GitHub/GitLab/local/outro; 5 labels de triagem; single/multi-context).
NÃO USE: nunca criar AGENTS.md se CLAUDE.md existe (ou vice-versa); não é a skill de triagem em si (é `triage`).

### Marketing, oferta e produto
Entrega é copy, oferta, preço, fluxo de conversão ou pesquisa.

#### `offers`
GATILHO: desenhar/construir/melhorar a oferta em si (value framing, bonus stack, garantia, escassez/urgência, nome, pagamento); termos literais "offer", "grand slam offer", "irresistible offer", "value stack", "bonus stack", "guarantee", "risk reversal", "high-ticket offer", "productize a service", "payment plan", "why isn't my offer converting"; serviços, cursos, coaching, info, B2B high-ticket, direct-response.
ENTREGA: diagnóstico pela value equation (4 alavancas), anatomia de 6 componentes, uma alavanca por iteração, projeção honesta de lift.
NÃO USE: SaaS self-serve com tiers (leia `pricing` primeiro); a página que apresenta a oferta (`copywriting` pode não estar instalada; faça sem skill); lançamento (`launch` pode não estar instalada; faça sem skill).

#### `pricing`
GATILHO: decisão de preço, packaging ou monetização; termos literais "pricing", "pricing tiers", "freemium", "free trial", "packaging", "price increase", "value metric", "Van Westendorp", "willingness to pay", "how much should I charge", "my pricing is wrong", "pricing page", "annual vs monthly", "per seat pricing", "should I offer a free plan".
ENTREGA: três eixos (packaging, métrica, ponto de preço), value metric, good-better-best, pesquisa de preço.
NÃO USE: tela de upgrade in-app (é `paywalls`); construção de oferta com bônus/garantia para serviços/cursos/coaching (é `offers`).

#### `paywalls`
GATILHO: criar/otimizar paywall in-app, tela de upgrade, modal de upsell, feature gate; termos literais "paywall", "upgrade screen", "upgrade modal", "upsell", "feature gate", "convert free to paid", "freemium conversion", "trial expiration screen", "limit reached screen", "free users won't upgrade", "trial to paid conversion".
ENTREGA: pontos de gatilho (feature gate, limite, expiração de trial, tempo), componentes da tela e templates de paywall por tipo.
NÃO USE: página pública de pricing (é `cro`); decisão de preço/tiers (é `pricing`).

#### `signup`
GATILHO: otimizar signup, registro, criação de conta ou ativação de trial; termos literais "signup conversions", "registration friction", "signup form optimization", "reduce signup dropoff", "account creation flow", "signup abandonment", "trial conversion rate", "nobody completes registration", "too many steps to sign up", "simplify our signup".
ENTREGA: otimização campo a campo (email, senha, nome, social auth, telefone, empresa), single vs multi-step, valor antes do compromisso.
NÃO USE: onboarding pós-signup (é `onboarding`); formulário de captura de lead sem criação de conta (é `cro`).

#### `onboarding`
GATILHO: otimizar onboarding pós-signup, ativação, first-run, time-to-value; termos literais "onboarding flow", "activation rate", "first-run experience", "empty states", "onboarding checklist", "aha moment", "users aren't activating", "nobody completes setup", "users sign up but don't use the product", "time to value".
ENTREGA: definição do aha moment e métrica de ativação, desenho do fluxo pós-signup (product-first/guided/value-first), checklist, empty states, tours e coordenação e-mail + in-app.
NÃO USE: o formulário de signup/registro (é `signup`); sequências de e-mail contínuas (é `emails`).

#### `churn-prevention`
GATILHO: reduzir churn, fluxo de cancelamento, save offers, recuperar pagamento falho, retenção; termos literais "churn", "cancel flow", "offboarding", "save offer", "dunning", "failed payment recovery", "win-back", "exit survey", "pause subscription", "involuntary churn", "people keep canceling", "customers are leaving".
ENTREGA: três modos: construir cancel flow (Trigger → Survey → Oferta dinâmica → Confirmação → Pós-cancel), otimizar fluxo existente, montar dunning.
NÃO USE: sequência de e-mail de win-back pós-cancel (é `emails`); paywall de upgrade in-app (é `paywalls`).

#### `emails`
GATILHO: criar/otimizar sequência de e-mail, drip, fluxo automatizado ou lifecycle; termos literais "email sequence", "drip campaign", "nurture sequence", "onboarding emails", "welcome sequence", "re-engagement emails", "email automation", "lifecycle emails", "email funnel", "email cadence", "welcome series".
ENTREGA: estratégia de sequência (tipo, tamanho, timing, subject lines, preview text) e estrutura e-mail a e-mail com um CTA por mensagem.
NÃO USE: cold outreach (`cold-email` pode não estar instalada; faça sem skill); onboarding in-app (é `onboarding`).

#### `cro`
GATILHO: otimizar/aumentar conversão de página de marketing ou formulário (home, landing, pricing, feature, lead capture, contato); termos literais "CRO", "conversion rate optimization", "this page isn't converting", "improve conversions", "my landing page sucks", "form abandonment", "low conversion rate"; usuário compartilha URL pedindo feedback.
ENTREGA: análise em 7 dimensões (proposta de valor, headline, CTA, hierarquia visual, prova social, objeções, fricção) com Quick Wins, mudanças de alto impacto, ideias de teste e alternativas de copy.
NÃO USE: fluxo de signup/registro (é `signup`); ativação pós-signup (é `onboarding`); popups/modais (`popups` pode não estar instalada; trate dentro de `cro`).

#### `ab-testing`
GATILHO: pedido de planejar/desenhar/implementar teste A/B ou programa de experimentação; termos literais "A/B test", "split test", "experiment", "variant copy", "multivariate test", "hypothesis", "statistical significance", "how long should I run this test", "ICE score", "experiment backlog"; comparar duas versões e medir qual ganha.
ENTREGA: hipótese estruturada, tipo de teste, tamanho de amostra, métricas primária/secundária/guardrail e desenho de variantes; lê `.agents/product-marketing.md` antes de perguntar.
NÃO USE: implementação de tracking/eventos (é `analytics`); otimização de página sem experimento (é `cro`).

#### `analytics`
GATILHO: configurar/melhorar/auditar tracking; termos literais "set up tracking", "GA4", "Google Analytics", "conversion tracking", "event tracking", "UTM parameters", "GTM", "tracking plan", "how do I measure this", "attribution", "Mixpanel", "Segment", "are my events firing", "analytics isn't working".
ENTREGA: plano de tracking (evento | categoria | propriedades | gatilho), convenção object_action, eventos essenciais e validação.
NÃO USE: medição de experimento A/B (é `ab-testing`).

#### `customer-research`
GATILHO: conduzir/analisar/sintetizar pesquisa de cliente; termos literais "customer research", "ICP research", "analyze transcripts", "customer interviews", "survey analysis", "support ticket analysis", "voice of customer", "VOC", "build personas", "JTBD", "Reddit mining", "G2 reviews", "review mining", "digital watering holes", "find out why customers churn/convert/buy".
ENTREGA: dois modos (analisar ativos existentes; garimpar fontes online), extração JTBD/dores/gatilhos/linguagem, síntese por tema com nível de confiança e checagem de viés.
NÃO USE: escrever copy a partir da pesquisa (`copywriting` pode não estar instalada; faça sem skill); agir na página (é `cro`).

#### `marketing-psychology`
GATILHO: aplicar psicologia, modelos mentais ou ciência comportamental ao marketing; termos literais "psychology", "mental models", "cognitive bias", "persuasion", "behavioral science", "why people buy", "anchoring", "social proof", "scarcity", "loss aversion", "framing", "nudge".
ENTREGA: identifica modelos aplicáveis (first principles, JTBD, inversão, 80/20, viés de atribuição, exposição, disponibilidade…), explica a psicologia e propõe aplicação ética.
NÃO USE: aplicar em página específica (é `cro`); tática de preço (é `pricing`); framing de copy (`copywriting` pode não estar instalada; faça sem skill).

#### `humanizer`
GATILHO: SOMENTE quando o usuário pede explicitamente "humanize", "de-AI", "remove AI tells", "make this sound human" sobre um texto dado.
ENTREGA: reescrita que remove padrões de escrita de IA (guia "Signs of AI writing" da Wikipedia), preservando cobertura e sentido, com calibração opcional de voz por amostra.
NÃO USE: nunca auto-ativar; só entra por pedido explícito sobre um texto dado. Não aplique em texto que use recursos retóricos de propósito (regra de três, staccato, paralelismo), que esta skill marcaria errado.

### Design e frontend
Interface visível.

#### `impeccable`
GATILHO: usuário quer design/redesign/critique/audit/polish/clarify/distill/harden/optimize/animate/colorize/extract de interface frontend (site, landing, dashboard, app shell, componente, formulário, onboarding, empty state); sub-comandos `craft|shape|audit|critique|polish|bolder|quieter|distill|harden|onboard|animate|init|document|extract|live`.
ENTREGA: código de produção com craft: roda `scripts/context.mjs` (PRODUCT.md/DESIGN.md), lê `reference/<comando>.md` e o registro brand/product, aplica regras de cor/tipografia/layout/motion e as "absolute bans" anti-slop.
NÃO USE: backend ou tarefa sem UI; para consulta de catálogo de estilos/paletas/fontes por stack, é `ui-ux-pro-max`.

#### `ui-ux-pro-max`
GATILHO: ações plan/build/create/design/implement/review/fix/improve em UI/UX (website, landing, dashboard, admin, e-commerce, SaaS, mobile, .html/.tsx/.vue/.svelte); elementos (button, modal, navbar, card, table, form, chart); estilos (glassmorphism, brutalism, neumorphism, bento grid, dark mode); tópicos (color palette, accessibility, font pairing, animation, spacing).
ENTREGA: banco pesquisável via CLI Python de 67 estilos, 96 paletas, 57 pares de fontes, 99 guidelines UX, 25 charts, 13 stacks, com prioridades (acessibilidade e touch primeiro).
NÃO USE: quando se quer o processo de craft/audit/polish com contexto de produto e bans anti-slop (é `impeccable`); requer Python instalado.

### Vault Obsidian
Só estas escrevem no vault. Se o seu projeto exigir aprovação antes de escrever no vault, aplique-a aqui.

#### `obsidian-markdown`
GATILHO: SOMENTE ao trabalhar com notas/MOCs dentro do vault, ou quando o usuário menciona explicitamente wikilinks, callouts, embeds ou notas Obsidian.
ENTREGA: Obsidian Flavored Markdown válido: frontmatter, `[[wikilinks]]`, `![[embeds]]`, `> [!callout]`, tags, comentários `%%`, highlight.
NÃO USE: saídas em texto puro que não sejam nota do vault; operar o vault por CLI (é `obsidian-cli`).

#### `obsidian-bases`
GATILHO: trabalhar com arquivos `.base`, criar views tipo banco de dados de notas, ou usuário menciona Bases, table/card views, filtros ou fórmulas no Obsidian.
ENTREGA: YAML válido de Base (filters and/or/not, formulas, properties, summaries, views table/cards/list/map) com validação de referências.
NÃO USE: canvas visual (é `json-canvas`); sintaxe de nota (é `obsidian-markdown`); operar o vault via linha de comando (é `obsidian-cli`).

#### `obsidian-cli`
GATILHO: usuário pede para interagir com o vault Obsidian pela CLI `obsidian` (ler, criar, buscar, tasks, properties, backlinks) ou desenvolver/depurar plugin/tema (reload, eval, dev:errors, screenshot, DOM).
ENTREGA: comandos `obsidian ...` com o vault declarado explicitamente, sempre com subpath de destino em `create`; o app precisa estar aberto.
NÃO USE: lookup rápido de conteúdo (Read/Grep/Glob nativos são melhores); escrever a sintaxe da nota em si (é `obsidian-markdown`).

#### `json-canvas`
GATILHO: trabalhar com arquivos `.canvas`, criar canvas visual, mind map, fluxograma, ou usuário menciona Canvas do Obsidian.
ENTREGA: JSON válido no spec JSON Canvas 1.0 (`nodes`/`edges`, ids hex de 16 chars, tipos text/file/link/group), com validação de ids e referências.
NÃO USE: notas Markdown do vault (é `obsidian-markdown`); views de banco `.base` (é `obsidian-bases`).

### Navegador e automação externa
Só com perfil e autorização do usuário. Nunca tocam cookies, tokens ou credenciais.

#### `adspower-browser`
(Não vendorada neste pacote: instale de upstream, ver MANIFEST.md. Sem ela instalada, apague esta ficha.)
GATILHO: pedido de criar/atualizar/apagar/listar perfis AdsPower, abrir/fechar browser ou "environment"/perfil, fingerprint, UA, proxy, grupos, tags, download de kernel, check-status; menção a AdsPower ou `adspower-browser` quando o MCP não está rodando ou não é desejado.
ENTREGA: comandos `ads <command> [json]` via CLI `adspower-browser` (porta local da API, chave em variável de ambiente), inclusive paginação de `get-browser-list`.
NÃO USE: controle de GUI de janela visível (é `computer-use`); browser embutido do Orca (é `orca-cli`); se o MCP `adspower` está ativo e preferido, use o MCP.

#### `computer-use`
GATILHO: uma janela visível de app local (nativo, Chrome/Edge/Safari externo ou webview) precisa de controle de GUI (árvore de acessibilidade, cliques, digitação, menus, diálogos, screenshots) via `orca computer`, e nenhum caminho programático (shell, filesystem, git, HTTP, CLI) alcança.
ENTREGA: resolve o executável Orca (`ORCA_CLI_COMMAND` → `orca-dev` → `orca-ide` → `orca`) e carrega o guia com `ORCA skills get computer-use` antes de qualquer comando.
NÃO USE: browser embutido do Orca (é `orca-cli`); sempre prefira caminho programático; nunca rode `orca` cru em Linux fora do Orca (é o leitor de tela GNOME).

#### `orca-cli`
GATILHO: usuário diz "$orca-cli", "Orca worktree", "child worktree", "spawn codex/claude in a worktree", "read/wait/send Orca terminal", "handoff"/"handover"/"give this to another agent", "Orca browser", "orca artifacts", "share skills"; qualquer operação com estado Orca (worktrees, contextos, terminais, repos, automações, artefatos, browser embutido).
ENTREGA: resolve o executável Orca e carrega `ORCA skills get orca-cli` antes de qualquer comando; prefira a raw `git worktree`, PTYs ad hoc ou Computer Use quando há estado Orca. No Codex (Windows), todo comando que fala com o runtime do Orca precisa rodar fora do sandbox (escalação): dentro dele o `orca status` responde `not_running` falsamente; nunca `orca open` por causa disso.
NÃO USE: supervisão/coordenação de DAG entre workers (é `orchestration`); janela GUI que CLI/API não alcança (é `computer-use`).

#### `orchestration`
GATILHO: coordenar workers Orca supervisionados: mensagens em thread, ask/reply bloqueante, despacho de tarefas, esperas worker_done/escalation, DAGs de tarefas, decision gates, loops de coordenador, decompor trabalho entre agentes; usuário pede para supervisionar, monitorar ou coordenar.
ENTREGA: carrega `ORCA skills get orchestration` (e `--reference references/<file>.md` para gates condicionais); exige estado real do runtime Orca. No Codex (Windows), todo comando que fala com o runtime do Orca precisa rodar fora do sandbox (escalação): dentro dele o `orca status` responde `not_running` falsamente; nunca `orca open` por causa disso. Em `codex exec` (sem aprovação) orquestração é impossível.
NÃO USE: handoff de propriedade total ("hand off", "handover", "another worktree") sem pedido de supervisão, controle de terminal, shell, worktree ou browser (é `orca-cli`); nunca substitua por subagente não-Orca.

#### `find-skills`
GATILHO: usuário pergunta "how do I do X", "find a skill for X", "is there a skill that can...", "can you do X" (capacidade especializada) ou quer estender capacidades do agente.
ENTREGA: consulta leaderboard skills.sh, `npx skills find <query>`, verifica instalações/reputação/estrelas, apresenta opções e oferece `npx skills add <owner/repo@skill> -g -y`.
NÃO USE: criar ou editar skills (é `writing-skills`); não recomende skill só pelo resultado da busca sem checar qualidade.

### Coleta web

#### `defuddle`
GATILHO: leitura rápida de UMA URL avulsa, quando uma ferramenta de scraping completa seria exagero ou não está disponível.
ENTREGA: `defuddle parse <url> --md` com saída no chat (não use `-o content.md`); requer `npm install -g defuddle`.
NÃO USE: URLs terminadas em `.md`; scraping/crawl/extração em geral (se o seu projeto tiver uma ferramenta de scraping preferida, ela vem antes).

### Estilo de resposta

#### `caveman`
(Não vendorada neste pacote: instale de upstream, ver MANIFEST.md. Sem ela instalada, apague esta ficha.)
GATILHO: usuário diz "caveman mode", "talk like caveman", "use caveman", "less tokens", "be brief" ou `/caveman`.
ENTREGA: respostas ultra-comprimidas (sem artigos, filler, hedging; ~75% menos tokens) persistentes até "stop caveman"/"normal mode", com exceção de clareza para avisos de segurança e ações irreversíveis.
NÃO USE: para remover tom de IA de um texto do usuário (é `humanizer`); código e termos técnicos permanecem exatos.

### Meta (escolha de skill)

#### `rcskillmaster`
GATILHO: só por invocação explícita do usuário: `/rcskillmaster [pedido]` no Claude Code (`disable-model-invocation: true`) ou `$rcskillmaster [pedido]` no Codex (`agents/openai.yaml` com `allow_implicit_invocation: false`).
ENTREGA: lê este guia na íntegra, aplica o protocolo de escolha ao pedido, mostra em até cinco linhas natureza, skill de processo, skill de domínio, descarte e travas, depois carrega a skill escolhida (Claude: ferramenta Skill; Codex: menção `$nome` ou leitura do SKILL.md dela).
NÃO USE: nunca auto-invocar; não edita este guia.

## Pares confundíveis

- `brainstorming` × `grill-me`: `brainstorming` parte de uma ideia e produz design/spec com gate de aprovação antes de implementar; `grill-me` parte de um plano que o usuário já tem e só interroga até entendimento compartilhado.
- `grill-me` × `grill-with-docs`: mesma entrevista; `grill-with-docs` além disso confronta o glossário `CONTEXT.md`, cruza com o código e escreve `CONTEXT.md`/ADRs inline.
- `impeccable` × `ui-ux-pro-max`: `impeccable` é processo de craft com contexto de produto (PRODUCT.md, registro brand/product, bans anti-slop) e código pronto para produção; `ui-ux-pro-max` é catálogo pesquisável de estilos/paletas/fontes/guidelines por stack.
- `systematic-debugging` × `diagnose`: `diagnose` pode não estar instalada (só é citada por `setup-matt-pocock-skills`); `systematic-debugging` é a skill de causa raiz disponível.
- `test-driven-development` × `tdd`: `tdd` pode não estar instalada (só citada por `setup-matt-pocock-skills`); `test-driven-development` é a única com o ciclo RED-GREEN-REFACTOR aqui.
- `writing-skills` × `write-a-skill`: `write-a-skill` não faz parte deste conjunto; `writing-skills` é a que cria/edita skills por TDD; `find-skills` é para descobrir e instalar skills prontas.
- `obsidian-markdown` × `obsidian-cli` × `obsidian-bases` × `json-canvas`: `obsidian-markdown` é a sintaxe da nota; `obsidian-cli` é operar o vault/plugins pelo binário `obsidian`; `obsidian-bases` é o arquivo `.base` (YAML); `json-canvas` é o arquivo `.canvas` (JSON).
- `computer-use` × `orca-cli` × `orchestration` × `adspower-browser`: `computer-use` é GUI de janela visível via `orca computer` quando nada programático alcança; `orca-cli` é estado Orca (worktrees, terminais, handoff, browser embutido); `orchestration` é supervisão de workers Orca (DAG, ask/reply, gates); `adspower-browser` é a API local do AdsPower para perfis/proxies/fingerprint, sem GUI. (`adspower-browser` não é vendorada neste pacote.)
- `to-prd` × `to-issues` × `triage`: `to-prd` sintetiza a conversa em PRD e publica; `to-issues` quebra plano/PRD em fatias verticais e publica; `triage` move issues já existentes pela máquina de estados de labels. Os três dependem de `setup-matt-pocock-skills`.
- `executing-plans` × `subagent-driven-development`: mesma entrada (plano escrito); `executing-plans` é para sessão separada/sem subagentes e para em checkpoints humanos; `subagent-driven-development` fica na sessão, um subagente por tarefa, execução contínua sem check-ins.
- `dispatching-parallel-agents` × `subagent-driven-development`: o primeiro é para falhas/tarefas independentes sem plano (um agente por domínio, todos de uma vez); o segundo executa um plano sequencial com revisão por tarefa.
- `requesting-code-review` × `receiving-code-review`: pedir revisão via subagente (antes de merge/após tarefa) × responder a feedback recebido (verificar antes de implementar).
- `cro` × `signup` × `onboarding` × `paywalls`: `cro` é página de marketing/lead form; `signup` é criação de conta; `onboarding` é pós-signup até ativação; `paywalls` é momento de upgrade in-app após valor experimentado.
- `pricing` × `offers` × `paywalls`: `pricing` é tiers/métrica/ponto de preço (SaaS self-serve); `offers` é a construção da oferta (bônus, garantia, escassez, nome) para serviços/cursos/coaching/high-ticket; `paywalls` é a tela in-app que apresenta o upgrade.
- `ab-testing` × `analytics`: desenho do experimento e estatística × implementação de eventos/tracking que o mede.
- `emails` × `churn-prevention`: sequência automatizada de e-mails (inclusive win-back) × cancel flow, save offers e dunning dentro do produto/billing.
- `defuddle` × ferramenta de scraping do projeto: `defuddle` só para 1 URL avulsa; crawl, extração em massa ou páginas pesadas ficam com a ferramenta de scraping que o seu projeto adotar.
- `caveman` × `humanizer`: `caveman` comprime as respostas do próprio agente; `humanizer` reescreve texto do usuário para tirar tom de IA, só por pedido explícito.
- `verification-before-completion` × `finishing-a-development-branch`: a primeira exige evidência antes de qualquer alegação de sucesso; a segunda é o ritual de integração (suíte verde → menu merge/PR/manter) depois disso.

## Onde as skills moram

As pastas reais das skills ficam em `skills/` no clone do rcskillmaster (não neste projeto); o instalador cria links nas pastas que cada ferramenta lê. Três fichas são de skills não vendoradas (spec-to-code-compliance, caveman, adspower-browser): instale-as de upstream ou apague ficha, linha da tabela e par confundível correspondentes.

Uma pasta real por skill. Nunca copie skill entre pastas: cópias divergem em silêncio. Skill nova nasce com `name` igual ao nome da pasta e `description` que diz só os gatilhos, e precisa de ficha neste guia.
