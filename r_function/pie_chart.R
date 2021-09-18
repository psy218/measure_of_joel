pie_chart = function(dataset, variable) {
  # dat = dataset %>% 
  #   count(!!sym(variable)) %>% 
  #   mutate(prop = round( n / sum(n)*100))
  # 
  # pos = dat %>% 
  #   mutate(csum = rev(cumsum(rev(n))), 
  #          pos = n/2 + lead(csum, 1),
  #          pos = if_else(is.na(pos), n/2, pos))
  
  dataset %>% 
    ggplot(aes(x = "",
               y = n,
               fill = fct_inorder(!!sym(variable)),
               labels = option_text)) +
    # geom_col(width = 1) +
    geom_bar(stat = "identity",
             width = 1) +
    coord_polar(theta = "y", start = 0) +
    geom_text(aes(label = paste0(n,"\n(", prop,"%)")),
              position = position_stack(vjust = 0.5)) +
    xlab(NULL) +
    # scale_y_continuous(breaks = pos$pos,
    #                    labels = dat[variable]) + 
    viridis::scale_fill_viridis("",
                                # guide = "none",
                                discrete = T,
                                begin = .2) +
    # theme(axis.ticks = element_blank(),
    #       axis.title = element_blank(),
    #       axis.text = element_text(size = 9), 
    #       legend.position = "none", # Removes the legend
    #       panel.background = element_rect(fill = "white"))
    theme_void()
  }
  