#########################################################################
### Description: This shiny app to explore concepts of TMDD in a 2 CMT PK model.
### 
### created by: Jane Knöchel
###
### created on date : 11.05.2025
### last code update: 11.05.2025
###
### key words: TMDD, 2CMT
#########################################################################
library(shiny)
library(mrgsolve)
library(dplyr)
library(ggplot2)

# UI definition
ui <- fluidPage(
  titlePanel("TMDD Model Simulator"),
  
  sidebarLayout(
    sidebarPanel(width=4,
                 # PK Parameters
                 h4("PK Parameters"),
                 fluidRow(
                   column(6, 
                          sliderInput("CL", "Clearance (L/day)", 
                                      value = 0.2, min = 0.01, max = 10, step = 0.01)
                   ),
                   column(6, 
                          sliderInput("V1", "Central Volume (L)", 
                                      value = 3.0, min = 0.1, max = 20, step = 0.1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("Q", "Intercomp. CL (L/day)", 
                                      value = 0.5, min = 0, max = 10, step = 0.1)
                   ),
                   column(6, 
                          sliderInput("V2", "Periph. Volume (L)", 
                                      value = 2.0, min = 0.1, max = 20, step = 0.1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("ka", "Absorption Rate (1/day)", 
                                      value = 1.0, min = 0.01, max = 10, step = 0.01)
                   )
                 ),
                 # TMDD Parameters
                 h4("TMDD Parameters"),
                 fluidRow(
                   column(6, 
                          sliderInput("kon", "kon (1/nM/day)", 
                                      value = 30.2, min = 0.1, max = 1000, step = 0.1)
                   ),
                   column(6, 
                          sliderInput("koff", "koff (1/day)", 
                                      value = 169, min = 0.1, max = 1000, step = 0.1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("kep", "kint (1/day)", 
                                      value = 0.17, min = 0.01, max = 10, step = 0.01)
                   ),
                   column(6, 
                          sliderInput("kout", "kdeg (1/day)", 
                                      value = 17.3, min = 0.1, max = 100, step = 0.1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("Rc0", "Initial R (nM)", 
                                      value = 0.00657, min = 0.0001, max = 1, step = 0.0001)
                   )
                 ),
                 # Dosing Parameters
                 h4("Dosing Regimen"),
                 fluidRow(
                   column(6, 
                          sliderInput("dose", "Dose (mg)", 
                                      value = 1, min = 0.1, max = 1000, step = 0.1)
                   ),
                   column(6, 
                          sliderInput("interval", "Interval (days)", 
                                      value = 56, min = 1, max = 365, step = 1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("numberDoses", "Number of Doses", 
                                      value = 20, min = 1, max = 10, step = 1)
                   ),
                   column(6, 
                          sliderInput("duration", "Duration (days)", 
                                      value = 100, min = 1, max = 1000, step = 1)
                   )
                 )
    ),
    mainPanel(width=8,
              plotOutput("tmddPlot"),
              wellPanel(
                fluidRow(
                  column(4, 
                         radioButtons("scale", "Y-axis Scale:",
                                      choices = c("Linear" = "linear",
                                                  "Logarithmic" = "log"),
                                      selected = "log",
                                      inline = TRUE)
                  ),
                  column(8, 
                         sliderInput("y_range", "Y-axis Range:",
                                     value = c(0.001, 1000),
                                     min = 0.0001, max = 10000,
                                     step = 0.1)
                  )
                )
              ),
              verbatimTextOutput("paramSummary")
    )
  ),
  
  tags$footer(paste0("created by Jane Knöchel, last updated on the ",Sys.Date()))
  
)
