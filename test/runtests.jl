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


@testset "Manpower Simulation I/O tests" begin

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


@testset "Database configuration tests" begin

include( "db/complete.jl" )

end  # @testset "Database configuration tests" begin


include( "report/simprep.jl" )


@testset "Simulation report tests" begin

include( "report/transitionflux.jl" )
include( "report/nodeflux.jl" )
include( "report/nodepop.jl" )
include( "report/nodecomposition.jl" )
include( "report/subpop.jl" )

end  # @testset "Simulation report tests"


@testset "Simulation plot tests" begin

include( "plot/transitionflux.jl" )
include( "plot/nodeflux.jl" )
include( "plot/nodepop.jl" )
include( "plot/nodecomposition.jl" )
include( "plot/subpop.jl" )

rm.( string.( "plot/", filter( fname -> endswith( fname, ".svg" ),
    readdir( "plot" ) ) ) )

end  # @testset "Simulation plot tests"

end  # @testset "Manpower Simulation I/O tests"


tElapsed = ( now() - tStart ).value / 1000
@info string( "Unit tests completed in ", tElapsed, " seconds." )
