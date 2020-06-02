@testset "Init pop plots" begin
    mpSim2 = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readInitPop( mpSim2, xf, filePath )
    end  # XLSX.openxlsx( fileName ) do xf

    excelInitPopPlot( mpSim2, "excelrequest/plotRequest" )
end  # @testset "Init pop plots"