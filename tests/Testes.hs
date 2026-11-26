module Main (main) where

import Classificacao
import Dados
import Leitura
import Tipos

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK      " ++ nome)
  | otherwise          = putStrLn ("FALHOU  " ++ nome ++ ": " ++ show obtido)

partidas :: [Partida]
partidas = either (const []) id (lerCampeonato dadosCampeonato)

exemplo :: Partida
exemplo = Partida 1 "Coritiba" 2 1 "Athletico"

tabelaFinalEsperada :: [Linha]
tabelaFinalEsperada =
  [ Linha "Athletico" 5 3 0 2  9  5
  , Linha "Coritiba"  5 2 3 0 10  6
  , Linha "Parana"    5 2 3 0  6  3
  , Linha "Operario"  5 2 2 1  7  5
  , Linha "Londrina"  5 1 1 3  4 10
  , Linha "Cascavel"  5 0 1 4  4 11
  ]

main :: IO ()
main = do
  putStrLn "--- Camada 1 ---"
  testar "resultadoPara mandante"      (resultadoPara "Coritiba" exemplo)  (Just Vitoria)
  testar "resultadoPara visitante"     (resultadoPara "Athletico" exemplo) (Just Derrota)
  testar "resultadoPara quem nao jogou" (resultadoPara "Parana" exemplo)   Nothing
  testar "resultadoPara empate"        (resultadoPara "Parana" (Partida 1 "Parana" 0 0 "Operario")) (Just Empate)
  testar "participou"                  (participou "Athletico" exemplo, participou "Parana" exemplo) (True, False)
  testar "times sem repeticao e em ordem" (times partidas)
    ["Athletico", "Cascavel", "Coritiba", "Londrina", "Operario", "Parana"]
  testar "times de lista vazia"        (times []) []

  putStrLn "--- Camada 2 ---"
  testar "pontos"                      (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "classificacao final"         (classificacao partidas) tabelaFinalEsperada
  testar "pontos da tabela final"      (map pontosLinha (classificacao partidas)) [9, 9, 9, 8, 4, 1]
  testar "desempate por vitorias (Athletico 3 x 2 Coritiba)"
    (criterios (linhaDoTime partidas "Athletico") (linhaDoTime partidas "Coritiba")) LT
  testar "desempate por saldo (Coritiba +4 x +3 Parana)"
    (map saldo [linhaDoTime partidas "Coritiba", linhaDoTime partidas "Parana"]) [4, 3]
  testar "Coritiba fica na frente do Parana"
    (criterios (linhaDoTime partidas "Coritiba") (linhaDoTime partidas "Parana")) LT
  testar "ordem na rodada 3"           (map time (classificacao (ateRodada 3 partidas)))
    ["Athletico", "Parana", "Operario", "Londrina", "Coritiba", "Cascavel"]
  testar "rodada 3 diferente da final" (classificacao (ateRodada 3 partidas) /= classificacao partidas) True
  testar "ateRodada 1 tem 3 partidas"  (length (ateRodada 1 partidas)) 3
  testar "aproveitamento do Athletico" (aproveitamento (linhaDoTime partidas "Athletico")) 60.0
  testar "aproveitamento sem jogos"    (aproveitamento (linhaDoTime [] "Athletico")) 0
  testar "maiorGoleada"                (maiorGoleada partidas) (Just (Partida 3 "Athletico" 4 0 "Londrina"))
  testar "maiorGoleada []"             (maiorGoleada []) Nothing
  testar "mediaGols"                   (mediaGols partidas) (Just (40 / 15))
  testar "mediaGols []"                (mediaGols []) Nothing
  testar "classificacao []"            (classificacao []) []

  putStrLn "--- Camada 3 ---"
  testar "separar"                     (separar ';' "1;Coritiba;2") ["1", "Coritiba", "2"]
  testar "separar campo vazio"         (separar ';' "a;;b") ["a", "", "b"]
  testar "lerCampeonato valido da Right" (fmap length (lerCampeonato dadosCampeonato)) (Right 15)
  testar "lerCampeonato texto vazio"   (lerCampeonato "") (Right [])
  testar "lerPartida valida"           (lerPartida 1 "1; Coritiba ;2;1;Athletico") (Right exemplo)
  testar "erro CamposInvalidos"        (lerPartida 4 "1;Londrina;1;Cascavel") (Left (CamposInvalidos 4))
  testar "erro CamposInvalidos (time em branco)" (lerPartida 9 "1;;1;0;Cascavel") (Left (CamposInvalidos 9))
  testar "erro NumeroInvalido (\"dois\")" (lerPartida 3 "1;Parana;dois;0;Operario") (Left (NumeroInvalido 3 "dois"))
  testar "erro NumeroInvalido (\"2a\")"  (lerPartida 3 "1;Parana;2a;0;Operario") (Left (NumeroInvalido 3 "2a"))
  testar "erro PlacarNegativo"         (lerPartida 5 "2;Coritiba;-1;0;Parana") (Left (PlacarNegativo 5))
  testar "erro MesmoTime"              (lerPartida 6 "2;Londrina;1;1;Londrina") (Left (MesmoTime 6 "Londrina"))
  testar "erro TimeRepetidoNaRodada"
    (lerCampeonato (unlines ["2;Athletico;0;0;Operario", "2;Athletico;3;1;Cascavel"]))
    (Left (TimeRepetidoNaRodada 2 "Athletico"))
  testar "lerCampeonato para no primeiro erro" (lerCampeonato dadosComErros) (Left (NumeroInvalido 3 "dois"))
  testar "todosOsErros lista todos"    (todosOsErros dadosComErros)
    [ NumeroInvalido 3 "dois"
    , CamposInvalidos 4
    , PlacarNegativo 5
    , MesmoTime 6 "Londrina"
    , TimeRepetidoNaRodada 2 "Athletico"
    ]
  testar "todosOsErros sem erros"      (todosOsErros dadosCampeonato) []
  testar "tabelaFormatada vazia tem so cabecalho" (length (lines (tabelaFormatada []))) 2
