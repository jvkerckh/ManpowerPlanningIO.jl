export nodeFluxPlot


function nodeFluxPlot( mpSim::MPsim, timeGrid::Vector{T}, fluxType::Symbol,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""
    plotType = haskey( plotTypes, plotType ) ? plotType : :normal
    plotFunction = plotTypes[plotType][1]

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    fluxReport = nodeFluxReport( mpSim, timeGrid, fluxType, nodes... )

    if isempty( fluxReport )
        return
    end  # if isempty( fluxReport )

    generateNodeFluxPlot( fluxReport, nodes, fluxType, timeFactor, showPlot,
        savePlot, filename, plotFunction )

end  # nodeFluxPlot( mpSim, timeGrid, fluxType, nodes, plotType, showPlot,
     #   savePlot, filename, timeFactor )

nodeFluxPlot( mpSim::MPsim, timeRes::Real, fluxType::Symbol,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeFluxPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), fluxType,
    nodes..., plotType=plotType, showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )


include( "private/nodeflux.jl" )