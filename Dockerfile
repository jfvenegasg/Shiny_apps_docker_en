# Downloading an r version of the tidyverse package
FROM rocker/shiny-verse:latest

# Libraries of general use
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

# Install r packages
RUN R -e "install.packages(c('shiny','htmlwidgets','dplyr','DT','echarts4r','bs4Dash'), repos='http://cran.rstudio.com/')"


# Cleaning
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configurations files in the docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copy shiny app in the docker image
COPY my_app /srv/shiny-server/

RUN rm /srv/shiny-server/index.html

# Enable 5000 port
EXPOSE 5000

# Copy shiny server in the docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

USER shiny

CMD ["/usr/bin/shiny-server"]