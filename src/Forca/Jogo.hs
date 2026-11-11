-- | RF04 e RF05: laco interativo da partida.
--
-- Este modulo concentra a entrada/saida. Toda regra de negocio vem de
-- 'Forca.Estado'; todo texto vem de 'Forca.Render'; todo sorteio vem de
-- 'Forca.Palavras'.
module Forca.Jogo
  ( executarJogo
  , chanceDeTroca
  ) where

import Control.Monad (when)
import Data.Char (toLower)
import System.IO (BufferMode (NoBuffering), hSetBuffering, isEOF, stdout)
import System.Random (randomRIO)

import Forca.Estado
import Forca.Palavras
import Forca.Render

-- | RF03: chance percentual de trocar a palavra quando falta uma letra.
chanceDeTroca :: Int
chanceDeTroca = 25

-- | Ponto de entrada do jogo.
executarJogo :: IO ()
executarJogo = do
  hSetBuffering stdout NoBuffering
  dicionario <- carregarDicionario caminhoDicionario
  case dicionario of
    Left erro -> putStrLn erro
    Right palavras -> do
      putStr cabecalho
      jogarPartidas palavras

-- | RF04: encadeia partidas enquanto o jogador quiser jogar.
jogarPartidas :: [String] -> IO ()
jogarPartidas dicionario = do
  sorteada <- sortearPalavra dicionario
  case sorteada of
    Nothing -> putStrLn "Dicionario vazio: nao ha palavra para sortear."
    Just p -> do
      estadoFinal <- rodada dicionario (novoEstado p)
      putStr (if venceu estadoFinal
                then mensagemVitoria estadoFinal
                else mensagemDerrota estadoFinal)
      continuar <- perguntarSimNao "Deseja jogar novamente? (s/n): "
      when continuar (jogarPartidas dicionario)

-- | Uma rodada: desenha, le o chute, atualiza o estado e repete.
rodada :: [String] -> Estado -> IO Estado
rodada dicionario e
  | fimDeJogo e = return e
  | otherwise = do
      putStr (desenharTela e)
      chute <- lerChute e
      let depoisDoChute = registrarTentativa chute e
      depoisDaTroca <- talvezTrocarPalavra dicionario depoisDoChute
      rodada dicionario depoisDaTroca

-- | Le um chute valido, insistindo ate receber uma letra A-Z inedita.
lerChute :: Estado -> IO Char
lerChute e = do
  putStr "Sua letra: "
  fimDaEntrada <- isEOF
  if fimDaEntrada
    then return ' '
    else do
      linha <- getLine
      case filter letraValida linha of
        [] -> do
          putStrLn "Digite uma letra de A a Z."
          lerChute e
        (c:_)
          | letraJaTentada c e -> do
              putStrLn ("Voce ja tentou a letra " ++ [normalizarLetra c] ++ ".")
              lerChute e
          | otherwise -> return c

-- | RF03: com 25% de chance, troca a palavra quando falta uma unica letra.
talvezTrocarPalavra :: [String] -> Estado -> IO Estado
talvezTrocarPalavra dicionario e
  | not (faltaUmaLetra e) = return e
  | otherwise = do
      sorte <- randomRIO (1, 100 :: Int)
      if sorte > chanceDeTroca
        then return e
        else do
          substituta <- sortearSubstituta dicionario e
          case substituta of
            Nothing -> return e
            Just nova -> do
              putStrLn ""
              putStrLn mensagemTroca
              return (trocarPalavra nova e)

-- | Pergunta de sim/nao tolerante a entradas estranhas.
perguntarSimNao :: String -> IO Bool
perguntarSimNao pergunta = do
  putStr pergunta
  fimDaEntrada <- isEOF
  if fimDaEntrada
    then return False
    else do
      linha <- getLine
      case map toLower (filter (/= ' ') linha) of
        ('s':_) -> return True
        ('n':_) -> return False
        _ -> do
          putStrLn "Responda com s ou n."
          perguntarSimNao pergunta
