export  nodePopPlot,
        nodeEvolutionPlot


function nodePopPlot( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; showPlot::Bool=true, savePlot::Bool=false,
    filename::AbstractString="", timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    popReport = nodePopReport( mpSim, timeGrid, nodes... )

    if isempty( popReport )
        return
    end  # if isempty( popReport )

    # Generate the plot.
    plotTitle = string( "Node population plot" )
    plotData = Matrix( popReport[:, 2:end] )
    labels = hcat( string.( names( popReport )[2:end] )... )
    ymax = maximum( plotData )

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

end  # nodePopPlot( mpSim, timeGrid, nodes, breakdownType, showPlot, savePlot,
     #   filename, timeFactor )

nodePopPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; breakdownType::Symbol=:none, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodePopPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...,
    showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )


function nodeEvolutionPlot( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""
    plotType = haskey( plotTypes, plotType ) ? plotType : :normal
    plotFunction = plotTypes[plotType][1]
    plotFunction2 = plotTypes[plotType][2]

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    popReport, fluxReports = nodeEvolutionReport( mpSim, timeGrid, nodes... )

    if isempty( popReport ) || isempty( fluxReports )
        return
    end  # if isempty( popReport ) || ...

    fileroot = nothing
    extension = nothing

    # Get file name ready.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            fileroot = string( "Population evolution plot (", dateStr, ") of " )
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

        # Plots.
        plotTitle = string( "Node population plot" )
        popPlot = plot( timePoints, plotData, title=plotTitle,
            labels=["population" "in flux" "out flux" "net flux"],
            color=[:black :green :red :cyan], lw=2,
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

end  # nodeEvolutionPlot( mpSim, timeGrid, nodes, plotType, showPlot, savePlot,
     #   filename, timeFactor )

nodeEvolutionPlot( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; plotType::Symbol=:normal, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    nodeEvolutionPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...,
    plotType=plotType, showPlot=showPlot, savePlot=savePlot, filename=filename,
    timeFactor=timeFactor )
    
    
# include( "private/nodeflux.jl" )