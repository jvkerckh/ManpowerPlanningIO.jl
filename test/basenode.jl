@testset "Base node configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( fileName ) do xf
        XLSX.openxlsx( catFileName ) do catXF
            MPIO.readBaseNodes( mpSim, xf, catXF )
        end  # XLSX.openXLSX( catFileName ) do xf
    end  # XLSX.openxlsx( fileName ) do xf

    @test length( mpSim.baseNodeList ) == 6
    @test length( mpSim.baseNodeOrder ) == 5
end  # @testset "Base node configuration tests"