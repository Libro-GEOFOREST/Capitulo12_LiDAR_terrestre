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

# 5.Descarga de las nubes de puntos en formato .laz ----------------------------

# Estas estarán en el repositorio de GitHub asociado a este libro.
# Las nubes de puntos pertenecen a una misma parcela establecida en un
# bosque mixto de Pinus radiata y Pinus pinaster del noroeste español (Galicia).
# Una de ellas corresponde a un escaneo único de TLS (GaliciaSingleScan.laz),
# y la otra a un escaneo múltiple de TLS (GaliciaMultiScanlaz). Este último,
# perteneciente a la unión de 5 escaneos únicos posicionados uno en el centro,
# y los 4 restantes desplazados 10 m desde el centro en dirección norte, este,
# sur y oeste. El TLS utilizado fue un FARO Focus3D X 130. Se utilizó una
# precisión de escaneado de 6.34 mm de separación entre dos puntos consecutivos
# a 10 m del dispositivo. Ambas nubes de puntos se cortaron a un radio de 17.5 m,
# y en el caso del escaneo múltiple, se realizó un submuestreo de la nube de puntos
# original para reducir la densidad. Este proceso consistió en establecer una
# distancia mínima entre puntos de 5 mm, de tal modo que no haya ningún par de
# puntos más próximos entre sí a este umbral. Para ello se utilizó el software
# CloudCompare.

# También podrán descargarse mediante el siguiente código:

# Escaneo único de TLS (GaliciaSingleScan)

download.file("https://www.dropbox.com/scl/fi/c3sey8w5yvlq1c901c0pl/GaliciaSingleScan.laz?rlkey=amsimtwltvslmhd7bsr7yhkx4&dl=1",
              destfile = file.path(dir.data, "GaliciaSingleScan.laz"), mode = "wb")

# Escaneo múltiple de TLS (GaliciaMultiScan)

download.file("https://www.dropbox.com/scl/fi/gacmiqqdkfuprxkrafciz/GaliciaMultiScan.laz?rlkey=86glhhez7ryxrl9jofgh0jtlx&dl=1",
              destfile = file.path(dir.data, "GaliciaMultiScan.laz"), mode = "wb")


# Normalización ----------------------------------------------------------------

# Escaneo único de TLS (GaliciaSingleScan)
# En los escaneos únicos de TLS es crucial indicar las coordenadas del centro de
# la parcela (x.center = 0 e y.center = 0 en este caso), ya que muchas de los
# criterios de detección de los árboles incluídos en las funciones de FORTLS
# tienen en cuenta la ubicación del TLS en el punto central de la parcela.

SingleScan <- normalize(las = "GaliciaSingleScan.laz", id = "GaliciaSingleScan",
                        x.center = 0, y.center = 0,
                        max.dist = 15,
                        dir.data = dir.data, dir.result = dir.result)


# Escaneo múltiple de TLS (GaliciaMultiScan)
# En este caso, es importante indicar en los argumentos que el escaneo es múltiple
# (scan.approach = "multi").

MultiScan <- normalize(las = "GaliciaMultiScan.laz",
                       id = "GaliciaMultiScan",
                       x.center = 0, y.center = 0,
                       max.dist = 15,
                       scan.approach = "multi",
                       dir.data = dir.data, dir.result = dir.result)

# 6.Detección de árboles -------------------------------------------------------

# Escaneo único de TLS (GaliciaSingleScan)
# Al igual que ocurría con la definición de las coordenas de ubicación del TLS,
# es también MUY importante definir la precisión del escaneo; ya sea como
# la distancia entre dos puntos consecutivos (en mm) a una distanción determinada
# del TLS (en m), así como en base a las aperturas angulares horizontales y
# verticales en grados sexagesimales. Para ello se utiliza el argumento tls.resolution.
# Un parámetro que puede ser importante dependiendo de la estructura forestal
# es la sección vertical libre de sotobosque (arbustos, matorral, etc.) y copas,
# ramas bajas, etc. Está sección debe ser lo más ancha posible dentro de las
# posibilidades del bosque en cuestión. No obstante, el valor por defecto
# (stem.section = c(0.7, 3.5)), suele mostrar un buen compromiso en muchos casos.

treeSingleScan <- tree.detection.single.scan(
  data = SingleScan,
  tls.resolution = list(point.dist = 6.34, tls.dist = 10),
  dir.result = dir.result)


# Escaneo múltiple de TLS (o tecnología SLAM)

treeMultiScan <- tree.detection.multi.scan(
  data = MultiScan,
  d.top = 20,
  dir.result = dir.result)

# 7.Comprobación con datos de campo --------------------------------------------
# Los datos de campo asociados a la parcela de ejemplo se encuentran también en
# el repositorio de GitHub asociado a este libro como un archivo csv con el nombre
# de GaliciaFieldData.csv
