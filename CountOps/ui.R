# CountOps UI
dashboardPage(
  dashboardHeader(title='Logan Airport CountOps Explorer', titleWidth=400),
  dashboardSidebar(
      sliderInput('year_range', 'Years',
                  2010, 2019, ticks=FALSE,
                  value=c(2010, 2019), step=1, round=TRUE, sep=''),
      sliderInput('hour_range', 'Hours',
                  0, 23, ticks=FALSE,
                  value=c(5, 8), step=1, round=TRUE),
      radioButtons('operation', 
                   span('Operation', icon('plane-departure')), 
                   list('Departure', 'Arrival'),
                   selected='Departure', inline=TRUE),
      radioButtons('runway_opt', 
                   span('Runways', icon('road')),
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
    fluidRow(
    tabBox(width=12,
      tabPanel("Plot", 
          fluidRow(box(width=12, status = "primary", 
              plotOutput('count_plot', width='90%')
          )),
          fluidRow(box(width=12, status = "primary", 
              plotOutput('seasonality_plot', width='90%')
          ))
      ),
      tabPanel('Data',
         fluidRow(box(width=12, solidHeader=TRUE,
                      uiOutput('data_header')),
                  box(width=9, solidHeader=TRUE,
                      DTOutput('data', width='90%'))
         ),
         downloadButton('download_data', 'Download data')
      ),
      tabPanel('About',
        fluidRow(
          box(title='Overview', 
              width=12, solidHeader=TRUE,
            p('Use this app to explore daily and monthly operation counts',
              'at Boston Logan Airport from March 2010 to June 2019.',
              'Choose arrival or departure counts, for one runway or all.',
              'Limit times of day to see how early morning or late night ',
              'operations have changed.'),
           p('Charts show the selected counts over time and, for monthly counts,',
             'the seasonality and trend. Count data is shown in a table and is ',
             'available for download.'),
           p('With this app you can answer questions such as, ',
           'how many departures are there on 33L between 10pm and midnight? ',
           'How have they changed? How have overall late night and ',
           'early morning departures changed?')),
        box(title=span(icon('chart-line'), 'Data and analysis'), 
            width=12, solidHeader=TRUE,
            p('Data for this app was obtained from the FAA CountOps ',
              'program via FOIA request.'),
            p('Analysis and programming by Kent S Johnson.')),
        box(title=span(icon("github"), 'GitHub'), 
            width=12, solidHeader=TRUE,
            'App:', a(href='https://github.com/kent37/CountOpsApp',
                      target='_blank',
                      'http://github.com/kent37/CountOpsApp',
                      icon('external-link-alt', 'fa-sm')),
            br(),
            'Data:', a(href='https://github.com/kent37/CountOpsLogan', 
                       target='_blank',
                       'http://github.com/kent37/CountOpsLogan',
                       icon('external-link-alt', 'fa-sm')))
        )
      )
    )
    )
  )
)