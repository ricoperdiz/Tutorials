import numpy as np
import matplotlib.pyplot as pp
import pandas as pd
import seaborn

pd.set_option("display.precision", 2)

df = pd.read_csv("docs/05_relatorioFinal/tabela_canta.csv", sep = "\t")
df.head()

df.describe()

df.dtypes
