export  initialiseFromExcel,
        initialiseFromDB,
        runFromExcel

"""
"""
function initialiseFromExcel( mpSim::MPsim, filename::AbstractString;
    initDB::Bool=true, showInfo::Bool=true )::Bool

    # Add extension .xlsx if necessary.
    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )

    # Check if the file exists.
    if !ispath( filename )
        @warn string( "The file '", filename,
            "' does not exist. The simulation is incorrectly configured ", 
            "and should not be relied upon." )
        return false
    end  # if !ispath( filename )

    setSimulationShowInfo!( mpSim, showInfo )
    configSource = "Excel"
    isOkay = true

    XLSX.openxlsx( filename ) do xf
        # Check if the file has a tab "General".
        if !XLSX.hassheet( xf, "General" )
            @warn "Excel file has no tab 'General', cannot perform basic simulation setup. The simulation is incorrectly configured and should not be relied upon."
            isOkay = false
            return
        end  # if !XLSX.hassheet( xf, "General" )

        # Read database parameters.
        filePath = filename[1:(end-5)]
        configSource = readDBpars( mpSim, xf["General"], filePath )
        
        # Don't read Excel parameters if the source of the configuration is a
        #   database.
        if configSource != "Excel"
            return
        end  # if !isDBnew

        # Read general parameters.
        readGeneralPars( mpSim, xf["General"], filePath )

        XLSX.openxlsx( mpSim.catFileName ) do catXF
            readAttritionSchemes( mpSim, catXF )
            readAttributes( mpSim, xf, catXF )
            readBaseNodes( mpSim, xf, catXF )
            readCompoundNodes( mpSim, xf, catXF )
        end  # XLSX.openxlsx( mpSim.catFileName ) do catXF

        readTransitions( mpSim, xf )
        readRetirement( mpSim, xf )
        readInitPop( mpSim, xf, filePath )
    end  # XLSX.openxlsx( filename ) do xf

    return isOkay

end  # initialiseFromExcel( mpSim, filename, initDB, showInfo )

"""
```
initialiseFromExcel(
    filename::String;
    initDB::Bool=true,
    showOutput::Bool=true )
```
"""
function initialiseFromExcel( filename::String; initDB::Bool=true,
    showInfo::Bool=true )::Tuple{MPsim, Bool}

    mpSim = MPsim()
    isOkay = initialiseFromExcel( mpSim, filename, initDB=initDB,
        showInfo=showInfo )

    return (mpSim, isOkay)

end  # initialiseFromExcel( filename, initDB, showInfo )


"""
```
initialiseFromDB(
    mpSim::MPsim,
    filename::String;
    configName::String="config",
    showInfo::Bool=true )
```
"""
function initialiseFromDB( mpSim::MPsim, filename::String;
    configName::String="config", showInfo::Bool=true )::Bool

    # Add extension .sqlite if necessary.
    filename = string( filename, endswith( filename, ".sqlite" ) ? "" :
        ".sqlite" )

    # Check if the file exists.
    if !ispath( filename )
        @warn string( "The file '", filename,
            "' does not exist. The simulation is incorrectly configured ", 
            "and should not be relied upon." )
        return false
    end  # if !ispath( filename )

    configDB = SQLite.DB( filename )

    # Check if the database has the required table.
    if configName ∉ SQLite.tables( configDB )[:name]
        @warn string( "The database '", filename, "' does not have a table '",
            configName, "'. The simulation is incorrectly configured ", 
            "and should not be relied upon." )
        return false
    end  # if configName ∉ SQLite.tables( configDB )[:name]

    setSimulationShowInfo!( mpSim, showInfo )
    isOkay = true

    readGeneralPars( mpSim, configDB, configName )
    readAttritionSchemes( mpSim, configDB, configName )
    readAttributes( mpSim, configDB, configName )
    readBaseNodes( mpSim, configDB, configName )
    readCompoundNodes( mpSim, configDB, configName )
    readRecruitment( mpSim, configDB, configName )
    readTransitions( mpSim, configDB, configName )
    readRetirement( mpSim, configDB, configName )
    
    return isOkay

end  # initialiseFromDB( mpSim, filename, configName, showInfo )

"""
```
initialiseFromDB(
    filename::String;
    configName::String="config",
    showInfo::Bool=true )
```
"""
function initialiseFromDB( filename::String; configName::String="config",
    showInfo::Bool=true )::Tuple{MPsim, Bool}

    mpSim = MPsim()
    isOkay = initialiseFromDB( mpSim, filename, configName=configName,
        showInfo=showInfo )
    return (mpSim, isOkay)

end  # initialiseFromDB( filename, configName, showInfo )


function runFromExcel( mpSim::MPsim, filename::String;
    initDB::Bool=true, showInfo::Bool=true )::Bool

    isOkay = initialiseFromExcel( mpSim, filename, initDB=initDB,
        showInfo=showInfo )

    if !isOkay
        return false
    end  # if !isOkay

    # Add extension .xlsx if necessary.
    filename = string( filename, endswith( filename, ".xlsx" ) ? "" : ".xlsx" )
    return runSim( mpSim, filename, showInfo )

end  # runFromExcel( mpSim, filename, initDB, showInfo )

function runFromExcel( filename; initDB::Bool=true,
    showInfo::Bool=true )::Tuple{MPsim, Bool}

    mpSim = MPsim()
    isOkay = runFromExcel( mpSim, filename, initDB=initDB, showInfo=showInfo )
    return (mpSim, isOkay)

end  # runFromExcel( fileName, initDB, showInfo )