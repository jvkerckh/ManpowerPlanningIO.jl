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

    fileroot = nothing
    extension = nothing

    # Get file name ready.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            fileroot = string( string( "Node composition plot (", dateStr, ")",
                labelInfix[:fluxType] ) )
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

    generateCompPlot( compReport, nodes, timeFactor, showPlot, savePlot,
        fileroot, extension, plotFunction )

end  # nodeCompositionPlot( mpSim, timeGrid, nodes, plotType, showPlot,
     #   savePlot, filename, timeFactor )

nodeCompositionPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeCompositionPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes..., plotType=plotType, showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )


include( "private/nodecomposition.jl" )