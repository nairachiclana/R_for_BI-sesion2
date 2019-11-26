################################################################
################################################################
#                                                              #
#          R FOR BUSINESS INTELLIGENCE: SESION 2               #
#                                                              #
################################################################
################################################################



#################################
#                               #
# 1. IMPORTAR DATOS             #
#                               #
#################################

#Definir directorio de trabajo
getwd()
setwd("/Users/nairachiclana/Documents/Github/R_for_BI-Season2/")
#Comprobar que se ha configurado correctamente
getwd()




##########DATOS#############

# DF Main: Daatos históricos incluyendo las ventas y clientes
  #store: id único para cada tienda
  #dayofweek
  #date
  #sales
  #customers: number of customer in that day and store
  #open: 0=closed, 1=open
  #promo: 1=promo that day in that store, 0=no
  #stateHoliday: a=public holiday, b=easter holiday, c=christmas, 0=none
  #SchoolHoliday: indica si la (tienda, fecha) ha sido afectada por el cierre de los colegios

#DF Store: información adicional de las tiendas
  #store: mismo id único
  #storeType: modelos de tienda, a b c y d
  #Assortment: grado de diversidad, a=basic, b=extra, c=extended
  #CompetitionDistance: distancia en metros al competidor más cercano
  #Promo2: una promoción continuada y consecutiva en algunas tiendas, 0=la tienda no participa, 1=la tienda participa
  #Promo2SinceWeek y Promo2SinceYear: semana y año cuando la tienda comenzó a participar en promo2
  #Promo interval: intervalos en los que comienza la promo2

##############################
  



# -----------Leer archivo csv con read.table() ---------------------------------------------
df_main_table<-read.table("data/Rossmann/main.csv") # sep= " " por defecto
df_main_table<-read.table("data/Rossmann/main.csv", sep=",") #header=FALSE por defecto
head(df_main_table)
df_main_table<-read.table("data/Rossmann/main.csv", header=TRUE, sep=",") 
head(df_main_table)

#Otras utilidades de la función read.table()
?read.table()
  #leer solo las n primeras lineas
dim(df_main_table)
df_main_table<-read.table("data/Rossmann/main.csv", header=TRUE, sep=",", nrows=1000) 
dim(df_main_table)

  #empezar a leer 1000 lineas después de las 300 primeras lineas 
head(df_main_table)
df_main_table<-read.table("data/Rossmann/main.csv",  sep=",", nrows=1000, skip=300) 
head(df_main_table)
  #crear vector de nombres
name_of_columns=c("Id", "Store", "DayOfWeek", "Date", "Open", "Promo", "StateHoliday", "SchoolHoliday")
df_main_table<-read.table("data/Rossmann/main.csv",  sep=",", nrows=1000, skip=300, col.names=name_of_columns) 
head(df_main_table)



# -----------Leer archivo csv con read.csv()---------------------------------------------
df_main_csv<-read.csv("data/Rossmann/main.csv") #header=TRUE and sep="," por defecto
head(df_main_csv)

?read.csv 

# -----------Leer archivo con read_excel()---------------------------------------------

#df_store_excel<-read.table("data/Rossmann/store.xlsm", sep="\t", header=TRUE)

#install.packages("readxl")
library(readxl)
library(xlsx)

df_store_excel<-read_excel("data/Rossmann/store.xlsm") 
head(df_store_excel)
class(df_store_excel)

#read_excel() llama a excel_format() para comprobar extensión
#Si la sabemos, mejor llamar directamente a la función correspondientes (read_xls(()),  read xlsx())
#Archivos grandes en formato xlsx se leen de forma más eficiente con la función read xlsx(file)


df_store_excel2<-read.xlsx(xlsxFile="data/Rossmann/store.xlsm")
head(df_store_excel2)

?read.xlsx

#Leemos hoja distinta a la princial
read.xlsx("data/Rossmann/store.xlsm", sheet=2) #por defecto salta lineas vacías al principio del archivo



#----------BORRAR ESTO PARA QUE LO HAGAN ELLOS------------------------------
read.xlsx("data/Rossmann/store.xlsm", sheet=2, colNames=FALSE, na.strings=c("-", " "))
read.xlsx("data/Rossmann/store.xlsm", sheet=2, colNames=TRUE, check.names=TRUE)




#################################
#                               #
# 2. PREPARAR DATOS             #
#                               #
#################################


#2.1. REDUCCIÓN DE TAMAÑO

#Con la función dim() podemos definir o ver la dimensión de un objeto. Para un df vemos el número de filas y columnas.
dim(df_main_csv)
dim(df_store_excel)

  #El conjunto "main" es algo grande, lo reduciremos a 500k observaciones para tratarlo con más velocidad.
  #Nos quedaremos con 50k filas de forma aleatoria para intentar que los datos se sesguen lo mínimo posible.
library(dplyr)
df_main_reduced<-sample_n(df_main_csv, 500000)
dim(df_main_reduced)

  #Para elegir el número de filas de forma dinámica, sabiendo que queremos más o menos la mitad,
  #podemos crear una variable con el valor de la mitad del número de filas, obtenido con la función nrow()
mitad_filas<-nrow(df_main_csv)/2
df_main_reduced<-sample_n(df_main_csv, mitad_filas)
dim(df_main_reduced)

#2.2.CONVERSIÓN DE TIPOS

#Tipos de datos del conjunto df_main
str(df_main_reduced)
  
  #con la función unique() vemos los valores distintos que contiene una variable
unique(df_main_reduced$DayOfWeek)
  #día de la semana tiene solo 7 valores distintos, por lo que la convertiremos de numérica a factor con la función as.factor()
df_main_reduced$DayOfWeek<-as.factor(df_main_reduced$DayOfWeek)
  #comprobamos que se ha transformado correctamente con la función class()
class(df_main_reduced$DayOfWeek)

  #Realizamos el mismo proceso para la variable Promo
unique(df_main_reduced$Promo)
df_main_reduced$Promo<-as.factor(df_main_reduced$Promo)
class(df_main_reduced$Promo)

  #Y para la variable SchoolHoliday
unique(df_main_reduced$SchoolHoliday)
df_main_reduced$SchoolHoliday<-as.factor(df_main_reduced$SchoolHoliday)
class(df_main_reduced$SchoolHoliday)

  #¿Alguna más? -> ----------BORRAR ESTO PARA QUE LO HAGAN ELLOS------------------------------
unique(df_main_reduced$Open)
df_main_reduced$Open<-as.factor(df_main_reduced$Open)
class(df_main_reduced$Open)
  #La fecha, debería estar en formato fecha, ¿no?
df_main_reduced$Date<-as.Date(df_main_reduced$Date)

df_main_reduced$Store<-as.character(df_main_reduced$Store)

  #--------Que prueben a poner promo y open como lógical y volver a dejarlo como categórico y explicar porqué.
  #--------En manipulación renombrar esos valores a Yes/No

  #comprobamos que los cambios se han guardado en el dataframe
str(df_main_reduced)

  
#Tipos del conjunto df_store
str(df_store_excel)

#-----------------ESTE LO HACEMOS ENTERO EN DIRECTO COMO EJERCICIO, BORRAR DE AQUÍ------------------------------
df_store<-df_store_excel
df_store$StoreType<-as.factor(df_store$StoreType)
df_store$Assortment<-as.factor(df_store$Assortment)
df_store$Promo2<-as.factor(df_store$Promo2)
df_store$Store<-as.character(df_store$Store)

  #¿Porqué poner años e intervalos mensuales como factor? Explicar
df_store$CompetitionOpenSinceYear<-as.factor(df_store$CompetitionOpenSinceYear)
df_store$Promo2SinceYear<-as.factor(df_store$Promo2SinceYear)
df_store$PromoInterval<-as.factor(df_store$PromoInterval)

str(df_store)

  #--------Prueba ejemplo de factor a numérico y volver a ponerlo bien
  
#2.3. VALORES PERDIDOS (MISSING VALUES) Y DATOS ERRONEOS

#Conjunto main
summary(df_main_reduced)
  #solo hay valores perdidos en Open y parece que muy pocos, veamos que % de los datos es
  #is.na() devuelve TRUE donde hay valores vacios
  #sum() suma valores, el valor TRUE lo cuenta como 1
number_of_nas_in_open<-sum(is.na(df_main_reduced$Open))
  #¿cuantos son en proporción al total?
(number_of_nas_in_open/nrow(df_main_reduced))*100
  #son muy pocos, podemos borrar esas filas

df_main_reduced<-df_main_reduced[!is.na(df_main_reduced$Open),]
sum(is.na(df_main_reduced$Open))
  #comprobamos que se han guardado los cambios y ya no tenemos ningún valor perdido
  #(aunque si nos fijamos mejor, vemos que solo es en la tienda 622)
summary(df_main_reduced)

#Conjunto store 
summary(df_store)

#----ESTO BORRAR PARA HACERLO ALLI--
df_store<-df_store[!is.na(df_store$CompetitionDistance),]

(sum(is.na(df_store$CompetitionOpenSinceMonth))/nrow(df_store))*100
#¿Es por alguna razón concreta? Veamos estas filas
df_store[is.na(df_store$CompetitionOpenSinceMonth),]
  #ARREGLAR
df_store[is.na(df_store$Promo2SinceWeek),]
#vemos que las filas con NAs para PromoInterval, Promo2SinceWeek y Promo2SinceYear coinciden y además coinciden con el número de no promo (y valor promo2=0) en Promo2.
#no se tratan de valores perdidos, sino de valores vacíos por depender de que otra variable tenga valor.
#una de las posibles opciones (habiendo validado la teoría) convertir estos valores en un nivel válido, por ejemplo "no promo"

library(data.table)

col="Promo2SinceWeek"
#Convertimos el dataframe a datatable para usar función set (:=)
df_store %>% setDT()
df_store<-data.table::set(df_store, i=which(is.na(df_store[[col]])), j=col, value="NoPromo2")
df_store[, Promo2SinceWeek:=as.character(Promo2SinceWeek)]
df_store<-data.table::set(df_store, i=which(is.na(df_store[[col]])), j=col, value="NoPromo2")
df_store$Promo2SinceWeek<-as.factor(df_store$Promo2SinceWeek)
summary(df_store)

#lo  hacemos para el resto de casos de fechas derivadas de promo2
col="Promo2SinceYear"
data.table::set(df_store, i=which(is.na(df_store[[col]])), j=col, value="NoPromo2")
col="PromoInterval"
data.table::set(df_store, i=which(is.na(df_store[[col]])), j=col, value="NoPromo2")
summary(df_store)


#¿Como podríamos comprobar si son las mismas filas que las funciones que conocemos hasta ahora?
length(unique(df_store$Store))
nrow(df_store)

sum(is.na(df_store$CompetitionOpenSinceMonth))
sum(is.na(df_store$CompetitionOpenSinceYear))
sum(df_store[is.na(CompetitionOpenSinceMonth),]$Store==df_store[is.na(CompetitionOpenSinceYear),]$Store)
  #Nas coinciden para ambas columnas
  #Es un porcentaje alto, podríamos, por ejemplo, imputarlo, o analizarlo más para encontrar la causa 
  #Por ahora vamos a eliminarlas  ya que no tienen interés analítico en este ejercicio
df_store[,CompetitionOpenSinceMonth:=NULL]
df_store[,CompetitionOpenSinceYear:=NULL]

summary(df_store)

#2.4. NIVELES SESGADOS 

#Conjunto store
summary(df_store)


#Columnas con niveles sospechosamente excasos
#con table(vector) podemos ver el número de apariciones (filas) de cada valor distinto
#con prop.table(table) vemos la proporción relativa de cada valor


table(df_store$Assortment)
prop.table(table(df_store$Assortment))*100
#solo un 0.8% de los datos con valor b -> Dejar este caso para Data manipulation
#df_store<-df_store[Assortment!="b",]
#table(df_store$Assortment)

prop.table(table(df_store$StoreType))*100
df_store<-df_store[StoreType!="b",]
table(df_store$StoreType)

#El resto de valores parece normalmente distribuido
library(funModeling)
freq(df_store)

#Conjunto main
summary(df_main_reduced)
freq(df_main_reduced)
  #¿Necesita algún cambio?


#2.5. Otros
#Ordenar df por fecha
summary(df_main_reduced)
df_main_reduced %>% setDT()
df_main_reduced<-df_main_reduced[order(Date)]





#################################
# 3. MANIPULAR DATOS            #
#################################


#4.1. RENOMBRAR DATOS - COLUMNAS

#Con la función setnames(df, old_name, new_name) del paquete data.table() podemos renombrar atributos. skip_absent nos permite saltar los old_name que no existan en el conjunto.
# Esta librería ya la hemos cargado anteriormente y se queda activa esta sesión, por lo que no hay que volver a hacerlo

#Conjunto Main
  #open: 0=closed, 1=open
  #promo: 1=promo that day in that store, 0=no
  #stateHoliday: a=public holiday, b=easter holiday, c=christmas, 0=none
  #SchoolHoliday: indica si la (tienda, fecha) ha sido afectada por el cierre de los colegios


setnames(df_main_reduced, old = c("SchoolHoliday", "Customers","Store"),new = c("SchoolHolidayAffected", "NumberOfCustomers", "StoreId"), skip_absent=TRUE)
str(df_main_reduced)

#Conjunto Store 
  #storeType: modelos de tienda, a b c y d
  #Assortment: grado de diversidad, a=basic, b=extra, c=extended
  #Promo2: una promoción continuada y consecutiva en algunas tiendas, 0=la tienda no participa, 1=la tienda participa
  #Promo2SinceWeek y Promo2SinceYear: semana y año cuando la tienda comenzó a participar en promo2
  #Promo interval: intervalos en los que comienza la promo2

#--------BORRAR ESTE PARA QUE LO HAGAN ELLOS-----------
setnames(df_store, old = c("Store"),new = c("StoreId"), skip_absent=TRUE)
str(df_store)


#4.1. RENOMBRAR DATOS - NIVELES

#La función revalue(vector, sustituciones) del paquete plyr nos permite renombrar los niveles de una variable categórica
#Con la función levels(vector) podemos ver los niveles de una variable

#Conjunto Main
  
library(plyr)

df_main_reduced$Open <- revalue(df_main_reduced$Open, c("0"="No", "1"="Yes"))
levels(df_main_reduced$Open)
df_main_reduced$Promo <- revalue(df_main_reduced$Promo, c("0"="No", "1"="Yes"))
df_main_reduced$StateHoliday <- revalue(df_main_reduced$StateHoliday, c("a"="Public_H", "b"="Easter_H", "c"="Christmas_H", "0"="None_H"))
df_main_reduced$SchoolHolidayAffected <- revalue(df_main_reduced$SchoolHolidayAffected, c("0"="NotAffected", "1"="Affected"))

#Comprobamos que se han guardado los cambios
str(df_main_reduced)

#Conjunto Store #--------BORRAR ESTE PARA QUE LO HAGAN ELLOS-----------
  
df_store$Assortment <- revalue(df_store$Assortment, c("a"="basic", "b"="extra", "c"="extended"))
df_store$Promo2  <- revalue(df_store$StateHoliday, c("0"="NotApplied", "1"="Applied"))
str(df_store)


# FITLRAR DATOS
#La función filter(df, filtro para columna) del paquete dplyr nos permite filtrar las filas que cumplan la condición indicada
#También podemos hacerlo directamente con las utilidades de r poniendo la condición en la selección de filas


#Conjunto store
summary(df_store)

hist(df_store$CompetitionDistance)
  #De CompetitionDistance, eliminaremos los competidores que estén a más de 40k metros
  
df_store<-dplyr::filter(df_store, CompetitionDistance<40000) #Con dplyr
#Con utilidades de R: df_store<-df_store[df_store$CompetitionDistance<40000,] 
hist(df_store$CompetitionDistance)
table(df_store$Promo2SinceYear)

#Conjunto main
summary(df_main_reduced)

hist(df_main_reduced$Sales)
hist(df_main_reduced$NumberOfCustomers)

#¿Se os ocurre algún posible otro filtro? ¿Como lo haríais?


#CREAR NUEVAS COLUMNAS

  #Indicador de competidor a menos de 10k metros
df_store %>% setDT()
df_store[,near_competitor:=ifelse(CompetitionDistance<1000, "Yes", "No")]
  #Usando lo aprendido en filtros del apartado anterior, filtramos por la nueva variable creada y comprobamos la distancia maxima
df_filtrado_competidoresCercanos<-dplyr::filter(df_store, near_competitor=="Yes")
max(df_filtrado_competidoresCercanos$CompetitionDistance)


  #Ventas por cliente para cada fecha y tienda
df_main_reduced[,sales_per_client:=(Sales/NumberOfCustomers)]
df_main_reduced[,sales_per_client:=ifelse(Sales==0 & NumberOfCustomers==0,0,(Sales/NumberOfCustomers))]
df_main_reduced
  #Estaría bien redondearlas, ¿Como lo haríamos? ¿Y redondear dejando un decimal?

hist(df_main_reduced$sales_per_client)
  #Ejercicio: Indicador que nos diga si las ventas por cliente son mayores a la media de ventas por cliente  


#¿Se os ocurre alguna otra?

#Con agregaciones (vistas) -EJERCICIOS

# a) Suma de ventas por cada tipo de vacaciones estatales

df_agregado1<-df_main_reduced %>% dplyr::group_by(StateHoliday) %>% dplyr::summarise(sum_by_holiday=sum(Sales)) %>% setDT()
#class(df_main_reduced$Sales)

# b) Media de ventas por cada tipo de vacaciones estatales

# c) Media de clientes por cada tipo de vacaciones estatales

# d) Ventas por cliente por cada tipo de grado de diversidad

# d) Ventas por cliente por cada tipo de grado de diversidad y vacaciones estatales



#UNIÓN DE CONJUNTOS
#Podemos unir conjuntos a partir de columnas coincidentes, en este caso el indetificador de tienda
#En este caso usaremos el paquete dplyr, con diferentes funciones de join para combinar conjuntos: left join, right, inner, full, semi,...
#Ver opciones de unión graficamente: https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

#Unir los datos de tienda al conjunto principal por identificador de tienda

  #Con unión interna nos quedamos solo con las filas en las que hay coincidencia en StoreId, por lo tanto, 
  #tendrá, como máximo el tamaño del menor conjunto de la unión (y como mínimo 0, ya que podrían no tener id coincidentes)
df_unioin_interna<-dplyr::inner_join(df_main_reduced, df_store, by = "StoreId")
  #¿Como lo haríamos ahora si cuando hemos renombrado columnas no le hubiéramos puesto el mismo nombre?
dim(df_unioin_interna)
sum(is.na(df_unioin_interna))

  #Con la unión completa tendremos todos los valores distintos de todas las columnas
df_unioin_completa<-dplyr::full_join(df_main_reduced, df_store, by = "StoreId")        
dim(df_unioin_completa)
sum(is.na(df_unioin_completa))

  #Ejercicio: ¿Y si quisieramos quedarnos solo con los valores conjunto de los id del conjunto main? (Mirar cheatsheet) d



#TRANSFORMACIONES VARIABLES NUMÉRICAS

#Cjto main
str(df_main_reduced)
#Guardamos un df auxiliar con las variables numéricas (todas las filas y columnas con los nombres indicados)
df_main_numericas<-df_main_reduced[,names(df_main_reduced) %in% c("Sales", "NumberOfCustomers", "sales_per_client"), with=FALSE]
#Diagramas de cajas y bigotes
boxplot(df_main_numericas)

par(mfrow=c(1,2))
boxplot(df_main_reduced$NumberOfCustomers)
hist(df_main_reduced$NumberOfCustomers)

par(mfrow=c(1,2))
boxplot(df_main_reduced$sales_per_client)
hist(df_main_reduced$NumberOfCustomers)

#Ambos tienen distribuciones muy asimétricas (skeweed distributions) con muchos outlayers.
#Sustituiremos esas variables por su valor estadístico para suavizarlas

df_main_reduced[,NumberOfCustomers_log:=log(NumberOfCustomers)]
par(mfrow=c(1,2))
boxplot(df_main_reduced$NumberOfCustomers_log)
hist(df_main_reduced$NumberOfCustomers_log)

  #Que vemos en el warning? ¿Como podemos solucionarlo con las herramientas que tenemos?
df_main_reduced[,NumberOfCustomers:=ifelse(NumberOfCustomers<0,0,NumberOfCustomers)] 
boxplot(df_main_reduced$NumberOfCustomers)
hist(df_main_reduced$NumberOfCustomers)




df_main_reduced[,sales_per_client_log:=log(sales_per_client)]
par(mfrow=c(1,2))
boxplot(df_main_reduced$sales_per_client_log, main="Boxplotlog Ventas/Cliente")
hist(df_main_reduced$sales_per_client_log, main="Histograma log Ventas/Cliente", xlab="ventas por cliente")




#################################
# 4. ANALIZAR DATOS             #
#################################


#Ventas
hist(df_main_reduced$Sales,50)

#Ventas medias por tienda cuando la tienda no estaba cerrada (ventas 0)
hist(aggregate(df_main_reduced[Sales != 0]$Sales, 
               by = list(df_main_reduced[Sales != 0]$Store), mean)$x, 50, 
     main = "Ventas medias por tienda")


#Clientes
hist(df_main_reduced$NumberOfCustomers,50)

#¿Y si queremos verlo sin logaritmo, con el dato original?

#Media de clientes por tienda cuando la tienda no estaba cerrada
hist(aggregate(df_main_reduced[Sales != 0]$NumberOfCustomers, 
               by = list(df_main_reduced[Sales != 0]$Store), mean)$x, 100,
     main = "Media clientes por tienda")


# ¿Como afectan las vacaciones escolares a las ventas?
ggplot(df_main_reduced[Sales != 0], aes(x = SchoolHolidayAffected, y = Sales)) +
  geom_jitter(alpha = 0.1) + geom_boxplot(color = "yellow",  fill = NA)

# ¿Qué relación hay entre las ventas y los cliente? ¿Es estrictamente lineal?

ggplot(df_main_reduced[df_main_reduced$Sales != 0 & df_main_reduced$NumberOfCustomers != 0],
       aes(x = NumberOfCustomers, y = Sales)) + 
  geom_point(alpha = 0.2) + geom_smooth()
  #¿Como sería esta curva sin logaritmo?    

#¿Cómo le afectan las promociones a las ventas?
ggplot(df_main_reduced[df_main_reduced$Sales != 0 & df_main_reduced$NumberOfCustomers != 0],
       aes(x = Promo, y = Sales)) + 
  geom_jitter(alpha = 0.1) +
  geom_boxplot(color = "yellow", outlier.colour = NA, fill = NA)

table(ifelse(df_main_reduced$Sales != 0, "Sales > 0", "Sales = 0"),ifelse(df_main_reduced$Promo=="Yes", "Promo", "No promo"))


#¿Y a los clientes? ¿aumentan, o solo se mantienen los mismos pero compran más?

ggplot(df_main_reduced[df_main_reduced$Sales != 0 & df_main_reduced$NumberOfCustomers != 0],
       aes(x = Promo, y = NumberOfCustomers)) + 
  geom_jitter(alpha = 0.1) +
  geom_boxplot(color = "yellow", outlier.colour = NA, fill = NA)



#¿Hay tiendas que no vendan nada aún estando abiertas?
table(ifelse(df_main_reduced$Open == "Yes", "Opened", "Closed"),
      ifelse(df_main_reduced$Sales > 0, "Sales > 0", "Sales = 0"))

#¿No venden nada porque no tienen clientes o porque los clientes no compran nada?
df_no_ventas<-df_main_reduced[Sales==0,]
table(ifelse(df_no_ventas$Open == "Yes", "Opened", "Closed"),
      ifelse(df_no_ventas$NumberOfCustomers > 0, "Customers > 0", "No customers"))

#¿Que tiendas y circunstancias han sido las que, estando abiertas, no han tenido compras?
df_main_reduced[Open == "Yes" & Sales == 0]

#¿Había alguna promoción? ¿Hay festividades en este grupo? ¿Ocurre solo en tiendas concretas?
df_open_withoutSales<-df_main_reduced[Open == "Yes" & Sales == 0]
table(df_open_withoutSales$StateHoliday)
table(df_open_withoutSales$Promo)
table(df_open_withoutSales$StoreId)

#Ventas 0 por tienda
zerosPerStore <- sort(tapply(df_main_reduced$Sales, list(df_main_reduced$Store), function(x) sum(x == 0)))
hist(zerosPerStore,50)
  #10 tiendas con más días de ventas 0
tail(zerosPerStore, 10)
#¿Estas tiendas han estado siempre abiertas?
plot(df_main_reduced[StoreId == "103", Sales], ylab = "Sales", xlab = "Days", main = "Store 103")
plot(df_main_reduced[StoreId == "708", Sales], ylab = "Sales", xlab = "Days", main = "Store 708")
plot(df_main_reduced[StoreId == "972", Sales], ylab = "Sales", xlab = "Days", main = "Store 972")

#¿Las tiendas abiertas los domingos tienen más ventas ese día que el resto de la semana?

ggplot(df_main_reduced, aes(x = Date, y = Sales, 
      color = factor(DayOfWeek == 7), shape = factor(DayOfWeek == 7))) + 
      geom_point(size = 3) + ggtitle("Sales of stores (True if sunday)")

#Mejor ver algún caso más concreto
ggplot(df_main_reduced[StoreId=="262"], aes(x = Date, y = Sales, 
  color = factor(DayOfWeek == 7), shape = factor(DayOfWeek == 7))) + 
  geom_point(size = 3) + ggtitle("Sales of stores (True if sunday)")

#Parece que si, ¿se cumple siempre? Veamos las ventas en general para cada día de la semana
ggplot(df_main_reduced[Sales != 0], aes(x = factor(DayOfWeek), y = Sales)) + 
  geom_jitter(alpha = 0.1) + 
  geom_boxplot(color = "yellow", outlier.colour = NA, fill = NA)


#¿Como afectan los tramos de promociones a las ventas?
#Están en conjuntos distintos, pero ya hemos visto antes que podemos unirlos
main_store <- merge(df_main_reduced, df_store, by = "StoreId")

ggplot(main_store[Sales != 0], aes(x =PromoInterval, y = Sales))  + 
  geom_jitter(alpha = 0.1) +
  geom_boxplot(color = "yellow", outlier.colour = NA, fill = NA)

#¿Como son las ventas por tipo de tienda?
ggplot(main_store[Sales != 0], aes(x = as.Date(Date), y = Sales, color = factor(StoreType))) + 
  geom_smooth(size = 2)


#EJERCICIO 
#¿Y los clientes?

#¿Y las ventas y los clientes según la diversidad?


#¿Afecta a las ventas que haya competencia? ya hemos creado antes esa variable :)
ggplot(main_store[Sales != 0], aes(x = factor(near_competitor), y = Sales)) + 
  geom_jitter(alpha = 0.1) + 
  geom_boxplot(color = "yellow", outlier.colour = NA, fill = NA)



#################################
# 5. VISUALIZAR DATOS           #
#################################

df_reduced=sample_n(main_store, 3000)
df_reduced_for_weekday=sample_n(main_store, 500)

##---------GGPLOT---------

#Colors
ggplot(df_reduced_for_weekday, aes(x=CompetitionDistance, y=Sales, colour=Promo)) + geom_point()
ggplot(df_reduced_for_weekday, aes(x=Date, y=NumberOfCustomers, colour=Promo)) + geom_point()
#Labels
ggplot(df_reduced_for_weekday[1:100,], aes(x=Date, y=NumberOfCustomers, colour=Promo)) + geom_point() + geom_text(aes(label=StateHoliday), size=3)
#Shapes
ggplot(df_reduced_for_weekday, aes(x=Date, y=NumberOfCustomers, shape=StoreType)) + geom_point()
#Sizes
ggplot(df_reduced_for_weekday[1:100,], aes(x=Date, y=NumberOfCustomers, size=Assortment)) + geom_point()
#Facet
ggplot(df_reduced_for_weekday, aes(x=Date, y=NumberOfCustomers, shape=StoreType)) + geom_point() + facet_wrap(~Promo) +theme_minimal()

  #barplor
p=ggplot(df_reduced_for_weekday, aes(x=DayOfWeek, y=sales_per_client)) + geom_bar(stat="identity")
p
p + coord_flip()

ggplot(df_reduced_for_weekday, aes(x=DayOfWeek, y=sales_per_client)) + geom_bar(stat="identity", width=0.7, fill="steelblue")  
ggplot(df_reduced_for_weekday, aes(x=Promo, y=sales_per_client, fill=Promo)) + geom_bar(width = 1, stat = "identity") + theme(legend.position="top")
ggplot(df_reduced_for_weekday, aes(x=DayOfWeek, y=sales_per_client, fill=Promo)) + geom_bar( stat = "identity", width=0.7, position=position_dodge())


gplot_barplot<-ggplot(df_reduced_for_weekday, aes(x="", y=sales_per_client, fill=Promo)) + geom_bar(width = 1, stat = "identity")
gplot_barplor
  #piechart
gplot_barplot + coord_polar("y", start=1) + scale_fill_brewer(palette="Dark2")


#Combinado
ggplot(df_reduced_for_weekday, aes(x=sales_per_client, y=NumberOfCustomers, shape=StoreType, color=Promo)) + geom_point()
  #line chart
ggplot(df_reduced_for_weekday[1:100,], aes(x=Date, y=NumberOfCustomers, shape=StoreType)) + geom_line(aes(color=Promo))






#---------PLOTLY---------
library(plotly)


#Simple scatter
plot_ly(data=df_reduced, x=~Sales, y=~NumberOfCustomers)

#Simple barplot of frequencys
plot_ly(data=df_reduced, x=~StoreType)

#Simple boxplot
plot_ly(data=df_reduced, x=~Sales, color=~PromoInterval, type="box")

#Colors
plot_ly(data=df_reduced, x=~Sales, y=~NumberOfCustomers, color=~StateHoliday)
plot_ly(data=df_reduced, x=~StoreType, color=~StateHoliday, type="histogram")



plot_ly(data=df_reduced_for_weekday, x=~Sales, y=~NumberOfCustomers, color=~StoreType)

pal<-c("red", "orange", "yellow", "pink", "blue", "gray", "purple")
plot_ly(data=df_reduced_for_weekday, x=~Sales, y=~NumberOfCustomers, color=~DayOfWeek, colors=pal)

df_reduced_for_weekday_2<-df_reduced_for_weekday[df_reduced_for_weekday$Sales<=10000,]
plot_ly(data=df_reduced_for_weekday_2, x=~Sales, y=~NumberOfCustomers, color=~DayOfWeek, colors="Set2")
plot_ly(data=df_reduced_for_weekday, x=~log(Sales), y=~NumberOfCustomers_log, color=~DayOfWeek, colors="Set2")

#Symbols
plot_ly(data=df_reduced_for_weekday_2, x = ~Sales, y = ~NumberOfCustomers, type = 'scatter',
        mode = 'markers', symbol = ~DayOfWeek)
plot_ly(data=df_reduced_for_weekday_2, x = ~Sales, y = ~NumberOfCustomers, type = 'scatter',
        mode = 'markers', symbol = ~DayOfWeek,  marker = list(size = 8), symbols = c('circle','x','o'))

#Sizes
plot_ly(data=df_reduced_for_weekday_2, x=~Sales, y=~NumberOfCustomers, 
        color=~DayOfWeek, colors="Set2", size=~CompetitionDistance)

#Etiquetas
plot_ly(data=df_reduced_for_weekday_2, x=~Sales, y=~NumberOfCustomers, 
        text=~paste("Weekday: ", DayOfWeek, "<br>Sales: ", Sales, "$<br>Customers: ", NumberOfCustomers, "<br>Promo: ", Promo ),
        color=~DayOfWeek, colors="Set2")

#Varias trazas
plot_ly(df_reduced[df_reduced$Sales,][1:500,], x=~Date, y =~Sales, name = 'Sales', type = 'scatter', mode = 'lines') %>%
  add_trace(y = ~NumberOfCustomers , name = 'Number of customers', mode = 'lines+markers') %>%
  add_trace(y = ~sales_per_client, name = 'Sales per client', mode = 'markers')

#3D
plot_ly(data=df_reduced_for_weekday, x=~NumberOfCustomers , y=~sales_per_client, z=~CompetitionDistance,type="scatter3d")
  #¿Como arreglaríais esta gráfica para que se entienda mejor? etiquetas, colores,...



#A mayor el dataset, más computacionalmente costoso es reproducirlo, especialmente von gráficos interctivos como los de plotly
#En los scatter plot no hay demasiadas opciones de reducción, el resto de gráficos depende del caso, pero normalmente siempre se suele poder reducir
#Siempre es más recomendable crear "vistas" de los datos que queremos graficar, obteniendo el mismo resultado con mucha más eficiencia y rapidez.
#En histogramas pueden crearse directamente los resúmenes de los datos a agregados a representar.

#ej:
#plot_ly(data=main_store, x=~DayOfWeek, y=~Sales)

df_sales_dayofweek<- df_reduced %>% group_by(DayOfWeek) %>% summarise(total_sales=sum(Sales)) %>% setDT()
plot_ly(data=df_sales_dayofweek, x=~DayOfWeek, y=~total_sales)

df_sales_dayofweek_typestore<- df_reduced %>% group_by(DayOfWeek, StoreType) %>% summarise(total_sales=sum(Sales)) %>% setDT()
plot_ly(data=df_sales_dayofweek_typestore, x=~DayOfWeek, y=~total_sales, color=~StoreType)


#EJERCICIOS (con ggplot o plotly) ---------------- BORRAR  ---------------


# a) Número de clientes medio para cada día de la semana

dummy<- df_reduced %>% group_by(DayOfWeek) %>% summarise(mean_customers=mean(NumberOfCustomers)) %>% setDT()
plot_ly(data=dummy, x=~DayOfWeek, y=~mean_customers)

# b) Número de clientes medio para cada dia de la semana cuando las tiendas están abiertas

dummy<-df_reduced[df_reduced$Sales!=0,]
dummy<- dummy %>% group_by(DayOfWeek) %>% summarise(mean_customers=mean(NumberOfCustomers)) %>% setDT()
plot_ly(data=dummy, x=~DayOfWeek, y=~mean_customers)


# c) Para cada tipo de tienda y(de las no afectadas por las vacaciones escolares) según haya promo o no, la venta máxima
dummy<- df_reduced[SchoolHolidayAffected=="NotAffected",]
dummy<- dummy %>% group_by(StoreType, Promo) %>% summarise(max_sale=max(Sales)) %>% setDT()
plot_ly(data=dummy, x=~StoreType, y=~max_sale, color=~Promo)

# d) Ventas medias según el día de la semana, en un grid con un gráfico distinto para cada tipo de tienda

dummy<- df_reduced %>% group_by(DayOfWeek, StoreType) %>% summarise(mean_sales=mean(Sales)) %>% setDT()
ggplot(dummy, aes(x=DayOfWeek, y=mean_sales))  + facet_wrap(~StoreType) + geom_bar(stat="identity")


#################################
#     EJERCICIO FINAL           #
#################################


# IMPORTAR OTRO CONJUNTO MÁS CONVENIENTE PARA VISUALIZACIÓN Y HACER UN EJERCICIO COMPLETO
# Importación, tipos de datos, tratamiento de datos, análisis primario y gráficas


