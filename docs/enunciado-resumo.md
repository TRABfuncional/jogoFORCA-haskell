# Trabalho 2 (2026/2) — Programação Funcional (PUCRS, Prof. Julio Henrique A P Machado)

Fonte: `docs/trabalho2_2026_2.pdf` (baixado do Moodle, TDE | Trabalho Discente Efetivo)

## A) Entrega
13/11/2026 — Sala de entrega no Moodle (aberta desde 23/10/2026, vence 13/11/2026 23:59)

## B) Objetivo
Consolidar conhecimento sobre construção de funções recursivas e programação interativa em Haskell.

## C) Enunciado — Jogo da Forca (CLI, interação via console de texto)

- **RF01** — Interface gráfica textual em ASCII Art: desenho do corpo do enforcado, número de
  tentativas restantes e status da palavra secreta.
- **RF02** — A palavra deve ser sorteada aleatoriamente a partir de um arquivo texto contendo um
  dicionário de palavras da língua portuguesa (no mínimo 25 palavras).
  Dicas do enunciado: `System.Random` (geradores aleatórios), `System.IO` (entrada/saída).
- **RF03** — Se o jogador estiver próximo da vitória (a uma letra de acertar a palavra), o jogo pode
  decidir aleatoriamente (**chance de 25%**) sortear uma nova palavra. Nesse caso, as letras que o
  usuário já acertou da palavra antiga devem preencher as posições da nova palavra de forma
  adequada, mas o número de tentativas restantes continua o mesmo.
- **RF04** — Ao final da partida (vitória ou derrota), perguntar ao jogador se deseja jogar novamente.
- **RF05** — A implementação deve obrigatoriamente seguir modularização em funções menores, cada
  qual com alto grau de coesão. Entregas com a maior parte da lógica em uma única função são
  consideradas inadequadas e sofrem desconto. A função `main` NÃO pode ser tornada de baixa coesão
  com adição de lógica de negócio indevida.

### DICA do enunciado
O pacote `random` deve estar instalado. É necessário o gerenciador de pacotes `Cabal` (instalação
completa do GHCup inclui o Cabal):

    cabal install --lib random
    ghci -package random main.hs

## D) Desenvolvimento e avaliação
- Individual ou em grupos de, no máximo, **4 alunos**.
- Programas que não consigam ser executados recebem **nota zero**.
- Mensagens de erro durante a execução são consideradas erros de execução e acarretam desconto.
- Avaliação conforme critérios do professor, considerando o que é pedido no enunciado e o que foi
  realizado com sucesso de acordo com os **princípios do paradigma de programação funcional**.
- Qualquer módulo adicional utilizado deve vir acompanhado das instruções de instalação das
  dependências.
- **Trabalhos copiados resultam em nota zero para todos os alunos envolvidos.**

## E) Entrega do trabalho
- Todos os arquivos-fonte necessários à execução empacotados em um **único arquivo .zip**, submetido
  pelo Moodle até a data de entrega.
- Deve haver um arquivo **readme** com todas as instruções de execução, apontando necessidade de
  configuração de biblioteca adicional.
- Não são aceitos trabalhos por e-mail.
- Não são aceitos trabalhos fora do prazo.

## Grupo
Bernardo Garcia (`bernardohlg`), Luiz Confortin (`confortin`),
Marco Antônio De Carli Rodegheri (`MarcoRodegheri`), Roger Rozales Ehlert (`RogerEhlert`)
