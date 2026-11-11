-- | RF05: a 'main' apenas dispara o jogo, sem nenhuma logica de negocio.
module Main (main) where

import Forca.Jogo (executarJogo)

main :: IO ()
main = executarJogo
