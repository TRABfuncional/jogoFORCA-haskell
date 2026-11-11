-- | RF01: interface grafica textual em ASCII Art.
--
-- Modulo puro: monta strings, quem imprime e o modulo 'Forca.Jogo'.
module Forca.Render
  ( desenharBoneco
  , desenharTela
  , mascaraEspacada
  , linhaTentativas
  , linhaErradas
  , mensagemVitoria
  , mensagemDerrota
  , mensagemTroca
  , cabecalho
  ) where

import Data.List (intersperse)

import Forca.Estado

-- | Os sete estagios do enforcado, do indice 0 (nenhum erro) ao 6.
estagios :: [String]
estagios =
  [ unlines [ "  +---+", "  |   |", "      |", "      |", "      |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", "      |", "      |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", "  |   |", "      |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", " /|   |", "      |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", " /|\\  |", "      |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", " /|\\  |", " /    |", "      |", "=========" ]
  , unlines [ "  +---+", "  |   |", "  O   |", " /|\\  |", " / \\  |", "      |", "=========" ]
  ]

-- | Boneco correspondente a quantidade de erros do estado.
desenharBoneco :: Estado -> String
desenharBoneco e = estagios !! indice
  where indice = max 0 (min maxErros (erros e))

-- | Palavra secreta com as letras separadas, ex.: @_ A _ A _ A@.
mascaraEspacada :: Estado -> String
mascaraEspacada = intersperse ' ' . mascara

linhaTentativas :: Estado -> String
linhaTentativas e = "Tentativas restantes: " ++ show (tentativasRestantes e)

linhaErradas :: Estado -> String
linhaErradas e
  | null erradas = "Letras erradas: (nenhuma)"
  | otherwise    = "Letras erradas: " ++ intersperse ' ' erradas
  where erradas = letrasErradas e

-- | Tela completa de uma rodada.
desenharTela :: Estado -> String
desenharTela e = unlines
  [ ""
  , desenharBoneco e
  , "Palavra: " ++ mascaraEspacada e
  , linhaTentativas e
  , linhaErradas e
  ]

cabecalho :: String
cabecalho = unlines
  [ "==============================="
  , "        JOGO DA FORCA"
  , "==============================="
  , "Digite uma letra por vez (A-Z)."
  ]

mensagemVitoria :: Estado -> String
mensagemVitoria e = unlines
  [ desenharBoneco e
  , "Voce venceu! A palavra era: " ++ palavra e
  ]

mensagemDerrota :: Estado -> String
mensagemDerrota e = unlines
  [ desenharBoneco e
  , "Voce perdeu. A palavra era: " ++ palavra e
  ]

-- | RF03: aviso de que a palavra secreta mudou.
mensagemTroca :: String
mensagemTroca = "A forca trocou a palavra secreta! As letras que voce ja acertou continuam valendo."
