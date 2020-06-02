const ageTypes = Dict( "age" => :age, "tenure" => :tenure,
    "time in node" => :timeInNode )
const ageTypesS = Dict( :age => "age", :tenure => "tenure",
    :timeInNode => "time in current node" )


function writeInitialPopData( report::DataFrame, mpSim::MPsim,
    timeFactor::Float64, reportGenerationTime::Float64, filename::String,
    overwrite::Bool )

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
        ws["A2"] = "Data generation time"
        ws["B2"] = reportGenerationTime
        ws["C2"] = "seconds"
        ws["A3"] = "Excel generation time"
        ws["C3"] = "seconds"

        if isempty( report )
            ws["A5"] = "No initial population in simulation"
            excelGenerationTime = ( now() - tStart ).value / 1000.0
            ws["B3"] = excelGenerationTime
            return
        end  # if isempty( report )

        # Initial population report.
        ws["A5"] = "Node"
        ws["B5"] = "# in initial population"
        nNodes = size( report, 1 )

        for ii in 1:nNodes
            ws[ii + 5, 1] = report[ii, 1]
            ws[ii + 5, 2] = report[ii, 2]
        end  # for ii in 1:nNodes

        ws[nNodes + 6, 1] = "Total"
        ws[nNodes + 6, 2] = sum( report[:, 2] )

        excelGenerationTime = ( now() - tStart ).value / 1000.0
        ws["B3"] = excelGenerationTime
    end  # XLSX.openxlsx( ... ) do xf

end  # writeInitialPopData( report, mpSim, timeFactor, reportGenerationTime,
     #   filename, overwrite )


function writeInitialPopAgeData( report::DataFrame, mpSim::MPsim,
    ageType::Symbol, timeFactor::Float64, reportGenerationTime::Float64,
    filename::String, overwrite::Bool )

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

end  # writeInitialPopAgeData( report, mpSim, ageType, timeFactor,
     #   reportGenerationTime, filename, overwrite )