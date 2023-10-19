---
editor_options: 
  markdown: 
    wrap: 72
---

# Shiny_apps_docker

Este es un ejemplo básico para ejecutar shiny-apps en contenedores
Docker.Para ejecutar el contenedor que se muestra en este tutorial se
asume que Docker ya esta instalado.Sin embargo a continuación te dejo el
enlace para la descarga de [Docker](https://www.docker.com/)

## Estructura

El siguiente proyecto considera como archivos y elementos principales,el archivo Dockerfile,la carpeta mi_app, y los archivos shiny-server.conf y shiny-server.sh.

El archivo Dockerfile sera con el que construiremos el contenedor,en cambio los otros archivos son necesarios para la ejecución de la shiny app.

``` docker
- 📁 Shiny_apps_docker
  - 📄 README.md
  - 📄 Dockerfile
    - 📁 mi_app
        - 📄 app.R
  - 📄 shiny-server.conf
  - 📄 shiny-server.sh
  - 📄 .gitignore
      
```

### Dockerfile

El archivo docker puede ser modificado segun el tipo de aplicación que
se utilice.En este caso si deseas seguir trabajando con shiny apps,y
agregar otras features,puedes agregar la instalación de otras librerias
para R.

``` docker
# Descarga de una version de r del paquete tidyverse
FROM rocker/shiny-verse:latest

# Librerias de uso general
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev\
    ## Limpieza
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Instalar paquetes de r que sean necesarios
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

# Limpieza
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copiar archivos de configuracion en la imagen docker
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copiar shiny app en la imagen docker
COPY mi_app /srv/shiny-server/

RUN rm /srv/shiny-server/index.html

# Habilitar el puerto 5000 para la shiny app
EXPOSE 5000

# Copiar el archivo de ejecucion de la shiny app en la imagen docker
COPY shiny-server.sh /usr/bin/shiny-server.sh

USER shiny

CMD ["/usr/bin/shiny-server"]
```

## Build

``` docker
docker build -t shiny_app .
```

## Run

``` docker
docker run -d -p 5000:5000 shiny_app 
```
## Acceso al contenedor

Si todos los pasos anteriores se desarrollaron de forma correcta,el contenedor se debe estar ejecutando en:

[127.0.0.1:5000](127.0.0.1:5000)


