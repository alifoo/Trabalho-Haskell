module Tipos
  ( Time
  , Resultado (..)
  , Partida (..)
  , Linha (..)
  , resultadoDoPlacar
  , placarPara
  , participou
  , resultadoPara
  , times
  ) where

import Data.List (nub, sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)

data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

data Linha = Linha
  { time       :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

resultadoDoPlacar :: Int -> Int -> Resultado
resultadoDoPlacar meus deles
  | meus > deles  = Vitoria
  | meus == deles = Empate
  | otherwise     = Derrota

placarPara :: Time -> Partida -> Maybe (Int, Int)
placarPara t p
  | t == mandante p  = Just (golsMandante p, golsVisitante p)
  | t == visitante p = Just (golsVisitante p, golsMandante p)
  | otherwise        = Nothing

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p = fmap (uncurry resultadoDoPlacar) (placarPara t p)

times :: [Partida] -> [Time]
times partidas = sort (nub (concatMap doisTimes partidas))
  where
    doisTimes p = [mandante p, visitante p]
