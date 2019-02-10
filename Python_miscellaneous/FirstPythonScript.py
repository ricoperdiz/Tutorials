#meu primeiro script em python 3

inicio = input("Bom dia! Ou sera boa tarde! Qual e seu nome?")

if len(inicio) > 0 and inicio.isalpha():
      print(inicio)
else:
      print("Seu nome parece errado. Ele nao pode conter numeros ou ser vazio. Conserte, por favor")
