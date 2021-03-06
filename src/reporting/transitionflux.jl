export  excelFluxReport


function excelFluxReport( mpSim::MPsim, timeGrid::Vector{T},
    transitions::MP.TransitionType...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    fluxReport = transitionFluxReport( mpSim, timeGrid, transitions... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( fluxReport )
        return
    end  # if isempty( fluxReport )

    writeTransFluxData( fluxReport, mpSim, timeFactor, reportGenerationTime,
        filename, overwrite )

end  # excelFluxReport( mpSim, timeGrid, transitions, filename, overwrite, timeFactor )

excelFluxReport( mpSim::MPsim, timeRes::Real,
    transitions::MP.TransitionType...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelFluxReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    transitions...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )


include( "private/transitionflux.jl" )