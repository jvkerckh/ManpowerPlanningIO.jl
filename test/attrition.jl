@testset "Attrition configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( catFileName ) do xf
        MPIO.readAttritionSchemes( mpSim, xf )
    end  # XLSX.openXLSX( catFileName ) do xf

    @test length( mpSim.attritionSchemes ) == 2
end  # @testset "Attrition configuration tests"