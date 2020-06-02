export  excelInitPopPlot


function excelInitPopPlot( mpSim::MPsim, filename::AbstractString,
    sheetname::AbstractString="Initial population plots" )

    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

    if !ispath( filename )
        @warn string( "File '", filename,
            "' not found. Can't generate plots/reports." )
        return
    end  # if !ispath( filename )

    makeCompositionPlot = nothing
    plotsToMake = Vector{Tuple}()

    XLSX.openxlsx( filename ) do xf
        if !XLSX.hassheet( xf, sheetname )
            @warn string( "Sheet '", sheetname,
                "' not found in file. Can't generate plots/reports." )
            return
        end  # if !XLSX.hassheet( xf, sheetname )

        xs = xf[sheetname]
        makeCompositionPlot = lowercase.( xs[CR( 5, 2, 7, 2 )][:] ) .== "yes"

        nToProcess = xs["B12"]

        for ii in (1:nToProcess) .+ 14
            # The age resolution and type of the plot.
            timeRes = xs[ii, 1]
            ageType = lowercase( string( xs[ii, 2] ) )

            if !( timeRes isa Real ) || ( timeRes <= 0 ) ||
                !haskey( ageTypes, ageType )
                continue
            end  # if !( timeRes isa Real ) || ...

            # Show plot in browser.
            showPlot = lowercase( string( xs[ii, 3] ) ) == "yes"

            # Save plot.
            savePlot = lowercase( string( xs[ii, 4] ) ) == "yes"

            # Generate report.
            makeReport = lowercase( string( xs[ii, 5] ) ) == "yes"

            push!( plotsToMake,
                (timeRes, ageTypes[ageType], showPlot, savePlot, makeReport) )
        end  # for ii in 1:nToProcess
    end  # XLSX.openxlsx( filename ) do xf

    plotdir = filename[1:(end-5)]

    if !ispath( plotdir )
        mkpath( plotdir )
    end  # if !ispath( plotdir )

    dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
    isFirst = true
    reportname = string( plotdir, "/initial population report ", dateStr )
    
    if any( makeCompositionPlot )
        tStart = now()
        report = initPopReport( mpSim )
        reportGenerationTime = ( now() - tStart ).value / 1000.0

        if !isempty( report )
            makePlot = any( makeCompositionPlot[1:2] )
            makeReport = makeCompositionPlot[3]

            if makePlot
                plotname = string( plotdir, "/initial population (", dateStr,
                    ")" )
                generateInitialPopPlot( report, makeCompositionPlot[1],
                    makeCompositionPlot[2], plotname )
            end  # makePlot

            if makeReport
                writeInitialPopData( report, mpSim, 12.0, reportGenerationTime,
                    reportname, isFirst )
                isFirst = false
            end  # if makeReport
        end  # if !isempty( report )
    end  # if any( makeCompositionPlot )

    for plotkey in plotsToMake
        if !any( [plotkey[3], plotkey[4], plotkey[5]] )
            continue
        end  # if !any( [plotkey[3], plotkey[4], plotkey[5]] )

        tStart = now()
        report = initPopAgeReport( mpSim, plotkey[1], plotkey[2] )
        reportGenerationTime = ( now() - tStart ).value / 1000.0

        if isempty( report )
            continue
        end  # if isempty( report )

        dateStr = string( " (", Dates.format( now(), "yyyymmdd HHMMSS" ), ")" )
        makePlot = plotkey[3] || plotkey[4]
        makeReport = plotkey[5]

        if makePlot
            plotname = string( plotdir, "/initial population ",
                ageTypesS[plotkey[2]], dateStr )
            generateInitialPopAgePlot( report, 12.0, plotkey[3], plotkey[4],
                plotname )
        end  # if makePlot
        
        if makeReport
            writeInitialPopAgeData( report, mpSim, plotkey[2], 12.0,
                reportGenerationTime, reportname, isFirst )
            isFirst = false
        end  # if makeReport
    end  # for plotkey in plotsToMake

end  # excelInitPopPlot( mpSim, filename, sheetname )