using Dates
using ManpowerPlanning
using ManpowerPlanningIO
using Test
using XLSX

versionMPIO()
println()

MPsim = ManpowerSimulation
MPIO = ManpowerPlanningIO

tStart = now()

@testset "Excel configuration tests" begin

include( "baseTest.jl" )

end  # @testset "Excel configuration tests"

tElapsed = ( now() - tStart ).value / 1000
@info string( "Unit tests completed in ", tElapsed, " seconds." )
