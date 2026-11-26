# PjBL2: Tabela de Classificação em Haskell

Calcula a tabela de um campeonato de futebol a partir dos resultados das partidas, lidos de um texto e validados com `Maybe` e `Either`.

Usamos o GHC local (testado com o GHC 9.14, instalado via GHCup ou Homebrew), não o playground. O código só depende da biblioteca `base`.

## Estrutura

```
src/Tipos.hs          Camada 1: tipos e consultas básicas
src/Classificacao.hs  Camada 2: classificação com funções de ordem superior
src/Leitura.hs        Camada 3: leitura com Maybe/Either e tabela formatada
src/Dados.hs          campeonato de teste (como String)
src/Main.hs           demonstração das três camadas
tests/Testes.hs       testes com resultado esperado
docs/decisoes.md      decisões de modelagem e limitações
```

## Instalação

O projeto precisa do GHC, o compilador de Haskell. O jeito oficial de instalar é pelo [GHCup](https://www.haskell.org/ghcup/).

No Windows, abra o PowerShell (não precisa ser como administrador), cole o comando abaixo e aceite as opções padrão. A instalação baixa bastante coisa e pode demorar.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; try { & ([ScriptBlock]::Create((Invoke-WebRequest https://www.haskell.org/ghcup/sh/bootstrap-haskell.ps1 -UseBasicParsing))) -Interactive -DisableCurl } catch { Write-Error $_ }
```

No macOS e no Linux, rode no terminal:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

No macOS também dá para usar o Homebrew: `brew install ghc`.

Depois de instalar, feche o terminal, abra de novo e confira com `ghc --version`. Se ele disser que `ghc` ou `runghc` não é reconhecido, o terminal não foi reaberto ou a instalação não terminou.

## Como executar

Os comandos abaixo rodam dentro da pasta do projeto (a que tem `src/` e `tests/`).

Rodar direto, sem compilar:

```sh
runghc -isrc src/Main.hs
runghc -isrc tests/Testes.hs
```

O `-isrc` diz ao GHC para procurar os módulos (`Tipos`, `Leitura`...) na pasta `src`.

Compilar com todos os avisos ligados:

```sh
ghc -Wall -isrc -outputdir build/main   -o campeonato src/Main.hs
ghc -Wall -isrc -outputdir build/testes -o testes     tests/Testes.hs
./campeonato
./testes
```

No Windows, os programas compilados são `campeonato.exe` e `testes.exe`, e no PowerShell eles rodam com `.\campeonato` e `.\testes`.

## O que o programa mostra

1. A tabela final do campeonato de teste.
2. A tabela depois da rodada 3.
3. As estatísticas: maior goleada, média de gols e aproveitamento de cada time.
4. Um texto com erros: primeiro o erro em que `lerCampeonato` para, depois a lista completa de `todosOsErros`.

## Formato da entrada

Uma partida por linha, campos separados por `;`. Linhas em branco e linhas que começam com `#` são ignoradas.

```
# rodada;mandante;gols mandante;gols visitante;visitante
1;Athletico;0;2;Parana
```
