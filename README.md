

Antonio Jesús Ariza-Salamanca & Juan Alberto Molina-Valero

# Capitulo15_LiDAR_terrestre

## Extracción de parámetros estructurales a nivel de parcela (caso práctico basado en el paquete de R FORTLS)

### Variables de árbol individual (o dendrométricas)

```r
# Instalación y carga del paquete

install.packages(“FORTLS”)
library(FORTLS)
```

#### Escaneo único de TLS

```r
# Establecimiento del directorio de trabajo (se aconseja que sea el mismo en dir.data y dir.result)

dir.data <- "…"
dir.result <- "…"

# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/s/17yl25pbrapat52/PinusRadiata.laz?dl=1",
  destfile = file.path(dir.data, "PinusRadiata.laz"), mode = "wb")

# Normalización

SingleScan <- normalize(
  las = "PinusRadiata.laz",
  id = "PinusRadiata",
  x.center = 0, y.center = 0, # Coordenadas del centro de la parcela
  max.dist = 15,
  dir.data = dir.data, dir.result = dir.result)
```

En el código se han utilizado los argumentos más relevantes de la función normalize, que serían el nombre del archivo (incluyendo la extensión) conteniendo la nube de puntos (argumento las), el directorio donde se localiza la nube de puntos a normalizar (argumento dir.data) y donde se volcarán los resultados (argumento dir.result). Como ya se ha mencionado, es totalmente recomendable que ambos directorios coincidan a lo largo de todo el flujo de trabajo. Además, se incluyen otros argumentos como las coordenadas del centro de la parcela (argumentos x.center e y.center) que en este caso deben coincidir con el punto donde se estacionó el TLS por tratarse de un escaneo único (en este ejemplo este punto tiene coordenadas x=0 e y=0 en la nube de puntos original). Hay que tener en cuenta que, de no especificar las coordenadas del centro de la parcela, la función normalize considerará como punto central las medias aritméticas entre los valores máximos y mínimos de las coordenadas x e y (x=(x_min+x_max)/2; y=(y_min+y_max)/2). También se especificó una distancia máxima desde el centro de la parcela de 15 m (argumento max.dist), la cual, en caso de querer estimar variables de masa debería ser como mínimo igual al radio de parcela considerado como se verá más adelante. Por último, se asignó un identificador a la nube de puntos normalizada (argumento id), al cual se le asignaría el valor 1 en caso de no especificarlo en este argumento. En el caso de trabajar con escaneos múltiples de TLS o tecnología SLAM, hay que añadir el argumento scan.approach = "multi", tal y como se muestra en el siguiente código:

```r
# Escaneo múltiple de TLS (o tecnología SLAM)

# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/s/i905wj0lavklczb/PinusRadiataMultiScan.laz?dl=1",
  destfile = file.path(dir.data, "PinusRadiataMultiScan.laz"), mode = "wb")

# Normalización

MultiScan <- normalize(
  las = "PinusRadiataMultiScan.laz",
  id = "PinusRadiataMultiScan",
  x.center = 0, y.center = 0, # Coordenadas del centro de la parcela
  max.dist = 15,
  scan.approach = "multi",
  dir.data = dir.data, dir.result = dir.result)
```

```r
# Escaneo único de TLS

treeSingleScan <- tree.detection.single.scan(data = SingleScan,
  tls.resolution = list(point.dist = 6.34, tls.dist = 10),
  dir.result = dir.result)

# Escaneo múltiple de TLS (o tecnología SLAM)

treeMultiScan <- tree.detection.multi.scan(
  data = MultiScan,
  d.top = 20, # Diámetro en punta delgada (cm)
  dir.result = dir.result)
```

### Variables de masa (o dasométricas)

```r
# Escaneo único de TLS

met.var <- metrics.variables(
  tree.tls = treeSingleScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)

# Escaneo múltiple de TLS (o tecnología SLAM)

met.var <- metrics.variables(
  tree.tls = treeMultiScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "multi",
  dir.data = dir.data, dir.result = dir.result)
```

### Rutina para automatizar el flujo de trabajo con varias parcelas

```r
# Descarga de las nubes de puntos en formato laz (pertenecientes a escaneos únicos de TLS)

download.file("https://www.dropbox.com/scl/fi/vvv7z9hczg96ks0n6ni16/PinusSylvestris1.laz?rlkey=7pmpim6z0u42i2e6ueyj8k2ct&dl=1",
  destfile = file.path(dir.data, "PinusSylvestris1.laz"), mode = "wb")

download.file("https://www.dropbox.com/scl/fi/855o2xqjqvaxezeqe0zic/PinusSylvestris2.laz?rlkey=vbskveu8lu5ooriniyl6n69o6&dl=1",
  destfile = file.path(dir.data, "PinusSylvestris2.laz"), mode = "wb")

# Especificación de las coordenadas del centro de las parcelas

center.coord <- data.frame(
  id = c("PinusSylvestris1", "PinusSylvestris2"),
  x = c(0, 0), y = c(0, 0))

# Detección de los árboles

tree.tls <- tree.detection.several.plots(
  las.list = c("PinusSylvestris1.laz", "PinusSylvestris2.laz"),
  id.list = c("PinusSylvestris1", "PinusSylvestris2"),
  center.coord = center.coord,
  max.dist = 25,
  tls.resolution = list(point.dist = 7.67, tls.dist = 10),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)

# Implementación de las metodologías para corregir las estimaciones por las oclusiones generadas
# según las metodologías de muestreo en la distancia

tree.ds <- distance.sampling(tree.tls = treeSingleScan)

# Estimación de variables y métricas

met.var <- metrics.variables(
  tree.tls = tree.tls, tree.ds = tree.ds,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)
```

### Optimización del diseño de parcela

```r
# A continuación se descargan los datos homólogos a los 2 escaneos de TLS medidos en campo:

download.file("https://www.dropbox.com/scl/fi/amxymzzw36i59fb499058/tree.field.csv?rlkey=f1y9siqnifl963hgs03b51xwc&dl=1",
  destfile = file.path(dir.data, "tree.field.csv"), mode = "wb")

tree.field <- read.csv("tree.field.csv")

sim <- simulations(
  tree.tls = tree.tls, tree.ds = tree.ds, tree.field = tree.field,
  plot.parameters = data.frame(radius.max = 20, k.max = 25, BAF.max = 4),
  dir.data = dir.data, dir.result = dir.result)
```

```r
# Variables de masa más comunes:

rb <- relative.bias(
  simulations = sim,
  dir.result = dir.result)

# Volumen:

rb <- relative.bias(
  simulations = sim,
  variables = "V.user", 
  dir.result = dir.result)
```

```r
# Correlaciones en base a las 16 parcelas de muestreo incluidas en los datos de ejemplo de FORTLS

data("Rioja.simulations")

# Todas las variables:

cor <- correlations(
  simulations = Rioja.simulations,
  dir.result = dir.result)

# Solo el volumen:

cor <- correlations(
  simulations = Rioja.simulations, 
  variables = "W.user",
  dir.result = dir.result)
```
