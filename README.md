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

## Como executar

Rodar direto, sem compilar:

```sh
runghc -isrc src/Main.hs
runghc -isrc tests/Testes.hs
```

Compilar com todos os avisos ligados:

```sh
ghc -Wall -isrc -outputdir build/main   -o campeonato src/Main.hs
ghc -Wall -isrc -outputdir build/testes -o testes     tests/Testes.hs
./campeonato
./testes
```

`-isrc` diz ao GHC para procurar os módulos (`Tipos`, `Leitura`...) na pasta `src`.

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
