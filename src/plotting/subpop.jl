export subpopPlot


function subpopPlot( mpSim::MPsim, timeGrid::Vector{T},
    subpops::Subpopulation...; showPlot::Bool=true, savePlot::Bool=false,
    filename::AbstractString="", timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    subpopReport = subpopulationPopReport( mpSim, timeGrid, subpops... )

    if isempty( subpopReport )
        return
    end  # if isempty( subpopReport )

    # Generate the plot.
    plotTitle = string( "Subpopulation plot" )
    plotData = Matrix( subpopReport[:, 2:end] )
    labels = hcat( string.( names( subpopReport )[2:end] )... )
    ymax = maximum( plotData )
    
    plt = plot( subpopReport[:, :timePoint] / timeFactor, plotData,
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
            filename = string( "Subpopulation plot  ", dateStr )
        end  # if filename == ""

        if !ispath( dirname( filename ) )
            mkpath( dirname( filename ) )
        end  # if !ispath( dirname( filename ) )

        extension = split( filename, "." )
        extension = length( extension ) == 1 ? "" : extension[end]
        filename = string( filename, extension ∈ extensions ? "" : ".svg" )
        savefig( plt, filename )
    end  # if savePlot

end  # subpopPlot( mpSim, timeGrid, subpops, showPlot, savePlot, fileName,
     #   timeFactor )

subpopPlot( mpSim::MPsim, timeRes::Real,
    subpops::Subpopulation...; breakdownType::Symbol=:none, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    subpopPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), subpops...,
    showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )