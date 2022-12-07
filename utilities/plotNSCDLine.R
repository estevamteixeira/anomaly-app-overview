plot_line <- function(data, var){
  # Use 'import' from the 'modules' package.
  # These listed imports are made available inside the module scope.
  import("dplyr")
  import("ggplot2")
  import("plotly")
  
  dta <- data
  var <- unlist(var)
  
  if(any(names(dta) %in% c("ntc","ntlvb"))){
    names(dta)[which(names(dta) %in% c("ntc","ntlvb"))] <- c("total_cases", "total_lvb")
  } else if(any(names(dta) %in% c("total_lvb_cd"))){
    names(dta)[which(names(dta) %in% c("total_lvb_cd"))] <- c("total_lvb")
  }
  
  pal <- "#008D8B"
  
  plotly::plot_ly(
    data = dta[order(BrthYear)],
    x = ~BrthYear,
    y = ~.data[[var]],
    type = "scatter",
    mode = "lines+markers",
    hovertemplate = ~paste(
      "<b>", cd_full, "-", BrthYear, "</b>",
      "<br> Total reported cases:",
      ifelse(total_cases < 5,
             "< 5",
             as.character(scales::comma(total_cases,
                          accuracy = 1))),
      "<br> Total births:",
      ifelse(total_lvb < 5,
             "< 5",
             as.character(scales::comma(total_lvb,
                          accuracy = 1))),
      "<br> Prevalence (*cases per 1,000 total births):",
              scales::comma(.data[[var]],
                            accuracy = 0.1),
      "<extra></extra>"
      ),
    line = list(color = pal),
    marker = list(color = pal)) %>% 
    plotly::style(hoverlabel = list(
      bgcolor  = "black",
      bordercolor = "transparent",
      font = list(
        color = "white",
        size = 14,
        face = "bold"
      )
    )) %>%
    plotly::layout(
      #showlegend = FALSE,
      legend = list(
        orientation = "h",
        y = -0.25, x = 0.35,
        font = list(
          size = 12,
          face = "bold"
        )
      ),
      xaxis = list(
        title = list(
          text = "Year",
          face = "bold",
          size = 14
        ),
        tickfont = list(
          face = "bold",
          size = 12
        ),
        tickformat = "%Y"
      ),
      yaxis = list(
        title = list(
          text = "Prevalence (*cases per 1,000 total births)",
          face = "bold",
          size = 14
        ),
        tickfont = list(
          face = "bold",
          size = 12
        )
      )
    ) %>% 
    plotly::config(displaylogo = FALSE,
                   modeBarButtonsToRemove = c(
                     "select2d",
                     "zoomIn2D",
                     "zoomOut2d",
                     "zoom2d",
                     "pan2d",
                     "lasso2d",
                     "autoScale2d",
                     "resetScale2d",
                     "hoverClosestCartesian",
                     "hoverCompareCartesian"
                   ))
  
  # plotly::ggplotly(
  #   p = {
  # lineplot <- ggplot(dta,
  #                    aes(x = BrthYear,
  #                    y = !!sym(var),
  #                    group = 1,
  #                    text = paste(
  #                    "<b>",cd_full, "-", BrthYear, "</b>",
  #                    "<br> Total reported cases:",
  #                    ifelse(total_cases < 5,
  #                           "< 5",
  #                           as.character(scales::comma(total_cases,
  #                                                      accuracy = 1))),
  #                    "<br> Total total births:",
  #                    ifelse(total_lvb < 5,
  #                           "< 5",
  #                           as.character(scales::comma(total_lvb,
  #                                                      accuracy = 1))),
  #                    "<br> s:",
  #                    scales::comma(!!sym(var),
  #                                  accuracy = 0.1)
  #                    ))) +
  #       geom_line(color = "#008D8B",
  #                 fill = "#008D8B",
  #                 alpha = 0.85) +
  #       geom_point(color = "#008D8B",
  #                  fill = "#008D8B") +
  #       scale_y_continuous(breaks = pretty
  #                          #labels = scales::comma_format(accuracy = 0.1)
  #       ) +
  #       coord_cartesian(ylim = c(0, NA)) +
  #       labs(x = "Year",
  #            y = "s") +
  #       theme_minimal()
  #   
  # lineplot}, tooltip = c("text")) %>%
  #   plotly::style(hoverlabel = list(
  #   bgcolor  = "black",
  #   bordercolor = "transparent",
  #   font = list(
  #     color = "white",
  #     size = 14,
  #     face = "bold"
  #   )
  # )) %>%
  # plotly::layout(legend = list(orientation = "h", y = -0.25, x = 0.35),
  #                font = list(face = "bold", size = 10))
  
}

plot_risk_line <- function(data, var, risk){
  # Use 'import' from the 'modules' package.
  # These listed imports are made available inside the module scope.
  import("dplyr")
  import("ggplot2")
  import("plotly")
  
  dta <- data
  var <- unlist(var)
  rsk <- unlist(risk)
  
  if(any(names(dta) %in% c("ntc","ntlvb"))){
    names(dta)[which(names(dta) %in% c("ntc","ntlvb"))] <- c("total_cases", "total_lvb")
  } else if(any(names(dta) %in% c("total_lvb_cd"))){
    names(dta)[which(names(dta) %in% c("total_lvb_cd"))] <- c("total_lvb")
  }
  
  if(any(unique(names(dta) %in% rsk))){
    if(rsk %in% "SexNum"){
      dta$SexNum <- factor(dta$SexNum,
                           levels = levels(dta$SexNum),
                           labels = c("Ambiguous","Female", "Male"))
      pal <- c("Ambiguous" = "#B3B8BA", 
               "Female" = "#FF0000",
               "Male" = "#0000FF")
    }
  }
  
  plotly::plot_ly(data = dta[order(BrthYear)],
                  x = ~BrthYear,
                  y = ~.data[[var]],
                  type = "scatter",
                  mode = "lines+markers",
                  linetype = ~.data[[rsk]],
                  color = ~.data[[rsk]],
                  colors = pal,
                  symbol = ~.data[[rsk]],
                  hovertemplate = ~paste(
                    "<b>", cd_full, "-", .data[[rsk]], "-", BrthYear, "</b>",
                    "<br> Total reported cases:",
                    ifelse(total_cases < 5,
                           "< 5",
                           as.character(scales::comma(total_cases,
                                                      accuracy = 1))),
                    "<br> Total births:",
                    ifelse(total_lvb < 5,
                           "< 5",
                           as.character(scales::comma(total_lvb,
                                                      accuracy = 1))),
                    "<br> Prevalence (*cases per 1,000 total births):",
                    scales::comma(.data[[var]],
                                  accuracy = 0.1),
                    "<extra></extra>" # removes the trace name from the hover text
                  ),
                  line = list(color = pal),
                  marker = list(col = pal)) %>% 
    plotly::style(hoverlabel = list(
      bgcolor  = "black",
      bordercolor = "transparent",
      font = list(
        color = "white",
        size = 14,
        face = "bold"
      )
    )) %>%
    plotly::layout(
      #showlegend = FALSE,
      legend = list(
        orientation = "h",
        y = -0.25, x = 0.35,
        font = list(
          size = 12,
          face = "bold"
          )
        ),
      xaxis = list(
        title = list(
          text = "Year",
          face = "bold",
          size = 14
          ),
        tickfonts = list(
          face = "bold",
          size = 12
          )
        ),
      yaxis = list(
        title = list(
          text = "Prevalence (*cases per 1,000 total births)",
          face = "bold",
          size = 14
          ),
        tickfonts = list(
          face = "bold",
          size = 12
          )
        )
      )
  
  # p = plotly::ggplotly(
  #   p = {
  #     lineplot <- ggplot(dta,
  #                        aes(x = BrthYear,
  #                            y = !!sym(var),
  #                            group = !!sym(rsk),
  #                            text = paste(
  #                              "<b>",cd_full, "-", !!sym(rsk), "-", BrthYear, "</b>",
  #                              "<br> Total reported cases:",
  #                              ifelse(total_cases < 5,
  #                                     "< 5",
  #                                     as.character(scales::comma(total_cases,
  #                                                                accuracy = 1))),
  #                              "<br> Total total births:",
  #                              ifelse(total_lvb < 5,
  #                                     "< 5",
  #                                     as.character(scales::comma(total_lvb,
  #                                                                accuracy = 1))),
  #                              "<br> s:",
  #                              scales::comma(!!sym(var),
  #                                            accuracy = 0.1)
  #                            ))) +
  #       geom_line(aes(
  #         color = !!sym(rsk),
  #         fill = !!sym(rsk)
  #         ),
  #         alpha = 0.85) +
  #       geom_point(aes(
  #         color = !!sym(rsk),
  #         fill = !!sym(rsk),
  #         shape = !!sym(rsk))
  #         ) +
  #       # Specifying colors by risk factor levels
  #       scale_color_manual(
  #         name = "",
  #         values = pal,
  #         limits = names(pal)
  #         ) +
  #       scale_fill_manual(
  #         name = "",
  #         values = pal,
  #         limits = names(pal)
  #         ) +
  #       scale_shape_manual(
  #         name = "",
  #         values = seq(from = 15,
  #                      length.out = length(levels(dta[[rsk]])))
  #         ) +
  #       scale_y_continuous(
  #         breaks = pretty
  #         #labels = scales::comma_format(accuracy = 0.1)
  #       ) +
  #       coord_cartesian(
  #         ylim = c(0, NA)
  #         ) +
  #       labs(x = "Year",
  #            y = "s"
  #            ) +
  #       theme_minimal()
  # 
  #     lineplot}, tooltip = c("text")) %>%
  #   plotly::style(hoverlabel = list(
  #     bgcolor  = "black",
  #     bordercolor = "transparent",
  #     font = list(
  #       color = "white",
  #       size = 14,
  #       face = "bold"
  #     )
  #   )) %>%
  #   plotly::layout(
  #     #showlegend = FALSE,
  #     legend = list(orientation = "h", y = -0.25, x = 0.35,
  #                   size = 11, face = "bold"),
  #     font = list(face = "bold", size = 10))
  
}

