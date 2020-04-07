@testset "Node flux report" begin

fName = "report/nodeflux"

excelFluxReport( mpSim, 12, :in, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", filename = fName )
excelFluxReport( mpSim, 12, :out, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", filename = fName, overwrite = false )

end  # @testset "Node flux report"