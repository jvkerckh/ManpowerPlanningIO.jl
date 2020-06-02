function readInitPop( mpSim::MPsim, xf::XF, filePath::String )

    if !XLSX.hassheet( xf, "Snapshot" )
        @warn "Configuration file is missing a 'Snapshoy' sheet, cannot load the initial population of the organisation."
        return
    end  # if !XLSX.hassheet( xf, "Snapshot" )

    ws = xf["Snapshot"]

    if ws["B3"] == "NO"
        return
    end  # if ws["B3"] == "NO"

    # Initial population file name.
    initPopName = ws["B4"] isa Missing ? "" : string( ws["B4"] )
    initPopName = string( initPopName,
        endswith( initPopName, ".xlsx" ) ? "" : ".xlsx" )
    initPopName = normpath( joinpath( filePath, "..", initPopName ) )

    if !ispath( initPopName )
        @warn string( "Initial population file '", initPopName,
            "' does not exist. Cannot upload initial population." )
        return
    end  # if !ispath( initPopName )

    initPopSheet = ws["B5"] isa Missing ? "" : string( ws["B5"] )
    isSheetOkay = true

    XLSX.openxlsx( initPopName ) do sxf
        isSheetOkay = XLSX.hassheet( sxf, initPopSheet )
    end  # XLSX.openxlsx( initPopName ) do sxf

    if !isSheetOkay
        @warn string( "Initial population file does not have sheet '",
            initPopSheet, "'. Cannot upload initial population." )
        return
    end  # if !isSheetOkay

    # Read special columns.
    specialCols = [ws["B6"], ws["B11"], ws["B7"], ws["B9"], ws["B12"]]

    for ii in 1:5
        if !( ( specialCols[ii] isa String ) || ( specialCols[ii] isa Int ) )
            specialCols[ii] = 0
        end  # if !( ... )
    end  # for ii in 1:5

    # Read attribute columns.
    nAttributes = ws["B16"]
    attributeCols = []

    if nAttributes > 0
        attributeCols = ws[CR( 19, 1, 18 + nAttributes, 1 )][:]
    end  # if nAttributes > 0

    attributeCols = map( attr -> ( attr isa Int ) || ( attr isa String ) ?
        attr : 0, attributeCols )    
    uploadSnapshot( mpSim, initPopName, initPopSheet, attributeCols,
        Tuple( specialCols ); generateSimData=ws["B13"] == "YES" )

end  # readInitPop( mpSim, xf, filePath )