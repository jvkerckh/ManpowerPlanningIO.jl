@testset "Complete config test" begin
    mpSim, isOkay = initialiseFromDB( "db/simDB", showInfo = false )
    @test isOkay

    println( mpSim.transitionsByName )
end  # @testset "Complete config test"