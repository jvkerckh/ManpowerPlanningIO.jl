function generatePopPlot( popReport::DataFrame, timeFactor::Float64,
    showPlot::Bool, savePlot::Bool, filename::String )

    # Generate the plot.
    plotTitle = string( "Node population plot" )
    plotData = Matrix( popReport[:, 2:end] )
    labels = hcat( string.( names( popReport )[2:end] )... )
    ymax = max( maximum( plotData ), 20 )

    plt = plot( popReport[:, :timePoint] / timeFactor, plotData,
        size=(960, 540), title=plotTitle, labels=labels, lw=2, ylim=[0, ymax] )

    # Show plot if needed.
    if showPlot
        gui( plt )
    end  # if showPlot
    
    # Save plot if needed.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            filename = string( "Node population plot  ", dateStr )
        end  # if filename == ""

        if !ispath( dirname( filename ) )
            mkpath( dirname( filename ) )
        end  # if !ispath( dirname( filename ) )

        extension = split( filename, "." )
        extension = length( extension ) == 1 ? "" : extension[end]
        filename = string( filename, extension ∈ extensions ? "" : ".svg" )
        savefig( plt, filename )
    end  # if savePlot

end  # generatePopPlot( popReport, timeFactor, showPlot, savePlot, filename )


function generateEvolutionPlot( popReport::DataFrame, mpSim::MPsim,
    fluxReports::Dict{String,Tuple}, nodes::NTuple{N,String},
    timeFactor::Float64, showPlot::Bool, savePlot::Bool, fileroot::String,
    extension::String, plotFunction::Function, plotFunction2::Function ) where N

    timePoints = popReport[:, :timePoint] / timeFactor

    # Generate plots.
    for node in unique( nodes )
        if !haskey( fluxReports, node )
            continue
        end  # if !haskey( fluxReports, node )

        plotfilename = string( fileroot, " ", node, ".", extension )
        fluxReport = fluxReports[node]

        # Data of overview plot.
        pop = popReport[:, Symbol( node )]
        inFlux = fluxReport[1][:, 3]
        outFlux = fluxReport[2][:, 3]
        netFlux = inFlux - outFlux
        plotData = hcat( pop, inFlux, outFlux, netFlux )
        ymin = minimum( vcat( 0, netFlux ) )
        ymax = maximum( pop )
        ymax = ymax - 20 < ymin ? ymin + 20 : ymax

        # Plots.
        plotTitle = string( "Node population plot" )
        popPlot = plot( timePoints, plotData, title=plotTitle,
            labels=["population" "in flux" "out flux" "net flux"],
            color=[:black :green :red :blue], lw=2,
            ylim=[ymin, ymax] )
        inFluxPlot = plotFunction( fluxReport[1], string( node ), :in,
            timeFactor )
        outFluxPlot = plotFunction( fluxReport[2], string( node ), :out,
            timeFactor )
        
        if haskey( mpSim.compoundNodeList, node )
            withinFluxPlot = plotFunction( fluxReport[3], string( node ),
                :within, timeFactor )
            compPlot = plotFunction2( fluxReport[4], string( node ),
                timeFactor )

            layout = @layout [
                grid( 1, 2 ){0.5625h}
                grid( 1, 3 )
            ]
            plt = plot( popPlot, compPlot, inFluxPlot, outFluxPlot,
                withinFluxPlot, size=(1440, 960), layout=layout )
        else
            layout = @layout [
                a{0.5625h}
                grid( 1, 2 )
            ]
            plt = plot( popPlot, inFluxPlot, outFluxPlot, size=(960, 960),
                layout=layout )
        end  # if haskey( mpSim.compoundNodeList, node )

        # Show plot if needed.
        if showPlot
            gui( plt )
        end  # if showPlot

        # Save plot if needed.
        if savePlot
            savefig( plt, plotfilename )
        end  # if savePlot
    end  # for node in unique( nodes )

end  # generateEvolutionPlot( popReport, mpSim, fluxReports, nodes, timeFactor,
     #   showPlot, savePlot, fileroot, extension, plotFunction, plotFunction2 )