module Leitura
  ( Erro (..)
  , mensagemErro
  , separar
  , limpar
  , linhasUteis
  , lerNumero
  , lerPartida
  , lerCampeonato
  , todosOsErros
  , tabelaFormatada
  ) where

import Data.Char (isSpace)
import Data.Either (lefts, rights)
import Data.List (dropWhileEnd, isPrefixOf, nub)
import Text.Read (readMaybe)

import Classificacao
import Tipos

data Erro
  = CamposInvalidos Int
  | NumeroInvalido Int String
  | PlacarNegativo Int
  | MesmoTime Int Time
  | TimeRepetidoNaRodada Int Time
  deriving (Show, Eq)

mensagemErro :: Erro -> String
mensagemErro (CamposInvalidos n) =
  "Linha " ++ show n ++ ": a linha precisa ter 5 campos (rodada;mandante;gols;gols;visitante)"
mensagemErro (NumeroInvalido n texto) =
  "Linha " ++ show n ++ ": \"" ++ texto ++ "\" nao e um numero valido"
mensagemErro (PlacarNegativo n) =
  "Linha " ++ show n ++ ": o placar nao pode ser negativo"
mensagemErro (MesmoTime n t) =
  "Linha " ++ show n ++ ": " ++ t ++ " nao pode jogar contra si mesmo"
mensagemErro (TimeRepetidoNaRodada r t) =
  "Rodada " ++ show r ++ ": " ++ t ++ " jogou mais de uma vez"

separar :: Char -> String -> [String]
separar sep texto =
  case break (== sep) texto of
    (pedaco, [])        -> [pedaco]
    (pedaco, _ : resto) -> pedaco : separar sep resto

limpar :: String -> String
limpar = dropWhileEnd isSpace . dropWhile isSpace

linhasUteis :: String -> [(Int, String)]
linhasUteis texto = filter (ehPartida . snd) (zip [1 ..] (lines texto))
  where
    ehPartida linha =
      let l = limpar linha
      in not (null l) && not ("#" `isPrefixOf` l)

lerNumero :: Int -> String -> Either Erro Int
lerNumero n texto = maybe (Left (NumeroInvalido n texto)) Right (readMaybe texto)

exigir :: Bool -> Erro -> Either Erro ()
exigir True  _    = Right ()
exigir False erro = Left erro

lerPartida :: Int -> String -> Either Erro Partida
lerPartida n linha =
  case map limpar (separar ';' linha) of
    [textoRodada, nomeMandante, textoGolsM, textoGolsV, nomeVisitante] -> do
      numRodada <- lerNumero n textoRodada
      golsM     <- lerNumero n textoGolsM
      golsV     <- lerNumero n textoGolsV
      exigir (numRodada > 0) (NumeroInvalido n textoRodada)
      exigir (not (null nomeMandante) && not (null nomeVisitante)) (CamposInvalidos n)
      exigir (golsM >= 0 && golsV >= 0) (PlacarNegativo n)
      exigir (nomeMandante /= nomeVisitante) (MesmoTime n nomeMandante)
      Right (Partida numRodada nomeMandante golsM golsV nomeVisitante)
    _ -> Left (CamposInvalidos n)

repetidosNaRodada :: [Partida] -> [(Int, Time)]
repetidosNaRodada partidas = filter apareceMaisDeUmaVez (nub pares)
  where
    pares = concatMap (\p -> [(rodada p, mandante p), (rodada p, visitante p)]) partidas
    apareceMaisDeUmaVez par = length (filter (== par) pares) > 1

verificarRodadas :: [Partida] -> Either Erro ()
verificarRodadas partidas =
  case repetidosNaRodada partidas of
    []           -> Right ()
    ((r, t) : _) -> Left (TimeRepetidoNaRodada r t)

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (\(n, linha) -> lerPartida n linha) (linhasUteis texto)
  verificarRodadas partidas
  Right partidas

todosOsErros :: String -> [Erro]
todosOsErros texto = errosDeLinha ++ errosDeRodada
  where
    resultados    = map (\(n, linha) -> lerPartida n linha) (linhasUteis texto)
    errosDeLinha  = lefts resultados
    errosDeRodada = map (\(r, t) -> TimeRepetidoNaRodada r t) (repetidosNaRodada (rights resultados))

esquerda :: Int -> String -> String
esquerda n s = s ++ replicate (n - length s) ' '

direita :: Int -> String -> String
direita n s = replicate (n - length s) ' ' ++ s

formatarLinha :: Int -> Linha -> String
formatarLinha posicao l =
     direita 3 (show posicao) ++ "  "
  ++ esquerda 12 (time l)
  ++ direita 5 (show (pontosLinha l))
  ++ direita 4 (show (jogos l))
  ++ direita 4 (show (vitorias l))
  ++ direita 4 (show (empates l))
  ++ direita 4 (show (derrotas l))
  ++ direita 5 (show (saldo l))

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (cabecalho : separador : zipWith formatarLinha [1 ..] linhas)
  where
    cabecalho = "Pos  Time          Pts   J   V   E   D   SG"
    separador = replicate (length cabecalho) '-'
