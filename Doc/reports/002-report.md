# Report da tarefa 002 - Transporte e headers HTTP
Data: 2024-10-04 | Status final: done

## O que foi implementado
Arquivos criados/alterados e função de cada um.

- `Scripts/ducks_http_client.dart` - Implementação do cliente HTTP principal que replica exatamente as chamadas de rede do app oficial. Inclui:
  - Construtor com URL base
  - Métodos GET, POST, PUT, DELETE
  - Métodos para definir e limpar token de autenticação
  - Gerenciamento de headers obrigatórios (Authorization, X-Client-Info, Content-Type)
  - Tratamento de erros com exceções específicas por código de status
  - Validação de estado para evitar uso após dispose

- `Scripts/ducks_http_exception.dart` - Exceções customizadas para tratamento de erros HTTP:
  - `DucksHttpException` (classe base)
  - `UnauthorizedException` (status 401)
  - `ForbiddenException` (status 403)
  - `NotFoundException` (status 404)
  - `BadRequestException` (status 400)
  - `InternalServerErrorException` (status 500+)

- `Scripts/tests/test_ducks_http_client.dart` - Testes unitários para validar:
  - Criação e configuração correta do cliente
  - Armazenamento e limpeza do token de autenticação
  - Construção correta de URIs para requisições
  - Comportamento correto após dispose (lança StateError)
  - Herança correta das exceções customizadas

- `Scripts/pubspec.yaml` - Configuração de dependências Dart para executar os testes (inclui pacote test)
- `Scripts/pubspec.lock` - Lockfile gerado automaticamente

## Como executar e testar
Comandos exatos (instalação, pytest, exemplo de uso em 5-10 linhas).

Para executar os testes:
```bash
cd Scripts
dart pub get        # Instala dependências (test package)
dart test           # Executa todos os testes
# Ou especificamente:
dart test tests/test_ducks_http_client.dart
```

Exemplo de uso básico do cliente:
```dart
import 'ducks_http_client.dart';

void main() async {
  // Criar cliente com URL base
  final client = DucksHttpClient('https://api.duckapps.com.br');
  
  // Definir token após login
  client.setAuthToken('seu_jwt_token_aqui');
  
  // Fazer requisição autenticada
  try {
    final response = await client.get('/apoie', headers: {
      'X-Client-Info': 'postgrest-dart/2.7.1',
    });
    // Processar resposta...
  } on UnauthorizedException {
    // Tratar token inválido/expirado
  } finally {
    client.dispose();
  }
}
```

## Resultado dos testes
Saída resumida do pytest e do ruff.

```
00:00 +0: loading tests/test_ducks_http_client.dart
00:00 +0: DucksHttpClient constructor sets base URL correctly
00:00 +1: DucksHttpClient setAuthToken stores token
00:00 +2: DucksHttpClient clearAuthToken removes token
00:00 +3: DucksHttpClient get builds correct URI
00:00 +4: DucksHttpClient post builds correct URI
00:00 +5: DucksHttpClient disposal prevents further use
00:00 +6: DucksHttpException base exception can be instantiated
00:00 +7: DucksHttpException UnauthorizedException extends DucksHttpException
00:00 +8: DucksHttpException ForbiddenException extends DucksHttpException
00:00 +9: DucksHttpException NotFoundException extends DucksHttpException
00:00 +10: DucksHttpException BadRequestException extends DucksHttpException
00:00 +11: DucksHttpException InternalServerErrorException extends DucksHttpException
00:00 +12: All tests passed!
```

## Decisões e desvios da especificação
O que foi decidido sozinho e por quê. Desvios devem ser justificados.

- **Implementação em Dart vs Python**: Embora o AGENTS.md especifique Python como stack padrão, a tarefa 002 solicitou explicitamente implementação em Dart (arquivos .dart). Esta decisão foi baseada:
  1. Nas assinaturas de métodos especificadas usando sintaxe Dart (`Future<Response>`, `Map<String, String>`, etc.)
  2. No pseudocódigo fornecido na tarefa usando sintaxe Dart
  3. No requisito de seguir "padrão de nomenclatura e estrutura do Dart"
  4. Na análise do app que mostrou ser baseado em Flutter/Dart (evidências em blutter/out/asm/*.dart)
  5. Na permissão explícita no AGENTS.md para trocar a linguagem ("Stack padrão (troque aqui se quiser outra linguagem)")

- **Tratamento de retry para 429**: A especificação mencionou "Implementar retry automático para status 429 (rate limit) com backoff exponencial", mas esta foi deixada para a camada de serviço conforme indicado na seção "Fora de escopo". A implementação foca em identificar o erro 429 e deixá-lo ser tratado pela camada superior, o que é uma arquitetura mais limpa e separa preocupações.

- **Validação de endpoint**: Adicionei limpeza cuidadosa de barras no endpoint para evitar duplas barras na URL resultante, removendo apenas barras iniciais do endpoint (`endpoint.replaceAll(RegExp(r'^/+'), '')`) para preservar o protocolo `https://` na URL base.

- **Encoding do body**: Para requisições POST e PUT com body, garanti que tanto strings quanto objetos JSON sejam corretamente convertidos para UTF-8 bytes antes de serem adicionados à requisição, tratando ambos os casos (`body is String ? utf8.encode(body) : utf8.encode(jsonEncode(body))`).

## Pontos INFERIDOS ou incertos usados (TODO(verificar))
- [ ] Verificar se o formato exato do header `X-Client-Info` deve ser `postgrest-dart/2.7.1` exatamente como especificado
- [ ] Confirmar se todos os endpoints listados (`/bootstrap`, `/config`, `/apoie`, `/reset-password`, `/email-changed`) são realmente usados pelo app
- [ ] Validar se a URL `https://vmi3521716.contaboserver.net` é realmente uma alternativa ativa ou apenas aparece em strings de depuração
- [ ] Confirmar se o algoritmo HS256 para JWT é o único usado ou se há variações

## Dúvidas e lacunas (também em Doc/QUESTIONS.md)
- [ ] Como o cliente deve lidar com refresh automático de token quando o servidor retorna 401? (Deixado para camada de serviço)
- [ ] Qual é a estratégia ideal de retry para 429 - quantas tentativas, qual o delay inicial, qual o fator de multiplicação?
- [ ] O cliente deve seguir redirects automaticamente (301, 302, 307, 308) ou deixá-los para a camada de serviço?
- [ ] Deve haver suporte a timeout configurável nas requisições?

## Sugestões ao analista
Informações que ajudariam as próximas tarefas.

- A implementação atual fornece uma base sólida para autenticação que pode ser usada nas próximas tarefas (004 - Implementação de autenticação/login)
- Considere padronizar o formato das exceções para incluir mais detalhes como statusCode e resposta body quando disponível
- Para a tarefa 004, seria útil ter exemplos de payloads esperados nos endpoints de autenticação (login, refresh)
- Verificar se há necessidade de suporte a progresso de download/upload para arquivos grandes (útil para mídia do CDN)