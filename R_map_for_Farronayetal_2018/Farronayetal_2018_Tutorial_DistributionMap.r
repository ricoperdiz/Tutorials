
library('dplyr')
library('stringr')
library('readr')
library('purrr')
library('magrittr')
library('broom')
library('rgdal')
library('measurements')
library('GISTools')
library('ggmap')
library('ggsn')
library('cowplot')

# Macrolobium longipes
nybg <- read_delim('nybg.csv', delim = ',')
splink <- read_delim('splink.csv', delim = ';')
inpa <- read_delim('inpa.csv', delim = ',')

# Macrolobium aracaense
araca <- read_delim('Maracaense.csv', delim = '\t')

# South and Central America shape
area_mapa <- rgdal::readOGR(dsn = 'SAm_CAm_shape.shp')

# Brazilian states shapefile
estados <- rgdal::readOGR(dsn = 'BRASIL.shp')
estados %>% summary

br_amazonas <- estados[grep('Amazonas', estados$ESTADO, ignore.case = T),]

br_amazonas_tidy <- tidy(br_amazonas)
area_mapa_tidy <- tidy(area_mapa)

# Macrolobium longipes
# first data from inpa
longipes <- inpa %>% 
    mutate(
        lat = str_split(COORD_, 'N') %>%
            sapply('[[', 1 ) %>%
            gsub('°' , ' ', .) %>% 
            gsub("’", " ", .) %>% 
            paste0(., ' 0') %>%
            gsub("  |   ", " ", .) %>% 
            str_trim('both') %>% 
            measurements::conv_unit(., from = 'deg_min_sec', to = 'dec_deg'),
        long = str_split(COORD_, 'N') %>%
            sapply('[[', 2) %>% 
            gsub('°' , ' ', .) %>% 
            gsub("’", " ", .) %>% 
            gsub('W', '0', .) %>% 
            str_trim('both') %>% 
            gsub("  ", " ", .) %>% 
            measurements::conv_unit(., from = 'deg_min_sec', to = 'dec_deg')
            ) %>% 
    dplyr::select(-COORD_)

names(longipes) <- tolower(names(longipes)) # turn all column names as lower case

# then we clean data downloaded from splink
longipes <- splink %>% 
    dplyr::select(herbaria = institutioncode,
           coletor, numero_col = numcoleta,
           especie = taxoncompleto,
           pais, estado = estado_prov,
           local = descrlocal) %>% 
    full_join(longipes, .) %>% 
    dplyr::select(-estado)

# at last, let's clean data downloaded from nybg
nybg_modif <- nybg %>% 
    dplyr::select(herbaria = DarInstitutionCode,
           coletor = DarCollectorNumber,
           numero_col = DarCollector,
           local = DarLocality,
           lat = DarDecimalLatitude,
           long = DarDecimalLongitude,
           pais = DarCountry)

longipes %>% glimpse

nybg_modif %>% glimpse

longipes <- longipes %>%  
    mutate_at(
        .vars = c('lat', 'long'),
        .funs = as.numeric
    ) %>% 
    full_join(., nybg_modif)

# filtra os dados para plotar
longipes <- longipes %>% 
    filter(!is.na(lat), coletor != 'Rodrigues') %>% 
# acrescenta o nome da especie na coluna
    mutate(
        especie = 'M. longipes'
    )

# Macrolobium aracaense
names(araca) <- tolower(names(araca))
araca_md <- araca %>% 
    mutate(
        lat = str_split(coordenadas, 'N') %>%
            sapply('[[', 1 ) %>%
            gsub('°' , ' ', .) %>% 
            gsub("\'|\'\'|\"", " ", .) %>% 
            gsub("  |   ", " ", .) %>% 
            str_trim('both') %>% 
            measurements::conv_unit(., from = 'deg_min_sec', to = 'dec_deg'),
        long = str_split(coordenadas, 'N') %>%
            sapply('[[', 2 ) %>%
            gsub('W', '', .) %>% 
            gsub('°' , ' ', .) %>% 
            gsub("\'|\'\'|\"", " ", .) %>% 
            gsub("  |   ", " ", .) %>% 
            str_trim('both') %>% 
            measurements::conv_unit(., from = 'deg_min_sec', to = 'dec_deg'),
        especie = 'M. aracaense'
    ) %>% 
    dplyr::select(coletor, numero_col = numero, 
                  pais = country,
                  lat, long, estado = majorarea, herbaria, especie) %>% 
    mutate_at(
        .vars = c('lat', 'long'),
        .funs = as.numeric
        )
araca_md

# join data for Macrolobium longipes and M. aracaense
dados <- full_join(longipes, araca_md)
dados %>% glimpse

dados$long <- ifelse(dados$long > 0, dados$long * -1, dados$long)

longipes <- dados %>% 
    filter(especie == 'M. longipes')
aracaense <- dados %>% 
    filter(especie == 'M. aracaense')


longipes %>% glimpse

aracaense %>% glimpse

# longitude range - main map
x1 <- br_amazonas@bbox[1,]
y1 <- br_amazonas@bbox[2,]

# longitude and latitude range - for ggmap
lat_long <- dados
y_geral <- range(lat_long$lat) + c(-0.01,0.01)
x_geral <- range(lat_long$long) + c(-0.01,0.01)


# Place your google KEY here - without it, you WILL NOT be able to download a google map
register_google(key = 'PlaceYourKeyRightHERE!')

#loadfonts()
#local_mp <- c(lon = sum(x_geral)/2, lat = sum(y_geral)/2)
#local_mp
#mapa <- get_map(location = local_mp, 
#        source = "google",
#        maptype = "terrain", crop = FALSE,
#        zoom = 7,
#        color = 'bw',
#        language = 'en-EN')

mapa <- readRDS("Farronayetal2017_ggmap.RDS")

ggmap(mapa, extent = 'panel')

# Main map - species distribution
x_escala = -65.1

araca_map1 <- 
    ggmap(mapa, extent = 'panel') +
    xlab('Longitude (WGS84)') +
    ylab('Latitude')
araca_map1

araca_map2 <- araca_map1 +
    geom_point(aes(x = long, y = lat, shape = especie), data = dados, alpha = .8, color ="black", size = 4) +
    scalebar(x.min = attr(mapa, "bb")[[2]], 
           y.min = attr(mapa, "bb")[[1]], 
           x.max = attr(mapa, "bb")[[4]], 
           y.max = attr(mapa, "bb")[[3]], 
           dist = 100, anchor = c(x=-66, y=-2.2), 
           dd2km = T, model = 'WGS84', location = "topleft", st.size = 4, st.dist = 0.02)
araca_map2

araca_map3 <- araca_map2 +
    geom_segment(arrow = arrow(length = unit(4,"mm"), type="closed", angle = 40), 
                 aes(x = x_escala, xend = x_escala,y = -1.7 , yend = -1.3), colour= 'black', size = 2) +
    annotate(x = x_escala, y = -1.85, label = 'N', color = 'black', geom = 'text', size = 6,
             fontface = 'bold') +
    theme_bw()
araca_map3

araca_map <- araca_map3 +
    theme(panel.border = element_rect(colour = "black", fill=NA, size=1),
          legend.title = element_blank(),legend.text = element_text(size = 12, face = 'bold.italic'),#family = 'Times New Roman'),
          legend.position = 'bottom',
          plot.margin = unit(x=c(0.1,0.1,0,0.1),units="in"))
araca_map

# plot the overview map
overviewmap1 <-
    ggplot() + 
    geom_polygon(data = br_amazonas_tidy,
                 aes(x = long, y = lat, group = group),
                 color = 'gray70', fill = 'gray70', linetype = 3)
overviewmap1

overviewmap2 <- overviewmap1 +
  geom_polygon(data = area_mapa_tidy,
               aes(long, lat, group = group), 
               color="black", fill=NA) +
    geom_point(data = subset(dados, especie %in%  'M. aracaense'), 
               aes(x = long, y = lat), size = 2,
               pch = 19, col = "black")
overviewmap2

overviewmap3 <- overviewmap2 +
    coord_equal() +
    coord_cartesian(
    xlim = x1 - c(2,-2), ylim = y1 - c(2,-2) 
    ) 
overviewmap3

overviewmap <- overviewmap3 +
    theme(plot.background =
              element_rect(fill = "white", linetype = 1,
                           size = 0.3, colour = "black"),
          axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          legend.position="none") +
    annotate(x = -63,y = -5,label = 'BRAZIL\nAmazonas',
             color = 'black', geom = 'text', 
             size = 3,fontface = 'bold') 
overviewmap

final_map <- ggdraw() +
    draw_plot(araca_map, 0, 0, 1, 1) +
    draw_plot(overviewmap, 0.15, 0.72, 0.225, 0.225)
final_map

cowplot::ggsave(
    plot = final_map, 
    filename = 'final_map_Macrolobium_aracaense_ggmap.pdf', dpi = 600, width = 6, height = 6, units = 'in')
