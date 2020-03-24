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

include( "base.jl" )
include( "attrition.jl" )
include( "attribute.jl" )
include( "basenode.jl" )
include( "compoundnode.jl" )
include( "recruitment.jl" )
include( "transition.jl" )
include( "retirement.jl" )

end  # @testset "Excel configuration tests"

tElapsed = ( now() - tStart ).value / 1000
@info string( "Unit tests completed in ", tElapsed, " seconds." )
