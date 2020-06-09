export nodeCompositionPlot


function nodeCompositionPlot( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""
    plotType = haskey( plotTypes, plotType ) ? plotType : :normal
    plotFunction = plotTypes[plotType][2]

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    compReport = nodeCompositionReport( mpSim, timeGrid, nodes... )

    if isempty( compReport )
        return
    end  # if isempty( compReport )

    generateCompPlot( compReport, nodes, timeFactor, showPlot, savePlot,
        filename, plotFunction )

end  # nodeCompositionPlot( mpSim, timeGrid, nodes, plotType, showPlot,
     #   savePlot, filename, timeFactor )

nodeCompositionPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeCompositionPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes..., plotType=plotType, showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )


include( "private/nodecomposition.jl" )