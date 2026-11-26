module Main (main) where

import Classificacao
import Dados
import Leitura
import Tipos

umaCasa :: Double -> String
umaCasa x = show (fromIntegral (round (x * 10) :: Int) / 10 :: Double)

descreverPartida :: Partida -> String
descreverPartida p =
  "R" ++ show (rodada p) ++ " " ++ mandante p ++ " "
    ++ show (golsMandante p) ++ " x " ++ show (golsVisitante p) ++ " " ++ visitante p

relatorioEstatisticas :: [Partida] -> String
relatorioEstatisticas partidas = unlines
  [ "Partidas:        " ++ show (length partidas)
  , "Maior goleada:   " ++ maybe "nenhuma partida" descreverPartida (maiorGoleada partidas)
  , "Media de gols:   " ++ maybe "nenhuma partida" umaCasa (mediaGols partidas)
  , "Aproveitamentos: " ++ unwords (map aproveitamentoDe (classificacao partidas))
  ]
  where
    aproveitamentoDe l = time l ++ "=" ++ umaCasa (aproveitamento l) ++ "%"

relatorioCompleto :: [Partida] -> String
relatorioCompleto partidas = unlines
  [ "=== Tabela final ==="
  , tabelaFormatada (classificacao partidas)
  , "=== Tabela apos a rodada 3 ==="
  , tabelaFormatada (classificacao (ateRodada 3 partidas))
  , "=== Estatisticas ==="
  , relatorioEstatisticas partidas
  ]

main :: IO ()
main = do
  putStr (either (\erro -> "Erro: " ++ mensagemErro erro ++ "\n") relatorioCompleto
                 (lerCampeonato dadosCampeonato))

  putStrLn "=== Entrada com erros: lerCampeonato para no primeiro ==="
  putStrLn (either mensagemErro (const "nenhum erro") (lerCampeonato dadosComErros))
  putStrLn ""
  putStrLn "=== Entrada com erros: todosOsErros lista todos ==="
  mapM_ (putStrLn . mensagemErro) (todosOsErros dadosComErros)
