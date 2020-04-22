library("DiagrammeR")

grViz("
      digraph foo {

      ## setting would make everything orthogonal
      #graph [splines = ortho]

      # nodes of main state variables
      node [shape = box, fontname = Helvetica, color=green]
      Susceptible, Infected, Recovered, Dead

      # a red, oval node
      node [shape = oval, fixedsize = false, color=red, bg=oragne, width = 0.9]
      Hospital

      ## an invisible node
      node [shape = point, width = 0]
      Exposed

      node [shape = oval, fixedsize = false, color=orange, width = 0.9]
      Healthcare, Contact

      # 'matter' flow
      edge [color=SteelBlue style=bold]
      Susceptible -> Exposed[arrowhead=none, weight = 3]
      Exposed -> Infected -> Recovered[weight = 3]
      Infected -> Hospital -> {Recovered, Dead}

      # information flow
      edge [color=orange style=solid]
      Healthcare -> {Infected, Hospital, Recovered}
      Contact -> Exposed
}")


