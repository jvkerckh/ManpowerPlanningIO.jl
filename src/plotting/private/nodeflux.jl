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
        plt = plot( size=(960, 540), title=plotTitle, label=labels[1], lw=3,
            color=:black, ylim=[0, maximum( dataPoints[:, 2:end] )] )
    else
        plt = plot( timePoints, dataPoints[:, 1], size=(960, 540),
            title=plotTitle, label=labels[1], lw=3, color=:black,
            ylim=[0, maximum( dataPoints[:, 1] )] )
    end
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

    plt = plot( size=(960,540), title=plotTitle,
        ylim=[0, maximum( dataPoints )] )

    for ii in 1:nSeries
        plot!( plt, timePoints, dataPoints[:, ii + 1], lw=2, lalpha=1.0, fillto=dataPoints[:, ii], falpha=0.5, label=labels[ii] )
    end  # for ii in 1:nSeries

    return plt

end  # stackedFluxPlot( fluxReport, node, fluxType, timeFactor )


function generateFluxLabels( labels::Vector{Symbol}, fluxType::Symbol )

    # Split the labels into transition, source node, and target node.
    labelBreakdown = split.( string.( labels ), ": " )
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