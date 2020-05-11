@testset "Node composition plots" begin

nodeCompositionPlot( mpSim, 12, "Master", "Junior", "Career", "Branch A",
    "Branch B", showPlot=false, filename="plot/node composition test 1" )
nodeCompositionPlot( mpSim, 12, "Junior", "Career", "Branch A", "Branch B",
    showPlot=false, plotType=:stacked, filename="plot/node composition test 2" )

end  # @testset "Node composition plots"