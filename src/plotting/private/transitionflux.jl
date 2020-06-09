function generateTransFluxPlot( fluxReport::DataFrame, timeFactor::Float64, showPlot::Bool, savePlot::Bool, filename::String )

    # Generate the plot.
    plotTitle = string( "Flux plot of transitions" )
    plotData = Matrix( fluxReport[:, 3:end] )
    labels = hcat( string.( names( fluxReport )[3:end] )... )
    ymax = max( maximum( plotData ), 20 )

    plt = plot( fluxReport[:, :timePoint] / timeFactor, plotData, show=false,
        size=(960, 540), title=plotTitle, label=labels, lw=2, ylim=[0, ymax] )

    # Show plot if needed.
    if showPlot
        gui( plt )
    end  # if showPlot

    # Save plot if needed.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            filename = string( "Transition flux plot  ", dateStr )
        end  # if filename == ""

        if !ispath( dirname( filename ) )
            mkpath( dirname( filename ) )
        end  # if !ispath( dirname( filename ) )

        extension = split( filename, "." )
        extension = length( extension ) == 1 ? "" : extension[end]
        filename = string( filename, extension ∈ extensions ? "" : ".svg" )
        savefig( plt, filename )
    end  # if savePlot
    
end  # generateTransFluxPlot( fluxReport, timeFactor, showPlot, savePlot,
     #   filename )