function readDBpars( mpSim::MPsim, ws::WS, filePath::String )

    isConfigFromDB = !( ws[ "B12" ] isa Missing ) && ( ws[ "B11" ] == "YES" )
    configDBname = Base.source_path()
    configDBname = configDBname isa Nothing ? "" : dirname( configDBname )
    tmpDBname = ws[ "B4" ]

    if tmpDBname isa Missing
        tmpDBname = ""
    else
        tmpDBname = string( joinpath( filePath,
            split( tmpDBname, r"[/\\]" )... ),
            endswith( tmpDBname, ".sqlite" ) ? "" : ".sqlite" )
        # ! The split( )... part ensures that the pathname is correct for both Windows and Linux systems.
    end  # if tmpDBname isa Missing

    if isConfigFromDB
        tmpConfigName = joinpath( split( sheet[ "B12" ], r"[/\\]" )... )

        if tmpConfigName isa Missing
            @warn "No database entered to get configuration from. Configuring simulation from Excel sheet."
            isConfigFromDB = false
        else
            configDBname = string( joinpath( configDBname, tmpConfigName ),
                endswith( configDBname, ".sqlite" ) ? "" : ".sqlite" )

            if ispath( configDBname )
                isRerun = ( configDBname == tmpDBname ) &&
                    ( ws[ "B14" ] == "YES" )
                configureSimFromDatabase( mpSim, configDBname, isRerun )

                # Don't make any further changes if the database is the same.
                if configDBname == tmpDBname
                    return "sameDB"
                end  # if configDBname == tmpDBname
            else
                @warn string( "Database '", configDBname,
                    "' does not exist. Configuring simulation from ",
                    "Excel sheet." )
                isConfigFromDB = false
            end  # if ispath( configDBname )
        end  # if tmpConfigName isa Missing
    end  # if isConfigFromDB

    # This block creates the database file if necessary and opens a link to it.
    mkpath( filePath )

    if mpSim.showInfo
        println( "Database file '", tmpDBname, "' ",
            isfile( tmpDBname ) ? "exists" : "does not exist", "." )
    end  # if mpSim.showInfo

    setSimulationDatabase!( mpSim, tmpDBname )
    
    # ! This line ensures that foreign key logic works.
    SQLite.execute!( mpSim.simDB, "PRAGMA foreign_keys = ON" )

    simName = ws[ "B5" ] isa Missing ? "simulation" : string( ws[ "B5" ] )
    setSimulationName!( mpSim, simName )

    # Check if databases are present and issue a warning if so.
    dbTableList = SQLite.tables( mpSim.simDB )[ :name ]

    if ( mpSim.persDBname ∈ dbTableList ) ||
        ( mpSim.histDBname ∈ dbTableList ) ||
        ( mpSim.transDBname ∈ dbTableList )
        @warn string( "Results for a simulation called '", mpSim.simName,
            "' already in database. These will be overwritten." )
    end  # if ( mpSim.personnelDBname ∈ dbTableList ) || ...

    return isConfigFromDB ? "otherDB" : "Excel"

end  # readDBpars( mpSim, ws, filePath )


function readGeneralPars( mpSim::MPsim, ws::WS, filePath::String )

    # Read the name of the catalogue file.
    catalogueName = ws[ "B3" ] isa Missing ? "" : string( ws[ "B3" ] )
    catalogueName = string( catalogueName,
        endswith( catalogueName, ".xlsx" ) ? "" : ".xlsx" )

    catalogueName = normpath( joinpath( filePath, "..", catalogueName ) )

    if !ispath( catalogueName )
        @error string( "Catalogue file '", catalogueName, "' does not exist." )
    end  # if !ispath( catalogueName )

    mpSim.catFileName = catalogueName

    # Set general simulation parameters.
    if ws[ "B6" ] isa Integer
        setSimulationPersonnelTarget!( mpSim, ws[ "B6" ] )
    end  # if ws[ "B6" ] isa Integer

    # if !isa( sheet[ "B7" ], Missings.Missing )
    #     setSimStartDate( mpSim, sheet[ "B7" ] )
    # end  # if !isa( sheet[ "B7" ], Missings.Missing )

    if ws[ "B8" ] isa Real
        setSimulationLength!( mpSim, ws[ "B8" ] * 12.0 )
    end  # if ws[ "B8" ] isa Real
    
    # setDatabaseCommitTime( mpSim, sheet[ "B8" ] * 12.0 / sheet[ "B9" ] )
    
end  # readGeneralPars( mpSim, ws, filePath )