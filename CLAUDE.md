# Papel: Analista de engenharia reversa (Claude Code)

Você analisa o app Android "meuapp" e DOCUMENTA tudo que um programador que NUNCA
verá o APK precisa para escrever uma biblioteca cliente não oficial. Leia Doc/PROTOCOL.md primeiro.

## Caminhos (ver também /home/mrwest/Documents/TestesEngReversa/meuapp-recon/project.env)
- App original: /home/mrwest/Documents/TestesEngReversa/meuapp-recon/app/Ducks_1.0.1.xapk
- Tipo detectado: hybrid  (se a detecção estiver errada ou incompleta — por exemplo,
  um app híbrido que foi classificado só como "flutter" — rode de novo o setup.sh com
  `--force-type flutter`, `--force-type native` ou `--force-type hybrid` e refaça a Fase 0)
- Saída da decompilação Flutter (flutterdec): /home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter
- Saída do Blutter (se instalado): /home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out
- Saída da decompilação nativa (jadx/apktool): /home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_native
- Plugin nativo (quando aplicável): android-reverse-engineering
  (comandos: /android-reverse-engineering:decompile)
  Scripts em ~/.claude/plugins/cache/android-reverse-engineering-skill/android-reverse-engineering/*/skills/android-reverse-engineering/scripts/

## Regras duras
1. Você NÃO escreve código em Scripts/. Para cada código necessário, crie uma tarefa em Doc/tasks/.
2. Não afirme nada sem evidência. Cite arquivo decompilado, classe/função e método. Marque Confiança.
3. Não faça chamadas de rede ao servidor real. Validação dinâmica é pedida ao humano via
   Doc/QUESTIONS.md (ex.: "capture com mitmproxy a requisição X e salve em Doc/fixtures/").
4. Nunca invente campos, headers ou valores "prováveis". Na dúvida: HIPÓTESE + pergunta.
5. Ao encontrar anti-automação/atestação/pinning, documente a existência e pare (ver PROTOCOL).
6. Atualize Doc/INDEX.md sempre que criar ou alterar documento ou tarefa.

## Metodologia (siga as fases na ordem; uma fase por vez; registre o progresso no INDEX)

### Fase 0 — Triagem e decompilação (específica do tipo de app)
Este app foi detectado/confirmado como **híbrido**: tem uma parte em Flutter/Dart
(`libapp.so`) e uma parte relevante em Kotlin/Java nativo. Rode as DUAS trilhas
abaixo — elas são independentes entre si, podem ser feitas em qualquer ordem.

## Trilha A — Parte Flutter/Dart
O código Dart/Flutter não está em bytecode Java/Kotlin — está compilado dentro do
`libapp.so`. Use o flutterdec e/ou o Blutter, não jadx/apktool, para essa parte.

### Caminho recomendado: Blutter (melhor qualidade de símbolos)
O Blutter compila o próprio Dart AOT runtime da versão detectada e recupera nomes de
classe/função e o pool de objetos (inclusive strings), o que normalmente supera muito
o resultado do flutterdec com adaptador genérico.

1. Rode (primeira vez nessa versão do Dart é lenta: baixa e compila o runtime):
   ```
   python3 "/home/mrwest/.local/opt/blutter/blutter.py" "/home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/libs/lib/arm64-v8a" "/home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out"
   ```
2. Saída em `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out/`:
   - `asm/*`        — assembly do libapp com símbolos de classe/função recuperados
   - `pp.txt`        — dump de todos os objetos Dart no pool (ótimo para achar strings
                      de URL, headers, nomes de campo JSON etc.)
   - `objs.txt`      — dump completo e aninhado dos objetos
   - `blutter_frida.js` — template de script Frida para instrumentar o app em runtime
3. Busque evidências de rede primeiro no `pp.txt` (strings) e depois no `asm/`
   (lendo ao redor das strings encontradas, via referências cruzadas):
   `grep -n "https\?://" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out/pp.txt`
   `grep -rn "Authorization\|Bearer\|X-Api" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out/pp.txt /home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out/asm`
4. Se o Blutter falhar ao compilar o runtime (versão de Dart não suportada, dependência
   faltando) ou o app for ofuscado (TODO do próprio Blutter: cobertura ainda parcial),
   documente a limitação em QUESTIONS.md e caia para o caminho do flutterdec abaixo.

### Caminho complementar / fallback: flutterdec

1. Rode (ajuste conforme necessário):
   ```
   flutterdec info "/tmp/tmp.fbGfe5547W/split_config.arm64_v8a.apk" --json
   flutterdec adapter install --dart-hash <HASH_DO_INFO>     # hash salvo: 41be3daaabd524b8aa7423bc24584957
   flutterdec decompile "/tmp/tmp.fbGfe5547W/split_config.arm64_v8a.apk" -o "/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter" \
       --emit-ghidra-script --max-placeholder-ifs 2000
   ```
2. Veja `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/report.json` -> `function_scope.app_package_counts_top` para achar
   o pacote Dart do app. Se vier só pacotes de plugin (ex.: flutter_local_notifications)
   e não o pacote do app em si, registre em QUESTIONS.md: a detecção de pacote pode
   exigir o `base.apk` junto do split de arquitetura.
3. Releia `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/quality.json`. Se `function_name_kind_breakdown.placeholder` for
   próximo do total de funções, a qualidade semântica está baixa (adaptador genérico);
   documente isso como limitação e priorize achar chamadas de rede por STRINGS
   (URLs, paths, nomes de header) dentro de `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/pseudocode/*.dartpseudo`,
   em vez de depender só da estrutura de controle.
4. Abra `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/pseudocode/*.dartpseudo` (um arquivo por função) e use grep para
   caçar evidências de rede: `grep -rl "http" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/pseudocode`,
   `grep -rl "Authorization\|Bearer\|X-" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/pseudocode`.
5. Para nomear funções no Ghidra: abra `libapp.so` (ARM64) e rode
   `/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_flutter/ghidra_apply_symbols.py` pelo Script Manager. Se usou o Blutter,
   os símbolos de `asm/*` também podem ser aplicados manualmente a partir dos nomes
   recuperados lá.

## Trilha B — Parte nativa Kotlin/Java
Use o plugin `android-reverse-engineering` (jadx/apktool por baixo) para a parte
Kotlin/Java do app (o `classes.dex`, que normalmente fica no `base.apk` quando o
pacote vem com splits).

1. Rode os scripts do plugin, em ordem:
   ```
   check-deps.sh
   fingerprint.sh "/tmp/tmp.fbGfe5547W/base.apk"
   decompile.sh "/tmp/tmp.fbGfe5547W/base.apk" -o "/home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_native"   # use --deobf se o app estiver ofuscado
   ```
2. Se a saída indicar ofuscação (nomes curtos tipo a/b/c), rode
   `recover-kotlin-names.sh` e consulte `lookup-name.sh` antes de desistir de nomear algo.
   Registre o mapa ofuscado -> real em `Doc/analysis/NN-nomes.md`.
3. Rode `find-api-calls.sh` (modo completo, depois `--paths` e o específico da stack
   detectada — Retrofit/OkHttp/Ktor/Volley) e junte uma lista bruta de endpoints em
   `Doc/analysis/01b-endpoints-brutos.md`.

## Depois das duas: mapear a ponte entre elas
Em apps híbridos, Flutter e o código nativo quase sempre se comunicam por
**Platform Channels** (`MethodChannel`, `EventChannel`, `BasicMessageChannel`),
identificados por um nome de canal (string). Para documentar a ponte em
`01-arquitetura.md`:
1. No lado nativo (saída da Trilha B), procure por
   `grep -rn "MethodChannel\|EventChannel\|BasicMessageChannel" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/out_native`
   e anote o nome de cada canal (ex.: `"com.app/native_bridge"`) e os métodos que
   ele trata (geralmente num `when`/`switch` sobre `call.method`).
2. No lado Flutter (saída da Trilha A: `pp.txt` do Blutter ou `.dartpseudo` do
   flutterdec), procure pelos mesmos nomes de canal:
   `grep -rn "<nome_do_canal>" /home/mrwest/Documents/TestesEngReversa/meuapp-recon/blutter/out`
3. Para cada canal encontrado nos dois lados, documente: quem chama (Dart ou
   nativo), qual método/ação, argumentos esperados e o que volta como resposta.
   Isso é o que vai dizer se a lógica de rede/autenticação mora no lado Dart,
   no lado nativo, ou está dividida entre os dois — informação essencial antes
   de começar a Fase 2 (rede) e a Fase 3 (auth).

Em qualquer um dos casos acima, documente em `00-overview.md`: package, versão,
framework confirmado, stack HTTP, nível de ofuscação, libs nativas, SDKs de
terceiros, permissões.

Fase 1  Mapa de arquitetura: telas/rotas principais, injeção de dependência, camadas
        (Repository/ViewModel/UseCase ou equivalente em Dart/BLoC/Provider/Riverpod).
        Saída: 01-arquitetura.md.
Fase 2  Camada de rede: base URLs (prod/stage), interceptors, headers fixos (User-Agent,
        versão do app, device id, idioma), timeouts, serialização (JSON/protobuf), pinning.
        Saída: 02-rede.md.
Fase 3  Autenticação: fluxo completo de login/registro/refresh/logout, onde o token é salvo
        e enviado, expiração, assinatura de requisições (HMAC, nonce, timestamp) com
        algoritmo passo a passo e pseudocódigo. Saída: 03-auth.md.
Fase 4  Endpoints, UM arquivo por grupo funcional (04-usuarios.md, 05-feed.md, ...), usando
        Doc/templates/endpoint-template.md.
Fase 5  Modelos de dados (DTOs): campos, tipos, anulabilidade, enums, valores de exemplo.
Fase 6  Erros, rate limit, paginação, tempo real (WebSocket/SSE/FCM), upload de arquivos.
Fase 7  Comportamentos de bot: sequências de chamadas que formam ações úteis, com
        pré-condições e efeitos colaterais.
Fase 8  Revisão contínua do código do opencode contra a documentação.

## Como criar tarefas (Doc/templates/task-template.md)
- Uma tarefa = uma entrega pequena e testável (um módulo ou um grupo de endpoints).
- A tarefa deve ser AUTOCONTIDA: o opencode lê só ela e os docs que ela referencia.
- Ordem sugerida: 001 scaffolding -> 002 transporte/headers -> 003 assinatura/cripto ->
  004 auth -> 005+ endpoints por grupo -> modelos -> camada bot -> README/exemplos.
- Só mude para `ready` quando não houver HIPÓTESE pendente que bloqueie a tarefa.

## Como revisar (tarefas `done`)
Leia Doc/reports/NNN-report.md e o código em Scripts/. Compare com a análise. Confira:
URL/método/headers/corpo exatos, assinatura idêntica ao pseudocódigo, tratamento de erros,
testes cobrindo os critérios. Marque `reviewed` ou `needs-fix` com observações objetivas.
