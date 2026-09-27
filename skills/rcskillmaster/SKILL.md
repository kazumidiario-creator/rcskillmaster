---
name: rcskillmaster
description: Carrega o guia de skills do projeto (.ai/SKILLS.md) e aplica o protocolo de escolha ao pedido, escolhendo primeiro a skill de processo e depois a de domínio. Use só quando o usuário invocar explicitamente (/rcskillmaster no Claude Code, $rcskillmaster no Codex).
disable-model-invocation: true
---

# rcskillmaster

Você foi chamado porque o usuário quer que a escolha de skill deste pedido siga o guia do projeto, não a sua memória. Funciona igual no Claude Code e no Codex; o que muda é só como você foi invocado e como carrega a skill escolhida.

## Passos

1. Leia na íntegra o guia `.ai/SKILLS.md` na raiz do projeto (a pasta em que a sessão foi aberta) com a ferramenta de leitura de arquivo. Não use resumo, não confie no que lembra de sessões anteriores. Se o arquivo não existir, procure `SKILLS.md` na raiz; se nenhum existir, pare e diga exatamente: "Sem guia de skills neste projeto. Crie `.ai/SKILLS.md` na raiz do projeto a partir do modelo `templates/SKILLS.md` do clone do rcskillmaster (ou rode o instalador com `-Project <pasta>` no Windows, `--project <pasta>` no macOS ou Linux) e me invoque de novo." Não crie o arquivo você mesmo.
2. Identifique o pedido: é o texto que veio junto da invocação. No Claude Code é o argumento do comando (`/rcskillmaster <pedido>`); no Codex é o que o usuário escreveu na mesma mensagem depois de `$rcskillmaster`.
   - Se não veio pedido nenhum, responda em uma linha: "Guia carregado (N skills). Qual é o pedido?" e espere. N é o número de fichas do guia.
   - Se veio, siga o "Protocolo de escolha" do guia: classifique a natureza, escolha a skill de processo, depois a de domínio, resolva empates por "Pares confundíveis".
3. Antes de executar qualquer coisa, mostre ao usuário em no máximo cinco linhas:
   - natureza do pedido;
   - skill de processo escolhida e por quê (uma linha, citando o GATILHO da ficha);
   - skill de domínio, se houver;
   - o que você descartou e o par confundível que decidiu, se houve dúvida;
   - se alguma regra "vale sempre" do guia trava o pedido, diga qual e pare.
4. Carregue a skill escolhida e siga o SKILL.md dela, não a lembrança que você tem dele. No Claude Code, use a ferramenta Skill. No Codex, invoque-a por menção (`$nome`) ou leia o SKILL.md dela na pasta de skills.
5. Se nenhuma skill do guia serve, diga "sem skill para isto" e faça o pedido sem skill. Não force vizinha.

## Proibições

- Não carregue duas skills "por precaução".
- Não invente ficha para skill que o guia marca como não instalada.
- Não altere o guia a partir daqui. Skill nova ou ficha faltando é tarefa separada.
- Nunca se auto-invoque: esta skill só entra por invocação explícita do usuário (no Claude Code, `disable-model-invocation: true`; no Codex, `agents/openai.yaml` com `allow_implicit_invocation: false`).
