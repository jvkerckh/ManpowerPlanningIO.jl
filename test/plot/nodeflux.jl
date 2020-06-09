@testset "Node flux report" begin

fName = "report/nodeflux"

nodeFluxPlot( mpSim, 12, :in, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master" )
nodeFluxPlot( mpSim, 12, :out, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", plotType=:stacked )
#=
nodeFluxPlot( mpSim, 12, :in, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", showPlot=false,
    filename="plot/node in flux test" )
nodeFluxPlot( mpSim, 12, :out, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", showPlot=false, plotType=:stacked,
    filename="plot/node out flux test" )
=#
end  # @testset "Node flux report"