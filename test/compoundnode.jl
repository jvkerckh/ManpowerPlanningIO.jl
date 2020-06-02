@testset "Compound node configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( fileName ) do xf
        XLSX.openxlsx( catFileName ) do catXF
            MPIO.readAttributes( mpSim, xf, catXF )
            MPIO.readBaseNodes( mpSim, xf, catXF )
            MPIO.readCompoundNodes( mpSim, xf, catXF )
        end  # XLSX.openXLSX( catFileName ) do xf
    end  # XLSX.openxlsx( fileName ) do xf

    @test length( mpSim.compoundNodeList ) == 12
end  # @testset "Compound node configuration tests"