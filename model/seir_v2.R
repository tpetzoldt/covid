## Basic SEIR model
## core model parameters taken from:
## https://towardsdatascience.com/social-distancing-to-slow-the-coronavirus-768292f04296
##
## implemented by tpetzoldt as a shiny app

library("deSolve")
library("dygraphs")


SEIR <- function(t, y, parms) {
  with(as.list(c(parms, y)), {
    dS <- -rho * beta * I * S
    dE <-  rho * beta * S * I - alpha * E
    dI <-  alpha * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR), r = dI/I)
  })
}

## estimate "observed" numerical derivatives from states
derivative <- function(out) {
  x <- matrix(0, nrow=nrow(out)-1, ncol=ncol(out))
  x[,1] <- out[-1,1]
  for (i in 2:ncol(out)) {
    x[,i] <- diff(out[,i])
  }
  class(x) <- c("deSolve", "matrix")
  dimnames(x) <- dimnames(out)
  x
}


y0 <- c(S=1 - 5e-4,       # susceptible
        E=4e-4,           # exposed
        I=1e-4,           # infected
        R=0)              # recovered + removed

parms  <- c(alpha = 0.2,  # inverse of incubation period
            beta = 1.75,  # average contact rate
            gamma = 0.5,  # inverse of mean infectious period
            rho = 1)      # social distancing


makelist <- function(i, obj, min=NA, max=NA, step=NA, width=NULL) {
  list(inputId=names(obj[i]), label=names(obj[i]),
       value=unname(obj[i]), min=min, max=max, step=step,
       width=width)
}

## two lists of lists
L_parms <- lapply(1:length(parms), makelist, obj=parms, min=0, max=10, step=0.1, width=100)
L_y0 <- lapply(1:length(y0), makelist, obj=y0, min=0, max=100, step=0.1, width=100)

server <- function(input, output) {

  simulation <- reactive({
    #L_input <- reactiveValuesToList(x) # to enable "with"
    #y0    <- with(L_input, c(S=S, E=E, I=I, R=R))
    #parms <- with(L_input, c(alpha=alpha, beta=beta, gamma=gamma, rho=rho))
    y0    <- c(S=input$S, E=input$E, I=input$I, R=input$R)
    parms <- c(alpha=input$alpha, beta=input$beta, gamma=input$gamma, rho=input$rho)

    times <- seq(0, 150, 1)
    out <- ode(y0, times, SEIR, parms, method="bdf", atol=1e-8, rtol=1e-8)
    out
  })

  output$dygraph <- renderDygraph({
    out <- as.data.frame(simulation())[c("time", "S", "E", "I", "R")]

    dygraph(out, group="grp") %>%
      dySeries("S", color="black", label="Susceptible") %>%
      dySeries("E", color="orange", label="Exposed") %>%
      dySeries("I", color="red", label="Infected") %>%
      dySeries("R", color="blue", label="Recovered or deceased") %>%
      dyAxis("y", label = "relative fraction", labelHeight = 12) %>%
      dyAxis("x", label = "time (d)", labelHeight = 18) %>%
      dyOptions(
                fillGraph = TRUE,
                #stackedGraph = TRUE,
                fillAlpha = 0.3,
                animatedZooms = TRUE) %>%
      dyLegend(labelsSeparateLines = TRUE)
  })

  output$derivative <- renderDygraph({
    out <- simulation()
    #d_out <- as.data.frame(derivative(out[, c(1,4)]))
    d_out <- as.data.frame(out)[c("time", "r")]

    dygraph(d_out, group="grp") %>%
      #dySeries("I", color="red", label="Rate") %>%
      dyAxis("y", label = "infected growth rate (1/d)", labelHeight = 12) %>%
      dyAxis("x", label = "time (d)", labelHeight = 18) %>%
      dyOptions(fillGraph = TRUE, fillAlpha = 0.5,
                animatedZooms = TRUE) %>%
      dyLegend(labelsSeparateLines = TRUE)
  })

  output$doubling <- renderDygraph({
    out <- simulation()
    d_out <- as.data.frame(out)
    d_out$doubling <- log(2)/d_out$r
    d_out <- d_out[c("time", "doubling")]
    dygraph(d_out, group="grp") %>%
      dyAxis("y", label = "doubling time (d)", valueRange=c(0, 10), labelHeight = 12) %>%
      dyAxis("x", label = "time (d)", labelHeight = 18) %>%
      dyOptions(fillGraph = TRUE, fillAlpha = 0.5,
                animatedZooms = TRUE) %>%
      dyLegend(labelsSeparateLines = TRUE)
  })

}

ui <- fluidPage(
  headerPanel("SEIR model"),
  sidebarLayout(
    sidebarPanel(
      ## generic creation of UI elements
      h3("Init values"),
      lapply(L_y0, function(x) do.call("numericInput", x)),

      h3("Parameters"),
      lapply(L_parms, function(x) do.call("numericInput", x))
    ),
    mainPanel(
      h3("Simulation results"),
      dygraphOutput("dygraph", height = "300px"),
      dygraphOutput("derivative", height = "300px"),
      dygraphOutput("doubling", height = "300px")
    )
  )
)

shinyApp(ui = ui, server = server)
