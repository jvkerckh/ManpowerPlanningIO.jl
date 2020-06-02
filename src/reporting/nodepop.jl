export  excelPopReport,
        excelPopEvolutionReport


function excelPopReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "popReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    popReport = nodePopReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( popReport )
        return
    end  # if isempty( popReport )

    writeNodePopData( popReport, mpSim, timeFactor, reportGenerationTime,
        filename, overwrite )

end  # excelPopReport( mpSim, timeGrid, nodes, filename, overwrite, timeFactor )

excelPopReport( mpSim::MPsim, timeRes::Real, nodes::AbstractString...;
    filename::AbstractString = "popReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) =
    excelPopReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...;
    filename = filename, overwrite = overwrite, timeFactor = timeFactor )


function excelPopEvolutionReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "popReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    popReport = nodeEvolutionReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( popReport[1] )
        return
    end  # if isempty( popReport[1] )

    writeNodeEvolutionData( popReport, mpSim, timeFactor, reportGenerationTime,
        filename, overwrite )

end  # excelPopEvolutionReport( mpSim, timeGrid, nodes, filename, overwrite,
     #   timeFactor )

excelPopEvolutionReport( mpSim::MPsim, timeRes::Real, nodes::AbstractString...;
    filename::AbstractString = "popReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) =
    excelPopEvolutionReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )


include( "private/nodepop.jl" )