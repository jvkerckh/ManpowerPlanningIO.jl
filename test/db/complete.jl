@testset "Complete config test" begin
    mpSim, isOkay = initialiseFromDB( "db/simDB", showInfo = false )
    @test isOkay
end  # @testset "Complete config test"