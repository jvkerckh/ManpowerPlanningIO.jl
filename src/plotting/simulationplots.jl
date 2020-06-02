const extensions = ["svg", "html", "png"]


include( "transitionflux.jl" )
include( "nodeflux.jl" )
include( "nodepop.jl" )
include( "nodecomposition.jl" )
include( "subpop.jl" )
include( "subpopage.jl" )
include( "initpop.jl" )


const plotTypes = Dict{Symbol,NTuple{2,Function}}(
    :normal => (normalFluxPlot, normalCompPlot),
    :stacked => (stackedFluxPlot, stackedCompPlot) )
const labelInfix = Dict{Symbol,NTuple{2,String}}( :in => (" into ", " from "),
    :out => (" out of ", " to "), :within => (" within ", " to ") )