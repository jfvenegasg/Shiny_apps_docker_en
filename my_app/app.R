library(shiny)
library(htmlwidgets)
library(dplyr)
library(DT)
library(echarts4r)
library(bs4Dash)


ui <-  dashboardPage(
  
  dashboardHeader(title = "Shiny-app Docker demo "),
  dashboardSidebar(side = "top", visible = FALSE, status = "teal",
                   sidebarMenu(
                     id = "sidebar",
                     menuItem("Home",tabName = "menu1",
                              icon=icon("laptop-medical"),
                              selected = TRUE)
                   ),
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "menu1",
              
              titlePanel("Shiny app demo for deployment in Docker"),
              fluidRow(imageOutput("imagen")),
              
              fluidRow(actionButton(inputId = "boton_carga_at",label =  "Load")),
              fluidRow(width=12,box(title = "Dara",dataTableOutput("datos_bigquery_at",width = "100%",height = "600px"),
                                    width = 6,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2),
                       box(title = "Bar Graph",echarts4rOutput("grafico_bigquery_at",width = "100%",height = "600px"),
                           width = 6,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2),
                       box(title = "Pie Chart",echarts4rOutput("grafico_torta_trip_id_at",width = "100%",height = "600px"),
                           width = 12,status = "lightblue",headerBorder = FALSE,collapsible = FALSE,closable = FALSE,elevation = 2))
              
      )))
  
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  #### Module data analysis for Austin Trips data ####
  
  respuesta_at <- reactiveValues(data=NULL)
  
  # observeEvent(input$boton_descarga_at, {
  #   project_id <- ""
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
  
  #Here the graph is generated, according to the data extracted in the SQL query.
  #The graph shows the type of subscriber on the x axis and the duration in minutes of the trips on the y axis.
  
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
  
  # Pie chart for trip id
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
