-- | Carga do dicionario e sorteio de palavras (RF02 e RF03).
module Forca.Palavras
  ( caminhoDicionario
  , minimoDePalavras
  , carregarDicionario
  , normalizarDicionario
  , candidatasSubstitutas
  , sortearElemento
  , sortearPalavra
  , sortearSubstituta
  ) where

import Control.Exception (IOException, try)
import Data.Char (isAsciiUpper, toUpper)
import Data.List (nub)
import System.Random (randomRIO)

import Forca.Estado (Estado (..), letrasErradas, revelada)

-- | Arquivo-texto com o dicionario, relativo a raiz do projeto.
caminhoDicionario :: FilePath
caminhoDicionario = "data/palavras.txt"

-- | Exigencia do enunciado: no minimo 25 palavras.
minimoDePalavras :: Int
minimoDePalavras = 25

-- | Limpa o conteudo do arquivo: maiusculas, so letras A-Z, sem repeticao.
normalizarDicionario :: [String] -> [String]
normalizarDicionario = nub . filter valida . map limpar
  where
    limpar  = filter isAsciiUpper . map toUpper
    valida p = length p >= 3

-- | Le o dicionario do disco.
--
-- Devolve 'Left' com uma mensagem amigavel em vez de deixar uma excecao
-- vazar: o enunciado penaliza mensagens de erro durante a execucao.
carregarDicionario :: FilePath -> IO (Either String [String])
carregarDicionario caminho = do
  resultado <- try (readFile caminho) :: IO (Either IOException String)
  return (validar resultado)
  where
    validar (Left _) =
      Left ("Nao foi possivel ler o dicionario em \"" ++ caminho
            ++ "\". Rode o jogo a partir da raiz do projeto.")
    validar (Right conteudo) =
      let palavras = normalizarDicionario (lines conteudo)
      in if length palavras < minimoDePalavras
           then Left ("O dicionario precisa de pelo menos "
                      ++ show minimoDePalavras ++ " palavras; encontrei "
                      ++ show (length palavras) ++ ".")
           else Right palavras

-- | RF03: palavras que podem substituir a atual sem quebrar o estado.
--
-- Precisam ter o mesmo tamanho (para que as letras ja acertadas caiam em
-- posicoes validas), ser diferentes da atual, nao estar completamente
-- reveladas pelos chutes atuais e nao conter nenhuma letra que o jogador ja
-- errou -- caso contrario um erro passado viraria um acerto de graca.
candidatasSubstitutas :: [String] -> Estado -> [String]
candidatasSubstitutas dicionario e =
  [ p
  | p <- dicionario
  , length p == length (palavra e)
  , p /= palavra e
  , not (all (revelada e) p)
  , not (any (`elem` letrasErradas e) p)
  ]

-- | Sorteia um elemento de uma lista; 'Nothing' se a lista for vazia.
sortearElemento :: [a] -> IO (Maybe a)
sortearElemento [] = return Nothing
sortearElemento xs = do
  i <- randomRIO (0, length xs - 1)
  return (Just (xs !! i))

-- | RF02: sorteia a palavra secreta da partida.
sortearPalavra :: [String] -> IO (Maybe String)
sortearPalavra = sortearElemento

-- | RF03: sorteia a palavra que vai substituir a atual.
sortearSubstituta :: [String] -> Estado -> IO (Maybe String)
sortearSubstituta dicionario e = sortearElemento (candidatasSubstitutas dicionario e)
