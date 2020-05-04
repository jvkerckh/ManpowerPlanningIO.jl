export subpopAgePlot


function subpopAgePlot( mpSim::MPsim, timeGrid::Vector{T}, ageRes::Real,
    ageType::Symbol, subpops::Subpopulation...; showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) where T <: Real

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    ageReport = subpopulationAgeReport( mpSim, timeGrid, ageRes, ageType,
        subpops... )

    if isempty( ageReport ) || all( subpop -> isempty( ageReport[ subpop ] ),
        collect( keys( ageReport ) ) )
        return
    end  # if isempty( ageReport ) || ...

    ageTypeString = ageType === :timeInnode ? "time in current node" :
        string( ageType )

    # Get file name ready.
    if savePlot
        # If the user doesn't specify a filename, a random one is generated.
        if filename == ""
            dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
            fileroot = string( "Subpopulation ", ageTypeString, " plot (",
                dateStr, ") of " )
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
    
    # Generate the plot.
    for subpop in filter( subpop -> haskey( ageReport, subpop.name ), subpops )
        plotfilename = string( fileroot, " ", subpop.name, ".", extension )
        report = ageReport[subpop.name]

        plotTitle = string( "Subpopulation ", subpop.name, ", ", ageTypeString,
            " plot" )

        timePoints = report[:, :timePoint] / timeFactor

        # Age summary plot.
        ageSummary = report[:, 2:6]

        if all( ageSummary[:, :mean] .=== missing )
            continue
        end  # if all( ageSummary[:, :mean] .=== missing )

        ymax = maximum( filter( age -> age isa Float64, ageSummary[:, :max] ) )
        ymax /= timeFactor
        agePlt = plot( timePoints,
            Matrix( ageSummary[:, [:mean, :median]] ) / timeFactor,
            title="Summary", labels=["mean" "median"], lw=2, ylim=[0, ymax] )
        plot!( agePlt, timePoints,
            Matrix( ageSummary[:, [:min, :max]] ) / timeFactor,
            labels=nothing, lw=1, color=:black )

        # Age distribution plot.
        ageDist = report[:, 7:end]
        ageLabels = parse.( Float64, string.( names( ageDist ) ) ) / timeFactor
        ageDist = Matrix( ageDist )
        zmax = maximum( ageDist )
        ageDistPlt = surface( timePoints, ageLabels, ageDist, zlims=[0, zmax],
            camera=(30, 60) )

        plt = plot( agePlt, ageDistPlt, size=(960, 1080), title=plotTitle,
            layout=grid( 2, 1 ) )

        # Show plot if needed.
        if showPlot
            gui( plt )
        end  # if showPlot

        # Save plot if needed.
        if savePlot
            savefig( plt, plotfilename )
        end  # if savePlot
    end  # for subpop in filter( ..., subpops )

    # plotTitle = string( "Subpopulation ", ageTypeString, " plot" )
    # plotData = Matrix( ageReport[:, 2:end] )
    # labels = hcat( string.( names( ageReport )[2:end] )... )
    # ymax = maximum( plotData )
    
    # plt = plot( ageReport[:, :timePoint] / timeFactor, plotData,
    #     size=(960, 540), title=plotTitle, labels=labels, lw=2, ylim=[0, ymax] )

    # # Show plot if needed.
    # if showPlot
    #     gui( plt )
    # end  # if showPlot
    
    # # Save plot if needed.
    # if savePlot
    #     # If the user doesn't specify a filename, a random one is generated.
    #     if filename == ""
    #         dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
    #         filename = string( "Subpopulation plot  ", dateStr )
    #     end  # if filename == ""

    #     if !ispath( dirname( filename ) )
    #         mkpath( dirname( filename ) )
    #     end  # if !ispath( dirname( filename ) )

    #     extension = split( filename, "." )
    #     extension = length( extension ) == 1 ? "" : extension[end]
    #     filename = string( filename, extension ∈ extensions ? "" : ".svg" )
    #     savefig( plt, filename )
    # end  # if savePlot

end  # subpopAgePlot( mpSim, timeGrid, ageRes, ageType, subpops, showPlot,
     #   savePlot, fileName, timeFactor )

subpopAgePlot( mpSim::MPsim, timeRes::Real, ageRes::Real, ageType::Symbol,
    subpops::Subpopulation...; breakdownType::Symbol=:none, showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="", timeFactor::Real=12.0 ) =
    subpopAgePlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ), ageRes,
    ageType, subpops..., showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )