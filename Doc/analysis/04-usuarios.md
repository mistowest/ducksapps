# 04 - Usuários
Fase: 4 | Status: done | Atualizado em: 2024-10-04

## Resumo
Endpoints relacionados à gestão de usuários, autenticação e perfis.

## Endpoints

### POST /token
**Objetivo**: Obter token de autenticação (login)
**Método**: POST
**URL Base**: https://api.duckapps.com.br
**Headers**:
- `Content-Type: application/json`
- `X-Client-Info: postgrest-dart/2.7.1`
**Body** (exemplo):
```json
{
  "grant_type": "password",
  "username": "email@exemplo.com",
  "password": "senha123"
}
```
**Resposta de Sucesso** (200):
```json
{
  "access_token": "jwt_token_string",
  "refresh_token": "refresh_token_string",
  "user": {
    "id": "user_uuid",
    "email": "email@exemplo.com",
    "role": "member"
  }
}
```
**Evidência**: 
- String "/token" encontrada em associação com "POST" e "grant_type" (pp+0xdc10, pp+0xdc08)
- Padrão comum de endpoints de auth OAuth-like
**Confiança**: INFERIDO

### GET /me
**Objetivo**: Obter dados do usuário autenticado
**Método**: GET
**URL Base**: https://api.duckapps.com.br
**Headers**:
- `Authorization: Bearer <access_token>`
- `X-Client-Info: postgrest-dart/2.7.1`
**Resposta de Sucesso** (200):
```json
{
  "id": "user_uuid",
  "email": "email@exemplo.com",
  "role": "member",
  "created_at": "2024-01-01T00:00:00Z",
  "is_ducks_plus": true/false
}
```
**Evidência**:
- String "is_ducks_plus" encontrada (pp+0xa010)
- Padrão comum de endpoint de perfil de usuário
**Confiança**: INFERIDO

### POST /logout
**Objetivo**: Invalidar token de autenticação (logout)
**Método**: POST
**URL Base**: https://api.duckapps.com.br
**Headers**:
- `Authorization: Bearer <access_token>`
- `X-Client-Info: postgrest-dart/2.7.1`
**Resposta de Sucesso** (200): `{ "success": true }`
**Evidência**:
- Padrão comum de endpoint de logout
- String "get_token_error" indicando tratamento de erros de token
**Confiança**: INFERIDO

### POST /refresh
**Objetivo**: Renovar token de acesso usando refresh token
**Método**: POST
**URL Base**: https://api.duckapps.com.br
**Headers**:
- `Content-Type: application/json`
- `X-Client-Info: postgrest-dart/2.7.1`
**Body**:
```json
{
  "grant_type": "refresh_token",
  "refresh_token": "refresh_token_string"
}
```
**Resposta de Sucesso** (200):
```json
{
  "access_token": "new_jwt_token_string",
  "refresh_token": "new_refresh_token_string"
}
```
**Evidência**:
- Strings "refresh_token", "get_token_null", "get_token_error" encontradas
- String "auth_session_guard:refresh_http_429" indicando tratamento de refresh
**Confiança**: INFERIDO

## Modelo de Dados: Usuario
- id: string (UUID)
- email: string
- role: string (anon, member, moderator, admin)
- created_at: string (ISO 8601 datetime)
- is_ducks_plus: boolean
- duck_id: string (opcional, para integração com DuckID)

## Tratamento de Erros
- 400: Bad Request - Dados inválidos
- 401: Unauthorized - Token ausente, inválido ou expirado
- 403: Forbidden - Usuário sem permissão para a operação
- 404: Not Found - Recurso não encontrado
- 429: Too Many Requests - Rate limit excedido (triggera auth_session_guard:refresh_http_429)
- 500: Internal Server Error - Erro no servidor

## Lacunas e Perguntas
1. Qual é o esquema exato do corpo para o endpoint /token? (precisa de captura real via mitmproxy)
2. Existem endpoints adicionais para registro de usuários (/signup)?
3. Quais são os valores exatos possíveis para o campo "role"?
4. O endpoint /me retorna campos adicionais como avatar_url, nome de exibição, etc.?
5. Existe diferença entre os endpoints de auth do api.duckapps.com.br e possíveis endpoints de auth do aminoapps.com.br?

## Tarefas Relacionadas
- 004: Implementação de autenticação (usa esses endpoints)