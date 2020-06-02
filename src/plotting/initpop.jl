export  initialPopPlot,
        initialPopAgePlot


function initialPopPlot( mpSim::MPsim; showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="" )

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    report = initPopReport( mpSim )
    
    if isempty( report )
        return
    end  # if isempty( report )

    generateInitialPopPlot( report, showPlot, savePlot, filename )

end  # initialPopPlot( mpSim, showPlot, savePlot, filename )


function initialPopAgePlot( mpSim::MPsim, ageRes::Real, ageType::Symbol;
    showPlot::Bool=true, savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 )

    savePlot |= filename != ""

    # Don't do anything if the plot mustn't be shown or saved.
    if !( showPlot || savePlot )
        return
    end  # if !( showPlot || savePlot )

    # Generate the report.
    report = initPopAgeReport( mpSim, ageRes, ageType )
    
    if isempty( report )
        return
    end  # if isempty( report )

    generateInitialPopAgePlot( report, timeFactor, showPlot, savePlot,
        filename )

end  # initialPopAgePlot( mpSim, ageRes, ageType; showPlot, savePlot, filename,
     #   timeFactor )


include( "private/initpop.jl" )