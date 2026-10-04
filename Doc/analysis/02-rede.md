# 02 - Camada de Rede
Fase: 2 | Status: done | Atualizado em: 2024-10-04

## Resumo
O app utiliza OkHttp como cliente HTTP para comunicação com servidores. Foram identificados diversos endpoints relacionados ao domínio duckapps.com.br e aminoapps.com.br. A autenticação é realizada via tokens Bearer no header Authorization.

## Achados

### Achado 1: Base URLs
- **Descrição**: URLs base utilizadas pelo app para requisições de API
- **Evidência**: Strings encontradas em blutter/out/pp.txt:
  - https://api.duckapps.com.br
  - https://api.aminoapps.com.br
  - https://api.aminoapps.com.br/bootstrap
  - https://api.aminoapps.com.br/config
  - https://cdn.duckapps.com.br
  - https://vmi3521716.contaboserver.net
- **Confiança**: CONFIRMADO

### Achado 2: Endpoints específicos
- **Descrição**: Caminhos específicos de API identificados no código
- **Evidência**: Strings encontradas em blutter/out/pp.txt:
  - https://duckapps.com.br/apoie
  - https://duckapps.com.br/reset-password
  - https://duckapps.com.br/email-changed
- **Confiança**: CONFIRMADO

### Achado 3: Headers de autenticação
- **Descrição**: Uso de header Authorization com token Bearer
- **Evidência**: 
  - Strings "Authorization" (pp+0xdbd0) e "Bearer " (pp+0xdbe8) encontradas
  - Token Bearer exemplo: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzgwODcyNjQ0LCJleHAiOjIwOTYyMzI2NDR9.Eus5Kl0BPJy4-cGa9yzZKO252XD1vArNAKRYv5Ql1hQ"
  - Referências no assembly mostrando uso dessas strings (msv.dart linhas 196-208)
- **Confiança**: CONFIRMADO

### Achado 4: Client HTTP
- **Descrição**: Utilização do OkHttp para client HTTP
- **Evidência**: fingerprint.sh indicou "HTTP stack: OkHttp"
- **Confiança**: CONFIRMADO

### Achado 5: Headers identificados
- **Descrição": Outros headers HTTP identificados
- **Evidência**: 
  - String "X-Client-Info": "postgrest-dart/2.7.1" (pp+0x13b68)
  - Indicação de uso de bibliotecas Supabase/PostgREST
- **Confiança**: CONFIRMADO

## Fluxo (tela -> camada intermediária -> HTTP)
[À ser determinado - necessita análise mais profunda para entender como as chamadas são iniciadas a partir da UI]

## Pseudocódigo (se houver algoritmo)
[Não disponível nesta fase - necessita decompilação mais detalhada do código Dart]

## Lacunas e perguntas (também registradas em Doc/QUESTIONS.md)
1. Quais são os métodos HTTP exatos (GET, POST, PUT, DELETE) utilizados em cada endpoint?
2. Quais são os parâmetros e estruturas de dados enviadas em cada requisição?
3. Como exatamente o token Bearer é obtido e renovado? (fluxo de auth)
4. O app utiliza certificate pinning ou outros mecanismos de segurança de rede?
5. Quais são os timeouts e políticas de retry configuradas?
6. Existem headers fixos além de Authorization (como User-Agent, device-id, etc.)?

## Tarefas geradas
- 002: Transporte e headers HTTP (a ser criada)