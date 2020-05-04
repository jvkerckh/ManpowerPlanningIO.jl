@testset "Transition flux plots" begin

transFluxPlot( mpSim, 12, ("", "A junior"), ("", "B junior"),
    ("", "Reserve junior"), showPlot=false, filename="plot/transition test 1" )
transFluxPlot( mpSim, 12, ("A junior", "A senior"), ("B junior", "B senior"),
    ("Reserve junior", "A senior"), ("Reserve junior", "B senior"),
    showPlot=false, filename="plot/transition test 2" )
transFluxPlot( mpSim, 12, ("A junior", ""), ("B junior", ""),
    ("Reserve junior", ""), showPlot=false, filename="plot/transition test 3" )
transFluxPlot( mpSim, 12, ("A senior", "Master"), ("B senior", "Master"),
    showPlot=false, filename="plot/transition test 4" )
transFluxPlot( mpSim, 12, ("A senior", ""), ("B senior", ""), ("Master", ""),
    showPlot=false, filename="plot/transition test 5" )

end  # @testset "Transition flux plots"