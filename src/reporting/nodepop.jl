export  excelPopReport,
        excelPopEvolutionReport


function excelPopReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "popReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    tStart = now()
    popReport = nodePopReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( popReport )
        return
    end  # if isempty( popReport )

    tStart = now()

    XLSX.openxlsx( filename, mode = overwrite ? "w" : "rw" ) do xf
        dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
        ws = xf[1]
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
        ws["A1"] = "Simulation length"
        ws["B1"] = mpSim.simLength / timeFactor
        ws["C1"] = "years"
        ws["A2"] = "Data generation time"
        ws["B2"] = reportGenerationTime
        ws["C2"] = "seconds"
        ws["A3"] = "Excel generation time"
        ws["C3"] = "seconds"

        popReport[:, :timePoint] /= timeFactor
        nrows, ncols = size( popReport )
        ii = 0
        
        for name in names( popReport )
            ii += 1
            ws[5, ii] = string( name )

            for jj in 1:nrows
                ws[jj + 5, ii] = popReport[jj, ii]
            end  # for jj in 1:nrows
        end  # for ii in 1:ncols

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws["B3"] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelPopReport( mpSim, timeGrid, nodes, filename, overwrite, timeFactor )

excelPopReport( mpSim::MPsim, timeRes::Real, nodes::AbstractString...;
    filename::AbstractString = "popReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) =
    excelPopReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ), nodes...;
    filename = filename, overwrite = overwrite, timeFactor = timeFactor )


function excelPopEvolutionReport( mpSim::MPsim, timeGrid::Vector{T},
    nodes::AbstractString...; filename::AbstractString = "popReport",
    overwrite::Bool = true, timeFactor::Real = 12.0 ) where T <: Real

    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    tStart = now()
    popReport = nodeEvolutionReport( mpSim, timeGrid, nodes... )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( popReport[1] )
        return
    end  # if isempty( popReport[1] )

    tStart = now()

    XLSX.openxlsx( filename, mode = overwrite ? "w" : "rw" ) do xf
        dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
        ws = xf[1]
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
        ws["A1"] = "Simulation length"
        ws["B1"] = mpSim.simLength / timeFactor
        ws["C1"] = "years"
        ws["A2"] = "Data generation time"
        ws["B2"] = reportGenerationTime
        ws["C2"] = "seconds"
        ws["A3"] = "Excel generation time"
        ws["C3"] = "seconds"

        report = popReport[1]
        report[:, :timePoint] /= timeFactor
        fluxReports = popReport[2]
        nrows, ncols = size( report )
        ii = 0
        
        for name in string.( names( report ) )
            ii += 1
            ws[5, ii] = ii == 1 ? "Time point" : name

            for jj in 1:nrows
                ws[jj + 5, ii] = report[jj, ii]
            end  # for jj in 1:nrows

            if ii > 1
                rws = XLSX.addsheet!( xf,
                    string( name, " flux  Report ", nReports ) )
                fluxReport = fluxReports[name]
                fluxReport[1][:, :timeStart] /= timeFactor
                fluxReport[1][:, :timePoint] /= timeFactor
                ncols = size( fluxReport[1], 2 )
                jj = 1

                # In flux breakdown.
                for name in names( fluxReport[1] )
                    rws[1, jj] = jj == 1 ? "Period start" :
                        ( jj == 2 ? "Period end" : string( name ) )

                    for kk in 1:nrows
                        rws[kk + 1, jj] = fluxReport[1][kk, name]
                    end  # for kk in 1:nrows

                    jj += 1
                end  # for jj in 1:ncols

                jj += 1

                # Out flux breakdown.
                for name in names( fluxReport[2] )[3:end]
                    rws[1, jj] = string( name )

                    for kk in 1:nrows
                        rws[kk + 1, jj] = fluxReport[2][kk, name]
                    end  # for kk in 1:nrows

                    jj += 1
                end  # for name in names( fluxReport[2] )[3:end]

                if !haskey( mpSim.compoundNodeList, name )
                    continue
                end  # if !haskey( mpSim.compoundNodeList, name )

                jj += 1

                # Within flux breakdown.
                for name in names( fluxReport[3] )[3:end]
                    jj += 1
                    rws[1, jj] = string( name )

                    for kk in 1:nrows
                        rws[kk + 1, jj] = fluxReport[3][kk, name]
                    end  # for kk in 1:nrows
                end  # for name in names( fluxReport[3] )[3:end]
                
                # Node composition report.
                rws = XLSX.addsheet!( xf,
                    string( name, " composition  Report ", nReports ) )
                compReport = fluxReport[4]
                compReport[:, :timePoint] /= timeFactor
                ncols = size( fluxReport[1], 2 )

                jj = 1

                for name in names( compReport )
                    rws[1, jj] = jj == 1 ? "Time point" : string( name )

                    for kk in 1:nrows
                        rws[kk + 1, jj] = compReport[kk, name]
                    end  # for kk in 1:nrows

                    jj += 1
                end  # for jj in 1:ncols
            end  # if ii > 1
        end  # for ii in 1:ncols

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws["B3"] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # excelPopEvolutionReport( mpSim, timeGrid, nodes, filename, overwrite,
     #   timeFactor )

excelPopEvolutionReport( mpSim::MPsim, timeRes::Real, nodes::AbstractString...;
    filename::AbstractString = "popReport", overwrite::Bool = true,
    timeFactor::Real = 12.0 ) =
    excelPopEvolutionReport( mpSim, MP.generateTimeGrid( mpSim, timeRes ),
    nodes...; filename = filename, overwrite = overwrite,
    timeFactor = timeFactor )