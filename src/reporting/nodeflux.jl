export  excelFluxReport


function excelFluxReport( mpSim::MPsim, timeGrid::Vector{T}, fluxType::Symbol,
    nodes::AbstractString...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    fluxReport = nodeFluxReport( mpSim, timeGrid, fluxType, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( fluxReport ) || all( node -> isempty( fluxReport[ node ] ),
        collect( keys( fluxReport ) ) )
        return
    end  # if isempty( fluxReport ) || ...

    writeNodeFluxData( fluxReport, nodes, fluxType, mpSim, timeFactor,
        reportGenerationTime, filename, overwrite )

end  # excelFluxReport( mpSim, timeGrid, fluxType, nodes, filename, overwrite,
     # timeFactor )

excelFluxReport( mpSim::MPsim, timeRes::Real, fluxType::Symbol,
    nodes::AbstractString...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelFluxReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ), fluxType,
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )


include( "private/nodeflux.jl" )