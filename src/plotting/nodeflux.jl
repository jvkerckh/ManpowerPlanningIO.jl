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

    fileroot = nothing
    extension = nothing

    # Get file name ready.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            fileroot = string( string( "Node flux plot (", dateStr, ")",
                labelInfix[:fluxType] ) )
            extension = "svg"
        else
            extension = split( filename, "." )
            fileroot = length( extension ) == 1 ? extension[1] :
                join( extension[1:(end - 1)], "." )
            extension = length( extension ) == 1 ? "" : extension[end]
            extension = extension ∈ extensions ? extension : "svg"
        end  # if filename == ""

        if !ispath( dirname( fileroot ) )
            mkpath( dirname( fileroot ) )
        end  # if !ispath( dirname( fileroot ) )
    end  # if savePlot

    # Generate plots.
    for node in unique( nodes )
        if !haskey( fluxReport, node )
            continue
        end  # if !haskey( fluxReport, node )

        plotfilename = string( fileroot, " ", node, ".", extension )
        plt = plotFunction( fluxReport[node], string( node ), fluxType,
            timeFactor )

        # Show plot if needed.
        if showPlot
            gui( plt )
        end  # if showPlot

        # Save plot if needed.
        if savePlot
            savefig( plt, plotfilename )
        end  # if savePlot
    end  # for node in unique( nodes )

end  # nodeFluxPlot( mpSim, timeGrid, fluxType, nodes, plotType, showPlot,
     #   savePlot, filename, timeFactor )

nodeFluxPlot( mpSim::MPsim, timeRes::Real, fluxType::Symbol,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeFluxPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), fluxType,
    nodes..., plotType=plotType, showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )


include( "private/nodeflux.jl" )