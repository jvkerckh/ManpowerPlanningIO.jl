function writeTransFluxData( fluxReport::DataFrame, mpSim::MPsim,
    timeFactor::Float64, reportGenerationTime::Float64, filename::String,
    overwrite::Bool )

    tStart = now()
    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

    XLSX.openxlsx( filename, mode = overwrite ? "w" : "rw" ) do xf
        dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
        ws = xf[1]

        # Prep the new sheet.
        if overwrite
            XLSX.rename!( ws, string( "Report 1  ", dateStr ) )
        else
            nSheets = XLSX.sheetcount( xf ) + 1
            ws = XLSX.addsheet!( xf, string( "Report ", nSheets, "  ",
                dateStr ) )
        end  # if overwrite

        # Sheet header
        ws["A1"] = "Simulation length"
        ws["B1"] = mpSim.simLength / timeFactor
        ws["C1"] = "years"
        ws["A2"] = "Data generation time"
        ws["B2"] = reportGenerationTime
        ws["C2"] = "seconds"
        ws["A3"] = "Excel generation time"
        ws["C3"] = "seconds"

        fluxReport[:, :timeStart] /= timeFactor
        fluxReport[:, :timePoint] /= timeFactor
        nrows, ncols = size( fluxReport )
        ii = 0

        for name in names( fluxReport )
            ii += 1
            ws[5, ii] = ii == 1 ? "Period start" : name # string( name )

            for jj in 1:nrows
                ws[5 + jj, ii] = fluxReport[jj, name]
            end  # for jj in 1:nrows
        end  # for name in names( fluxReport )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws["B3"] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # writeTransFluxData( fluxReport, mpSim, timeFactor, reportGenerationTime,
     #   filename, overwrite )