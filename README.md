# Trabalho de Assembly - UFSC

Eduardo Henke

Bruno M. Pacheco

Nathan Willian  D. S.

## O que falta fazer:
Obs: tenta modularizar o código, deixando funções bonitinhas ao invés de ```n``` linhas de código pra uma função básica
### Agora
* Tratador de interrupção
* Procedures para limpar memória/impressora/display
* Procedure para imprimir nome e preço formatados(Alfinete)
### Depois
* Pegar e tratar input do DOS
* Cadastrar produtos
### Feito
* ~~Mostrar no display(Henke)~~
* ~~Calcular total e mostrar na tela a cada get_product(Henke)~~
* ~~Pegar input das chaves(Alfinete)~~
* ~~Procedures para pegar produtos/preços pelo ID~~

## Estrutura dos dados:
```
data segment
	;IDs         01h           02h       03h...
    produtos db "macarrao$", "leite$", "quiboa$"
    precos   db 3, 50      , 3, 99   , 2, 99 
ends
```
