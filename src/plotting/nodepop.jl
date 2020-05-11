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

    fileroot = nothing
    extension = nothing

    # Get file name ready.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            fileroot = string( "Population evolution plot (", dateStr, ") of " )
            extension = "svg"
        else
            extension = split( filename, "." )
            fileroot = length( extension ) == 1 ? string( extension[1] ) :
                join( extension[1:(end - 1)], "." )
            extension = length( extension ) == 1 ? "" : extension[end]
            extension = extension ∈ extensions ? extension : "svg"
        end  # if filename == ""

        if !ispath( dirname( fileroot ) )
            mkpath( dirname( fileroot ) )
        end  # if !ispath( dirname( fileroot ) )
    end  # if savePlot

    generateEvolutionPlot( popReport, mpSim, fluxReports, nodes, timeFactor,
        showPlot, savePlot, fileroot, extension, plotFunction, plotFunction2 )

end  # nodeEvolutionPlot( mpSim, timeGrid, nodes, plotType, showPlot, savePlot,
     #   filename, timeFactor )

nodeEvolutionPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeEvolutionPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...,
    plotType=plotType, showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )


include( "private/nodepop.jl" )