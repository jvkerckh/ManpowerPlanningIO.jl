@testset "Node composition report" begin

fName = "report/nodecomposition"

excelPopCompositionReport( mpSim, 12, "Junior", "Career", "Branch A",
    "Branch B", filename = fName )

end  # @testset "Node composition report"