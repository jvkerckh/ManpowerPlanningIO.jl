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

    generateTransFluxPlot( fluxReport, timeFactor, showPlot, savePlot,
        filename )

end  # transFluxPlot( mpSim, timeGrid, transitions, showPlot, savePlot,
     #   filename, timeFactor )

transFluxPlot( mpSim::MPsim, timeRes::Real,
    transitions::MP.TransitionType...; showPlot::Bool=true,
    savePlot::Bool=false, filename::AbstractString="",
    timeFactor::Real=12.0 ) =
    transFluxPlot( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    transitions..., showPlot=showPlot, savePlot=savePlot,
    filename=filename, timeFactor=timeFactor )


include( "private/transitionflux.jl" )