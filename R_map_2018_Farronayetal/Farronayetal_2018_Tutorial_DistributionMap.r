
# ----------
## ATTENTION
# ----------

# ---------------------------------------------------------------
## ALL Data needed for plotting this map is available at: 
# <https://github.com/ricoperdiz/Tutorials/tree/master/R_map_2018_Farronayetal>
## Script author: Ricardo Perdiz <ricardoperdiz@yahoo.com>
## Any doubts or error, please leave an issue at <github.com/ricoperdiz/Tutorials/> or write an email.
# ---------------------------------------------------------------


# list of packages needed for this tutorial
package_list <- c('dplyr', 'stringr', 'readr', 'purrr', 'magrittr', 'broom', 'rgdal', 'measurements', 'GISTools', 'ggsn', 'cowplot', 'sf')

# Run command below to install all packages inside vector package_list
#install.packages(package_list, dependencies = TRUE)

# Run command below to install GitHub version of ggmap package
# Install ggmap package from GitHub version - this is needed in order to be able to download Google Maps nowadays
#if(!requireNamespace("devtools")) {
#    install.packages("devtools")
#    devtools::install_github("dkahle/ggmap")
#    }

# Load packages
libs <- c(package_list, "ggmap")
sapply(libs, library, character.only = TRUE, logical.return = TRUE, quietly = TRUE, warn.conflicts = FALSE)
# If any of the messages below points FALSE, it means that you do not have that package installed. So, please install it before proceeding with the tutorial.
# if you do not remember how to install a package, use the command below
# install.packages("PackageName", dependencies = TRUE)

# Macrolobium longipes
nybg <- read_delim('nybg.csv', delim = ',')
splink <- read_delim('splink.csv', delim = ';')
inpa <- read_delim('inpa.csv', delim = ',')

# Macrolobium aracaense
araca <- read_delim('Maracaense.csv', delim = '\t')

# South and Central America shape
area_mapa <- rgdal::readOGR(dsn = 'SAm_CAm_shape.shp')

# Brazilian states shapefile
estados <- st_read('BRASIL.shp')

# Retrive only the state of Amazonas from object `estados`
br_amazonas <- estados %>% filter(ESTADO == 'Amazonas')
br_amazonas

br_amazonas_tidy <- st_geometry(br_amazonas)
br_amazonas_tidy

area_mapa_tidy <- tidy(area_mapa)
area_mapa_tidy

# Macrolobium longipes
# first data from inpa
inpa_modif <- inpa %>% 
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
inpa_modif
inpa_modif %>% glimpse

names(inpa_modif) <- tolower(names(inpa_modif)) # turn all column names as lower case
names(inpa_modif)

# then we get speciesLink data and select only columns we want to keep
longipes <- splink %>% 
    dplyr::select(herbaria = institutioncode,
           coletor, numero_col = numcoleta,
           especie = taxoncompleto,
           pais, estado = estado_prov,
           local = descrlocal) %>% 
    # then join them with data from INPA
    full_join(inpa_modif, .) %>% 
    dplyr::select(-estado) %>% 
    # turn lat and long columns as numeric
    mutate_at(
        .vars = c('lat', 'long'),
        .funs = as.numeric
    )
longipes
longipes %>% glimpse

# at last, we get nybg data and select and rename columns that we want to keep
nybg_modif <- nybg %>% 
    dplyr::select(herbaria = DarInstitutionCode,
           coletor = DarCollectorNumber,
           numero_col = DarCollector,
           local = DarLocality,
           lat = DarDecimalLatitude,
           long = DarDecimalLongitude,
           pais = DarCountry)
nybg_modif

longipes
longipes %>% glimpse

nybg_modif

longipes <- 
    longipes %>%  
    full_join(., nybg_modif)
longipes # now with data from INPA and NY herbaria

longipes <- 
    longipes %>% 
    filter(!is.na(lat), coletor != 'Rodrigues') %>% 
# add species name in a separate column
    mutate(
        especie = 'M. longipes'
    )
longipes %>% glimpse

# Macrolobium aracaense
## Clean data

# turn column names to lower case
names(araca) <- tolower(names(araca))

araca_md <- araca %>% 
    mutate(
        # clean coordinate columns to extract and convert degrees min sec to decimal degrees
        lat = str_split(coordenadas, 'N') %>%
            sapply('[[', 1 ) %>%
            gsub('°' , ' ', .) %>% 
            gsub("\'|\'\'|\"", " ", .) %>% 
            gsub("  |   ", " ", .) %>% 
            str_trim('both') %>% 
            measurements::conv_unit(., from = 'deg_min_sec', to = 'dec_deg'),
        # do the same done for long data
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
    # turn lat and long columns as numeric
    mutate_at(
        .vars = c('lat', 'long'),
        .funs = as.numeric
        )
araca_md %>% glimpse

# join data for Macrolobium longipes and M. aracaense
dados <- 
    full_join(longipes, araca_md) %>% 
    dplyr::select(herbaria, coletor, numero_col, especie, lat, long)
dados %>% glimpse

dados$long <- ifelse(dados$long > 0, dados$long * -1, dados$long)
longipes <- dados %>% 
    filter(especie == 'M. longipes')
aracaense <- dados %>% 
    filter(especie == 'M. aracaense')

longipes

aracaense

# longitude range - main map
x1 <- st_bbox(br_amazonas)[c(1,3)]
x1
y1 <- st_bbox(br_amazonas)[c(2,4)]
y1

# longitude and latitude range - for ggmap
lat_long <- dados
y_geral <- range(lat_long$lat) + c(-0.01,0.01)
y_geral
x_geral <- range(lat_long$long) + c(-0.01,0.01)
x_geral

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
# plot the map with X and Y Label on it
# take a first look to see if everything is all right
araca_map1

# Main map
araca_map <- araca_map1 +
    geom_point(aes(x = long, y = lat, shape = especie), data = dados, alpha = .8, color ="black", size = 4) +
    # add scale bar on topleft
    scalebar(x.min = attr(mapa, "bb")[[2]], 
           y.min = attr(mapa, "bb")[[1]], 
           x.max = attr(mapa, "bb")[[4]], 
           y.max = attr(mapa, "bb")[[3]], 
           dist = 100, anchor = c(x=-66, y=-2.2), 
           dd2km = T, model = 'WGS84', location = "topleft", st.size = 4, st.dist = 0.02) +
    # add North arrow
    geom_segment(arrow = arrow(length = unit(4,"mm"), type="closed", angle = 40), 
                 aes(x = x_escala, xend = x_escala,y = -1.7 , yend = -1.3), colour= 'black', size = 2) +
    annotate(x = x_escala, y = -1.85, label = 'N', color = 'black', geom = 'text', size = 6,
             fontface = 'bold') +
    # change ggplot2 theme to Black and White
    theme_bw() +
    # change few details:
    # color contour of panel border, legend position, plot margin etc
    theme(panel.border = element_rect(colour = "black", fill=NA, size=1),
          legend.title = element_blank(),legend.text = element_text(size = 12, face = 'bold.italic'),
          legend.position = 'bottom',
          plot.margin = unit(x=c(0.1,0.1,0,0.1),units="in"))

araca_map

# plot the overview map
overviewmap1 <-
    ggplot() + 
    geom_polygon(data = as_tibble(st_coordinates(br_amazonas_tidy)),
                 aes(x = X, y = Y, group = L1),
                 color = 'gray70', fill = 'gray70', linetype = 3)
overviewmap1

overviewmap2 <- overviewmap1 +
  geom_polygon(data = area_mapa_tidy,
               aes(x = long, y = lat, group = group), 
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
