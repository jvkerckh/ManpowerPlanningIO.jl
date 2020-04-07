export  excelFluxReport


function excelFluxReport( mpSim::MPsim, timeGrid::Vector{T}, transitions::MP.TransitionType...; filename::AbstractString = "fluxReport", overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    tStart = now()
    fluxReport = transitionFluxReport( mpSim, timeGrid, transitions... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( fluxReport )
        return
    end  # if isempty( fluxReport )

    tStart = now()

    XLSX.openxlsx( filename, mode = overwrite ? "w" : "rw" ) do xf
        dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
        ws = xf[ 1 ]

        # Prep the new sheet.
        if overwrite
            XLSX.rename!( ws, string( "Report 1  ", dateStr ) )
        else
            nSheets = XLSX.sheetcount( xf ) + 1
            ws = XLSX.addsheet!( xf, string( "Report ", nSheets, "  ",
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

        fluxReport[ :, :timeStart ] /= timeFactor
        fluxReport[ :, :timePoint ] /= timeFactor
        nrows, ncols = size( fluxReport )
        ii = 0

        for name in names( fluxReport )
            ii += 1
            ws[ 5, ii ] = ii == 1 ? "Period start" : string( names )

            for jj in 1:ncols
                ws[ 5 + jj, ii ] = fluxReport[ jj, name ]
            end  # for jj in 1:ncols
        end  # for name in names( fluxReport )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws[ "B3" ] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelFluxReport( mpSim, timeGrid, transitions, filename, overwrite, timeFactor )

excelFluxReport( mpSim::MPsim, timeRes::Real,
    transitions::MP.TransitionType...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelFluxReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    transitions...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )