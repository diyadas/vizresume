# Title: Visual Resume (Timelines)
# Author: Diya Das
# Source repo: github.com/diyadas/vizresume
# Last revised: Sun Jan 27 20:52:39 2019

# Description: This Shiny app loads activities from a Google spreadsheet and plots
# a visual resume, color-coded by institutional affiliation. Please see the 
# README for the GitHub repo to get started. Some data entry is required before 
# the Shiny app can be used.

library(shiny)
library(dplyr)
library(ggplot2)
library(scales)
library(googlesheets)
library(stringr)
library(emojifont)
library(cowplot)
library(gridExtra)
library(shinyjqui)

# Load icons and map to activity type
## Make sure "type" matches the "type" column of the Google spreadsheet.
load.fontawesome(font = "fa-solid-900.ttf")
fa_default <- data.frame(type = c("Award", 
                                  "Poster", 
                                  "Publication",
                                  "Software", 
                                  "Talk", 
                                  "Workshop"),
                         fnt = fontawesome(c('fa-trophy', 
                                             'fa-pie-chart', 
                                             'fa-pencil',
                                             'fa-code', 
                                             'fa-comment',
                                             'fa-wrench')))

# Define UI for application
ui <- fluidPage(
  tags$style(".shiny-input-container { margin-bottom: 0px; margin-top: 0px }
             #datfile_progress { margin-bottom: 0px } 
             #catfile_progress { margin-bottom: 0px }"),
  # Application title
  titlePanel("Visual Resume"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      h3("Enter data"),
      # Input: Select genes based on data ----
      textInput("ss_url","Link to Published Google Spreadsheet"),
      # Input: Select a file ----
      fileInput("datfile", "- OR - Upload a Text File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      radioButtons("filesep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = "\t"),
      h4("Link types to Font Awesome icons (Optional)"),
      p("Default mappings include Award, Poster, Publication, Software, Talk, Workshop"),
      p("Uploading a file here will overwrite all mappings. Please do not include a header row."),
      fileInput("catfile", "Upload a Text File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      radioButtons("catfilesep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = "\t"),
      tags$hr(),
      p("Enter dimensions for saved PNG:"),
      numericInput("width","Width (inches)", 9.5),
      numericInput("height","Height (inches)", 6.6),
      tags$hr()
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      htmlOutput("selected_data"),
      downloadButton("export_resume", label = "Download Resume as PNG"),
      # Input: Select order of categories to facet by
      htmlOutput("order_selection"),
      tags$hr(),
      plotOutput("plot", height = "600px")
    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output) {
  output$selected_data <- renderText({
    if (is.null(input$datfile$datapath)){
      paste("<h4>Plotting From Google Spreadsheet</h4>")
    } else {
      paste("<h4>Plotting Uploaded File</h4>")
    }
  })
  resume_gather <- function(){
    # Load data from spreadsheet
    get_data <- reactive({
      if (input$ss_url != "") {
        dat <- tryCatch(gs_url(input$ss_url, lookup = FALSE) %>% gs_read(),
                        error=function(err) NA)
        return(dat)
      } else if (!is.null(input$datlist$datapath)) {
        return(read.table(input$datlist$datapath, sep = input$filesep))
      } else {
        return(NA)
      }
    })
    df <- get_data()
    if(is.na(df)) return(NA)
    
    get_catlevels <- reactive({
      if (!is.null(input$timeline_order)) {
        return(input$timeline_order)
      } else {
        return(sort(unique(df$category)))
      }
    })
    df$category <- factor(df$category, levels = get_catlevels()) # reorder factor levels
    
    get_fa <- reactive({
      if (!is.null(input$catfile$datapath)) {
        return(read.table(input$catlist$datapath, sep = input$catfilesep))
      } else {
        return(fa_default)
      }})
    fa <- get_fa()
    
    
    # Center rows within each category
    df <- df %>% group_by(category) %>% mutate(
      y1n = y1 - mean(y1),
      y2n = y2 - mean(y1)) %>% ungroup()
    
    # Wrap long names for activities 
    df$name_wrap <- mapply(function(name, wraplen) str_wrap(name, wraplen),
                           df$name,
                           df$wraplen)
    
    # Add a row for each organization so NAs don't result in point and bar data with 
    # different levels
    for (x in unique(df$org)) df <- add_row(df, category = df$category[1],
                                            type = df$type[1],
                                            wraplen = 1, org = x)
    # Split data into data to be graphed as bars and data to be font-awesome "points" 
    df_rect <- df %>% filter(as.character(start) != as.character(end) | is.na(start))
    df_point <- df %>% filter(as.character(start) == as.character(end) | is.na(start))
    df_point <- left_join(df_point, fa)
    
    # Define a no_style theme to strip away unwanted labels and formatting
    no_style <- theme(axis.ticks.y = element_blank(),
                      axis.text.y = element_blank(),
                      axis.ticks.y.left = element_blank(),
                      axis.title.y = element_blank(),
                      strip.text = element_text(face = "bold"),
                      text = element_text(size = 8),
                      axis.text.x = element_text(size = 8),
                      plot.margin = unit(c(0, 0, 5.5, 0),"pt"),
                      plot.title = element_blank()
    ) 
    
    # Create plot (no legend)
    p <- ggplot() +
      scale_x_date(labels = date_format("%Y"), date_breaks = "1 year") +
      geom_rect(data = df_rect, 
                mapping = aes(xmin = as.Date(paste(1, start), "%d %b %Y"),
                              xmax = as.Date(paste(1, end), "%d %b %Y"),
                              ymin = y1n, ymax = y2n, 
                              fill = wrap_format(40)(org)),
                color = "grey", alpha = 0.5) + labs(fill='Organization') + 
      guides(fill = guide_legend(ncol=2)) +
      geom_text(data = df_rect, aes(x = as.Date(paste(1, start), "%d %b %Y") +
                                      (as.Date(paste(1, end), "%d %b %Y") -
                                         as.Date(paste(1, start), "%d %b %Y")) / 2,
                                    y = y1n + (y2n - y1n) / 2, 
                                    label = name_wrap), size = 2.8, lineheight = 0.7) + 
      geom_text(data = df_point,  aes(x = as.Date(paste(1, start), "%d %b %Y"),
                                      y = (y1n + y2n)/2, 
                                      colour = wrap_format(40)(org),
                                      label = fnt), 
                alpha = 0.5, family='fontawesome-webfont') +
      scale_colour_discrete(guide = 'none') + 
      facet_grid(category ~ ., switch = "y", labeller = label_wrap_gen(width = 20)) +
      labs(x = "Year", y = "")  + no_style 
    
    # Extract legend from plot to plot in a separate pane, code from Luciano Selzer
    ## https://stackoverflow.com/a/11886071/743568
    g_legend <- function(a.gplot){
      tmp <- ggplot_gtable(ggplot_build(a.gplot))
      leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
      legend <- tmp$grobs[[leg]]
      return(legend)}
    legend <- g_legend(p)
    
    # Plot a legend for the font-awesome icons 
    # The font-awesome icons are text annotations so this is a hack.
    annot_point <- data.frame(fa, x = rep(0, nrow(fa)), y = nrow(fa):1)
    
    icon_plot <- ggplot(data.frame()) + geom_point() + xlim(0, 1) + ylim(0.5, 6.5)+
      geom_text(data = annot_point,  aes(x = x,
                                         y = y,
                                         label = fnt), alpha = 0.5,
                family='fontawesome-webfont') +
      geom_text(data = annot_point,  aes(x = x + 0.1,
                                         y = y,
                                         label = type),
                hjust = 0, size = 2.8) + theme_nothing() 
    return(list(p = p, legend = legend, icon_plot = icon_plot))
  }
  resume_plot <- function(filename, pobj){
    png(file = filename, width = input$width, height = input$height, units = "in", res = 320)
    lay <- rbind(c(1,1,1),
                 c(2,2,3))
    grid.arrange(grobs = list(ggplotGrob(pobj$p + theme(legend.position = "none")),
                              pobj$legend,
                              ggplotGrob(pobj$icon_plot)), 
                 layout_matrix = lay,
                 heights = unit(c(26/33 * input$height, 5/33 * input$height), c("in", "in")))
    dev.off()
  }
  output$plot <- renderImage({
    pobj <- resume_gather()
    validate(need(!is.na(pobj),
                  paste("Can't plot a resume without data! Enter URL of a",
                        "published spreadsheet OR upload data.")))
    # Create a png and lay out the plots!
    filename <- paste0("vizresume_", format(Sys.time(), "%Y-%m-%d_%H%M%OS3"),".png")
    resume_plot(filename, pobj)
    
    return(list(src = filename,
                contentType = 'image/png',
                width = 600,
                height = 400,
                alt = "This is alternate text")
    )
  }, deleteFile = TRUE)
  
  output$order_selection <- renderUI({
    get_data <- reactive({
      if (input$ss_url != "") {
        dat <- tryCatch(gs_url(input$ss_url, lookup = FALSE) %>% gs_read(),
                        error=function(err) NA)
        return(dat)
      } else if (!is.null(input$datlist$datapath)) {
        return(read.table(input$datlist$datapath, sep = input$filesep))
      } else {
        return(NA)
      }
    })
    validate(need(!is.na(get_data()),""))
    tlorder <- levels(factor(get_data()$category))
    orderInput(inputId = "timeline", label = "Drag to Order Categories.", 
               tlorder)
  })
  
  output$export_resume <- downloadHandler(paste0("vizresume_", format(Sys.time(), "%Y-%m-%d_%H%M%OS3"),".png"), function(filename) {
    pobj <- resume_gather()
    resume_plot(filename, pobj)
  })
  
}

# Run the app ----
shinyApp(ui, server)
