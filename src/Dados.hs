module Dados (dadosCampeonato, dadosComErros) where

dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;mandante;gols mandante;gols visitante;visitante"
  , "1;Athletico;0;2;Parana"
  , "1;Operario;1;1;Coritiba"
  , "1;Londrina;2;1;Cascavel"
  , ""
  , "2;Athletico;2;0;Cascavel"
  , "2;Coritiba;1;1;Londrina"
  , "2;Parana;0;0;Operario"
  , ""
  , "3;Athletico;4;0;Londrina"
  , "3;Cascavel;1;2;Operario"
  , "3;Coritiba;2;2;Parana"
  , ""
  , "4;Athletico;2;1;Operario"
  , "4;Londrina;0;1;Parana"
  , "4;Cascavel;1;4;Coritiba"
  , ""
  , "5;Athletico;1;2;Coritiba"
  , "5;Parana;1;1;Cascavel"
  , "5;Operario;3;1;Londrina"
  ]

dadosComErros :: String
dadosComErros = unlines
  [ "# campeonato com erros de digitacao"
  , "1;Coritiba;2;1;Athletico"
  , "1;Parana;dois;0;Operario"
  , "1;Londrina;1;Cascavel"
  , "2;Coritiba;-1;0;Parana"
  , "2;Londrina;1;1;Londrina"
  , "2;Athletico;0;0;Operario"
  , "2;Athletico;3;1;Cascavel"
  ]
