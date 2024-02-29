

Antonio Jesús Ariza-Salamanca & Juan Alberto Molina-Valero

# Capitulo15_LiDAR_terrestre

## Extracción de parámetros estructurales a nivel de parcela (caso práctico basado en el paquete de R FORTLS)

```r
# Instalación y carga del paquete

install.packages(“FORTLS”)
library(FORTLS)
```

```r
# Establecimiento del directorio de trabajo (se aconseja que sea el mismo en dir.data y dir.result)

dir.data <- "…"
dir.result <- "…"

# Escaneo único de TLS

# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/s/17yl25pbrapat52/PinusRadiata.laz?dl=1", destfile = file.path(dir.data, "PinusRadiata.laz"), mode = "wb")

# Normalización

SingleScan <- normalize(las = "PinusRadiata.laz", id = "PinusRadiata",
x.center = 0, y.center = 0, # Coordenadas del centro de la parcela
max.dist = 15,
dir.data = dir.data, dir.result = dir.result)
```


```r
# Escaneo múltiple de TLS (o tecnología SLAM)

# Descarga de la nube de puntos en formato laz

download.file("https://www.dropbox.com/s/i905wj0lavklczb/PinusRadiataMultiScan.laz?dl=1",
destfile = file.path(dir.data, "PinusRadiataMultiScan.laz"), 
mode = "wb")

# Normalización

MultiScan <- normalize(las = "PinusRadiataMultiScan.laz", 
id = "PinusRadiataMultiScan",
x.center = 0, y.center = 0, # Coordenadas del centro de la parcela
max.dist = 15,
scan.approach = "multi",
dir.data = dir.data, dir.result = dir.result)
```
