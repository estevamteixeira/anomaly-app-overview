# Use 'import' from the 'modules' package.
# These listed imports are made available inside the module scope.
import("rintrojs")
import("shiny")

# 'use' is similar to 'import' but instead of importing from packages,
# we import from a module.
consts <- use("constants/constants.R")



function(input, output, session){
  
  ## Show intro modal
  
  observeEvent("", {
    showModal(
      modalDialog(
      includeHTML("intro_text.html"),
      easyClose = TRUE,
      footer = tagList(
        actionButton(inputId = "intro",
                     label = "Introduction Tour",
                     icon = icon("info-circle"))
      )
    ))
  })
  
  ## Remove modal when clicking th button
  
  observeEvent(input$intro,{
    removeModal()
  })
  
  # show intro tour
  observeEvent(input$intro,
               introjs(session,
                       options = list("nextLabel" = "Continue",
                                      "prevLabel" = "Previous",
                                      "doneLabel" = "Alright. Let's go",
                                      "skipLabel" = "Skip",
                                      showStepNumbers = TRUE))
  )
  
  # Using a "server-side selectize" option that massively improves 
  # performance and efficiency (for large numbers of choices)
  updateSelectInput(
    session,
    inputId = "icd10",
    choices = list("All conditions" = "0",
                   `Congenital malformations of the nervous system`= 
                     consts$icd10_opts[which(grepl("^Q(0[0-7])", consts$icd10_opts))],
                   `Congenital malformations of eye, ear, face and neck` =
                     consts$icd10_opts[which(grepl("^Q(1[0-8])", consts$icd10_opts))],
                   `Congenital malformations of the circulatory system` =
                     consts$icd10_opts[which(grepl("^Q(2[0-8])", consts$icd10_opts))],
                   `Congenital malformations of the respiratory system` =
                     consts$icd10_opts[which(grepl("^Q(3[0-4])", consts$icd10_opts))],
                   `Cleft lip and cleft palate` = 
                     consts$icd10_opts[which(grepl("^Q(3[5-7])", consts$icd10_opts))],
                   `Other congenital malformations of the digestive system` =
                     consts$icd10_opts[which(grepl("^Q(3[8-9]|4[0-5])", consts$icd10_opts))],
                   `Congenital malformations of genital organs` =
                     consts$icd10_opts[which(grepl("^Q(5[0-6])", consts$icd10_opts))],
                   `Congenital malformations of the urinary system` =
                     consts$icd10_opts[which(grepl("^Q(6[0-4])", consts$icd10_opts))],
                   `Congenital malformations and deformations of the musculoskeletal system` =
                     consts$icd10_opts[which(grepl("^Q(6[5-9]|7[0-9])", consts$icd10_opts))],
                   `Other congenital malformations` =
                     consts$icd10_opts[which(grepl("^Q(8[0-9])", consts$icd10_opts))],
                   `Chromosomal abnormalities, not elsewhere classified` =
                     consts$icd10_opts[which(grepl("^Q(9[0-9])", consts$icd10_opts))]
    ),
    selected = c("0")
  )
  
  ## Update the options for the initial year selectInput
  observeEvent(input$icd10,{
    
    if (!input$icd10 %in% 0){
    updateSelectInput(
    session,
    inputId = "init_time",
    choices = c(sort(unique(consts$cd_anom$BrthYear[
      consts$cd_anom$cat_tier2 %in% input$icd10]))),
    selected = c(min(consts$cd_anom$BrthYear[
      consts$cd_anom$cat_tier2 %in% input$icd10]))
    )} else {
      updateSelectInput(
        session,
        inputId = "init_time",
        choices = c(sort(unique(consts$cd_anom$BrthYear))),
        selected = c(min(consts$cd_anom$BrthYear))
      )
  }
  })
  
  ## Make the final year option to be greater than or equal the
  ## initial year option
  observeEvent(c(input$icd10, input$init_time),{
    
    if (!input$icd10 %in% 0 ){
      updateSelectInput(
        session,
        inputId = "end_time",
        choices = c(sort(unique(consts$cd_anom$BrthYear[
          consts$cd_anom$cat_tier2 %in% input$icd10])))[
            c(sort(unique(consts$cd_anom$BrthYear))) >= input$init_time],
        selected = c(max(consts$cd_anom$BrthYear[
          consts$cd_anom$cat_tier2 %in% input$icd10]))
      )
    } else {
      updateSelectInput(
        session,
        inputId = "end_time",
        choices = c(sort(unique(consts$cd_anom$BrthYear)))[
            c(sort(unique(consts$cd_anom$BrthYear))) >= input$init_time],
        selected = c(max(consts$cd_anom$BrthYear))
      )
    }
    
  })
  
  initial_year <- reactive({ input$init_time})
  final_year <- reactive({ input$end_time})
  condition <- reactive({ input$icd10})
  
  session$userData$county_view <- county_view$init_server(
    "county_advanced_view",
    df = consts$cd_anom,
    y1 = initial_year,
    y2 = final_year,
    q = condition
  )
  
  # global_metrics_view$init_server("global_metrics_advanced_view")
  
  # local_metrics_view$init_server("local_metrics_advanced_view")
  session$userData$local_metrics_view <- local_metrics_view$init_server(
    "local_metrics_advanced_view",
    df = consts$cd_anom,
    y1 = initial_year,
    y2 = final_year,
    q = condition
  )
  
  session$userData$map_view <- map_view$init_server(
    "map_advanced_view",
    df = consts$cd_anom,
    y1 = initial_year,
    y2 = final_year,
    q = condition
  )
  
    session$userData$line_view <- line_view$init_server(
    "line_advanced_view",
    df = consts$cd_anom,
    y1 = initial_year,
    y2 = final_year,
    q = condition
  )
    
    # session$userData$upset_view <- dlv_view$init_server(
    #   "bar_advanced_view",
    #   df = consts$cd_anom,
    #   y1 = initial_year,
    #   y2 = final_year,
    #   q = condition
    # )
    
    session$userData$upset_view <- upset_view$init_server(
      "bar_advanced_view",
      df = consts$cd_anom,
      y1 = initial_year,
      y2 = final_year,
      q = condition
    )
  
}