library("tidyverse")
library("data.table")
arac <- fread("R_make_a_map/nybg_paracouchini.csv")
hept <- fread("R_make_a_map/nybg_pheptaphyllum.csv")
dados <- full_join(arac,hept)
fwrite(dados, file = "R_make_a_map/dados.csv", sep = "\t")
dados
