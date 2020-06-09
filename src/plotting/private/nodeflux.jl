function generateNodeFluxPlot( fluxReport::Dict{String,DataFrame},
    nodes::NTuple{N,String}, fluxType::Symbol, timeFactor::Float64,
    showPlot::Bool, savePlot::Bool, filename::String,
    plotFunction::Function ) where N

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

        fileroot = string( fileroot )

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

end  # generateNodeFluxPlot( fluxReport, nodes, fluxType, timeFactor, showPlot,
     #   savePlot, fileroot, extension, plotFunction )


function normalFluxPlot( fluxReport::DataFrame, node::String, fluxType::Symbol,
    timeFactor::Float64 )

    timePoints = fluxReport[:, :timePoint]
    labels = generateFluxLabels( names( fluxReport )[4:end], fluxType )
    labels = vcat( string( "Flux", labelInfix[fluxType][1], node ),
        labels )
    plotTitle = string( "Breakdown of ", labels[1] )
    timePoints = fluxReport[:, :timePoint] / timeFactor
    dataPoints = Matrix( fluxReport[:, 3:end] )

    plt = nothing

    if fluxType === :within
        ymax = size( dataPoints, 2 ) == 1 ? 20 :
            max( maximum( dataPoints[:, 2:end] ), 20 )
        plt = plot( show=false, size=(960, 540), title=plotTitle,
            label=labels[1], lw=3, color=:black, ylim=[0, ymax] )
    else
        ymax = max( maximum( dataPoints[:, 1] ), 20 )
        plt = plot( timePoints, dataPoints[:, 1], show=false, size=(960, 540),
            title=plotTitle, label=labels[1], lw=3, color=:black,
            ylim=[0, ymax] )
    end  # if fluxType === :within

    plot!( plt, timePoints, dataPoints[:, 2:end],
        label=hcat( labels[2:end]... ), lw=2 )
    
    return plt

end  # normalFluxPlot( fluxReport, node, fluxType, timeFactor )


function stackedFluxPlot( fluxReport::DataFrame, node::String, fluxType::Symbol,
    timeFactor::Float64 )

    timePoints = fluxReport[:, :timePoint]
    labels = generateFluxLabels( names( fluxReport )[4:end], fluxType )
    plotTitle = string( "Breakdown of ", labels[1] )
    timePoints = fluxReport[:, :timePoint] / timeFactor
    dataPoints = Matrix( fluxReport[:, 4:end] )
    nPoints, nSeries = size( dataPoints )
    dataPoints = hcat( fill( 0, nPoints ), cumsum( dataPoints, dims=2 ) )
    ymax = max( maximum( fluxReport[:, 3] ), 20 )

    plt = plot( show=false, size=(960,540), title=plotTitle, ylim=[0, ymax] )

    for ii in 1:nSeries
        plot!( plt, timePoints, dataPoints[:, ii + 1], lw=2, lalpha=1.0, fillto=dataPoints[:, ii], falpha=0.5, label=labels[ii] )
    end  # for ii in 1:nSeries

    return plt

end  # stackedFluxPlot( fluxReport, node, fluxType, timeFactor )


function generateFluxLabels( labels::Vector{String}, fluxType::Symbol )

    # Split the labels into transition, source node, and target node.
    labelBreakdown = split.( labels, ": " )
    transitions = getindex.( labelBreakdown, 1 )
    labelBreakdown = split.( getindex.( labelBreakdown, 2 ), " => " )
    sourceNodes = getindex.( labelBreakdown, 1 )
    targetNodes = getindex.( labelBreakdown, 2 )

    if fluxType === :within
        return string.( sourceNodes, labelInfix[fluxType][2], targetNodes )
    end  # if fluxType === :within

    return string.( transitions, labelInfix[fluxType][2],
        fluxType === :in ? sourceNodes : targetNodes )

end  # generateFluxLabels( labels, plotType )