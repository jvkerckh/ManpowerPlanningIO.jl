@testset "Initial population reports" begin
    mpSim2 = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readInitPop( mpSim2, xf, filePath )
    end  # XLSX.openxlsx( fileName ) do xf

    fName = "report/initpop"
    excelInitPopReport( mpSim2, filename=fName )
    excelInitPopAgeReport( mpSim2, 12, :age, filename=fName, overwrite=false )
    excelInitPopAgeReport( mpSim2, 12, :tenure, filename=fName,
        overwrite=false )
    excelInitPopAgeReport( mpSim2, 12, :timeInNode, filename=fName,
        overwrite=false )
end  # @testset "Initial population reports"