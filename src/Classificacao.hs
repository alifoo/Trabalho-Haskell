module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , criterios
  , classificacao
  , ateRodada
  , diferencaDeGols
  , maiorGoleada
  , golsDaPartida
  , mediaGols
  ) where

import Data.List (maximumBy, sortBy)
import Data.Ord (Down (..), comparing)

import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

linhaVazia :: Time -> Linha
linhaVazia t = Linha
  { time       = t
  , jogos      = 0
  , vitorias   = 0
  , empates    = 0
  , derrotas   = 0
  , golsPro    = 0
  , golsContra = 0
  }

contar :: Resultado -> Resultado -> Int
contar esperado r = if esperado == r then 1 else 0

adicionarPartida :: Time -> Linha -> Partida -> Linha
adicionarPartida t linha p =
  case placarPara t p of
    Nothing -> linha
    Just (feitos, sofridos) ->
      let r = resultadoDoPlacar feitos sofridos
      in linha
           { jogos      = jogos linha + 1
           , vitorias   = vitorias linha + contar Vitoria r
           , empates    = empates linha + contar Empate r
           , derrotas   = derrotas linha + contar Derrota r
           , golsPro    = golsPro linha + feitos
           , golsContra = golsContra linha + sofridos
           }

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t =
  foldl (adicionarPartida t) (linhaVazia t) (filter (participou t) partidas)

pontosLinha :: Linha -> Int
pontosLinha l = pontos Vitoria * vitorias l + pontos Empate * empates l

saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise    = 100 * fromIntegral (pontosLinha l) / fromIntegral (3 * jogos l)

criterios :: Linha -> Linha -> Ordering
criterios a b =
     comparing (Down . pontosLinha) a b
  <> comparing (Down . vitorias) a b
  <> comparing (Down . saldo) a b
  <> comparing (Down . golsPro) a b
  <> comparing time a b

classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy criterios (map (linhaDoTime partidas) (times partidas))

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter (\p -> rodada p <= n)

diferencaDeGols :: Partida -> Int
diferencaDeGols p = abs (golsMandante p - golsVisitante p)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada []       = Nothing
maiorGoleada partidas = Just (maximumBy (comparing diferencaDeGols) partidas)

golsDaPartida :: Partida -> Int
golsDaPartida p = golsMandante p + golsVisitante p

mediaGols :: [Partida] -> Maybe Double
mediaGols []       = Nothing
mediaGols partidas = Just (fromIntegral total / fromIntegral (length partidas))
  where
    total = sum (map golsDaPartida partidas)
