# CountOps server

filter_data = function(start_year, end_year, 
                       start_hour, end_hour, 
                       operation, equip, 
                       runways, group_by_) {
    group_by_ = as.character(group_by_)
    
    # Using base R here is orders of magnitude faster than filter
    df = all_data[all_data$Year >= start_year & all_data$Year <= end_year &
             all_data$Hour >= start_hour & all_data$Hour <= end_hour &
             all_data$Operation==operation,]
    
    if (equip=='Jet') df = df[df$Jet, ]
    else if (equip=='Non-Jet') df = df[!df$Jet, ]
    
    if (!is.null(runways)) df = df[df$Runway %in% runways,]
    
    df = df %>% 
        group_by(!!ensym(group_by_)) %>% 
        summarize(Count=sum(Count))
    
    # If grouping by month, leave out 7/2019, it is incomplete
    if (group_by_=='Month')
        df = df  %>% filter(Month != "2019-07-01")
    df
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
      runways = if (input$runway_opt=='All') NULL else input$runway_sel
      filter_data(input$year_range[1], input$year_range[2],
                     input$hour_range[1], input$hour_range[2],
                     input$operation, input$equip, 
                  runways, input$group_by)
  })
  
  title = reactive({
    period = if_else(input$group_by=='Month', 'monthly', 'daily')
    operation = if_else(input$operation=='Departure', 
                        'departures', 'arrivals')
    runways = if (input$runway_opt=='All' || is.null(input$runway_sel)) 
        'all runways'
      else paste('runways', paste(input$runway_sel, collapse=', '))
    equip = if_else(input$equip=='Jet', 'jets only', 
                    if_else(input$equip=='Non-Jet', 'non-jets only',
                            'All equipment'))
    glue('Logan Airport total {period} {operation}, {runways}, {equip},',
    '{as_am_pm(input$hour_range[1])}-{as_am_pm(input$hour_range[2]+1)}')
  })
  
  #### Counts ####
  output$count_plot = renderPlot({
    df = filtered()
    

    p = ggplot(df, aes_string(input$group_by, 'Count')) +
      geom_point(color='steelblue') +
      scale_x_date(date_breaks='1 year', minor_breaks=NULL,
                   date_labels='%Y', expand=expand_scale(mult=0.1)) +
      silgelib::theme_plex() +
      labs(title=title(),
         x='', y='Operation count',
         caption='Data from FAA FOIA request | Chart © 2020 Kent Johnson')
    if (input$show_smooth)
        p = p + stat_smooth(method=lm, se=FALSE, 
                            color='darkblue', size=1)
    p
    })
  
  #### Seasonality ####
  output$seasonality_plot = renderPlot({
    req(input$group_by=='Month') # Don't do daily seasonality
    df = filtered()
    
    # Lots of ugly munging
    # First make a ts object so we can get seasonality
    start = if (input$year_range[1]==2010) c(2010, 3)
      else c(input$year_range[2], 1)
    frequency = 12

    df_ts = ts(df$Count, start=start, frequency=frequency)
    df_seas = stl(df_ts, s.window=7)
    
    # Convert back to a long data frame for plotting
    df_df = as_tibble(df_seas$time.series) %>% 
      mutate(Date=as.Date(as.yearmon(time(df_seas$time.series)))) %>% 
      rename_at(-4, stringr::str_to_title) %>% 
      pivot_longer(-Date, names_to='Series', values_to='Count') %>% 
      mutate(Series = factor(Series, 
                             levels=c('Trend', 'Seasonal', 'Remainder')))
    
    ggplot(df_df, aes(Date, Count)) +
      geom_line(color='darkblue') +
      facet_wrap(~Series, ncol=1, scales='free_y') +
      labs(x='', y='Operation count',
         title=glue('Seasonality and trend of {title()}'),
         caption='Data from FAA FOIA request | Chart © 2020 Kent Johnson') +
      theme_plex()
  })
}
