using Dates
using ManpowerPlanningIO
using Test

versionMPIO()
println()

tStart = now()

@testset "Excel configuration tests" begin

@test true

end  # @testset "Excel configuration tests"

tElapsed = ( now() - tStart ).value / 1000
@info string( "Unit tests completed in ", tElapsed, " seconds." )
