@testset "Node pop report" begin

fName = "report/nodepop"

excelPopReport( mpSim, 12, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", "Career", filename=fName )
excelPopEvolutionReport( mpSim, 12, "A junior", "B junior", "Reserve junior",
    "A senior", "B senior", "Master", "Career", filename=fName,
    overwrite=false )

end  # @testset "Node pop report"