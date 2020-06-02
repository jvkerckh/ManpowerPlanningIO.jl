@testset "Snapshot loading test" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readInitPop( mpSim, xf, filePath )
    end  # XLSX.openxlsx( fileName ) do xf

    @test mpSim.orgSize == 50
    @test length( mpSim.attributeList ) == 3
    @test length( mpSim.baseNodeList ) == 5
end  # @testset "Snapshot loading test"