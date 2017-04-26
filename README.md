# Trabalho de Assembly - UFSC

Eduardo Henke

Bruno M. Pacheco

Nathan Willian  D. S.

## O que falta fazer:
Obs: tenta modularizar o código, deixando funções bonitinhas ao invés de ```n``` linhas de código pra uma função básica
### Agora
* Tratador de interrupção
* Mostrar no display(Henke)
* Pegar input das chaves(Bruno)
### Daqui a pouco
* Procedures para limpar memória/impressora/display
* Procedures para pegar produtos/preços pelo ID
### Depois
* Pegar e tratar input do DOS
* Cadastrar produtos

## Estrutura dos dados:
```
data segment
	;IDs         01h           02h       03h...
    produtos db "macarrao$", "leite$", "quiboa$"
    precos   db 3, 50      , 3, 99   , 2, 99 
ends
```
