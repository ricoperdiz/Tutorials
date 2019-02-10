__author__ = 'ricoperdiz'

from random import randint

board = []

for x in range(0,5):
    board.append(["O"] * 5)

def print_board(board):
    for row in board:
        print(" ".join(row))

print("Vamos jogar BATALHA NAVAL!\n OS ZEROS ABAIXO CORRESPONDEM A PONTOS NO OCEANO.\n  ESCOLHA UM PONTO,\nE TENTE AFUNDAR O BARCO INIMIGO!")

print_board(board)

def random_row(board):
    return randint(0, len(board) - 1)

def random_col(board):
    return randint(0, len(board[0]) - 1)

ship_row = random_row(board)
ship_col = random_col(board)
#print ship_row
#print ship_col

for turn in range(5):
    guess_row = int(input("Adivinha a Linha:"))
    guess_col = int(input("Adivinha a Coluna:"))

    if guess_row == ship_row and guess_col == ship_col:
        print("PARABENS! VOCE AFUNDOU MEU BARCO!")
        break
    else:
        if (guess_row < 0 or guess_row > 5) or (guess_col < 0 or guess_col > 5):
            print("OPS, ESSA PASSOU LONGE! NEM NO OCEANO CAIU.")
        elif(board[guess_row-1][guess_col-1] == "X"):
            print("VOCE JA ESCOLHEU ESSA. ESCOLHA OUTRA.")
        else:
            print("IU IU IU! VOCE ERROU!!!")
            board[guess_row-1][guess_col-1] = "X"
    print("Tentativa", turn + 1)
    if turn == 5:
        print("Fim do jogo!")
    print_board(board)
