@testset "Attrition configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( fileName ) do xf
        XLSX.openxlsx( catFileName ) do catXF
            MPIO.readAttributes( mpSim, xf, catXF )
        end  # XLSX.openXLSX( catFileName ) do xf
    end  # XLSX.openxlsx( fileName ) do xf

    @test length( mpSim.attributeList ) == 3
end  # @testset "Attrition configuration tests"