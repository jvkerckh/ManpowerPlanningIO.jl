using Dates
using ManpowerPlanning
using ManpowerPlanningIO
using Plots
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
include( "initpop.jl" )

end  # @testset "Excel configuration tests"


@testset "Excel run tests" begin

include( "randomseed.jl" )

end  # @testset "Excel run tests"


@testset "Database configuration tests" begin

include( "db/complete.jl" )

end  # @testset "Database configuration tests" begin


include( "report/simprep.jl" )


@testset "Simulation report tests" begin

rm.( string.( "report/", filter( fname -> endswith( fname, ".xlsx" ),
    readdir( "report" ) ) ) )
include( "report/transitionflux.jl" )
include( "report/nodeflux.jl" )
include( "report/nodepop.jl" )
include( "report/nodecomposition.jl" )
include( "report/subpop.jl" )
include( "report/initpop.jl" )

end  # @testset "Simulation report tests"


@testset "Simulation plot tests" begin

gui( plot() )

rm.( string.( "plot/", filter( fname -> endswith( fname, ".svg" ),
    readdir( "plot" ) ) ) )
include( "plot/transitionflux.jl" )
include( "plot/nodeflux.jl" )
include( "plot/nodepop.jl" )
include( "plot/nodecomposition.jl" )
include( "plot/subpop.jl" )
include( "plot/initpop.jl" )

end  # @testset "Simulation plot tests"


@testset "Excel plot request tests" begin

rm( "excelrequest/plotRequest", recursive=true, force=true )
include( "excelrequest/transitionflux.jl" )
include( "excelrequest/nodepop.jl" )
include( "excelrequest/initpop.jl" )

end  # @testset "Excel plot request tests"

end  # @testset "Manpower Simulation I/O tests"


tElapsed = ( now() - tStart ).value / 1000
@info string( "Unit tests completed in ", tElapsed, " seconds." )
