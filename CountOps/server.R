# CountOps server

filter_data = function(start_year, end_year, 
                       start_hour, end_hour, group_by_) {
    group_by_ = as.character(group_by_)
    # Using base R here is orders of magnitude faster than filter
    all_data[all_data$Year >= start_year & all_data$Year <= end_year &
             all_data$Hour >= start_hour & all_data$Hour <= end_hour,] %>% 
        group_by(!!rlang::ensym(group_by_)) %>% 
        summarize(Count=sum(Count))
}

server <- function(input, output) {
  output$the_plot = renderPlot({
    df = filter_data(input$year_range[1], input$year_range[2],
                     input$hour_range[1], input$hour_range[2],
                     input$group_by)
    
    period = if_else(input$group_by=='Month', 'monthly', 'daily')
    title=paste0('Logan Airport total ', period, ' departures, ',
                 paste0(input$hour_range, ':00', collapse='-'))

    p = ggplot(df, aes_string(input$group_by, 'Count')) +
      geom_point(color='steelblue') +
      # scale_color_gradientn(colors=pals::kovesi.rainbow(100), 
      #                       guide='none') +
      scale_x_date(date_breaks='1 year', minor_breaks=NULL,
                   date_labels='%Y', expand=expand_scale(mult=0.1)) +
      silgelib::theme_plex() +
      labs(title=title,
           x='', y='Departure count',
           caption='Data from FAA FOIA request Chart © 2020 Kent Johnson')
    if (input$show_smooth)
        p = p + stat_smooth(method=lm, se=FALSE, 
                            color='darkblue', size=1)
    p
    })
}
