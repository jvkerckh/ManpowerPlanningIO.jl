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
    DBInterface.execute( mpSim.simDB, "PRAGMA foreign_keys = ON" )

    simName = ws[ "B5" ] isa Missing ? "simulation" : string( ws[ "B5" ] )
    setSimulationName!( mpSim, simName )

    # Check if databases are present and issue a warning if so.
    dbTableList = get( SQLite.tables( mpSim.simDB ), :name, Vector{String}() )

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

    if ws[ "B8" ] isa Real
        setSimulationLength!( mpSim, ws[ "B8" ] * 12.0 )
    end  # if ws[ "B8" ] isa Real
    
    # setDatabaseCommitTime( mpSim, sheet[ "B8" ] * 12.0 / sheet[ "B9" ] )
    
end  # readGeneralPars( mpSim, ws, filePath )

function readGeneralPars( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    generalPars = DataFrame( DBInterface.execute( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'General'" ) ) )

    if isempty( generalPars )
        return
    end  # if isempty( generalPars )

    parInds = map( [ "Sim name", "ID key", "Personnel target", "Sim length",
        "Current time", "DB commits" ] ) do parName
        return findfirst( parName .== generalPars[ :, :parName ] )
    end  # map( ... ) do parName

    # Read simulation name.
    if parInds[ 1 ] isa Int
        setSimulationName!( mpSim, generalPars[ parInds[ 1 ], :parValue ] )
    end  # if parInds[ 1 ] isa Int

    # Read ID key.
    if parInds[ 2 ] isa Int
        setSimulationKey!( mpSim, generalPars[ parInds[ 2 ], :parValue ] )
    end  # if parInds[ 2 ] isa Int

    # Read global personnel target.
    if parInds[ 3 ] isa Int
        parVal = tryparse( Int, generalPars[ parInds[ 3 ], :parValue ] )
        
        if parVal isa Int
            setSimulationPersonnelTarget!( mpSim, parVal )
        end  # if parval isa Int
    end  # if parInds[ 3 ] isa Int

    # Read simulation length.
    if parInds[ 4 ] isa Int
        parVal = tryparse( Float64, generalPars[ parInds[ 4 ], :parValue ] )
        
        if parVal isa Float64
            setSimulationLength!( mpSim, parVal )
        end  # if parval isa Float64
    end  # if parInds[ 4 ] isa Int

    # Read current simulation time.
    if parInds[ 5 ] isa Int
        parVal = tryparse( Float64, generalPars[ parInds[ 5 ], :parValue ] )
        
        if ( parVal isa Float64 ) && ( parVal > 0.0 )
            run( mpSim.sim, parVal )
        end  # if parval isa Float64
    end  # if parInds[ 5 ] isa Int
    
    # Read number of database commits.
    if parInds[ 6 ] isa Int
        parVal = tryparse( Int, generalPars[ parInds[ 6 ], :parValue ] )
        
        if parVal isa Int
            # setSimulationPersonnelTarget!( mpSim, parVal )
        end  # if parval isa Int
    end  # if parInds[ 6 ] isa Int

end  # readGeneralPars( mpSim, configDB, configName )