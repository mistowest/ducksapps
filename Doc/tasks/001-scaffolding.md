---
id: 001
title: Esqueleto do projeto e infraestrutura de testes
status: done
phase: base
depends_on: []
created_by: claude
---

## Objetivo
Criar o pacote meuapp_client com a estrutura de camadas, ferramentas de teste e
lint, sem nenhum conhecimento específico do app.

## Contexto
AGENTS.md (seção "Arquitetura da biblioteca").

## Especificação
- Scripts/pyproject.toml: pacote `meuapp_client`, Python>=3.11, deps: httpx, pydantic>=2;
  dev: pytest, pytest-asyncio, respx, ruff.
- Criar pastas e módulos vazios com docstring: config, transport, signing, auth, errors,
  models/, api/, bot/.
- config.py: dataclass `Settings` com base_url, timeout, user_agent, app_version, max_rps
  (padrão 1.0), retries (padrão 3), carregando de variáveis de ambiente `MEUAPP_*`.
  Valores sem fonte documentada devem ficar como None/placeholder, nunca inventados.
- errors.py: hierarquia `MeuappError` > `NetworkError`, `AuthError`, `RateLimitError`,
  `ApiError(status, code, message)`.
- transport.py: classes `Transport` (sync) e `AsyncTransport` (async) sobre httpx, com retry
  exponencial com jitter para erros de rede/5xx, rate limiter simples por segundo e logging
  que mascara Authorization/tokens. Ganchos para `signing` e `auth` injetarem headers.
- Scripts/tests/ com testes para config, retry e rate limit usando respx.
- Scripts/README.md com instalação e execução dos testes.

## Arquivos a criar
Scripts/pyproject.toml, Scripts/README.md, Scripts/meuapp_client/**, Scripts/tests/**

## Critérios de aceite
- [ ] `cd Scripts && pip install -e ".[dev]" && pytest` passa
- [ ] `ruff check .` sem erros
- [ ] retry testado: 2 falhas 503 seguidas de 200 resultam em sucesso
- [ ] logs nunca exibem o valor do header Authorization

## Fora de escopo
Qualquer endpoint, URL, assinatura ou autenticação real do app.
