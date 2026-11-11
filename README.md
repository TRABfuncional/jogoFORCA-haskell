# Jogo da Forca em Haskell

Trabalho 2 da disciplina **98703-02 Programacao Funcional** - PUCRS, 2026/2
Prof. Julio Henrique A P Machado. Entrega: **13/11/2026**.

## Integrantes

| Nome | GitHub |
|---|---|
| Bernardo Garcia | [@bernardohlg](https://github.com/bernardohlg) |
| Luiz Confortin | [@confortin](https://github.com/confortin) |
| Marco Antonio De Carli Rodegheri | [@MarcoRodegheri](https://github.com/MarcoRodegheri) |
| Roger Rozales Ehlert | [@RogerEhlert](https://github.com/RogerEhlert) |

## Descricao

Implementacao do "Jogo da Forca" como programa de linha de comando, com
interface textual em ASCII Art, palavra sorteada de um dicionario em arquivo
texto e a regra de troca surpresa de palavra descrita no enunciado.

## Dependencias

Alem do GHC, o projeto usa **apenas** o pacote `random`. Instale com o Cabal
(que acompanha uma instalacao completa do GHCup):

```
cabal update
cabal install --lib random
```

## Como rodar

Sempre execute **a partir da raiz do projeto**: o dicionario e lido do caminho
relativo `data/palavras.txt`.

Com Cabal (recomendado):

```
cabal run forca
```

Sem Cabal, direto com o GHC:

```
ghc -isrc -iapp -package random -o forca app/Main.hs
./forca
```

Ou no interpretador:

```
runghc -isrc -package random app/Main.hs
```

## Como testar

```
cabal test --test-show-details=direct
```

Sem Cabal:

```
runghc -isrc -itest test/Spec.hs
```

A suite usa somente a `base` - nenhuma biblioteca de teste extra e necessaria.

## Estrutura e mapa dos requisitos

```
app/Main.hs            chamada unica para o jogo (main sem regra de negocio)
src/Forca/Estado.hs    estado da partida e regras puras
src/Forca/Palavras.hs  leitura do dicionario e sorteios
src/Forca/Render.hs    ASCII Art e textos de tela
src/Forca/Jogo.hs      laco interativo (unico modulo com entrada/saida)
test/Spec.hs           testes automatizados
data/palavras.txt      dicionario com 30 palavras
docs/                  enunciado original e resumo
```

| Requisito | Onde esta implementado |
|---|---|
| **RF01** - interface textual em ASCII Art com boneco, tentativas restantes e status da palavra | `Forca.Render`: `desenharBoneco`, `desenharTela`, `mascaraEspacada`, `linhaTentativas`, `linhaErradas`; mascara vem de `Forca.Estado.mascara` |
| **RF02** - palavra sorteada de arquivo texto com no minimo 25 palavras | `Forca.Palavras`: `carregarDicionario`, `normalizarDicionario`, `sortearPalavra`; dicionario em `data/palavras.txt` (30 palavras) |
| **RF03** - 25% de chance de trocar a palavra quando falta uma letra, mantendo acertos e tentativas | `Forca.Estado`: `faltaUmaLetra`, `trocarPalavra`; `Forca.Palavras.candidatasSubstitutas`; `Forca.Jogo`: `chanceDeTroca`, `talvezTrocarPalavra` |
| **RF04** - perguntar se deseja jogar novamente ao fim da partida | `Forca.Jogo`: `jogarPartidas`, `perguntarSimNao` |
| **RF05** - modularizacao em funcoes pequenas e coesas, `main` sem logica de negocio | `app/Main.hs` so chama `executarJogo`; regra de negocio isolada em `Forca.Estado` (puro), texto em `Forca.Render` (puro), IO so em `Forca.Jogo` |

## Decisoes de implementacao

- **Tentativas**: 6 erros encerram a partida (um por parte do boneco). Repetir
  uma letra ja tentada nao custa tentativa.
- **Acentos**: o dicionario usa palavras sem acento e em maiusculas, para que
  o jogador consiga digitar qualquer letra da palavra em qualquer teclado.
- **RF03 - interpretacao**: a palavra substituta e sorteada com o **mesmo
  numero de letras** da atual, para que as letras ja acertadas caiam em
  posicoes validas. Sao descartadas como candidatas: a propria palavra atual,
  palavras que os chutes atuais ja revelariam por inteiro e palavras que
  contenham alguma letra que o jogador ja errou (senao um erro passado viraria
  acerto de graca). Se nao houver candidata, a palavra simplesmente nao muda.
  O contador de erros e guardado explicitamente no estado, e por isso a troca
  nao mexe nas tentativas restantes.
- **Erros de execucao**: dicionario ausente ou pequeno demais resulta em
  mensagem clara e saida limpa, sem excecao nao tratada.
