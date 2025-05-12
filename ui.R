#########################################################################
### Description: This shiny app to explore concepts of TMDD in a 2 CMT PK model.
### 
### created by: Jane Knöchel
###
### created on date : 11.05.2025
### last code update: 12.05.2025
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
                 # TMDD Parameters
                 h4("TMDD Parameters"),
                 fluidRow(
                   column(6, 
                          sliderInput("kon", "kon (1/nM/day)", 
                                      value = 30.2, min = 0, max = 1000, step = 0.1)
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
                                      value = 17.3, min = 0.1, max = 10, step = 0.1)
                   )
                 ),
                 fluidRow(
                   column(6, 
                          sliderInput("Rc0", "Initial R (nM)", 
                                      value = 0.00657, min = 0.1, max = 10, step = 0.1)
                   )
                 ),
                 # Dosing Parameters
                 h4("Dosing Regimen"),
                 radioButtons("dose_type", "Dose Type:",
             choices = c("Single Dose" = "single",
                        "Multiple Doses" = "multiple"),
             selected = "single"),

conditionalPanel(
    condition = "input.dose_type == 'single'",
    fluidRow(
        column(12,
               textInput("single_doses", "Dose Levels (mg, comma-separated)", 
                        value = "1, 3, 10, 30")
        )
    )
),

conditionalPanel(
    condition = "input.dose_type == 'multiple'",
    fluidRow(
        column(6,
               textInput("multiple_doses", "Dose Levels (mg)", 
                        value = "1, 3, 10, 30")
        ),
        column(6,
               sliderInput("interval", "Dosing Interval (days)", 
                          value = 56, min = 1, max = 365, step = 1)
        )
    ),
    fluidRow(
        column(12,
               sliderInput("numberDoses", "Doses per Group", 
                          value = 3, min = 1, max = 10, step = 1)
        )
    )
)
    ),
    mainPanel(width=8,
    tabsetPanel(
      tabPanel("Simulation",
      wellPanel(
    fluidRow(
      column(12,
        checkboxGroupInput("plot_vars", "Select Variables to Plot:",
          choices = list(
            "Total Drug" = "show_total_drug",
            "Total Receptor" = "show_total_receptor",
            "Free Drug" = "show_free_drug",
            "Free Receptor" = "show_free_receptor"
          ),
          selected = "show_free_drug",
          inline = TRUE
        )
      )
    )
  ),
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
                                     min = 0.001, max = 1000,
                                     step = 0.1)
                  ),
                  column(12,
                         sliderInput("duration", "Duration (days)", 
                                     value = 200, min = 1, max = 1000, step = 1)
                  )
                )
              ),
              verbatimTextOutput("paramSummary")
    ),
  tabPanel("About",
          wellPanel(
            h3("TMDD Model Simulator"),
            h4("Purpose"),
            p("This app simulates a two-compartment pharmacokinetic model with target-mediated drug disposition (TMDD). 
              It allows exploration of how different parameters affect drug and receptor concentrations over time."),
            
            h4("How to Use"),
            tags$ul(
              tags$li("PK Parameters: Adjust clearance and volumes to modify the drug distribution"),
              tags$li("TMDD Parameters: Modify binding kinetics and receptor dynamics"),
              tags$li("Dosing Regimen: Choose between single or multiple doses and set dose levels"),
              tags$li("Plot Controls: Select which variables to display and adjust the plot appearance")
            ),
            
            h4("Variables Explained"),
            tags$ul(
              tags$li(strong("Total Drug:"), "Sum of free drug (both central and peripheral compartment) and drug-receptor complex"),
              tags$li(strong("Free Drug:"), "Unbound central drug concentration"),
              tags$li(strong("Total Receptor:"), "Sum of free receptor and drug-receptor complex"),
              tags$li(strong("Free Receptor:"), "Unbound receptor concentration")
            ),
            
            h4("Parameter Definitions"),
            tags$ul(
              tags$li(strong("kon:"), "Association rate constant"),
              tags$li(strong("koff:"), "Dissociation rate constant"),
              tags$li(strong("kint:"), "Internalization rate constant"),
              tags$li(strong("kdeg:"), "Receptor degradation rate constant")
            ),
            
            hr(),
            p("For more information about TMDD models, see:",
              a("Tutorial on Target-Mediated Drug Disposition Models", 
                href="https://ascpt.onlinelibrary.wiley.com/doi/10.1002/psp4.41",
                target="_blank"))
          )
        )
      )  # Close tabsetPanel
    )    # Close mainPanel
  ),      # Close sidebarLayout
# Add footer outside of fluidPage
tags$footer(paste0("Created by Jane Knöchel, last updated on ", Sys.Date()))
)        # Close fluidPage


