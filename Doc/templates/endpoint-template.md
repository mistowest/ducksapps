# Endpoint: <nome funcional>   (ex.: "Listar feed")
- Origem na UI: tela/ação que dispara
- Evidência: Classe#metodo/função (arquivo:linha) e camada de rede correspondente
- Confiança: CONFIRMADO | INFERIDO | HIPÓTESE

## Requisição
- Método e URL: `GET {BASE_URL}/v1/...`   (base URL referenciada em 02-rede.md)
- Autenticação: sim/não, como (header, formato)
- Headers específicos:
- Path params:
- Query params: nome | tipo | obrigatório | valores aceitos | padrão
- Corpo: formato (JSON/form/multipart/protobuf) + esquema campo a campo
- Assinatura/nonce/timestamp: sim/não -> ver 03-auth.md seção X

## Resposta
- Status de sucesso:
- Esquema (campo | tipo | anulável? | descrição | enum)
- Paginação (cursor/offset/page) e como obter a próxima página

## Erros
status/código | significado | como o app reage

## Exemplo completo (sanitizado)
request e response (placeholders para segredos)

## Efeitos colaterais e pré-condições
(ex.: exige login, consome cota, altera estado)

## Observações para o implementador
