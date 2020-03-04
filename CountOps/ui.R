# CountOps UI
dashboardPage(
  dashboardHeader(title='Logan Airport CountOps Explorer', titleWidth=400),
  dashboardSidebar(
      sliderInput('year_range', 'Years', 2010, 2019, ticks=FALSE,
                  value=c(2010, 2019), step=1, round=TRUE, sep=''),
      sliderInput('hour_range', 'Hours', 0, 23, ticks=FALSE,
                  value=c(5, 8), step=1, round=TRUE),
      radioButtons('operation', 'Operation', 
                   list('Departure', 'Arrival'),
                   selected='Departure', inline=TRUE),
      radioButtons('group_by', 'Summarize by', 
                   list('Month'='Month', 'Day'='Date'), 
                   selected='Month', inline=TRUE),
      checkboxInput('show_smooth', 'Show linear fit?', value=TRUE)
  ),
  
  dashboardBody(
      fluidRow(
          plotOutput('the_plot', width='95%')
      )
  )
)