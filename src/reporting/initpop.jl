export  excelInitPopReport,
        excelInitPopAgeReport


function excelInitPopReport( mpSim::MPsim;
    filename::AbstractString="initPopReport", overwrite::Bool=true,
    timeFactor::Real=12.0 )

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    report = initPopReport( mpSim )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( report )
        return
    end  # if isempty( report )

    writeInitialPopData( report, mpSim, timeFactor, reportGenerationTime,
        filename, overwrite )

end   # excelInitPopReport( mpSim, filename, overwrite, timeFactor )


function excelInitPopAgeReport( mpSim::MPsim, ageRes::Real, ageType::Symbol;
    filename::AbstractString="initPopReport", overwrite::Bool=true,
    timeFactor::Real=12.0 )

    if !haskey( ageTypesS, ageType )
        return
    end  # if !haskey( ageTypesS, ageType )

    filename, overwrite = setupFile( filename, overwrite )
    tStart = now()
    report = initPopAgeReport( mpSim, ageRes, ageType )
    reportGenerationTime = ( now() - tStart ).value / 1000.0

    if isempty( report )
        return
    end  # if isempty( report )

    writeInitialPopAgeData( report, mpSim, ageType, timeFactor,
        reportGenerationTime, filename, overwrite )
    #=
    tStart = now()
    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

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

        # Sheet header.
        ws["A1"] = "Simulation length"
        ws["B1"] = mpSim.simLength / timeFactor
        ws["C1"] = "years"
        ws["A2"] = "Report on"
        ws["B2"] = ageTypesS[ageType]
        ws["A3"] = "Data generation time"
        ws["B3"] = reportGenerationTime
        ws["C3"] = "seconds"
        ws["A4"] = "Excel generation time"
        ws["C4"] = "seconds"

        if isempty( report )
            ws["A6"] = "No initial population in simulation"
            excelGenerationTime = ( now() - tStart ).value / 1000.0
            ws["B4"] = excelGenerationTime
            return
        end  # if isempty( report )
    
        ws["A5"] = "Initial population size"
        ws["B5"] = sum( report[1:(end-5), 2] )

        ws["A7"] = "Summary statistics"
        ws["A8"] = "Mean"
        ws["A9"] = "Median"
        ws["A10"] = "Std. Dev."
        ws["A11"] = "Minimum"
        ws["A12"] = "Maximum"

        for ii in 1:5
            val = report[end - (5-ii), 2]
            ws[ii + 7, 2] = val isa Missing ? "N/A" : val / timeFactor
        end  # for ii in 1:5

        ws["A14"] = "Age"
        ws["A15"] = "Amount"
        nBrackets = size( report, 1 ) - 5

        for ii in 1:nBrackets
            ws[14, ii + 1] = report[ii, 1] / timeFactor
            ws[15, ii + 1] = report[ii, 2]
        end  # for ii in 1:nBrackets

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws["B4"] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf
=#
end  # excelInitPopAgeReport( mpSim, ageRes, ageType, filename, overwrite,
     #   timeFactor )


include( "private/initpop.jl" )