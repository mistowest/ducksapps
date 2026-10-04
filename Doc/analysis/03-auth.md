# 03 - Autenticação
Fase: 3 | Status: done | Atualizado em: 2024-10-04

## Resumo
O app utiliza autenticação baseada em tokens Bearer (JWT) para acessar as APIs. O fluxo de autenticação parece envolver obtenção de tokens via endpoints de auth, refresh de tokens e armazenamento provavelmente em algum mecanismo de storage local (SharedPreferences ou similar). Integração com Supabase/PostgREST identificada via headers.

## Achados

### Achado 1: Tipo de Token
- **Descrição**: Utilização de tokens Bearer no formato JWT para autenticação
- **Evidência**:
  - String Bearer token encontrada: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzgwODcyNjQ0LCJleHAiOjIwOTYyMzI2NDR9.Eus5Kl0BPJy4-cGa9yzZKO252XD1vArNAKRYv5Ql1hQ"
  - String "jwt" encontrada isoladamente
  - Estrutura do token decodificada (parcialmente): 
    - Header: {"alg":"HS256","typ":"JWT"}
    - Payload: {"role":"anon","iss":"supabase","iat":1780872644,"exp":2096232644}
  - Confirmação de algoritmo HS256 e emissão por Supabase
- **Confiança**: CONFIRMADO

### Achado 2: Headers de Autenticação
- **Descrição**: Uso do header Authorization com prefixo "Bearer "
- **Evidência**:
  - Strings "Authorization" (pp+0xdbd0) e "Bearer " (pp+0xdbe8) encontradas no pp.txt
  - Referências no assembly mostrando uso dessas strings (msv.dart linhas 196-208)
  - String "auth_session_guard:refresh_http_429" indicando tratamento de refresh em caso de 429
- **Confiança**: CONFIRMADO

### Achado 3: Fluxo de Tokens
- **Descrição**: Indicações de mecanismos de obtenção, refresh e tratamento de erros de token
- **Evidência**:
  - Strings: "get_token_null", "get_token_error", "refresh_token"
  - Strings de estado: "unauthenticated", "not_authenticated", "authentication_required", "unauthorized: not authenticated"
  - String "Messaging#getToken" e "Messaging#onTokenRefresh" indicando integração com Firebase Cloud Messaging para tokens de push
  - String "`const Object()` cannot be used as the token." com referências a tokenRefreshed
- **Confiança**: CONFIRMADO

### Achado 4: Integração com Supabase
- **Descrição**: Uso aparente do Supabase como backend de autenticação
- **Evidência**:
  - Header "X-Client-Info": "postgrest-dart/2.7.1" indicando uso de biblioteca Dart para PostgREST
  - String "supabase.postgrest" encontrada
  - Token JWT com "iss":"supabase" no payload
  - Strings relacionadas a push: "[Push] Token nulo na tentativa", "[Push] Erro ao obter token", "register_push_token"
- **Confiança**: CONFIRMADO

### Achado 5: Endpoints de Autenticação
- **Descrição**: Possíveis endpoints relacionados a autenticação
- **Evidência**:
  - String "/token" encontrada em associação com "POST" e "grant_type" (pp+0xdc10, pp+0xdc08)
  - Isso sugere um endpoint de token OAuth-like em POST /token
- **Confiança**: INFERIDO (baseado em padrões comuns de auth)

## Fluxo (tela -> camada intermediária -> HTTP)
[À ser determinado - necessita análise mais profunda para entender o fluxo exato de login/refresh]

## Pseudocódigo (se houver algoritmo)
[Não disponível nesta fase - necessita decompilação mais detalhada do código Dart]

## Lacunas e perguntas (também registradas em Doc/QUESTIONS.md)
1. Qual é o fluxo exato de login (quais endpoints são chamados, em que ordem)?
2. Onde e como os tokens são armazenados localmente (SharedPreferences, KeyStore, etc.)?
3. Qual é a estratégia de refresh de token (quando e como é renovado)?
4. Quais são os endpoints exatos para login, logout, refresh e registro?
5. O app utiliza PKCE ou outros fluxos de auth OAuth2.0 específicos?
6. Como são tratados os erros de autenticação (401, 403) e redirecionamentos?

## Tarefas geradas
- 004: Implementação de autenticação (a ser criada)