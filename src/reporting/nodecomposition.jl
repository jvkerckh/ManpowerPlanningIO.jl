export  excelNodeCompositionReport


function excelNodeCompositionReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    compReport = nodeCompositionReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( compReport )
        return
    end  # if isempty( compReport )

    writeNodeCompositionData( compReport, nodes, mpSim, timeFactor,
        reportGenerationTime, filename, overwrite )

end  # excelNodeCompositionReport( mpSim, timeGrid, nodes, filename, overwrite,
     #   timeFactor )

excelNodeCompositionReport( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelNodeCompositionReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )


include( "private/nodecomposition.jl" )