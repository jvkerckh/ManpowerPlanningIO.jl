export  excelSubpopReport


function excelSubpopReport( mpSim::MPsim, timeGrid::Vector{T},
    subpops::Subpopulation...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    subpopReport = subpopulationPopReport( mpSim, timeGrid, subpops... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( subpopReport )
        return
    end  # if isempty( subpopReport )

    tStart = now()

    XLSX.openxlsx( filename, mode = overwrite ? "w" : "rw" ) do xf
        dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
        ws = xf[ 1 ]
        nReports = 1

        # Prep the new sheet.
        if overwrite
            XLSX.rename!( ws, string( "Report 1  ", dateStr ) )
        else
            nReports = length( filter( name -> startswith( name, "Report" ),
                XLSX.sheetnames( xf ) ) ) + 1
            ws = XLSX.addsheet!( xf, string( "Report ", nReports, "  ",
                dateStr ) )
        end  # if overwrite

        # Sheet header
        ws[ "A1" ] = "Simulation length"
        ws[ "B1" ] = mpSim.simLength / timeFactor
        ws[ "C1" ] = "years"
        ws[ "A2" ] = "Data generation time"
        ws[ "B2" ] = reportGenerationTime
        ws[ "C2" ] = "seconds"
        ws[ "A3" ] = "Excel generation time"
        ws[ "C3" ] = "seconds"

        subpopReport[ :, :timePoint ] /= timeFactor
        nrows, ncols = size( subpopReport )
        ii = 0
        
        for name in names( subpopReport )
            ii += 1
            ws[ 5, ii ] = string( name )

            for jj in 1:nrows
                ws[ jj + 5, ii ] = subpopReport[ jj, ii ]
            end  # for jj in 1:nrows
        end  # for ii in 1:ncols

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws[ "B3" ] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelSubpopReport( mpSim, timeGrid, nodes, filename, overwrite,
     #   timeFactor )

excelSubpopReport( mpSim::MPsim, timeRes::Real,
    subpops::Subpopulation...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelSubpopReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    subpops...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )