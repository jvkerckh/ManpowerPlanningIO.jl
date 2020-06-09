function generateInitialPopPlot( report::DataFrame, showPlot::Bool,
    savePlot::Bool, filename::String )

    plotTitle = "Initial population composition plot"
    initSize = sum( report[:, 2] )
    hoverValues = string.( report[:, 1], ": ", report[:, 2], " (",
        round.( 100.0 * report[:, 2] / initSize, digits=2 ), "%)" )
    plt = pie( report[:, 1], report[:, 2], show=false, size=(960,540),
        title=plotTitle, hover=hoverValues )

    # Show plot if needed.
    if showPlot
        gui( plt )
    end  # if showPlot

    # Save plot if needed.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            filename = string( "Initial population composition plot  ",
                dateStr )
        end  # if filename == ""

        if !ispath( dirname( filename ) )
            mkpath( dirname( filename ) )
        end  # if !ispath( dirname( filename ) )

        extension = split( filename, "." )
        extension = length( extension ) == 1 ? "" : extension[end]
        filename = string( filename, extension ∈ extensions ? "" : ".svg" )
        savefig( plt, filename )
    end  # if savePlot

end  # generateInitialPopPlot( report, showPlot, savePlot, filename )


function generateInitialPopAgePlot( report::DataFrame, timeFactor::Float64, showPlot::Bool, savePlot::Bool, filename::String )

    # Generate the plot.
    plotTitle = string( "Initial population ", names( report )[1], " plot" )
    ages = report[1:(end-5), 1] / timeFactor

    if length( ages ) > 1
        ages .+= ( ages[2] - ages[1] ) / 2
    end  # if length( ages ) > 1

    plotData = report[1:(end-5), 2]
    ymax = max( maximum( plotData ), 20 )

    plt = bar( ages, plotData, show=false, size=(960, 540), title=plotTitle,
        bar_width=length( ages ) == 1 ? .5 : ages[2] - ages[1], labels=nothing,
        ylim=[0, ymax], fa=0.5 )
    plt = vline!( [report[(end-4), 2] / timeFactor], labels="mean", lw=2,
        ls=:dash )
    plt = vline!( [report[(end-3), 2] / timeFactor], labels="median", lw=2,
        ls=:dash )

    # Show plot if needed.
    if showPlot
        gui( plt )
    end  # if showPlot

    # Save plot if needed.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            filename = string( "Initial population ", names( report )[1],
                " plot  ", dateStr )
        end  # if filename == ""

        if !ispath( dirname( filename ) )
            mkpath( dirname( filename ) )
        end  # if !ispath( dirname( filename ) )

        extension = split( filename, "." )
        extension = length( extension ) == 1 ? "" : extension[end]
        filename = string( filename, extension ∈ extensions ? "" : ".svg" )
        savefig( plt, filename )
    end  # if savePlot

end  # generateInitialPopAgePlot( report, timeFactor, showPlot, savePlot,
     #   filename )