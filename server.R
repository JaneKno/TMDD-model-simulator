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
            ka = 1.0, # fixed ka value
            # TMDD parameters
            kon = input$kon,
            koff = input$koff,
            kint = input$kep,
            kdeg = input$kout,
            Rc0 = input$Rc0)
    
    # Parse dose levels
    if (input$dose_type == "single") {
        doses <- as.numeric(unlist(strsplit(input$single_doses, ",")))
    } else {
        doses <- as.numeric(unlist(strsplit(input$multiple_doses, ",")))
    }
    
    # Create dosing events for all dose levels
    data <- do.call(rbind, lapply(seq_along(doses), function(i) {
        dose_nmol <- (doses[i] * 1e-3/150000) * 1e9
        expand.ev(ID = i,
                 time = 0,
                 addl = if(input$dose_type == "multiple") input$numberDoses - 1 else 0,
                 ii = if(input$dose_type == "multiple") input$interval else 0,
                 amt = dose_nmol,
                 cmt = 1)
    })) %>% 
      mutate(ID=row_number()) %>% 
      mutate(DOSE=(amt*150000/1e-3)/1e9)
    
    # Run simulation
    out <- mod %>%
      init(Rc = input$Rc0) %>%
      data_set(data) %>%
      carry.out(DOSE) %>% 
      mrgsim(end = input$duration, delta = 0.1) %>%
      as.data.frame()
    
    return(out)
  })
  
  # Plot output
  output$tmddPlot <- renderPlot({
    # Get selected measurements
   selected_vars <- c()
if ("show_total_drug" %in% input$plot_vars) selected_vars <- c(selected_vars, "Lctot")
if ("show_total_receptor" %in% input$plot_vars) selected_vars <- c(selected_vars, "Rctot")
if ("show_free_drug" %in% input$plot_vars) selected_vars <- c(selected_vars, "CENT")
if ("show_free_receptor" %in% input$plot_vars) selected_vars <- c(selected_vars, "R")
  
  # Reshape data for faceting
  plot_data <- sim_data() %>%
    mutate(DOSE = factor(paste(DOSE, "mg"),
                        levels = paste(sort(unique(DOSE)), "mg"))) %>%
    # Select only chosen columns
    tidyr::pivot_longer(
      cols = all_of(selected_vars),
      names_to = "Measurement",
      values_to = "Concentration"
    ) %>%
    mutate(Measurement = factor(Measurement, 
                              levels = c("Lctot", "Rctot", "CENT", "R"),
                              labels = c("Total Drug", "Total Receptor", 
                                       "Free Drug", "Free Receptor")))

    # Create faceted plot
    p <- ggplot(plot_data, aes(x = time, y = Concentration, color = DOSE)) +
      geom_line() +
      facet_wrap(~Measurement, scales = "free_y", ncol = 2) +
      theme_bw() +
      labs(x = "Time (days)",
           y = "Concentration (nM)",
           color = "Dose"#,
           #title = "TMDD Model Simulation"
           ) +
      theme(legend.position = "bottom",
            axis.line = element_line(colour = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_rect(colour = "black"),
            text = element_text(size = 14),
            strip.background = element_rect(fill = "white"),
            strip.text = element_text(face = "bold"))
    
    # Add scale based on user selection with range control
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
