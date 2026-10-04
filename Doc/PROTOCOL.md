# Protocolo de colaboração Claude (analista) <-> opencode (programador)

Projeto: **meuapp**
App analisado: `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/app/Ducks_1.0.1.xapk` (tipo detectado: **hybrid**)
Objetivo: biblioteca NÃO OFICIAL que reproduz as chamadas de rede do app para
permitir automação (bot) sobre ele, usando a conta do próprio operador.

## Papéis
| Agente | Faz | NÃO faz |
|---|---|---|
| Claude Code | Analisa o app decompilado, documenta, cria tarefas, revisa o código | Escrever código em Scripts/ |
| opencode | Lê docs/tarefas, implementa e testa em Scripts/, escreve reports | Analisar o app, editar Doc/analysis ou Doc/tasks (exceto o campo status) |
| Humano | Responde Doc/QUESTIONS.md, captura tráfego real quando necessário, decide prioridades | — |

## Canais (tudo é arquivo)
- Doc/analysis/   achados do Claude (fonte da verdade sobre o app)
- Doc/tasks/      ordens de serviço Claude -> opencode
- Doc/reports/    retorno opencode -> Claude
- Doc/fixtures/   exemplos reais de request/response (sanitizados), fornecidos pelo humano
- Doc/QUESTIONS.md fila de dúvidas e bloqueios
- Doc/INDEX.md    painel: lista de documentos e tarefas com status

## Ciclo de vida da tarefa
draft -> ready -> in-progress -> done -> reviewed
                                  \-> needs-fix -> ready
                 in-progress -> blocked
- Só o Claude cria tarefas e move para `ready`, `reviewed` ou `needs-fix`.
- Só o opencode move para `in-progress`, `done` ou `blocked`.

## Convenções
- IDs de tarefa com 3 dígitos: 001-nome-curto.md. Um relatório por tarefa: 001-report.md.
- Documentos de análise: NN-tema.md (ex.: 03-auth.md).
- Todo fato sobre o app recebe:
  - `Evidência:` caminho do arquivo decompilado/pseudocódigo + classe/método/função (+ linha quando possível)
  - `Confiança:` CONFIRMADO (visto no código ou em fixture) | INFERIDO (dedução lógica) | HIPÓTESE (palpite)
- O opencode só hardcoda valores CONFIRMADO. INFERIDO vira constante configurável com
  comentário TODO(verificar). HIPÓTESE não vira código: vira pergunta em QUESTIONS.md.
- Nunca colocar segredos reais (tokens, senhas, chaves de usuário) em Doc/ ou no git.
  Use placeholders como <ACCESS_TOKEN>. Segredos ficam em .env (ignorado pelo git).
- Se o app usar mecanismos de atestação/anti-automação (Play Integrity, SafetyNet, root
  detection, certificate pinning etc.), documente o que existe e PARE: registre em
  QUESTIONS.md para o humano decidir. Não documente nem implemente formas de burlá-los.
