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
      radioButtons('runway_opt', 'Runways',
                   list('All', 'Selected'),
                   selected='All', inline=TRUE),
      conditionalPanel("input.runway_opt=='Selected'",
          selectInput('runway_sel', 'Select runways:', runways,
                      multiple=TRUE, selected='33L')
      ),
      radioButtons('equip', 'Equipment', 
                   list('Jet', 'Non-Jet', 'All'),
                   selected='Jet', inline=TRUE),
      radioButtons('group_by', 'Summarize by', 
                   list('Month'='Month', 'Day'='Date'), 
                   selected='Month', inline=TRUE),
      checkboxInput('show_smooth', 'Show linear fit?', value=TRUE)
  ),
  
  dashboardBody(
    tags$head(tags$style(HTML('.shiny-plot-output {
               margin-left: 5%;
               }'))),
      fluidRow(
          plotOutput('count_plot', width='90%')
      ),
      fluidRow(hr(style="
    border-top: 2px solid darkblue;
    margin-left: 5%;
    margin-right:  5%;
    margin-top: 0;
    margin-bottom: 1px;
")),
      fluidRow(
          plotOutput('seasonality_plot', width='90%')
      )
  )
)