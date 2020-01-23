@testset "Base Excel configuration tests" begin

    # File doesn't exist.
    mpSim, isOkay = initialiseFromExcel( joinpath( "base", "baseConfig0" ) )
    @test !isOkay

    # Excel file has no General tab.
    mpSim, isOkay = initialiseFromExcel( joinpath( "base", "baseConfig1" ) )
    @test !isOkay

    # initialiseFromExcel( joinpath( "base", "baseConfig" ), showInfo = false )

end  # @testset "Base Excel configuration tests"


@testset "Database parameter test" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        @test MPIO.readDBpars( mpSim, xf[ "General" ], filePath ) == "Excel"
    end  # XLSX.openXLSX( fileName ) do xf

    @test mpSim.dbName == joinpath( "base", "baseConfig", "simDB.sqlite" )
    @test mpSim.simName == "sim"
end  # @testset "Database parameter test"

@testset "General parameter test" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readGeneralPars( mpSim, xf[ "General" ], filePath )
    end  # XLSX.openXLSX( fileName ) do xf

    @test mpSim.catFileName == joinpath( "base", "catalogue.xlsx" )
    @test mpSim.personnelTarget == 0
    @test mpSim.simLength == 300.0
end  # @testset "General parameter test"