export  excelSubpopAgeReport


function excelSubpopAgeReport( mpSim::MPsim, timeGrid::Vector{T}, ageRes::Real,
    ageType::Symbol, subpops::Subpopulation...;
    filename::AbstractString = "compReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) where T <: Real

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    ageReport = subpopulationAgeReport( mpSim, timeGrid, ageRes, ageType,
        subpops... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( ageReport ) || all( subpop -> isempty( ageReport[ subpop ] ),
        collect( keys( ageReport ) ) )
        return
    end  # if isempty( ageReport ) || ...

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
        ws[ "A4" ] = "Subpopulations"

        subpopNames = getfield.( vcat( subpops... ), :name )
        ii = 3

        for subpop in filter( subpop -> haskey( ageReport, subpop ),
            subpopNames )
            report = ageReport[ subpop ]

            if isempty( report )
                continue
            end  # if isempty( report )

            ii += 1
            ws[ ii, 2 ] = subpop

            rws = XLSX.addsheet!( xf,
                string( subpop, " ages  Report ", nReports ) )
            nrows, ncols = size( report )
            jj = 0

            for name in names( report )
                jj += 1
                val = tryparse( Float64, string( name ) )
                rws[ 1, jj ] = val isa Float64 ? val / timeFactor :
                    string( name )

                for kk in 1:nrows
                    rws[ kk + 1, jj ] = report[ kk, name ] /
                        ( val isa Float64 ? 1.0 : timeFactor )
                end  # for kk in 1:nrows
            end
        end  # for subpop in filter( ... )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws[ "B3" ] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelSubpopAgeReport( mpSim, timeGrid, ageRes, ageType, nodes, filename,
     #   overwrite, timeFactor )

excelSubpopAgeReport( mpSim::MPsim, timeRes::Real, ageRes::Real,
    ageType::Symbol, subpops::Subpopulation...;
    filename::AbstractString = "compReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) =
    excelSubpopAgeReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ), ageRes,
    ageType, subpops...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )