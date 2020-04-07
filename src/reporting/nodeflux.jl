export  excelFluxReport


function excelFluxReport( mpSim::MPsim, timeGrid::Vector{T}, fluxType::Symbol,
    nodes::AbstractString...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    tStart = now()
    fluxReport = nodeFluxReport( mpSim, timeGrid, fluxType, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( fluxReport ) || all( node -> isempty( fluxReport[ node ] ),
        collect( keys( fluxReport ) ) )
        return
    end  # if isempty( fluxReport ) || ...

    # println( fluxReport )

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
        ws[ "A4" ] = "Flux type"
        ws[ "B4" ] = string( fluxType )
        ws[ "A5" ] = "Nodes"
        ii = 4

        for node in filter( node -> haskey( fluxReport, node ),
            vcat( nodes... ) )
            ii += 1
            ws[ ii, 2 ] = node

            rws = XLSX.addsheet!( xf, string( node, " ", fluxType, "  Report ",
                nReports ) )
            report = fluxReport[ node ]
            report[ :, :timeStart ] /= timeFactor
            report[ :, :timePoint ] /= timeFactor
            nrows, ncols = size( report )
            headers = string.( names( report ) )

            for jj in 1:ncols
                rws[ 1, jj ] = jj == 1 ? "Period start" : headers[ jj ]

                for kk in 1:nrows
                    rws[ kk + 1, jj ] = report[ kk, jj ]
                end  # for kk in 1:nrows
            end  # for jj in 1:ncols
        end  # for node in filter( ... )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws[ "B3" ] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelFluxReport( mpSim, timeGrid, fluxType, nodes, filename, overwrite,
     # timeFactor )

excelFluxReport( mpSim::MPsim, timeRes::Real, fluxType::Symbol,
    nodes::AbstractString...; filename::AbstractString = "fluxReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) =
    excelFluxReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ), fluxType,
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )