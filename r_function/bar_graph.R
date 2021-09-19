bar_graph = function(dataset, variable, ...) {
  
  dataset %>% 
    ggplot(aes(x = !!sym(variable),
      # x = fct_reorder(!!sym(variable), n),
               y = n,
               fill = !!sym(variable),
               labels = option_text)) +
    geom_bar(stat = "identity",
             width = .8,
             position = position_dodge(.8),
             color = "black") +
    geom_text(aes(label = paste0(prop,"%")),
              position = position_dodge(.8),
              vjust = -0.25) +
    scale_x_discrete("",
                     labels = stringr::str_to_title) +
    # scale_y_continuous("",
    #                    breaks = unique(dataset$n)) +
    scale_y_continuous("Number of Votes",
                       limits = c(0, max(dataset$n) + 1),
                       n.breaks = max(dataset$n) + 1) + 
    viridis::scale_fill_viridis("",
                               guide = "none",
                                discrete = T,
                                begin = .2) +
    theme_classic() 
}
