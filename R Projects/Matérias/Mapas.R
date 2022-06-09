# Importando bibliotecas
library(raster)
library(rgdal)
library(googledrive)
library(tidyverse)
library(broom)
library(maptools)

# Por algum motivo precisa baixar isso para funfar a função do maptools, mas não 
# precisa importar
install.packages("gpclib")

# Diretório
setwd("C:/Users/CLIENTE/OneDrive/Área de Trabalho/Economia/6º Semestre/Series - Manuel/Laboratorio-Econometria")

# Procurando o arquivo no Drive
dados <- drive_find(q = "name contains 'Dados_Educacao_Final'")

# Criando arquivo temporário
temp <- tempfile()

# Importando o arquivo
dl <- drive_download(as_id(dados$id), path = temp, overwrite = TRUE)
df.educ <- read.csv(dl$local_path)

df.eduf.mun <- df.educ %>%
  group_by(id_municipio) %>%
  summarise(mean(Taxa_Aprovacao_IDEB, na.rm = T))

names(df.eduf.mun)[2] <- paste("Média")

# Removendo
rm(list = c("dados", "temp", "dl"))

# Gerando mapa
# Depois vou tenat puxar direto do site 
MAPA <- shapefile("BR_Municipios_2020.shp")

# Subset para região norte  
MAPA_N <- subset(MAPA, SIGLA_UF %in% c("AP", "AM", "AC", "RR", "PA", "RO", "TO"))

# Plotando mapa simples para ver se ta tudo certo
plot(MAPA_N)

# 
mapa_tidy <- tidy(MAPA_N, region = "CD_MUN")

ggplot() +
  geom_polygon(data = mapa_tidy, aes( x = long, y = lat, group = group),
               fill="white", color="grey") +
  theme_void() +
  coord_map()

df.eduf.mun$id_municipio <- as.character(df.eduf.mun$id_municipio)

mapa_tidy <- mapa_tidy %>%
  left_join(. , df.eduf.mun,
            by=c("id"="id_municipio"))

ggplot() +
  geom_polygon(data = mapa_tidy,
               aes(fill = Média, x = long, y = lat, group = group)) +
  theme_void() +
  coord_map() 
