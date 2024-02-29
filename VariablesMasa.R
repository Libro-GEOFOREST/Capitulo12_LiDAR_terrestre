# 1.Autoría --------------------------------------------------------------------
# Juan Alberto Molina Valero - 2024

# 2.Descripción ----------------------------------------------------------------
# Este script de R es un material suplementario al capítulo 15 LiDAR terrestre.

# 3.Instalación del paquete ----------------------------------------------------

# VERSIÓN BETA. Para instalar la versión beta desde el repositorio de GitHub es
# necesario tener previamente instalado en el directorio C:/ RTools
# (https://cran.r-project.org/bin/windows/Rtools/) para poder compilar el código,
# así como las librerías de R devtools y remotes

install.packages("devtools")
install.packages("remotes")
remotes::install_github("Molina-Valero/FORTLS", ref = "devel", dependencies = TRUE)

# VERSIÓN ALPHA. Esta se puede instalar desde los repositorios CRAN o GitHub

install.packages("FORTLS")
# remotes::install_github("Molina-Valero/FORTLS", dependencies = TRUE)
library(FORTLS)

# 4.Establecimiento del directorio de trabajo ----------------------------------
# Se aconseja que sea el mismo en dir.data y dir.result (p. ej. un carpeta creada
# C:/ con el nombre de GEOFOREST)

setwd("C:/GEOFOREST")
dir.data <- "C:/GEOFOREST"
dir.result <- "C:/GEOFOREST"

# 5. Métricas y variables ------------------------------------------------------

# En el ejemplo, que se implementará para los árboles detectados previamente,
# se estimarán las variables a nivel de masa (o dasocráticas) para parcelas circulares
# de área fija de radio 10 m, parcelas k-tree de 8 árboles, y parcelas relascópicas
# (o de conteo angular) de BAF 1 m2/ha:

# Escaneo único de TLS

met.var <- metrics.variables(
  tree.tls = treeSingleScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)

# Con el siguiente código se pueden extraer los diferentes elementos de la lista creada,
# cada uno de ellos representando un diseño de parcela:

parc.circular <- met.var$fixed.area
parc.k.tree <- met.var$k.tree
parc.relasc <- met.var$angle.count

# Escaneo múltiple de TLS (o tecnología SLAM)

met.var <- metrics.variables(
  tree.tls = treeMultiScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "multi",
  dir.data = dir.data, dir.result = dir.result)

# Con el siguiente código se pueden extraer los diferentes elementos de la lista creada,
# cada uno de ellos representando un diseño de parcela:

parc.circular <- met.var$fixed.area
parc.k.tree <- met.var$k.tree
parc.relasc <- met.var$angle.count

# 6.Varias parcelas ------------------------------------------------------------

# Escaneos únicos de TLS en un bosque de Pinus sylvestris

download.file(
  "https://www.dropbox.com/scl/fi/vvv7z9hczg96ks0n6ni16/PinusSylvestris1.laz?rlkey=7pmpim6z0u42i2e6ueyj8k2ct&dl=1",
  destfile = file.path(dir.data, "PinusSylvestris1.laz"), mode = "wb")

download.file(
  "https://www.dropbox.com/scl/fi/855o2xqjqvaxezeqe0zic/PinusSylvestris2.laz?rlkey=vbskveu8lu5ooriniyl6n69o6&dl=1",
  destfile = file.path(dir.data, "PinusSylvestris2.laz"), mode = "wb")


# Definición de las coordenadas del centro de las parcelas (0,0)

center.coord <- data.frame(
  id = c("PinusSylvestris1", "PinusSylvestris2"),
  x = c(0, 0), y = c(0, 0))

# 6.1. Pocesado de las parcelas de forma automática

tree.tls <- tree.detection.several.plots(
  las.list = c("PinusSylvestris1.laz", "PinusSylvestris2.laz"),
  id.list = c("PinusSylvestris1", "PinusSylvestris2"),
  center.coord = center.coord,
  max.dist = 25,
  tls.resolution = list(point.dist = 7.67, tls.dist = 10),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)


# 6.2.Implementación de las métodologías para corregir las oclusiones ----------

# Estas metodologías se utilizan en muestreos en los que los individuos a muestrear
# se detectan a distancia. Sirven para corregir las subestimaciones causadas por
# la menor probabilidad de detectar árboles a medida que estos están más lejos del
# centro de la parcela. Esta menor probabilidad de detección es consecuencia de las
# oclusiones generadas por los árboles y la vegetación en geneal, así como la pérdida
# de precisión en las nubes de puntos a medida que los objetos están más lejos.
# Esta disminución de la probailidad de detección a medida que estamos más lejos
# del centro de la parcela, puede modelizarse con diferentes expresiones matemáticas.
# Para más detalle se puede consultar el artículo de Molina-Valero et al., (2022).

tree.ds <- distance.sampling(tree.tls = tree.tls)

# 6.3. Estimación de variables y métricas

met.var <- metrics.variables(
  tree.tls = tree.tls, tree.ds = tree.ds,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)

# Con el siguiente código se pueden extraer los diferentes elementos de la lista creada,
# cada uno de ellos representando un diseño de parcela:

parc.circular <- met.var$fixed.area
parc.k.tree <- met.var$k.tree
parc.relasc <- met.var$angle.count


# 7.Simulaciones ---------------------------------------------------------------

# A continuación se descargan los datos homólogos a los 2 escaneos de TLS medidos en campo:

download.file(
  "https://www.dropbox.com/scl/fi/amxymzzw36i59fb499058/tree.field.csv?rlkey=f1y9siqnifl963hgs03b51xwc&dl=1",
  destfile = file.path(dir.data, "tree.field.csv"), mode = "wb")

tree.field <- read.csv("tree.field.csv")

# Ejecución de la función simulations con los inputs de los árboles detectados con
# FORTLS (tree.tls), las correcciones en las estimaciones aplicando las metodologías
# de muestreo basadas en la distancia (tree.ds), y los datos de control medidos
# en campo (tree.field). Se consideran simulaciones hasta un radio de 20 m para
# parcelas circulares de área fija, 25 árboles para parcelsas k.tree, y BAF = 4
# para parcelas relascópicas (o de conteo angular).

sim <- simulations(
  tree.tls = tree.tls,
  tree.ds = tree.ds,
  tree.field = tree.field,
  plot.parameters = data.frame(radius.max = 20, k.max = 25, BAF.max = 4),
  dir.data = dir.data, dir.result = dir.result)

# 8.Sesgo relativo -------------------------------------------------------------

# Variables de masa más comunes:

rb <- relative.bias(simulations = sim, dir.result = dir.result)

# Volumen:

rb <- relative.bias(simulations = sim, variables = "V.user", 
                    dir.result = dir.result)


# 9.Correlaciones --------------------------------------------------------------

data("Rioja.simulations")

# Todas las variables:

cor <- correlations(simulations = Rioja.simulations, dir.result = dir.result)

# Solo el volumen:

cor <- correlations(simulations = Rioja.simulations, 
                    variables = "W.user",
                    dir.result = dir.result)



# 10.Modelo de regresión -------------------------------------------------------

data <- Rioja.simulations$fixed.area[Rioja.simulations$fixed.area$radius == 10, ]
plot(data$W.user ~ data$V.sh, main = "Ajuste AGB~V.sh", 
     xlab = "V.sh", ylab = "AGB (Mg/ha)", asp = 1)
abline(lm(data$W.user ~ data$V.sh), col = "blue", lwd = 2)

