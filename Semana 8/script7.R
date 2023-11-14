library(corrplot)
library(psych)

usarrests <- read.csv("files//USArrests.csv", stringsAsFactors = F)
View(usarrests)
rownames(usarrests) <- usarrests$X 
usarrests$X <- NULL
head(usarrests)
View(usarrests)

usarrests<-na.omit(usarrests)
# el acp se realiza sobre datos numericos y debe existir correlacion alta entre las variales
# la idea es reducir las variables para explicar los datos con la menor cantidad de variales
str(usarrests)
cor(usarrests)

corrplot.mixed(cor(usarrests),
               lower = "number", 
               upper = "circle",
               tl.col = "black")


pairs.panels(usarrests,
             smooth = TRUE,      # Si TRUE, dibuja ajuste suavizados de tipo loess
             scale = FALSE,      # Si TRUE, escala la fuente al grado de correlación
             density = TRUE,     # Si TRUE, añade histogramas y curvas de densidad
             ellipses = TRUE,    # Si TRUE, dibuja elipses
             method = "pearson", # Método de correlación (también "spearman" o "kendall")
             pch = 21,           # Símbolo pch
             lm = FALSE,         # Si TRUE, dibuja un ajuste lineal en lugar de un ajuste LOESS
             cor = TRUE,         # Si TRUE, agrega correlaciones
             jiggle = FALSE,     # Si TRUE, se añade ruido a los datos
             factor = 2,         # Nivel de ruido añadido a los datos
             hist.col = 4,       # Color de los histogramas
             stars = TRUE,       # Si TRUE, agrega el nivel de significación con estrellas
             ci = TRUE)          # Si TRUE, añade intervalos de confianza a los ajustes


apply(usarrests, 2, var)

acp <- prcomp(usarrests, center = TRUE, scale = TRUE)
# ver el porcentage de explicacion de los datos con proportion of varianza
summary(acp)
#print(acp)

plot(acp, type = "l")
# seleccionamos los compontentes principales con los que 
#queremos trabajar

# sacarmos la desviacion standar extrayento la sd de cada
desv_stand= acp[[1]]  # nos  da los primeros valores
# aca vemos que los ACP tiene una variaza pero nesecitamos la variaza 
desv_stand # es la raiz de la variaza

# pero necesitamos ver la  varianza para saber si esta varianza es mayor a  1
variaza=desv_stand^2 #multiplicamos por raiz cuadrada

# aca sacamos  los ACP que necesitamos porque tiene la varianza mayor a 1
variaza # aca explicamos la mayor variabliddad posive perdiendo la minima informacion

# otra manera grafica de ver la cantidad requerida de CP a utilizar
plot(acp,type="l")
library(factoextra)
library("ade4")
fviz_eig(acp)

cp1 =acp[[2]][,1]
cp2 =acp[[2]][,2]
cp3 =acp[[2]][,3]

componentes<-cbind(cp1,cp2,cp3)
individuos<-acp$x[,1:3]
library(corrplot)
??s.corcircle
s.corcircle(componentes[,-3],sub = "CP1 y CP2",possub = "topright" )
s.label(individuos[,-3],label = row.names(usarrests),sub = "CP1 y CP2",possub = "topright")


########################################################################################
## Ejemplo 2

install.packages("corrplot")
library(corrplot)

bh <- read.csv("files/BostonHousing.csv")
View(bh)

corr <- cor(bh[,-14])
corr
chart.Correlation(corr, histogram = F, pch = 19)

corrplot(corr, method = "circle")

corrplot.mixed(cor(bh),
               lower = "number", 
               upper = "circle",
               tl.col = "black")


pairs.panels(cor(bh),
             smooth = TRUE,      # Si TRUE, dibuja ajuste suavizados de tipo loess
             scale = FALSE,      # Si TRUE, escala la fuente al grado de correlación
             density = TRUE,     # Si TRUE, añade histogramas y curvas de densidad
             ellipses = TRUE,    # Si TRUE, dibuja elipses
             method = "pearson", # Método de correlación (también "spearman" o "kendall")
             pch = 21,           # Símbolo pch
             lm = FALSE,         # Si TRUE, dibuja un ajuste lineal en lugar de un ajuste LOESS
             cor = TRUE,         # Si TRUE, agrega correlaciones
             jiggle = FALSE,     # Si TRUE, se añade ruido a los datos
             factor = 2,         # Nivel de ruido añadido a los datos
             hist.col = 4,       # Color de los histogramas
             stars = TRUE,       # Si TRUE, agrega el nivel de significación con estrellas
             ci = TRUE)          # Si TRUE, añade intervalos de confianza a los ajustes



#scale = T, matriz de correlaciones
#scale = F, matriz de covarianzas
bh.acp <- prcomp(bh[,-14], scale = F)

summary(bh.acp)

plot(bh.acp)
plot(bh.acp, type = "lines")

#Seleccionamos los componentes principales con lo que se desea trabajar
res_acp <-bh.acp$x[,1:4]
str(res_acp)

View(res_acp)


