# CountOps server

filter_data = function(start_year, end_year, 
                       start_hour, end_hour, operation, group_by_) {
    group_by_ = as.character(group_by_)
    # Using base R here is orders of magnitude faster than filter
    all_data[all_data$Year >= start_year & all_data$Year <= end_year &
             all_data$Hour >= start_hour & all_data$Hour <= end_hour &
             all_data$Operation==operation,] %>% 
        group_by(!!ensym(group_by_)) %>% 
        summarize(Count=sum(Count))
}

as_am_pm = function(t) {
    case_when(
        t == 12 ~ 'noon',
        t == 0 || t == 24 ~ 'midnight',
        t < 12 ~ as.character(glue('{t}am')),
        TRUE ~ as.character(glue('{t-12}pm'))
    )
}

server <- function(input, output) {
  filtered = reactive({
      filter_data(input$year_range[1], input$year_range[2],
                     input$hour_range[1], input$hour_range[2],
                     input$operation, input$group_by)
  })
  
  title = reactive({
    period = if_else(input$group_by=='Month', 'monthly', 'daily')
    operation = if_else(input$operation=='Departure', 
                        'departures', 'arrivals')
    glue('Logan Airport total {period} {operation}, ',
    '{as_am_pm(input$hour_range[1])}-{as_am_pm(input$hour_range[2]+1)}')
  })
  
  output$the_plot = renderPlot({
    df = filtered()
    

    p = ggplot(df, aes_string(input$group_by, 'Count')) +
      geom_point(color='steelblue') +
      scale_x_date(date_breaks='1 year', minor_breaks=NULL,
                   date_labels='%Y', expand=expand_scale(mult=0.1)) +
      silgelib::theme_plex() +
      labs(title=title(),
           x='', y='Departure count',
           caption='Data from FAA FOIA request Chart © 2020 Kent Johnson')
    if (input$show_smooth)
        p = p + stat_smooth(method=lm, se=FALSE, 
                            color='darkblue', size=1)
    p
    })
}
