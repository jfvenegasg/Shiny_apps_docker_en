#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(htmlwidgets)
library(dplyr)
library(DT)
library(echarts4r)
library(bs4Dash)


ui <- fluidPage(

    # Application title
    titlePanel("Shiny app demo para ejecutarse en contenedor"),
    fluidRow(imageOutput("imagen")),
    
    fluidRow(actionButton(inputId = "boton_carga_at",label =  "Carga")),
    fluidRow(width=12,box(title = "Datos",dataTableOutput("datos_bigquery_at",width = "100%",height = "600px"),
                          width = 6,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2),
             box(title = "Grafico",echarts4rOutput("grafico_bigquery_at",width = "100%",height = "600px"),
                 width = 6,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2),
             box(title = "Grafico",echarts4rOutput("grafico_torta_trip_id_at",width = "100%",height = "600px"),
                 width = 12,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2))
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  #### Modulo analisis de datos Austin Trips ####
  
  respuesta_at <- reactiveValues(data=NULL)
  
  # observeEvent(input$boton_descarga_at, {
  #   project_id <- "apps-392022"
  #   sql<-"SELECT * from `bigquery-public-data.austin_bikeshare.bikeshare_trips` limit 100"
  #   consulta <- bigrquery::bq_project_query(project_id, sql)
  #   respuesta_at$datos <-bigrquery::bq_table_download(consulta)
  #   write.csv(x =respuesta_at$datos,file = "trips_austin.csv",row.names = FALSE)
  # })
  
  observeEvent(input$boton_carga_at, {
    respuesta_at$datos<-read.csv(file = "trips_austin.csv")
  })
  
  output$datos_bigquery_at<-renderDataTable(
    datatable(respuesta_at$datos,escape=FALSE,
              options=list(
                pageLength =5,
                columnDefs = list(list(targets = 9, width = '200px')),
                scrollX = TRUE))
  )
  
  #Aca se genera el grafico,de acuerdo a los datos extraidos en la consulta SQL.
  #El grafico muestra en el eje x el tipo de suscriptor y en el eje y la duracion en minutos de los viajes
  output$grafico_bigquery_at<-renderEcharts4r({
    if(is.null(respuesta_at$datos)==TRUE){
      
    }else{
      datos_graficos <- respuesta_at$datos %>%
        group_by(subscriber_type) %>%
        summarise(duration_minutes = sum(duration_minutes)) %>%
        arrange(desc(duration_minutes))
      
      datos_graficos |>
        echarts4r::e_chart(subscriber_type) |>
        echarts4r::e_bar(duration_minutes) |>
        echarts4r::e_theme("walden")   |>
        echarts4r::e_tooltip()
    }
  })
  
  # Grafico de torta para trip id
  output$grafico_torta_trip_id_at<-renderEcharts4r({
    if(is.null(respuesta_at$datos)==TRUE){
      
    }else{
      datos_graficos<-respuesta_at$datos %>% group_by(subscriber_type)  %>%
        summarise(duration_minutes = sum(duration_minutes)) %>%
        arrange(desc(duration_minutes))
      
      porcentajes <- datos_graficos %>%
        summarise(percentage = (duration_minutes / sum(duration_minutes)) * 100)
      
      datos<-cbind(datos_graficos,porcentajes)
      
      
      datos |>
        echarts4r::e_chart(subscriber_type) |>
        echarts4r::e_pie(percentage) |>
        echarts4r::e_theme("walden")   |>
        echarts4r::e_tooltip()
    }
  })
    
    output$imagen <- renderImage({
    
    list(src = "docker_1.png")
    
    }, deleteFile = F)
    
}

# Run the application 
shinyApp(ui = ui, server = server)
