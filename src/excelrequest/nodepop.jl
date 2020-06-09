export  excelPopPlot


function excelPopPlot( mpSim::MPsim, filename::AbstractString,
    sheetname::AbstractString="Node population plots" )

    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

    if !ispath( filename )
        @warn string( "File '", filename,
            "' not found. Can't generate plots/reports." )
        return
    end  # if !ispath( filename )

    plotsToMake = Dict{Tuple, Vector{String}}()

    XLSX.openxlsx( filename ) do xf
        if !XLSX.hassheet( xf, sheetname )
            @warn string( "Sheet '", sheetname,
                "' not found in file. Can't generate plots/reports." )
            return
        end  # if !XLSX.hassheet( xf, sheetname )

        xs = xf[sheetname]
        nToProcess = xs["B4"]

        for ii in (1:nToProcess) .+ 6
            # The name of the node to plot.
            node = xs[ii, 1]
            node = node isa Missing ? "active" : node

            # The time resolution.
            timeRes = xs[ii, 2]

            if !( timeRes isa Real ) || ( timeRes <= 0 )
                continue
            end  # if !( timeRes isa Real ) || ...

            # The type of the flux plots.
            fluxType = lowercase( string( xs[ii, 3] ) )
            fluxType = fluxType == "line" ? :normal :
                ( fluxType == "stacked" ? :stacked : :none )
            
            # The type of the composition plots.
            compType = :none

            if haskey( mpSim.compoundNodeList, node )
                if fluxType === :none
                    compType = lowercase( string( xs[ii, 4] ) )
                    compType = compType == "line" ? :normal :
                        ( compType == "stacked" ? :stacked : :none )
                    else
                    compType = fluxType
                end  # if fluxType === :none
            end  # if haskey( mpSim.compoundNodeList, node )

            # Show plot in browser.
            showPlot = lowercase( string( xs[ii, 5] ) ) == "yes"

            # Save plot.
            savePlot = lowercase( string( xs[ii, 6] ) ) == "yes"

            # Generate report.
            makeReport = lowercase( string( xs[ii, 7] ) ) == "yes"

            plotkey = (timeRes, fluxType, compType, showPlot, savePlot,
                makeReport)

            if haskey( plotsToMake, plotkey )
                push!( plotsToMake[plotkey], node )
            else
                plotsToMake[plotkey] = [node]
            end  # if haskey( plotsToMake, plotkey )
        end  # for ii in 1:nToProcess
    end  # XLSX.openxlsx( filename ) do xf
        
    plotdir = filename[1:(end-5)]

    if !ispath( plotdir )
        mkpath( plotdir )
    end  # if !ispath( plotdir )

    dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
    isFirst = true
    reportname = string( plotdir, "/node report ", dateStr )

    for plotkey in keys( plotsToMake )
        if !any( [plotkey[4], plotkey[5], plotkey[6]] )
            continue
        end  # if !any( [plotkey[4], plotkey[5], plotkey[6]] )

        dateStr = string( " (", Dates.format( now(), "yyyymmdd HHMMSS" ), ";",
            plotkey[1], ")" )
        makePlot = plotkey[4] || plotkey[5]
        makeReport = plotkey[6]

        if plotkey[2] === :none
            # Generate the report.
            tStart = now()
            popReport = nodePopReport( mpSim, plotkey[1],
                plotsToMake[plotkey]... )
            reportGenerationTime = ( now() - tStart ).value / 1000.0

            if isempty( popReport )
                continue
            end  # if isempty( popReport )

            plotname = string( plotdir, "/node population", dateStr )

            if makePlot
                generatePopPlot( popReport, 12.0, plotkey[4], plotkey[5],
                    plotname )
            end  # makePlot

            if makeReport
                writeNodePopData( popReport, mpSim, 12.0, reportGenerationTime,
                    reportname, isFirst )
                isFirst = false
            end  # if makeReport
            
            if plotkey[3] !== :none
                nodes = filter( node -> haskey( mpSim.compoundNodeList, node ),
                    plotsToMake[plotkey] )

                # Generate the report.
                tStart = now()
                compReport = nodeCompositionReport( mpSim, plotkey[1],
                    nodes... )
                reportGenerationTime = ( now() - tStart ).value / 1000.0

                if isempty( compReport )
                    continue
                end  # if isempty( compReport )

                plotFunction = plotTypes[plotkey[3]][2]
                plotname = string( plotdir, "/node composition", dateStr,
                    ".svg" )

                if makePlot
                    generateCompPlot( compReport, nodes, 12.0, plotkey[4],
                        plotkey[5], plotname, plotFunction )
                end  # if makePlot

                if makeReport
                    writeNodeCompositionData( compReport, nodes, mpSim, 12.0,
                        reportGenerationTime, reportname, false )
                end  # if makeReport
            end  # if plotkey[3] !== :none
        else
            # Generate the report.
            tStart = now()
            popReport, fluxReports = nodeEvolutionReport( mpSim, plotkey[1],
                plotsToMake[plotkey]... )
            reportGenerationTime = ( now() - tStart ).value / 1000.0

            if isempty( popReport ) || isempty( fluxReports )
                return
            end  # if isempty( popReport ) || ...

            plotFunction = plotTypes[plotkey[2]][1]
            plotFunction2 = plotTypes[plotkey[2]][2]
            plotname = string( plotdir, "/node evolution", dateStr, ".svg" )

            if makePlot
                generateEvolutionPlot( popReport, mpSim, fluxReports,
                    Tuple( plotsToMake[plotkey] ), 12.0, plotkey[4], plotkey[5],
                    plotname, plotFunction, plotFunction2 )
            end  # if makePlot

            if makeReport
                writeNodeEvolutionData( (popReport, fluxReports), mpSim, 12.0,
                    reportGenerationTime, reportname, isFirst )
                isFirst = false
            end  # if makeReport
        end  # if plotkey[2] === :none
    end  # for plotkey in keys( plotsToMake )

end  # excelPopPlot( mpSim, filename )