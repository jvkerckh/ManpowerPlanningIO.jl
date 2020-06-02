@testset "Initial population plots" begin
    mpSim2 = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readInitPop( mpSim2, xf, filePath )
    end  # XLSX.openxlsx( fileName ) do xf

    initialPopPlot( mpSim2, filename="plot/initpop" )
    initialPopAgePlot( mpSim2, 12, :age, filename="plot/initpop age" )
    initialPopAgePlot( mpSim2, 12, :tenure, filename="plot/initpop tenure" )
    initialPopAgePlot( mpSim2, 12, :timeInNode,
        filename="plot/initpop time in node" )
end  # @testset "Initial population plots"