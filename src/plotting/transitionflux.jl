export  transFluxPlot


function transFluxPlot( mpSim::MPsim, timeGrid::Vector{T},
    transitions::MP.TransitionType...; showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    fluxReport = transitionFluxReport( mpSim, timeGrid, transitions... )

    if isempty( fluxReport )
        return
    end  # if isempty( fluxReport )

    # Generate the plot.
    plotTitle = string( "Flux plot of transitions" )
    plotData = Matrix( fluxReport[:, 3:end] )
    labels = hcat( string.( names( fluxReport )[3:end] )... )
    ymax = maximum( plotData )

    plt = plot( fluxReport[:, :timePoint] / timeFactor, plotData,
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

end  # transFluxPlot( mpSim, timeGrid, transitions, showPlot, savePlot,
     #   filename, timeFactor )

transFluxPlot( mpSim::MPsim, timeRes::Real,
    transitions::MP.TransitionType...; showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) =
    transFluxPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    transitions..., showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )