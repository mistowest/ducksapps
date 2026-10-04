# 🦆 DucksApps - Análise e Reconstrução (Não-Oficial)

> **Aviso Importante**: Este projeto é uma análise e reconstrução **não-oficial** do aplicativo DucksApps, realizada exclusivamente para fins educacionais e de pesquisa em engenharia reversa. Não temos qualquer afiliação, patrocínio ou conexão com os desenvolvedores oficiais do DucksApps, Amino Apps ou quaisquer entidades relacionadas. Todo o código, análise e documentação aqui apresentados foram desenvolvidos independentemente através de inspeção pública do aplicativo e não devem ser usados para fins comerciais, distribuição não autorizada ou violação de termos de serviço.

## 📱 Sobre o Aplicativo DucksApps

Com base na análise realizada durante este projeto, o DucksApps aparenta ser uma plataforma de redes sociais baseada em comunidades, similar ao modelo do Amino Apps. Os indicadores coletados sugerem:

- **URLs de API principais**:
  - `https://api.duckapps.com.br` - API principal do serviço
  - `https://api.aminoapps.com.br` - Possível integração ou ambiente relacionado
  - `https://cdn.duckapps.com.br` - Rede de entrega de conteúdo (CDN)
  - `https://vmi3521716.contaboserver.net` - Servidor de backup ou ambiente de staging

- **Mecanismo de Autenticação**:
  - Utiliza JWT (JSON Web Tokens) com algoritmo HS256
  - Issuer identificado como "supabase" (indicando uso da plataforma Supabase como backend)
  - Tokens são obtidos através de endpoint `/token` com `grant_type` (password/refresh_token)

- **Headers Obrigatórios**:
  - `X-Client-Info: postgrest-dart/2.7.1` - Header obrigatório em todas as requisições
  - `Authorization: Bearer <jwt>` - Para requisições autenticadas

- **Padrões de Erro Identificados**:
  - `get_token_null`, `get_token_error`
  - `refresh_token`
  - `auth_session_guard:refresh_http_429` (indica tratamento de rate limit 429)

## 🔧 Tecnologias e Arquitetura Descobertas

Durante a análise, foram identificados vários padrões técnicos característicos de aplicativos Flutter/Dart modernos:

### Camada de Rede e Transporte
- Cliente HTTP personalizado baseado em `dart:io.HttpClient`
- Tratamento específico de cabeçalhos obrigatórios
- Mecanismo de refresh automático de token (conforme análise do padrão 429)
- Mapeamento de códigos de status HTTP para exceções específicas do app

### Arquitetura do Aplicativo
- **Utilização de MethodChannel, EventChannel e BasicMessageChannel** para comunicação com código nativo
- **Injeção de Dependência** através de padrão Service Locator
- **Organização por Camadas**: Services, Models, Repositories (padrão comum em apps Flutter escaláveis)
- **Gerenciamento de Estado**: Indicações de uso de notificações (possivelmente Stream ou similar)
- **Navegação**: Uso de GoRouter ou equivalente com rotas identificadas
- **Plataforma Channels**: Canal específico identificado como "ducks_id"

### Serviços Identificados na Análise
- Serviço de push notifications (`package:ducks/core/services/push_notification_service.dart`)
- Serviço de relatório de erro (`package:ducks/core/services/relatorio_de_erro.dart`)
- Estrutura possivelmente organizada em serviços core (`package:ducks/core/services/`)

## 🛠️ Implementação Reconstruída (Dart/Flutter)

Este repositório contém uma reconstrução independente dos componentes-chave identificados durante a análise, implementada em Dart/Flutter siguiendo as especificações descobertas.

### Estrutura do Projeto
```
meuapp-recon/
├── Doc/                    # Documentação da análise e tarefas
│   ├── analysis/           # Análises técnicas por área
│   ├── reports/            # Relatórios de conclusão de tarefas
│   ├── tasks/              # Definições e especificações das tarefas
│   └── templates/          # Templates utilizados na análise
├── Scripts/                # Implementação Dart/Flutter reconstruída
│   ├── ducks_http_client.dart      # Cliente HTTP customizado (Tarefa 002)
│   ├── ducks_http_exception.dart   # Exceções específicas de HTTP
│   ├── routes.dart                 # Definição de rotas do app
│   ├── locator.dart                # Service Locator para injeção de dependência
│   │
│   ├── services/                   # Camada de serviços
│   │   ├── base_service.dart       # Classe base abstrata para serviços
│   │   ├── auth_service.dart       # Serviço de autenticação (login/refresh)
│   │   ├── api_service.dart        # Serviço genérico de API
│   │   └── navigation_service.dart # Serviço de navegação entre telas
│   │
│   └── tests/                      # Testes unitários
│       ├── test_ducks_http_client.dart
│       ├── test_services.dart
│       ├── test_config.py          # Scripts auxiliares de configuração (Python)
│       └── test_transport.py
├── pubspec.yaml              # Configuração do projeto Flutter/Dart
├── pubspec.lock              # Lock de dependências
└── .gitignore                # Configurações de exclusão (APKs, builds, etc.)
```

### Componentes Principais Implementados

#### 1. **DucksHttpClient** (`Scripts/ducks_http_client.dart`)
- Cliente HTTP personalizado que replica exatamente as chamadas de rede do app oficial
- Obrigatoriamente inclui o header `X-Client-Info: postgrest-dart/2.7.1` em todas as requisições
- Gerencia automaticamente o token de autenticação (Bearer JWT)
- Trata códigos de status HTTP comuns (400, 401, 403, 404, 500, 429) com exceções específicas
- Métodos: `get()`, `post()`, `put()`, `delete()`

#### 2. **AuthService** (`Scripts/services/auth_service.dart`)
- Serviço responsável por todas as operações de autenticação
- Métodos:
  - `login(email, password)` - Autenticação com email/senha
  - `logout()` - Limpa o token de autenticação
  - `refreshToken(refreshToken)` - Renova token usando refresh token
  - `isAuthenticated()` - Verifica estado de autenticação
  - Métodos auxiliares para gestão de token (`getAuthToken`, `setAuthToken`, `clearAuthToken`)
  - Métodos HTTP autenticados (`getAuthenticated`, `postAuthenticated`, etc.)

#### 3. **ApiService** (`Scripts/services/api_service.dart`)
- Serviço genérico para chamadas de API não-autenticadas ou quando o token é gerenciado externamente
- Métodos HTTP padrão com opção de autenticação
- Integração com o mesmo `DucksHttpClient` para consistência de headers e tratamento de erros

#### 4. **NavigationService** (`Scripts/services/navigation_service.dart`)
- Serviço singleton para gerenciamento de navegação entre telas
- Implementação simplificada com métodos:
  - `pushRoute(Route route)`
  - `pushAndRemoveUntil(Route route)`
  - `pop()`
  - `canPop()`

#### 5. **Service Locator** (`Scripts/locator.dart`)
- Implementação do padrão Service Locator para injeção de dependência
- Permite registro e recuperação de serviços em toda a aplicação
- Suporta tanto registro lazy quanto singleton pré-criado

#### 6. **Definição de Rotas** (`Scripts/routes.dart`)
- Enum com as rotas identificadas no app:
  - `Route.home`
  - `Route.login`
  - `Route.community`
  - `Route.profile`
  - `Route.settings`

## 📊 Como Este Projeto Foi Construído

Este resultado foi obtido através de uma metodologia estruturada de engenharia reversa colaborativa:

1. **Fase de Análise**: Exame cuidadoso do APK para identificar padrões de rede, arquitetura e componentes
2. **Fase de Implementação**: Reconstrução independente dos componentes identificados em Dart/Flutter
3. **Fase de Validação**: Criação de testes unitários para verificar o comportamento correto
4. **Fase de Documentação**: Registro detalhado de todas as descobertas e decisões

Todas as tarefas foram realizadas seguindo um protocolo de colaboração estrito que proibia a invenção de dados não documentados - apenas evidências obtidas através da análise do app foram utilizadas.

## ⚠️ Limitações e Avisos Importantes

- **Este não é o código-fonte oficial** do DucksApps ou Amino Apps
- A implementação é uma **reconstrução baseada em observação externa**, não acesso ao código fonte original
- Alguns componentes podem ter sido simplificados ou implementados com base em inferências
- **Não recomendado para uso em produção** ou distribuição de aplicativos similares
- **Respeite os termos de serviço** e propriedades intelectuais dos desenvolvedores oficiais
- Este projeto deve ser usado **apenas para fins educacionais** de aprendizado de engenharia reversa, arquitetura de apps móveis e padrões de desenvolvimento Flutter/Dart

## 📚 Recursos e Referências

Durante a análise, foram consultados os seguintes documentos internos do projeto (disponíveis na pasta `Doc/`):

- `Doc/analysis/00-overview.md` - Visão geral do aplicativo
- `Doc/analysis/01-arquitetura.md` - Padrões arquiteturais identificados
- `Doc/analysis/02-rede.md` - Detalhes de comunicação de rede e headers
- `Doc/analysis/03-auth.md` - Mecanismos de autenticação e tokens
- `Doc/analysis/04-usuarios.md` - Endpoints relacionados a usuários
- `Doc/PROTOCOL.md` - Diretrizes de colaboração seguidas durante o projeto
- `Doc/tasks/` - Especificações detalhadas de cada tarefa realizada
- `Doc/reports/` - Relatórios de conclusão de cada fase

## 🙏 Créditos

Este projeto foi realizado como um exercício de engenharia reversa educacional, seguindo práticas éticas e legais de análise de software disponível publicamente. Agradecemos à comunidade de código aberto por ferramentas e conhecimentos que tornaram essa análise possível.

---

**Lembre-se**: Se você gostou do conceito por trás do DucksApps, considere apoiar os desenvolvedores oficiais através dos canais legítimos de distribuição. Este projeto existe apenas para fins de estudo e não deve ser usado como substituto ou base para aplicativos não autorizados.

*Última atualização: Outubro de 2024*