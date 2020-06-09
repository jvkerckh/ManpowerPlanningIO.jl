export  nodePopPlot,
        nodeEvolutionPlot


function nodePopPlot( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; showPlot::Bool=true, savePlot::Bool=false,
    filename::AbstractString="", timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    popReport = nodePopReport( mpSim, timeGrid, nodes... )

    if isempty( popReport )
        return
    end  # if isempty( popReport )

    generatePopPlot( popReport, timeFactor, showPlot, savePlot, filename )

end  # nodePopPlot( mpSim, timeGrid, nodes, breakdownType, showPlot, savePlot,
     #   filename, timeFactor )

nodePopPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; breakdownType::Symbol=:none, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodePopPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...,
    showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )


function nodeEvolutionPlot( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""
    plotType = haskey( plotTypes, plotType ) ? plotType : :normal
    plotFunction = plotTypes[plotType][1]
    plotFunction2 = plotTypes[plotType][2]

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    popReport, fluxReports = nodeEvolutionReport( mpSim, timeGrid, nodes... )

    if isempty( popReport ) || isempty( fluxReports )
        return
    end  # if isempty( popReport ) || ...

    generateEvolutionPlot( popReport, mpSim, fluxReports, nodes, timeFactor,
        showPlot, savePlot, filename, plotFunction, plotFunction2 )

end  # nodeEvolutionPlot( mpSim, timeGrid, nodes, plotType, showPlot, savePlot,
     #   filename, timeFactor )

nodeEvolutionPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeEvolutionPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...,
    plotType=plotType, showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )


include( "private/nodepop.jl" )