#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
# Server logic
library(shiny)
library(mrgsolve)
library(dplyr)
library(ggplot2)

server <- function(input, output) {
  
  # Reactive expression for model simulation
  sim_data <- reactive({
    # Update model parameters
    mod <- mread("TMDD_model.cpp") %>%
      param(CL = input$CL,
            V1 = input$V1,
            Q = input$Q,
            V2 = input$V2,
            ka = input$ka,
            kon = input$kon,
            koff = input$koff,
            kep = input$kep,
            kout = input$kout,
            Rc0 = input$Rc0)
    
    # Create dosing events
    dose_nmol <- (input$dose * 1e-3/150000) * 1e9
    
    data <- expand.ev(ID = 1,
                      time = 0,
                      addl = input$numberDoses,
                      ii = input$interval,
                      amt = dose_nmol,
                      cmt = 1)
    
    # Run simulation
    out <- mod %>%
      init(Rc = input$Rc0) %>%
      data_set(data) %>%
      mrgsim(end = input$duration, delta = 0.1) %>%
      as.data.frame()
    
    return(out)
  })
  
  # Plot output
  output$tmddPlot <- renderPlot({
    p <- ggplot(sim_data(), aes(x = time)) +
      geom_line(aes(y = Lctot, color = "Total Drug")) +
      geom_line(aes(y = Rctot, color = "Total Receptor")) +
      theme_bw() +
      labs(x = "Time (days)",
           y = "Concentration (nM)",
           color = "",
           title = "2CMT with TMDD in central Compartment") +
      theme(legend.position = "bottom",
            axis.line = element_line(colour="black"),
            panel.grid.major=element_blank(),
            panel.grid.minor = element_blank(),
            panel.border=element_blank(),
            text=element_text(size=14),
            plot.caption=element_text(colour="gray84",size=10))
    
    # Add scale based on user selection
    if(input$scale == "log") {
      p <- p + scale_y_log10(limits = input$y_range)
    } else {
      p <- p + scale_y_continuous(limits = input$y_range)
    }
    
    p
  })
  
  # Parameter summary
  output$paramSummary <- renderText({
    paste("KD =", round(input$koff/input$kon, 3), "nM\n",
          "Terminal half-life =", round(log(2)/(input$CL/input$V1), 1), "days")
  })
}
