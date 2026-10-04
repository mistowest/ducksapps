---
id: 000
title: Título curto e acionável
status: draft
phase: ex.: auth
depends_on: []
created_by: claude
---

## Objetivo
1-2 frases: o que existe depois desta tarefa que não existia antes.

## Contexto (leitura obrigatória)
- Doc/analysis/02-rede.md (seções ...)
- Doc/analysis/03-auth.md
- Doc/fixtures/...

## Especificação
Tudo que o programador precisa, sem precisar ver o app:
- Assinaturas das funções/classes a criar (nome, parâmetros, tipos, retorno)
- Valores exatos: URLs, métodos, headers, nomes de campos, enums, constantes
- Algoritmos em pseudocódigo passo a passo + vetores de teste (entrada -> saída esperada)
- Regras de erro: que exceção lançar para cada status/código
- Comportamento de retry/rate limit esperado

## Arquivos a criar ou alterar
- Scripts/...

## Critérios de aceite (verificáveis)
- [ ] `pytest Scripts/tests/test_xxx.py` passa
- [ ] função X com entrada Y retorna Z (exemplo concreto)
- [ ] erros A/B mapeados para as exceções C/D

## Fora de escopo
O que NÃO fazer nesta tarefa.

## Notas de revisão (preenchidas pelo Claude em caso de needs-fix)
