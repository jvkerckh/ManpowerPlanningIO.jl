@testset "Recruitment configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( fileName ) do xf
        MPIO.readRetirement( mpSim, xf )
    end  # XLSX.openxlsx( fileName ) do xf

    @test ( mpSim.retirement.freq == 3 ) && ( mpSim.retirement.offset == 0 )
    @test ( mpSim.retirement.maxCareerLength == 120 ) &&
        ( mpSim.retirement.retirementAge == 360 )
    @test mpSim.retirement.isEither
end  # @testset "Recruitment configuration tests"