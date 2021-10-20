library("tidyverse")
library("data.table")
arac <- fread("R_make_a_map/nybg_paracouchini.csv")
hept <- fread("R_make_a_map/nybg_pheptaphyllum.csv")
dados_pre <- 
  full_join(arac,hept) %>% 
  select(recordedBy, recordNumber, decimalLatitude, decimalLongitude, identifiedBy, specificEpithet) %>%
  arrange(recordedBy, recordNumber) %>% 
  filter(recordedBy != '') %>%
  #elimina os registros sem lat ou long
  filter(decimalLatitude != '' | decimalLongitude != '') %>%
  #filtra apenas os especimes identificados pelo especialista da família Burseraceae
  filter(identifiedBy == 'D. C. Daly')
dados_pre$recordedBy <- 
  gsub('\\.', '_', dados_pre$recordedBy) %>%
  gsub(' ', '_', .) %>%
  gsub("'", '_', .) %>%
  gsub('__', '_', .)

dados_pre$recordNumber <- 
  gsub('/','_', dados_pre$recordNumber) %>%
  gsub(' ', '_', .) %>%
  gsub('\\.', '_', .)

#cria o identificador de coleta e especie
dados <- 
  dados_pre %>%
  mutate(
    ID = paste(recordedBy, recordNumber, sep = '_'),
    Species = paste('Protium', specificEpithet, sep = ' ')
  )
dados$ID <- gsub('__', '_', dados$ID)


#quem sao os dados unicos
unicos <- unique(dados$ID)

#agora filtra os dados unicos no dataframe, eliminando os duplicados
#faz-se uso da funcao match para obter esse resultado
prot <- 
  match(unicos, dados$ID) %>%
  dados[.,]
#verifica a cobertura de lat e long para ver se estao dentro
# dos limites da America do Sul
lat <- range(prot$decimalLatitude)
long <- range(prot$decimalLongitude) #aqui tem algo estranho
#percebe-se aqui que ha valores que caem fora da Am Sul
#limite e pouco mais de -80
head(sort(prot$decimalLongitude))
#devemos eliminar
protium <-
  prot %>%
  filter(decimalLongitude > -80)

fwrite(protium, file = "R_make_a_map/dados.csv", sep = "\t")
dados
