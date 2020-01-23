export  initialiseFromExcel

"""
"""
function initialiseFromExcel( mpSim::MPsim, fileName::String;
    initDB::Bool = true, showInfo::Bool = true )::Bool

    # Add extension .xlsx if necessary.
    fileName = string( fileName, endswith( fileName, ".xlsx" ) ? "" : ".xlsx" )

    # Check if the file exists.
    if !ispath( fileName )
        @warn string( "The file '", fileName,
            "' does not exist. The simulation is incorrectly configured ", 
            "and should not be relied upon." )
        return false
    end  # if !ispath( fileName )

    setSimulationShowInfo!( mpSim, showInfo )
    configSource = "Excel"
    isOkay = true

    XLSX.openxlsx( fileName ) do xf
        # Check if the file has a tab "General".
        if !XLSX.hassheet( xf, "General" )
            @warn "Excel file has no tab 'General', cannot perform basic simulation setup. The simulation is incorrectly configured and should not be relied upon."
            isOkay = false
            return
        end  # if !XLSX.hassheet( xf, "General" )

        # Read database parameters.
        filePath = fileName[ 1:(end-5) ]
        configSource = readDBpars( mpSim, xf[ "General" ], filePath )
        
        # Don't read Excel parameters if the source of the configuration is a
        #   database.
        if configSource != "Excel"
            return
        end  # if !isDBnew

        # Read general parameters.
        readGeneralPars( mpSim, xf[ "General" ], filePath )

        XLSX.openxlsx( mpSim.catFileName ) do catXF
            # Read attrition schemes.
            readAttritionSchemes( mpSim, catXF )
        end  # XLSX.openxlsx( mpSim.catFileName ) do catXF
    end  # XLSX.openxlsx( fileName ) do xf

    return isOkay

end  # initialiseFromExcel( mpSim, fileName, initDB, showInfo )

"""
```
initialiseFromExcel(
    fileName::String;
    initDB::Bool = true,
    showOutput::Bool = true )
```
"""
function initialiseFromExcel( fileName::String; initDB::Bool = true,
    showInfo::Bool = true )::Tuple{MPsim, Bool}

    mpSim = ManpowerSimulation()
    isOkay = initialiseFromExcel( mpSim, fileName, initDB = initDB,
        showInfo = showInfo )

    return (mpSim, isOkay)

end  # initialiseFromExcel( fileName, initDB, showInfo )