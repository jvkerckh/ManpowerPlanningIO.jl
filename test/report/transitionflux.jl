@testset "Transition flux report" begin

fName = "report/transitionflux"

excelFluxReport( mpSim, 12, ("", "A junior"), ("", "B junior"),
    ("", "Reserve junior"), filename = fName )
excelFluxReport( mpSim, 12, ("A junior", "A senior"), ("B junior", "B senior"),
    ("Reserve junior", "A senior"), ("Reserve junior", "B senior"),
    filename = fName, overwrite = false )
excelFluxReport( mpSim, 12, ("A junior", ""), ("B junior", ""),
    ("Reserve junior", ""), filename = fName, overwrite = false )
excelFluxReport( mpSim, 12, ("A senior", "Master"), ("B senior", "Master"),
    filename = fName, overwrite = false )
excelFluxReport( mpSim, 12, ("A senior", ""), ("B senior", ""), ("Master", ""),
    filename = fName, overwrite = false )

end  # @testset "Transition flux report"