export  excelNodeCompositionReport


function excelNodeCompositionReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    tStart = now()
    compReport = nodeCompositionReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( compReport )
        return
    end  # if isempty( compReport )

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
        ws[ "A4" ] = "Nodes"
        ii = 3

        for node in filter( node -> haskey( compReport, node ),
            vcat( nodes... ) )
            ii += 1
            ws[ ii, 2 ] = node

            rws = XLSX.addsheet!( xf, string( node, "  Report ", nReports ) )
            report = compReport[ node ]
            report[ :, :timePoint ] /= timeFactor
            nrows, ncols = size( report )
            jj = 0

            for name in names( report )
                jj += 1
                rws[ 1, jj ] = string( name )

                for kk in 1:nrows
                    rws[ kk + 1, jj ] = report[ kk, name ]
                end  # for kk in 1:nrows
            end  # for name in names( report )
        end  # for node in filter( ... )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws[ "B3" ] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelNodeCompositionReport( mpSim, timeGrid, nodes, filename, overwrite,
     #   timeFactor )

excelNodeCompositionReport( mpSim::MPsim, timeRes::Real,
    nodes::AbstractString...; filename::AbstractString = "compReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelNodeCompositionReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )