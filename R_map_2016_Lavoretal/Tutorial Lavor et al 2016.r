
# ----------
## ATTENTION
# ----------

# ---------------------------------------------------------------
## ALL Data needed for plotting this map is available at: 
# <https://github.com/ricoperdiz/Tutorials/R_map_2016_Lavoretal/>
## Script author: Ricardo Perdiz <ricardoperdiz@yahoo.com>
## Any doubts or error, please leave an issue at <github.com/ricoperdiz/Tutorials/> or write an email.
# ---------------------------------------------------------------

# list of packages needed for this tutorial
package_list <- c('maps', 'rgdal', 'maptools', 'foreign', 'GISTools', 'knitr')

# Run command below to install all packages inside vector package_list, in case you need it
#install.packages(package_list, dependencies = TRUE)
# Load packages
sapply(package_list, library, character.only = TRUE, logical.return = TRUE, quietly = TRUE, warn.conflicts = FALSE)
# If any of the messages below points FALSE, it means that you do not have that package installed. So, please install it before proceeding with the tutorial.
# if you do not remember how to install a package, use the command below
# install.packages("PackageName", dependencies = TRUE)

# read data and create vectors

# ----------------------
## Data for overview map
# ----------------------

# Vectors with coordinate range
x1 <- c(-80,-40)
y1 <- c(-20,10)

# Load shapefile for P. oligolepis occurrence area
area_mapa <- readShapePoly('area_mapa_piloso_oligolepis')

# Retrieve data for British Guyana 
guy <- subset(area_mapa, GEOUNIT == 'Guyana')

# Load shapefile of Roraima state, Brazil
rr <- readShapePoly('roraima')

# Shapefile with rivers in RR
rios_rr <- rgdal::readOGR('.','rios_para_Piloso_oligolepis', encoding = 'latin1')

# Pilosocereus oligolepis collections
coord <- read.table('coord.csv', header = T, as.is = TRUE, sep = '\t')
coord

coord_boavista <- read.table('coord_boavista.csv', header = T, as.is = T, sep = '\t')
coord_boavista

# Vector to create a legend
legendas <- unique(coord$LEGENDA)
legendas

# Coordinates for map 2 - *Pilosocereus oligolepis* distribution
y2 <- round(range(coord$LAT)) + c(-0.5,0.5)
x2 <- round(range(coord$LONG)) + c(-0.5, 0.5)

# Vector for point shapes
pontos <- c(17, 2, 11)

# Vector for point sizes
cex_tam <- seq(0.8, 1.6, by = 0.1)
cex_tam

# Vector for colors in legend
cores_leg <- c(rep('black',5),'grey80')

# plot number 1 - Overview map
par(mar = c(0,2,2,2))
plot(area_mapa, xlim = x1, ylim = y1, col = 'white')
plot(rr, add = TRUE, col = 'gray70')
par(cex = 1, las = 1)
# Add North arrow
GISTools::north.arrow(-45,5, len = 1, cex.lab = 0.9,lab = 'N', col = 'black')
# Add a text 
text(-58, -10, labels ='BRAZIL', pos = 4, cex = cex_tam[1], font = 2)
box()

# plot number 2 - Pilosocereus oligolepis distribution
par(mar = c(2,2,2,3))

plot(area_mapa, xlim = x2, ylim = y2, lwd = 1.2)
plot(rr, add = T, col = 'gray70', lwd = 1.2)
# Plot rivers
plot(rios_rr, add = T, border = 'gray80', lwd = 0.8)

# For loop to plot points with different shapesloop para plotar pontos com shapes diferentes
for(p in seq_along(legendas)) {
    
    points(coord$LONG[coord$LEGENDA == legendas[p]], coord$LAT[coord$LEGENDA == legendas[p]], pch = pontos[p], cex = cex_tam[7], lwd = 1.4)
    
}

points(coord_boavista$LONG[1], coord_boavista$LAT[1], pch = 3,cex = cex_tam[6], font = 2, lwd = 2)

# Plot text
text(min(x2), min(y2), labels = 'BRAZIL', pos = 4, cex = cex_tam[5], font = 2)
text(coord$LONG[coord$LEGENDA == 'Localidade tipo de P. kanukuensis'], coord$LAT[coord$LEGENDA == 'Localidade tipo de P. kanukuensis'], labels = 'GUYANA', pos = 1, offset = 1, cex = cex_tam[5], font = 2)
text(min(x2) - 0.5, max(y2) - 0.5, labels = 'VENEZUELA', pos = 4, cex = cex_tam[5], font = 2)

par(cex = 1, las = 1)
# Add scale bar
maps::map.scale(max(x2) + 0.1, min(y2) + 0.1, ratio = F, cex = 1.2, metric = T, col = 'black')

# Add North arrow
GISTools::north.arrow(max(x2) + 1, min(y2) + 0.35, len = 0.08, lab = 'N', cex.lab = 1.2, lwd = 1.5, col = 'black')

# Add map axes
map.axes()
axis(side=4,las=1)
axis(side=3,las=1)

# plot number 3 - LEGEND
par(mar = c(0,0,0,0))
plot.new()
par(cex = 1.2)
legend(x = 'center', ncol = 1, legend = c(expression(paste('New sites for ', italic('P. oligolepis'), sep = '')), 'Sites searched without records', 'Extra Brazil site', 'Boa Vista, capital city of Roraima', 'International borders', 'River courses'), 
       pch = c(pontos, 3, NA, NA), 
       col = cores_leg, 
       title = expression(paste(italic('Pilosocereus oligolepis'), '\n record data', sep='')), 
       lty = c(0, 0, 0, 0, 1, 1), 
       pt.lwd = 1.25, 
       lwd = 3, 
       text.width = 0.86, 
       y.intersp = 1.8, 
       box.col = 'black')

##layout-----------------------------------------------------------------------------
par.norm <- par(no.readonly=T)
graphics.off()

# Start a pdf
pdf('final_map_Lavoretal_2016.pdf', height = 7, width = 14, onefile = T)

# Map layout
mapa.layout <- layout(matrix(c(1,1,2,2,2,2,2,2,3,3,2,2,2,2,2,2,3,3,2,2,2,2,2,2),nrow=3,byrow=T),widths=rep(2/8,8),heights=rep(1/3,3),respect=T)

# ----------------------------
# plot number 1 - Overview map
# ----------------------------

par(mar = c(0,2,2,2))
plot(area_mapa, xlim = x1, ylim = y1, col = 'white')
plot(rr, add = TRUE, col = 'gray70')
par(cex = 1, las = 1)
# Add North arrow
GISTools::north.arrow(-45,5, len = 1, cex.lab = 0.9,lab = 'N', col = 'black')
# Add a text 
text(-58, -10, labels ='BRAZIL', pos = 4, cex = cex_tam[1], font = 2)
box()

# ----------------------------------------------------
# plot number 2 - Pilosocereus oligolepis distribution
# ----------------------------------------------------

par(mar = c(2,2,2,3))
plot(area_mapa, xlim = x2, ylim = y2, lwd = 1.2)
plot(rr, add = T, col = 'gray70', lwd = 1.2)
# Plot rivers
plot(rios_rr, add = T, border = 'gray80', lwd = 0.8)

# For loop to plot points with different shapesloop para plotar pontos com shapes diferentes
for(p in seq_along(legendas)) {
    
    points(coord$LONG[coord$LEGENDA == legendas[p]], coord$LAT[coord$LEGENDA == legendas[p]], pch = pontos[p], cex = cex_tam[7], lwd = 1.4)
    
}

points(coord_boavista$LONG[1], coord_boavista$LAT[1], pch = 3,cex = cex_tam[6], font = 2, lwd = 2)

# Plot text
text(min(x2), min(y2), labels = 'BRAZIL', pos = 4, cex = cex_tam[5], font = 2)
text(coord$LONG[coord$LEGENDA == 'Localidade tipo de P. kanukuensis'], coord$LAT[coord$LEGENDA == 'Localidade tipo de P. kanukuensis'], labels = 'GUYANA', pos = 1, offset = 1, cex = cex_tam[5], font = 2)
text(min(x2) - 0.5, max(y2) - 0.5, labels = 'VENEZUELA', pos = 4, cex = cex_tam[5], font = 2)

par(cex = 1, las = 1)
# Add scale bar
maps::map.scale(max(x2) + 0.1, min(y2) + 0.1, ratio = F, cex = 1.2, metric = T, col = 'black')

# Add North arrow
GISTools::north.arrow(max(x2) + 1, min(y2) + 0.35, len = 0.08, lab = 'N', cex.lab = 1.2, lwd = 1.5, col = 'black')

# Add map axes
map.axes()
axis(side=4,las=1)
axis(side=3,las=1)


# ----------------------
# plot number 3 - LEGEND
# ----------------------

par(mar = c(0,0,0,0))
plot.new()
par(cex = 1.2)
legend(x = 'center', ncol = 1, legend = c(expression(paste('New sites for ', italic('P. oligolepis'), sep = '')), 'Sites searched without records', 'Extra Brazil site', 'Boa Vista, capital city of Roraima', 'International borders', 'River courses'), 
       pch = c(pontos, 3, NA, NA), 
       col = cores_leg, 
       title = expression(paste(italic('Pilosocereus oligolepis'), '\n record data', sep='')), 
       lty = c(0, 0, 0, 0, 1, 1), 
       pt.lwd = 1.25, 
       lwd = 3, 
       text.width = 0.86, 
       y.intersp = 1.8, 
       box.col = 'black')
#finaliza o layout
dev.off()
