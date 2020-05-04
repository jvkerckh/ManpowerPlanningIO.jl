@testset "Node pop plots" begin

nodePopPlot( mpSim, 12, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", "Career", showPlot=false,
    filename="plot/node pop test" )
nodeEvolutionPlot( mpSim, 12, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", "Career", showPlot=false,
    filename="plot/node evolution test" )

end  # @testset "Node pop plots"