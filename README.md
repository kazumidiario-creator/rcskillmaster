# rcskillmaster

Uma coleção de 46 skills para Claude Code e Codex, mais a inteligência de quando e como usar cada uma: o guia `.ai/SKILLS.md` e a skill `rcskillmaster`, que lê esse guia e escolhe a skill certa para o pedido antes de agir.

- **Processo (superpowers, de Jesse Vincent):** brainstorming, writing-plans, executing-plans, subagent-driven-development, test-driven-development, systematic-debugging, verification-before-completion, requesting e receiving-code-review, finishing-a-development-branch, using-git-worktrees, dispatching-parallel-agents, writing-skills, using-superpowers.
- **Engenharia (Matt Pocock e vercel-labs):** grill-me, grill-with-docs, zoom-out, to-prd, to-issues, triage, setup-matt-pocock-skills, find-skills.
- **Marketing (Corey Haines):** offers, pricing, paywalls, signup, onboarding, churn-prevention, emails, cro, ab-testing, analytics, customer-research, marketing-psychology.
- **Interface:** impeccable (Paul Bakaus), ui-ux-pro-max.
- **Obsidian (Steph Ango):** obsidian-markdown, obsidian-bases, obsidian-cli, json-canvas, defuddle.
- **Texto:** humanizer (Siqi Chen).
- **Orca (stablyai):** orchestration, orca-cli, computer-use, com uma correção para o sandbox do Codex no Windows.
- **Escolha de skill:** rcskillmaster (original deste pacote).

Origem e licença de cada uma em `MANIFEST.md`; textos de licença em `LICENSES/`. Três skills ficaram só como referência de instalação por licença ou origem: spec-to-code-compliance (Trail of Bits), caveman e adspower-browser. O guia traz 49 fichas: 46 das skills instaladas mais essas 3, marcadas no texto.

## Requisitos

- Claude Code, Codex CLI ou os dois. Git para clonar.
- Orca (https://github.com/stablyai/orca) só para `orchestration`, `orca-cli` e `computer-use`. Sem Orca, instale com `-Exclude orchestration,orca-cli,computer-use` (ou `--exclude` no sh) e apague as três fichas do guia.

## Instalação

1. Clone em um lugar definitivo. Os links das skills apontam para esta pasta: se você apagar ou mover o clone depois, as skills somem.

```
git clone https://github.com/kazumidiario-creator/rcskillmaster.git
cd rcskillmaster
```

2. Crie os links das skills nas pastas que cada ferramenta lê. Os destinos são `~/.claude/skills` (Claude Code), `~/.agents/skills` (Codex, local documentado) e `~/.codex/skills` (Codex, também lido nas versões atuais). Pasta ou link que já existir no destino é deixado em paz, com aviso.

Windows (a política de execução padrão bloqueia scripts, por isso o `-ExecutionPolicy Bypass`; não precisa de administrador):

```
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Project "C:\caminho\do\seu\projeto"
```

macOS ou Linux:

```
sh install.sh --project /caminho/do/seu/projeto
```

`-Project` (ou `--project`) copia `templates/SKILLS.md` para `<projeto>/.ai/SKILLS.md`, que é o guia que o `rcskillmaster` lê na raiz da sessão. Sem esse arquivo a skill para e pede para criá-lo. O guia é por projeto: em cada projeto novo, rode o instalador de novo com outro `-Project` (os links já existentes só geram avisos). Outras opções: `-Only claude` ou `-Only codex` (`--only` no sh) limita os destinos; `-Skill a,b` (`--skill`) instala só as listadas; `-Exclude a,b` (`--exclude`) pula as listadas; `-ForceGuide` (`--force-guide`) sobrescreve um guia existente.

3. Abra `<projeto>/.ai/SKILLS.md` e apague o que se refere a skills que você não instalou: a ficha, a linha na tabela de naturezas e o par confundível. As três não vendoradas já vêm marcadas com "(não vendorada neste pacote)". Skill sem ficha não é escolhida; ficha sem skill confunde o agente.

4. Abra uma sessão nova da ferramenta na raiz do projeto. Skills e guia são lidos na abertura.

5. Confira: no Claude Code, `/rcskillmaster` sem argumento deve responder "Guia carregado (N skills). Qual é o pedido?", em que N é o número de fichas que sobraram no seu guia. No Codex, `/skills` deve listar as skills e `$rcskillmaster` deve responder a mesma frase.

## Como invocar

| Ferramenta | Sintaxe |
|---|---|
| Claude Code | `/rcskillmaster <pedido>` |
| Codex CLI ou app | `$rcskillmaster <pedido>` na mesma mensagem, ou `/skills` para escolher no seletor |

No Codex não existe `/skill:nome`: isso é sintaxe do Claude Code. O `rcskillmaster` só entra por invocação explícita: no Claude Code por `disable-model-invocation: true`, no Codex por `agents/openai.yaml` com `allow_implicit_invocation: false` (o Codex ignora o campo do frontmatter). As demais skills podem ser escolhidas pelo próprio agente, pela descrição, ou invocadas do mesmo jeito (`/nome` e `$nome`).

Com pedido, o `rcskillmaster` lê o guia inteiro, classifica a natureza do pedido pelas categorias definidas no próprio guia (construir ou mudar comportamento, corrigir falha, auditar ou entender, delegar, vender ou converter, interface, vault, navegador ou automação, texto ou estilo), escolhe a skill de processo, depois a de domínio, resolve empates pela seção "Pares confundíveis" e mostra a escolha em cinco linhas antes de executar.

## O guia `.ai/SKILLS.md`

É o que dá valor ao conjunto: o protocolo de escolha, as regras que valem sempre e uma ficha por skill, sempre com três linhas.

```
#### `nome-da-skill`
GATILHO: o que no pedido ou no estado dispara esta skill.
ENTREGA: o que ela produz ou impõe.
NÃO USE: a vizinha confundível ou a exclusão declarada.
```

O modelo em `templates/SKILLS.md` já traz as fichas e os pares confundíveis (brainstorming x grill-me, orchestration x orca-cli, impeccable x ui-ux-pro-max, e outros). Regra de ouro: skill de processo (como trabalhar) antes de skill de domínio (o que saber), e nunca carregar duas "por precaução". Para acrescentar uma skill sua, instale-a e escreva a ficha.

## Orca dentro do Codex (Windows)

Medido em 25/09/2026 com Codex CLI 0.155: a mesma `orca status --json` responde "rodando" fora do sandbox do Codex e "não rodando" dentro dele, com ambiente idêntico. O sandbox de token restrito bloqueia a conexão da CLI com o app do Orca e não levanta `runtime_access_denied`. Os stubs originais mandariam então abrir o Orca de novo. As versões deste pacote tratam `not_running` de dentro do sandbox como bloqueio: o agente pede para rodar o comando fora do sandbox (aprove a escalação quando o Codex perguntar), usa `cmd /c` com o executável resolvido em vez do PowerShell do sandbox (que roda em modo de linguagem restrita) e nunca executa `orca open` por causa disso. Em `codex exec` não interativo não há aprovação, então orquestração ali é impossível por desenho.

## Atualizar e desinstalar

Os links apontam para a pasta do clone, então `git pull` no clone atualiza as skills; se aparecer skill nova, rode o instalador de novo (ele só cria o que falta). O guia do projeto é uma cópia, não um link: depois do `git pull`, compare `templates/SKILLS.md` com `<projeto>/.ai/SKILLS.md` (por exemplo com `diff`) e leve as fichas novas, ou rode o instalador com `-ForceGuide` (`--force-guide`) para trocar o guia inteiro, sabendo que a sua poda se perde.

Para desinstalar, use os desinstaladores, que removem só os links e nunca entram neles:

```
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1 -Project "C:\caminho\do\seu\projeto"
sh uninstall.sh --project /caminho/do/seu/projeto
```

Se preferir à mão no Windows, use `cmd /c rmdir "%USERPROFILE%\.claude\skills\<nome>"` para cada link. Nunca use `rmdir` nem `Remove-Item -Recurse` dentro do PowerShell para isso: ali `rmdir` é apelido de `Remove-Item`, que segue a junction e apaga a pasta de origem no clone. No macOS ou Linux, `rm ~/.claude/skills/<nome>` (sem `-r`) remove só o link.

## Estrutura

```
skills/<nome>/SKILL.md                    uma pasta por skill (46)
skills/rcskillmaster/agents/openai.yaml   política do Codex: sem invocação implícita
templates/SKILLS.md                       guia completo para copiar em <projeto>/.ai/SKILLS.md
MANIFEST.md                               origem e licença de cada skill
LICENSES/                                 textos de licença e NOTICE de terceiros
install.ps1, install.sh                   instaladores (junctions no Windows, symlinks no resto)
uninstall.ps1, uninstall.sh               removem só os links
LICENSE                                   MIT para o que é original deste pacote
```

## Créditos

Este pacote junta trabalho de outras pessoas, cada um sob a própria licença: superpowers (obra), skills do Matt Pocock, find-skills (vercel-labs), marketingskills (Corey Haines), impeccable (Paul Bakaus, Apache 2.0), ui-ux-pro-max (nextlevelbuilder), obsidian-skills (kepano), humanizer (blader) e os stubs de descoberta do Orca (stablyai). `orchestration`, `orca-cli` e `computer-use` são cópias modificadas dos stubs que o próprio Orca instala em `~/.agents/skills`; o guia de versão de cada um continua vindo do binário (`orca skills get <nome>`). Se o Orca atualizar os stubs, reaplique a ressalva sobre o sandbox.
