-- | Testes automatizados das regras do jogo.
--
-- Usa apenas a biblioteca base: nenhuma dependencia extra precisa ser
-- instalada para rodar os testes.
module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)

import Forca.Estado
import Forca.Jogo (chanceDeTroca)
import Forca.Palavras
import Forca.Render

-- | Um caso de teste: nome e condicao que precisa ser verdadeira.
data Caso = Caso String Bool

casos :: [Caso]
casos = concat
  [ casosRF01
  , casosRF02
  , casosRF03
  , casosRF05
  , casosGerais
  ]

-- Requisito 1: interface textual (mascara, boneco, contadores).
casosRF01 :: [Caso]
casosRF01 =
  [ Caso "RF01 mascara esconde letras nao tentadas"
      (mascara (novoEstado "CASA") == "____")
  , Caso "RF01 mascara revela todas as ocorrencias da letra"
      (mascara (registrarTentativa 'A' (novoEstado "CASA")) == "_A_A")
  , Caso "RF01 mascara espacada separa as letras"
      (mascaraEspacada (novoEstado "BOLO") == "_ _ _ _")
  , Caso "RF01 boneco comeca sem cabeca"
      (notElem 'O' (desenharBoneco (novoEstado "CASA")))
  , Caso "RF01 boneco ganha a cabeca no primeiro erro"
      (elem 'O' (desenharBoneco umErro))
  , Caso "RF01 boneco avanca a cada erro"
      (desenharBoneco (registrarTentativa 'Z' (novoEstado "CASA"))
         /= desenharBoneco (novoEstado "CASA"))
  , Caso "RF01 lista de erradas comeca vazia"
      (linhaErradas (novoEstado "CASA") == "Letras erradas: (nenhuma)")
  , Caso "RF01 contador de tentativas aparece na tela"
      (linhaTentativas (novoEstado "CASA") == "Tentativas restantes: 6")
  ]

-- Requisito 2: dicionario vindo de arquivo com no minimo 25 palavras.
casosRF02 :: [Caso]
casosRF02 =
  [ Caso "RF02 normalizacao poe tudo em maiusculas"
      (normalizarDicionario ["casa", "bolo"] == ["CASA", "BOLO"])
  , Caso "RF02 normalizacao descarta linhas vazias e curtas"
      (normalizarDicionario ["", "ab", "casa"] == ["CASA"])
  , Caso "RF02 normalizacao remove duplicatas"
      (normalizarDicionario ["casa", "CASA"] == ["CASA"])
  , Caso "RF02 exigencia minima do enunciado e 25 palavras"
      (minimoDePalavras == 25)
  ]

-- Requisito 3: troca de palavra quando falta uma letra.
casosRF03 :: [Caso]
casosRF03 =
  [ Caso "RF03 detecta que falta exatamente uma letra"
      (faltaUmaLetra quaseVencendo)
  , Caso "RF03 nao dispara quando faltam duas letras"
      (not (faltaUmaLetra (registrarTentativa 'C' (novoEstado "CASA"))))
  , Caso "RF03 troca preserva as tentativas restantes"
      (tentativasRestantes (trocarPalavra "MESA" quaseVencendo)
         == tentativasRestantes quaseVencendo)
  , Caso "RF03 troca preserva as letras ja acertadas na nova palavra"
      (mascara (trocarPalavra "MESA" quaseVencendo) == "__SA")
  , Caso "RF03 candidatas tem o mesmo tamanho da palavra atual"
      (all ((== 4) . length) (candidatasSubstitutas dicionarioDeTeste quaseVencendo))
  , Caso "RF03 candidatas excluem a propria palavra atual"
      (notElem "CASA" (candidatasSubstitutas dicionarioDeTeste quaseVencendo))
  , Caso "RF03 candidatas excluem palavras de tamanho diferente"
      (notElem "LIVRO" (candidatasSubstitutas dicionarioDeTeste quaseVencendo))
  , Caso "RF03 candidatas excluem palavras com letra ja errada"
      (notElem "ZEBU" (candidatasSubstitutas dicionarioDeTeste comErro))
  , Caso "RF03 troca nao transforma acerto antigo em letra errada"
      (letrasErradas (trocarPalavra "MESA" quaseVencendo)
         == letrasErradas quaseVencendo)
  , Caso "RF03 troca nao aumenta a contagem de erros"
      (erros (trocarPalavra "LUPA" comErro) == erros comErro)
  , Caso "RF03 chance de troca configurada e de 25 por cento"
      (chanceDeTroca == 25)
  ]

-- Requisito 5: coesao -- a logica vive em funcoes pequenas e puras.
casosRF05 :: [Caso]
casosRF05 =
  [ Caso "RF05 registrarTentativa nao altera o estado ao repetir letra"
      (registrarTentativa 'A' umAcerto == umAcerto)
  , Caso "RF05 acerto nao consome tentativa"
      (tentativasRestantes umAcerto == maxErros)
  , Caso "RF05 erro consome exatamente uma tentativa"
      (tentativasRestantes umErro == maxErros - 1)
  ]

casosGerais :: [Caso]
casosGerais =
  [ Caso "vitoria quando todas as letras foram reveladas"
      (venceu (registrarTentativa 'S'
                 (registrarTentativa 'C' quaseVencendo)))
  , Caso "derrota apos seis erros"
      (perdeu (foldr registrarTentativa (novoEstado "CASA") "ZXWVUT"))
  , Caso "fim de jogo cobre vitoria e derrota"
      (fimDeJogo (foldr registrarTentativa (novoEstado "CASA") "ZXWVUT"))
  , Caso "letras erradas listam apenas o que nao esta na palavra"
      (letrasErradas umErro == "Z")
  , Caso "partida nova nao esta terminada"
      (not (fimDeJogo (novoEstado "CASA")))
  ]

-- Estados auxiliares -------------------------------------------------------

-- | "CASA" com A e S acertados: falta somente o C.
quaseVencendo :: Estado
quaseVencendo = foldr registrarTentativa (novoEstado "CASA") "AS"

umAcerto :: Estado
umAcerto = registrarTentativa 'A' (novoEstado "CASA")

umErro :: Estado
umErro = registrarTentativa 'Z' (novoEstado "CASA")

-- | "CASA" com A e S acertados e Z errado.
comErro :: Estado
comErro = registrarTentativa 'Z' quaseVencendo

dicionarioDeTeste :: [String]
dicionarioDeTeste = ["CASA", "MESA", "REDE", "ZEBU", "LIVRO", "JANELA"]

-- Execucao -----------------------------------------------------------------

main :: IO ()
main = do
  let falhas = [nome | Caso nome ok <- casos, not ok]
  mapM_ (\(Caso nome ok) -> putStrLn ((if ok then "ok   - " else "FALHA- ") ++ nome)) casos
  putStrLn ("\n" ++ show (length casos - length falhas) ++ "/"
            ++ show (length casos) ++ " testes passaram.")
  unless (null falhas) exitFailure
