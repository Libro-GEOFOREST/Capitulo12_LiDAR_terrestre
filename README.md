

Antonio Jesús Ariza-Salamanca & Juan Alberto Molina-Valero

# Capitulo15_LiDAR_terrestre

## Extracción de parámetros estructurales a nivel de parcela (caso práctico basado en el paquete de R FORTLS)

### Variables de árbol individual (o dendrométricas)
##### Instalación de FORTLS

```r
install.packages(“FORTLS”)
library(FORTLS)
```

#### Proceso de normalización
##### Escaneo único de TLS

```r
# Establecimiento del directorio de trabajo (se aconseja que sea el mismo en dir.data y dir.result)

dir.data <- "…"
dir.result <- "…"

# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/scl/fi/c3sey8w5yvlq1c901c0pl/GaliciaSingleScan.laz?rlkey=amsimtwltvslmhd7bsr7yhkx4&dl=1",
              destfile = file.path(dir.data, "GaliciaSingleScan.laz"), mode = "wb")

# Normalización

SingleScan <- normalize(las = "GaliciaSingleScan.laz", id = "GaliciaSingleScan",
                        x.center = 0, y.center = 0,
                        max.dist = 15,
                        dir.data = dir.data, dir.result = dir.result)
```

En el código se han utilizado los argumentos más relevantes de la función normalize, que serían el nombre del archivo (incluyendo la extensión) conteniendo la nube de puntos (argumento las), el directorio donde se localiza la nube de puntos a normalizar (argumento dir.data) y donde se volcarán los resultados (argumento dir.result). Como ya se ha mencionado, es totalmente recomendable que ambos directorios coincidan a lo largo de todo el flujo de trabajo. Además, se incluyen otros argumentos como las coordenadas del centro de la parcela (argumentos x.center e y.center) que en este caso deben coincidir con el punto donde se estacionó el TLS por tratarse de un escaneo único (en este ejemplo este punto tiene coordenadas x=0 e y=0 en la nube de puntos original). Hay que tener en cuenta que, de no especificar las coordenadas del centro de la parcela, la función normalize considerará como punto central las medias aritméticas entre los valores máximos y mínimos de las coordenadas x e y (x=(x_min+x_max)/2; y=(y_min+y_max)/2). También se especificó una distancia máxima desde el centro de la parcela de 15 m (argumento max.dist), la cual, en caso de querer estimar variables de masa debería ser como mínimo igual al radio de parcela considerado como se verá más adelante. Por último, se asignó un identificador a la nube de puntos normalizada (argumento id), al cual se le asignaría el valor 1 en caso de no especificarlo en este argumento. En el caso de trabajar con escaneos múltiples de TLS o tecnología SLAM, hay que añadir el argumento scan.approach = "multi", tal y como se muestra en el siguiente código:

##### Escaneo múltiple de TLS (o tecnología SLAM)

```r
# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/scl/fi/gacmiqqdkfuprxkrafciz/GaliciaMultiScan.laz?rlkey=86glhhez7ryxrl9jofgh0jtlx&dl=1",
              destfile = file.path(dir.data, "GaliciaMultiScan.laz"), mode = "wb")

# Normalización

MultiScan <- normalize(las = "GaliciaMultiScan.laz",
                       id = "GaliciaMultiScan",
                       x.center = 0, y.center = 0,
                       max.dist = 15,
                       scan.approach = "multi",
                       dir.data = dir.data, dir.result = dir.result)
```
A continuación se muestran el output obtenido para el escaneo múltiple:

#### Proceso de detección de árboles y estimación de variables dendrométricas
##### Escaneo único de TLS

```r
treeSingleScan <- tree.detection.single.scan(data = SingleScan,
  tls.resolution = list(point.dist = 6.34, tls.dist = 10),
  dir.result = dir.result)
```

##### Escaneo múltiple de TLS (o tecnología SLAM)

```r
treeMultiScan <- tree.detection.multi.scan(
  data = MultiScan,
  d.top = 20, # Diámetro en punta delgada (cm)
  dir.result = dir.result)
```
A continuación se muestra la lista de árboles detectados y las variables estimadas para el escaneo múltiple:

| id               | file                 | tree | x      | y      | phi  | h.dist | dbh   | h     | h.com | v    | v.com | SS.max | sinuosity | n.pts | n.pts.red | n.pts.est | n.pts.red.est | partial.occlusion |
|------------------|----------------------|------|--------|--------|------|--------|-------|-------|-------|------|-------|--------|-----------|-------|-----------|-----------|---------------|-------------------|
| GaliciaMultiScan | GaliciaMultiScan.txt | 1    | 0.34   | 3.07   | 1.46 | 3.08   | 31.43 | 21.49 | 7.76  | 0.58 | 0.45  | 2.38   | 1.28      | 1170  | 591       | 803       | 401           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 2    | -3.69  | -2.04  | 3.65 | 4.22   | 34.07 | 23.85 | 9.53  | 0.74 | 0.61  | 0.83   | 4.31      | 1484  | 750       | 870       | 435           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 3    | 4.77   | -0.34  | 6.21 | 4.78   | 48.17 | 22.31 | 12.38 | 1.40 | 1.31  | 0.28   | 1.03      | 1563  | 767       | 1230      | 614           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 4    | -0.75  | -5.24  | 4.57 | 5.29   | 47.01 | 28.78 | 15.52 | 1.66 | 1.54  | 0.15   | 1.00      | 1555  | 768       | 1201      | 600           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 5    | -3.22  | -4.66  | 4.11 | 5.67   | 27.73 | 21.82 | 6.29  | 0.46 | 0.31  | 6.52   | 2.25      | 807   | 409       | 708       | 354           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 6    | -6.87  | 1.40   | 2.94 | 7.01   | 30.09 | 22.99 | 7.68  | 0.56 | 0.42  | 2.45   | 3.18      | 800   | 405       | 768       | 384           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 7    | -5.63  | -5.47  | 3.91 | 7.85   | 29.58 | 18.01 | 6.04  | 0.44 | 0.33  | 7.00   | 2.22      | 930   | 454       | 756       | 377           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 8    | 2.11   | 9.37   | 1.35 | 9.61   | 48.11 | 27.48 | 15.09 | 1.67 | 1.56  | 0.34   | 1.00      | 2155  | 1089      | 1229      | 614           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 9    | 2.11   | 9.37   | 1.35 | 9.61   | 48.11 | 18.12 | 10.16 | 1.17 | 1.10  | 0.26   | 1.01      | 2155  | 1089      | 1229      | 614           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 10   | 7.80   | 5.92   | 0.65 | 9.80   | 24.54 | 12.54 | 3.84  | 0.29 | 0.17  | 4.26   | 1.43      | 594   | 294       | 627       | 313           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 11   | -2.32  | 9.69   | 1.81 | 9.97   | 22.34 | 18.37 | 2.84  | 0.26 | 0.11  | NA     | NA        | 879   | 443       | 571       | 285           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 12   | 9.76   | -2.51  | 6.03 | 10.08  | 34.64 | 22.78 | 9.33  | 0.74 | 0.61  | 2.98   | 3.16      | 722   | 367       | 885       | 442           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 13   | -7.07  | 7.95   | 2.30 | 10.64  | 32.62 | 22.35 | 8.48  | 0.64 | 0.51  | 0.18   | 1.01      | 474   | 235       | 833       | 416           | 0                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 14   | 6.35   | -9.34  | 5.31 | 11.30  | 29.83 | 22.33 | 7.38  | 0.54 | 0.40  | 0.36   | 1.02      | 439   | 226       | 762       | 381           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 15   | 3.51   | -10.90 | 5.02 | 11.45  | 32.93 | 19.90 | 7.74  | 0.59 | 0.48  | 2.34   | 3.55      | 789   | 393       | 841       | 420           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 16   | -10.60 | 6.39   | 2.60 | 12.38  | 21.18 | 17.32 | 2.13  | 0.23 | 0.08  | 0.27   | 1.00      | 338   | 164       | 541       | 270           | 0                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 17   | -11.60 | -4.84  | 3.54 | 12.57  | 32.57 | 21.81 | 8.28  | 0.63 | 0.50  | 0.87   | 1.02      | 629   | 318       | 832       | 415           | 0                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 18   | -9.10  | -9.43  | 3.95 | 13.10  | 32.48 | 23.85 | 8.94  | 0.67 | 0.53  | 0.41   | 1.01      | 601   | 285       | 829       | 414           | 0                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 19   | -13.42 | 0.20   | 3.13 | 13.42  | 26.94 | 20.15 | 5.53  | 0.40 | 0.26  | 0.43   | 1.01      | 778   | 388       | 688       | 344           | 1                 |
| GaliciaMultiScan | GaliciaMultiScan.txt | 20   | -7.80  | -12.06 | 4.14 | 14.36  | 29.14 | 23.27 | 7.33  | 0.53 | 0.38  | NA     | NA        | 758   | 371       | 744       | 372           | 1                 |


Aunque no se han mencionado hasta ahora, hay dos argumentos que pueden ser interesantes para mejorar la ratio de detección de árboles. Uno es el que define la sección en altura que se utiliza para la detección de árboles (argumento stem.section). Este argumento define la sección libre de ramas y sotobosque en la medida de lo posible que será utilizada para la detección de los fustes de los árboles en base a criterios relacionados con regiones de alta densidad de puntos, la cual en caso de no especificar nada, toma unos valores por defecto que suelen ser adecuados en muchos casos (stem.section = c(0.7, 3.5)). No obstante, estos valores podrán ser modificados dependiendo de las condiciones estructurales del bosque. Otro argumento interesante hace alusión al número de secciones horizontales que se tienen en cuenta tanto para la detección de árboles como para la reconstrucción de los fustes. Cuando no se especifica nada, las funciones para la detección de árboles considerarán secciones a razón de incrementos de 0.3 m desde una altura de 0.4 m hasta la altura máxima de la nube de puntos. Este número de secciones se puede modificar utilizando el argumento breaks, aunque siempre se recomienda mantener al menos una sección a 1.3 m para una mejor estimación del diámetro normal. Cuando solo se está interesado en el diámetro normal y se analizan bosques relativamente sencillos desde el punto de vista estructural y con buena visibilidad en torno a 1.3 m, se recomienda establecer el argumento como breaks = c(1, 1.3, 1.6), reduciendo así el tiempo de computación considerablemente. En cualquier caso, es importante incluir varias secciones, ya que en caso de no detectar un árbol a 1.3 m, habría posibilidad de detectarlo en secciones establecidas a otras alturas, incrementando así la probabilidad de detección de árboles. En tales casos, el diámetro normal será interpolado y estimado desde las secciones más próximas a 1.3 m.

### Variables de masa (o dasométricas)
##### Escaneo único de TLS
```r
met.var <- metrics.variables(
  tree.tls = treeSingleScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "single",
  dir.data = dir.data, dir.result = dir.result)
```

##### Escaneo múltiple de TLS (o tecnología SLAM)

```r
met.var <- metrics.variables(
  tree.tls = treeMultiScan,
  plot.design = c("fixed.area", "k.tree", "angle.count"),
  plot.parameters = data.frame(radius = 10, k = 8, BAF = 1),
  scan.approach = "multi",
  dir.data = dir.data, dir.result = dir.result)
```

#### Rutina para automatizar el flujo de trabajo con varias parcelas

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
#### Simulaciones

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

#### Estimación del sesgo relativo

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

#### Estimación de las correlaciones

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
