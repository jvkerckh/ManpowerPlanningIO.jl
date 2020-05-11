function generateCompPlot( compReport::Dict{String,DataFrame}, nodes::NTuple{N,String}, timeFactor::Float64, showPlot::Bool, savePlot::Bool, fileroot::String, extension::String, plotFunction::Function ) where N

    # Generate plots.
    for node in unique( nodes )
        if !haskey( compReport, node )
            continue
        end  # if !haskey( compReport, node )

        plotfilename = string( fileroot, " ", node, ".", extension )
        plt = plotFunction( compReport[node], string( node ), timeFactor )

        # Show plot if needed.
        if showPlot
            gui( plt )
        end  # if showPlot

        # Save plot if needed.
        if savePlot
            savefig( plt, plotfilename )
        end  # if savePlot
    end  # for node in unique( nodes )
    
end  # generateCompPlot( compReport, nodes, timeFactor, showPlot, savePlot, fileroot, extension, plotFunction )


function normalCompPlot( compReport::DataFrame, node::String,
    timeFactor::Float64 )

    timePoints = compReport[:, :timePoint]
    labels = vcat( "Node total", string.( names( compReport )[3:end] ) )
    plotTitle = string( "Composition of node ", node )
    timePoints = compReport[:, :timePoint] / timeFactor
    dataPoints = Matrix( compReport[:, 2:end] )
    ymax = max( maximum( dataPoints[:, 1] ), 20 )

    plt = plot( timePoints, dataPoints[:, 1], size=(960, 540), title=plotTitle,
        label=labels[1], lw=3, color=:black, ylim=[0, ymax] )
    plot!( plt, timePoints, dataPoints[:, 2:end],
        label=hcat( labels[2:end]... ), lw=2 )
    
    return plt

end  # normalCompPlot( compReport, node, timeFactor )


function stackedCompPlot( compReport::DataFrame, node::String,
    timeFactor::Float64 )

    timePoints = compReport[:, :timePoint]
    labels = names( compReport )[3:end]
    plotTitle = string( "Composition of node ", node )
    timePoints = compReport[:, :timePoint] / timeFactor
    dataPoints = Matrix( compReport[:, 3:end] )
    nPoints, nSeries = size( dataPoints )
    dataPoints = hcat( fill( 0, nPoints ), cumsum( dataPoints, dims=2 ) )
    ymax = max( maximum( dataPoints[:, 1] ), 20 )

    plt = plot( size=(960,540), title=plotTitle, ylim=[0, ymax] )

    for ii in 1:nSeries
        plot!( plt, timePoints, dataPoints[:, ii + 1], lw=2, lalpha=1.0, fillto=dataPoints[:, ii], falpha=0.5, label=labels[ii] )
    end  # for ii in 1:nSeries

    return plt

end  # stackedCompPlot( compReport, node, timeFactor )