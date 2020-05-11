export  excelTransPlot


function excelTransPlot( mpSim::MPsim, filename::AbstractString,
    sheetname::AbstractString="Transition flux plots" )

    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

    if !ispath( filename )
        @warn string( "File '", filename,
            "' not found. Can't generate plots/reports." )
        return
    end  # if !ispath( filename )

    plotsToMake = Dict{Tuple, Vector{MP.TransitionType}}()

    XLSX.openxlsx( filename ) do xf
        if !XLSX.hassheet( xf, sheetname )
            @warn string( "Sheet '", sheetname,
                "' not found in file. Can't generate plots/reports." )
            return
        end  # if !XLSX.hassheet( xf, sheetname )

        xs = xf[sheetname]
        nToProcess = xs["B4"]
        
        for ii in (1:nToProcess) .+ 6
            # Read transition type, if given.
            transName = xs[ii, 1]
            sourceNode, targetNode = xs[ii, 2], xs[ii, 3]
            isNamed = !( transName isa Missing )
            isTargetted = !( ( sourceNode isa Missing ) &&
                ( targetNode isa Missing ) )

            if isNamed &&
                !( haskey( mpSim.transitionsByName, string( transName ) ) ||
                haskey( mpSim.recruitmentByName, string( transName ) ) )
                continue
            end  # if isNamed && ...

            if !isNamed && !isTargetted
                continue
            end  # if !isNamed && ...

            transName = transName isa Missing ? "" : string( transName )
            sourceNode = sourceNode isa Missing ? "" : string( sourceNode )
            sourceNode = sourceNode ∈ MP.specialNodes ? "" : sourceNode
            targetNode = targetNode isa Missing ? "" : string( targetNode )
            targetNode = targetNode ∈ MP.specialNodes ? "" : targetNode

            # Check if source/target pair is valid.
            isSourceValid = haskey( mpSim.baseNodeList, sourceNode ) ||
                ( lowercase( sourceNode ) ∈ vcat( "", "active" ) )
            isTargetValid = haskey( mpSim.baseNodeList, targetNode ) ||
                ( lowercase( targetNode ) ∈ vcat( "", "active" ) )

            if !( isSourceValid && isTargetValid ) ||
                ( isTargetted && ( sourceNode == targetNode ) )
                continue
            end  # if !( isSourceValid && isTargetValid ) || ...

            # The time resolution.
            timeRes = xs[ii, 4]

            if !( timeRes isa Real ) || ( timeRes <= 0 )
                continue
            end  # if !( timeRes isa Real ) || ...
            
            # Show plot in browser.
            showPlot = lowercase( string( xs[ii, 5] ) ) == "yes"

            # Save plot.
            savePlot = lowercase( string( xs[ii, 6] ) ) == "yes"

            # Generate report.
            makeReport = lowercase( string( xs[ii, 7] ) ) == "yes"

            plotkey = (timeRes, showPlot, savePlot, makeReport)

            trans = isNamed ?
                ( isTargetted ? (transName, sourceNode, targetNode) :
                transName ) : (sourceNode, targetNode)

            if haskey( plotsToMake, plotkey )
                push!( plotsToMake[plotkey], trans )
            else
                plotsToMake[plotkey] = [trans]
            end  # if haskey( plotsToMake, plotkey )
        end  # for ii in (1:nToProcess) .+ 6
    end  # XLSX.openxlsx( filename ) do xf

    plotdir = filename[1:(end-5)]

    if !ispath( plotdir )
        mkpath( plotdir )
    end  # if !ispath( plotdir )

    dateStr = Dates.format( now(), "yyyymmdd HHMMSS" )
    isFirst = true
    reportname = string( plotdir, "/transition flux ", dateStr )

    for plotkey in keys( plotsToMake )
        if !( any( [plotkey[2], plotkey[3], plotkey[4]] ) )
            continue
        end  # if !( any( [plotkey[2], plotkey[3], plotkey[4]] ) )

        # Generate the report.
        tStart = now()
        fluxReport = transitionFluxReport( mpSim, plotkey[1],
            plotsToMake[plotkey]... )
        reportGenerationTime = ( now() - tStart ).value / 1000.0

        if isempty( fluxReport )
            continue
        end  # if isempty( fluxReport )

        if plotkey[2] || plotkey[3]
            dateStr = string( " (", Dates.format( now(), "yyyymmdd HHMMSS" ),
                ";", plotkey[1], ")" )
            plotname = string( plotdir, "/transition flux", dateStr )
            generateTransFluxPlot( fluxReport, 12.0, plotkey[2], plotkey[3],
                plotname )
        end  # if plotkey[2] || ...

        if plotkey[4]
            writeTransFluxData( fluxReport, mpSim, 12.0, reportGenerationTime,
                reportname, isFirst )
            isFirst = false
        end  # if plotkey[4]
    end  # for plotkey in keys( plotsToMake )

end  # excelTransPlot( mpSim, filename, sheetname )