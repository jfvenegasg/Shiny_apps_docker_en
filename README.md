# Shiny apps in Docker

This is a tutorial to run shiny-apps in the Cloud Run service of Google Cloud Platform. To deploy a shiny-app, docker images will be used, which are first tested locally and then migrated to the cloud. In this tutorial It assumes that you already have Docker installed, however below I leave you the link to download [Docker](https://www.docker.com/)

## Structure

The following project considers as main files and elements the **Dockerfile** file, the **my_app** folder, and the *shiny-server.conf* and *shiny-server.sh* files.

The Dockerfile file will be the one with which we will build the container, however the other files are necessary for the execution of the shiny app.

``` docker
- 📁 Shiny_apps_docker
  - 📄 README.md
  - 📄 Dockerfile
    - 📁 my_app
        - 📄 app.R
        - 🖼️ docker_1.png
        - 💹 trip_austin.csv        
  - 📄 shiny-server.conf
  - 📄 shiny-server.sh
  - 📄 .gitignore
  - 🖼 image_app.png
  - 🖼 image_repo_docker.png
  - 🖼 create_repo.png
  - 🖼 artifact_registry.png
  - 🖼 cloud_run_1.png
  - 🖼 cloud_run_2.png
  - 🖼 cloud_run_3.png
      
```

### Dockerfile

The docker file can be modified depending on the type of application being used. In this case, if you want to continue working with shiny apps, and add other features, you can add the installation of other libraries for R.

``` docker
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
```

## Build

To build the docker image called shiny_app, the following line is used.

``` docker
docker build -t shiny_app .
```

If the image is built well, this will be the one we migrate to the cloud.

## Run

Once the shiny_app image is ready, we execute the following line to run our image inside a container locally, the app will have port 5000 exposed.

``` docker
docker run -d -p 5000:5000 shiny_app 
```

## Access to container

If all the previous steps were carried out correctly, the container should be running at the following local address.

[127.0.0.1:5000](http://127.0.0.1:5000)

![app-shiny](image_app.png)

## Push docker image

To migrate the already built image, we must first enable the Artifact Registry service in Google Cloud Platform. If we enable it correctly we should see the following screen.

![artifact_rgistry_gcp](artifact_registry.png)

Then in this service we must create a repository, which can be created from the GCP console or from the **Create Repository** menu.

![create repository](create_repo.png)

When we create the repository we choose the format as Docker, the mode as standard and the region in this case I will set it to southamerica-west1[Santiago]. Once the repository is created we configure our docker locally to be able to push or pull the images .

``` dockerfile
gcloud auth configure-docker southamerica-west1-docker.pkg.dev
```

Then we have to tag our shiny_app with the directory path of the cloud image repository.

``` dockerfile
docker tag shiny_app_en:latest southamerica-west1-docker.pkg.dev/driven-saga-403916/docker-repo/shiny_app_en:latest
```

Once the image has been tagged, we can push the image with the following line.

``` dockerfile
docker push southamerica-west1-docker.pkg.dev/driven-saga-403916/docker-repo/shiny_app_en:latest
```

If the image was uploaded correctly we can see it in the Artifact Registry repository as seen in the image.

![image in the repo docker](image_repo_docker.png)

As we can see in the image, we already have the image of our shiny app. This way we can now deploy it with the Cloud Run service.

## Deploy with Cloud Run

Once we access the Cloud Run service, we have to create a service where the following menu will open.

![Configuration Cloud Run](cloud_run_1.png)

From the service configuration menu we have to select in the first option **Container image URL**, the path where our image is located in the repository, then we assign the **Service Name** and the **Region** .

Below we select the value of 1 in the **Minimum number of instances** option, so that the first deployment is not so slow.

Also in the **Authentication** menu, we select the option ***Allow unauthenticated invocations***

Finally, in the last configuration module we select the value of 5000 in the **Container port** option, which corresponds to the port we assigned in the dockerfile.

If the image is displayed correctly, we should be able to see it as it looks in the image.

![Deploy service in cloud run](cloud_run_2.png)

Finally, if we want to access the service, we can enter the URL shown in the image.

I leave them below.

<https://shiny-app-en-vvrixyvk3q-uc.a.run.app/>

Here is a view of the shiny app.

![Shiny app deploy](cloud_run_3.png)
