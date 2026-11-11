-- | Estado do jogo e toda a logica pura da partida.
--
-- Este modulo nao faz entrada/saida: todas as funcoes sao puras, o que
-- atende ao RF05 (modularizacao em funcoes pequenas e coesas) e permite
-- testar a regra de negocio isoladamente.
module Forca.Estado
  ( Estado(..)
  , maxErros
  , erros
  , novoEstado
  , registrarTentativa
  , trocarPalavra
  , normalizarLetra
  , letraValida
  , letraJaTentada
  , letraPertenceAPalavra
  , tentativasRestantes
  , revelada
  , mascara
  , letrasErradas
  , letrasFaltantes
  , faltaUmaLetra
  , venceu
  , perdeu
  , fimDeJogo
  ) where

import Data.Char (isAsciiUpper, toUpper)
import Data.List (nub, sort)

-- | Uma partida em andamento.
--
-- As letras erradas sao guardadas explicitamente (em vez de serem derivadas
-- da palavra secreta) justamente porque o RF03 troca a palavra no meio da
-- partida: um acerto antigo que nao exista na palavra nova nao pode virar
-- erro retroativo, nem mexer nas tentativas restantes.
data Estado = Estado
  { palavra  :: String  -- ^ Palavra secreta, sempre em maiusculas.
  , tentadas :: [Char]  -- ^ Letras ja chutadas, sem repeticao e ordenadas.
  , erradas  :: [Char]  -- ^ Chutes que ja custaram uma tentativa.
  } deriving (Eq, Show)

-- | Numero de erros que encerra a partida (tamanho do boneco da forca).
maxErros :: Int
maxErros = 6

-- | Comeca uma partida com a palavra informada.
novoEstado :: String -> Estado
novoEstado p = Estado { palavra = map toUpper p, tentadas = [], erradas = [] }

-- | Converte um chute para a forma usada internamente.
normalizarLetra :: Char -> Char
normalizarLetra = toUpper

-- | Apenas letras A-Z sao aceitas como chute.
letraValida :: Char -> Bool
letraValida = isAsciiUpper . normalizarLetra

letraJaTentada :: Char -> Estado -> Bool
letraJaTentada c e = normalizarLetra c `elem` tentadas e

letraPertenceAPalavra :: Char -> Estado -> Bool
letraPertenceAPalavra c e = normalizarLetra c `elem` palavra e

-- | Aplica um chute. Repetir uma letra ja tentada nao custa tentativa.
registrarTentativa :: Char -> Estado -> Estado
registrarTentativa c e
  | letraJaTentada c e = e
  | otherwise =
      e { tentadas = sort (nub (l : tentadas e))
        , erradas  = if acertou then erradas e else sort (nub (l : erradas e))
        }
  where
    l        = normalizarLetra c
    acertou  = l `elem` palavra e

-- | RF03: troca a palavra secreta preservando letras tentadas e erradas.
--
-- Como 'tentadas' e 'erradas' permanecem intactos, as letras ja acertadas
-- preenchem automaticamente as posicoes correspondentes da nova palavra e o
-- numero de tentativas restantes continua o mesmo.
trocarPalavra :: String -> Estado -> Estado
trocarPalavra nova e = e { palavra = map toUpper nova }

-- | Quantidade de chutes que ja custaram uma tentativa.
erros :: Estado -> Int
erros = length . erradas

tentativasRestantes :: Estado -> Int
tentativasRestantes e = maxErros - erros e

-- | Uma letra aparece na tela quando ja foi chutada.
revelada :: Estado -> Char -> Bool
revelada e c = c `elem` tentadas e

-- | Palavra secreta com as letras ainda desconhecidas trocadas por @_@.
mascara :: Estado -> String
mascara e = map ocultar (palavra e)
  where ocultar c = if revelada e c then c else '_'

letrasErradas :: Estado -> [Char]
letrasErradas = erradas

-- | Letras distintas da palavra que ainda nao foram descobertas.
letrasFaltantes :: Estado -> [Char]
letrasFaltantes e = nub (filter (not . revelada e) (palavra e))

-- | RF03: o jogador esta a uma unica letra de vencer.
faltaUmaLetra :: Estado -> Bool
faltaUmaLetra e = length (letrasFaltantes e) == 1

venceu :: Estado -> Bool
venceu e = all (revelada e) (palavra e)

perdeu :: Estado -> Bool
perdeu e = tentativasRestantes e <= 0 && not (venceu e)

fimDeJogo :: Estado -> Bool
fimDeJogo e = venceu e || perdeu e
