# 01 - Arquitetura do App
Fase: 1 | Status: done | Atualizado em: 2024-10-04

## Resumo
O app "meuapp" é um aplicativo híbrido Flutter com integração a código nativo via Platform Channels. A arquitetura parece seguir padrões comuns de aplicativos Flutter com uso de serviços separados e possivelmente um padrão de estado baseado em notificações ou streams.

## Achados

### Achado 1: Estrutura Híbrida (Flutter + Nativo)
- **Descrição**: O app utiliza Flutter/Dart para a maior parte da UI e lógica de negócios, com integração a código nativo Kotlin/Java via Platform Channels para funcionalidades específicas
- **Evidência**:
  - Blutter conseguiu processar libapp.so (Dart AOT) com sucesso
  - Decompilação nativa mostrou presença de MethodChannel em múltiplos arquivos (O3/m.java, N8/D.java, etc.)
  - Referências a MethodChannel encontradas no pp.txt e arquivos asm/*.dart
- **Confiança**: CONFIRMADO

### Achado 2: Serviços Identificados
- **Descrição**: Presença de serviços específicos no código Dart
- **Evidência**:
  - Referências a "package:ducks/core/services/push_notification_service.dart" encontradas múltiplas vezes no pp.txt
  - Referência a "package:ducks/core/services/relatorio_de_erro.dart" encontrada
  - Strings indicando serviços como: "Fga" (possível classe de serviço), "get_token_null", "get_token_error", "refresh_token"
- **Confiança**: CONFIRMADO

### Achado 3: Mecanismo de Estado e Notificações
- **Descrição**: Uso aparente de mecanismos de notificação para gerenciamento de estado
- **Evidência**:
  - Múltiplas referências a "while dispatching notifications for" no pp.txt (ex: WidgetsBindingObserver.didPushRoute, didPopRoute, etc.)
  - Referências a EventChannel em fontes nativas (wa/n.java)
  - Strings relacionadas a eventos: "community_update", "join_request", "role_change", "title_granted", "post_approved", "post_rejected", "member_joined", "member_left"
- **Confiança**: INFERIDO (baseado em padrões de notificação comuns em Flutter)

### Achado 4: Navegação
- **Descrição**: Sistema de rotas e navegação baseado em GoRouter ou similar
- **Evidência**:
  - Strings relacionadas a rotas: "pushRoute", "popRoute", "pushRouteInformation", "SystemNavigator.pop"
  - Referências a "No GoRouter found in context" e "RouterConfiguration"
  - Strings de ciclo de vida de rotas: "_RouteLifecycle", "RoutePopDisposition"
- **Confiança**: CONFIRMADO

### Achado 5: Plataforma Channels (Ponte Flutter-Nativo)
- **Descrição**: Uso de MethodChannel para comunicação entre Flutter e código nativo
- **Evidência**:
  - Múltiplas referências a MethodChannel no pp.txt e nos arquivos asm/*.dart
  - Exemplos de canais encontrados: "com.fluttercandies/photo_manager/notify", "com.tekartik.sqflite", "dev.fluttercommunity.plus/share", entre outros
  - Referências a MethodChannel nos fontes nativos decompilados (ex: O3/m.java, N8/D.java)
  - Canal específico encontrado: "ducks_id" (swv.dart)
- **Confiança**: CONFIRMADO

## Fluxo (tela -> camada intermediária -> HTTP)
[À ser determinado - necessita análise mais profunda para entender como as chamadas são iniciadas a partir da UI]

## Pseudocódigo (se houver algoritmo)
[Não disponível nesta fase - necessita decompilação mais detalhada do código Dart]

## Lacunas e perguntas (também registradas em Doc/QUESTIONS.md)
1. Qual é a arquitetura de estado utilizada no app (Bloc, Riverpod, Provider, setState, etc.)?
2. Como exatamente as camadas de serviço estão estruturadas e como elas interagem com a camada de rede?
3. Qual é o fluxo exato de navegação entre telas principais do app?
4. Como os Platform Channels são utilizados especificamente no app (quais canais customizados existem além dos de plugins)?
5. Onde fica o código responsável pelas chamadas de rede e como ele é chamado pelas camadas de serviço?

## Tarefas geradas
- 003: Estrutura de camadas e navegação (a ser criada)