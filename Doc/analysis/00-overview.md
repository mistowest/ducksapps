# 00 - Visão Geral do App
Fase: 0 | Status: completo | Atualizado em: 2024-10-04

## Resumo
O aplicativo "meuapp" é um app híbrido desenvolvido principalmente com Flutter/Dart (versão 3.12.0) contendo uma libapp.so compilada em AOT, com alguma camada nativa em Kotlin/Java para funcionalidades específicas. O app utiliza OkHttp para comunicações de rede e tem como domínio principal duckapps.com.br, com integrações a serviços como Amino Apps, Firebase e diversos plugins Flutter.

## Achados

### Achado 1: Tipo e estrutura do app
- **Descrição**: App híbrido com código Flutter/Dart em libapp.so e componentes nativos em Kotlin/Java
- **Evidência**: 
  - fingerprint.sh indicou "Flutter (code-only split?)" no base.apk
  - Blutter conseguiu processar libapp.so com Dart version 3.12.0
  - Diretório lib/ contém libapp.so (27MB) e libflutter.so (11MB)
- **Confiança**: CONFIRMADO

### Achado 2: Pacote do aplicativo
- **Descrição**: Pacote principal do app é com.ducks.app
- **Evidência**:
  - Nome do APK: Ducks_1.0.1.xapk
  - Strings em pp.txt referenciando "com.ducks.app" (ex: play.google.com/store/account/subscriptions?sku=ducks_plus_monthly&package=com.ducks.app)
  - Diretório community com package com.ducks.community
- **Confiança**: CONFIRMADO

### Achado 3: Endpoints de API identificados
- **Descrição**: URLs de endpoints utilizados pelo app para comunicação com servidores
- **Evidência**: Strings encontradas em blutter/out/pp.txt:
  - https://api.duckapps.com.br
  - https://api.aminoapps.com.br
  - https://api.aminoapps.com.br/bootstrap
  - https://api.aminoapps.com.br/config
  - https://cdn.duckapps.com.br
  - https://vmi3521716.contaboserver.net
  - https://duckapps.com.br/apoie
  - https://duckapps.com.br/reset-password
  - https://duckapps.com.br/email-changed
- **Confiança**: CONFIRMADO

### Achado 4: Mecanismo de autenticação
- **Descrição**: Uso de tokens Bearer para autenticação nas requisições
- **Evidência**: 
  - String em pp.txt: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzgwODcyNjQ0LCJleHAiOjIwOTYyMzI2NDR9.Eus5Kl0BPJy4-cGa9yzZKO252XD1vArNAKRYv5Ql1hQ"
  - Strings "Authorization" e "Bearer " encontradas no pp.txt
  - Referências em assembly mostrando uso dessas strings
- **Confiança**: CONFIRMADO

### Achado 5: Stack de rede
- **Descrição**: Utilização do OkHttp para client HTTP
- **Evidência**: fingerprint.sh indicou "HTTP stack: OkHttp"
- **Confiança**: CONFIRMADO

### Achado 6: Plataforma Channels (ponte Flutter-Nativo)
- **Descrição**: Uso de MethodChannel para comunicação entre Flutter e código nativo
- **Evidência**:
  - Múltiplas referências a MethodChannel no pp.txt e nos arquivos asm/*.dart
  - Exemplos de canais encontrados: "com.fluttercandies/photo_manager/notify", "com.tekartik.sqflite", "dev.fluttercommunity.plus/share", entre outros
  - Referências a MethodChannel nos fontes nativos decompilados (ex: O3/m.java, N8/D.java)
- **Confiança**: CONFIRMADO
  - **Nota**: Canais específicos do app ainda não identificados; necessário investigar mais para encontrar canais com prefixo "com.ducks" ou similares

### Achado 7: Ofuscação
- **Descrição**: Baixo nível de ofuscação detectado
- **Evidência**: fingerprint.sh indicou "Obfuscation: LOW (no significant short-name namespace pollution)"
- **Confiança**: CONFIRMADO

### Achado 8: SDKs e serviços de terceiros
- **Descrição**: Integração com diversos serviços externos
- **Evidência**: 
  - Firebase (strings de inicialização do Firebase)
  - Google Play Services
  - Facebook SDK
  - Plugins Flutter como: flutter_local_notifications, sqflite, share, path_provider, image_picker, url_launcher, webview_flutter, video_player, media_kit, etc.
- **Confiança**: CONFIRMADO

## Fluxo (tela -> camada intermediária -> HTTP)
[À ser determinado nas próximas fases - necessita análise mais profunda do fluxo de navegação e chamadas de método]

## Pseudocódigo (se houver algoritmo)
[Não aplicável nesta fase]

## Lacunas e perguntas (também registradas em Doc/QUESTIONS.md)
1. Qual é o canal MethodChannel específico usado pelo app para comunicação Flutter ↔ Nativo?
2. Onde fica o código Dart responsável pelas chamadas de rede? (provavelmente em libapp.dartpseudo ou similar)
3. Quais são os endpoints exatos e seus métodos HTTP? (necessita análise de chamadas de método ao redor dos URLs)
4. Como exatamente o token Bearer é obtido e renovado? (necessita análise do fluxo de auth)
5. O app utiliza certificate pinning ou outros mecanismos de segurança de rede?

## Tarefas geradas
- 001: Esqueleto do projeto e testes (já criada)