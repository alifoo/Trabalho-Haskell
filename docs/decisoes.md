# Decisões de modelagem

## Camada 1: tipos

Usamos um record para `Partida` em vez de uma tupla `(Int, String, Int, Int, String)`. Com nomes nos campos, trocar `golsMandante` por `golsVisitante` fica visível no código; numa tupla de Ints o compilador aceitaria a troca sem reclamar.

`Resultado` é um tipo soma com três construtores: `Vitoria`, `Empate` e `Derrota`. Um quarto valor ou um "v" minúsculo nem compila, e com `-Wall` o compilador avisa quando uma função esquece um dos três casos.

A `Linha` guarda vitórias, empates, derrotas e gols, mas não guarda pontos nem saldo. Os dois são calculados por `pontosLinha` e `saldo`, então os pontos sempre batem com as vitórias e os empates.

`placarPara` devolve `Maybe (Int, Int)` com os gols feitos e sofridos do ponto de vista do time. `resultadoPara` e `linhaDoTime` usam essa função, e por isso a regra de quem é mandante e quem é visitante está escrita num lugar só.

## Camada 2: classificação

`linhaDoTime` usa `foldl`. A linha do time é um acumulador que começa zerado e soma uma partida por vez, da primeira para a última, que é a mesma ordem de uma conta feita à mão. Como a soma não depende da ordem, `foldr` daria o mesmo resultado.

Os critérios de desempate são os do Brasileirão que dá para calcular com os nossos dados: pontos, vitórias, saldo de gols e gols pró. Ficam numa única função de comparação, `criterios`, montada com `comparing`, `Down` e `<>` e passada para `sortBy`. Vários `sortBy` em sequência dariam errado, porque cada ordenação desfaz a anterior.

O Brasileirão desempata ainda por confronto direto, cartões e sorteio, e nós não temos esses dados. No lugar deles, o último critério é a ordem alfabética, que só serve para a tabela sair sempre na mesma ordem.

Todas as funções são totais. `maiorGoleada` e `mediaGols` tratam a lista vazia na primeira equação e devolvem `Nothing`, então `maximumBy` só recebe lista com elementos. `aproveitamento` devolve 0 para quem não jogou, em vez de dividir por zero. O valor vai de 0 a 100 (é um percentual), e `fromIntegral` converte os `Int` em `Double` para a divisão.

## Camada 3: leitura

Cada `Erro` guarda o número da linha no texto original, contando comentários e linhas em branco, para bater com o que a pessoa vê no arquivo. A exceção é `TimeRepetidoNaRodada`, que guarda a rodada, porque o problema envolve duas linhas.

`lerPartida` usa `do` na mônada `Either`. Cada passo (`lerNumero`, `exigir`) pode falhar, e o primeiro `Left` interrompe o resto, o que dispensa `case` aninhados.

`lerCampeonato` usa `traverse` e para no primeiro erro. `todosOsErros` usa `map` para ler todas as linhas e depois separa erros e partidas com `lefts` e `rights`.

Os espaços em volta de cada campo são removidos por `limpar`, então `1; Coritiba ;2;1;Athletico` é aceito. Rodada zero ou negativa gera `NumeroInvalido`, já que não existe rodada 0.

`separar` usa recursão com `break`. A proibição de recursão vale só para a Camada 2.

`main` é a única função com IO. Os relatórios são montados como `String` por funções puras, e o `main` só imprime.

## Campeonato de teste

São 6 times e 5 rodadas, todos contra todos em turno único: 15 jogos, 3 por rodada. Tem um 0 x 0 na rodada 2, uma vitória por 4 gols (Athletico 4 x 0 Londrina) e três times terminam com 9 pontos:

| Pos | Time      | Pts | V | E | D | GP | GC | SG | Decidiu                     |
|-----|-----------|-----|---|---|---|----|----|----|-----------------------------|
| 1   | Athletico | 9   | 3 | 0 | 2 | 9  | 5  | +4 | mais vitórias (3)           |
| 2   | Coritiba  | 9   | 2 | 3 | 0 | 10 | 6  | +4 | saldo maior que o do Parana |
| 3   | Parana    | 9   | 2 | 3 | 0 | 6  | 3  | +3 |                             |
| 4   | Operario  | 8   | 2 | 2 | 1 | 7  | 5  | +2 |                             |
| 5   | Londrina  | 4   | 1 | 1 | 3 | 4  | 10 | -6 |                             |
| 6   | Cascavel  | 1   | 0 | 1 | 4 | 4  | 11 | -7 |                             |

Depois da rodada 3 a ordem é outra: Athletico, Parana, Operario, Londrina, Coritiba, Cascavel. Parana e Operario estão empatados em pontos e vitórias nesse momento, e o Parana fica na frente pelo saldo.

## Limitações conhecidas

Os nomes dos times e as mensagens não têm acento. Imprimir "Paraná" depende da configuração do terminal (o locale), e num terminal sem UTF-8 o programa pode falhar na hora de imprimir.

Os nomes de time diferenciam maiúsculas e espaços internos: "Coritiba" e "coritiba" viram dois times.

O programa não confere se o campeonato está completo. Ele não avisa se um time jogou menos vezes que os outros, nem se o mesmo confronto aparece em duas rodadas.

O desempate não usa confronto direto, cartões nem sorteio; o último critério é a ordem alfabética.

Se duas partidas tiverem a mesma diferença de gols, `maiorGoleada` devolve a última delas na lista, porque é assim que `maximumBy` funciona.

`nub` e a busca de times repetidos na rodada levam tempo quadrático. Com algumas dezenas de jogos isso não faz diferença.
