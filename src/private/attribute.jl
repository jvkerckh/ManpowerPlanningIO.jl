function readAttributes( mpSim::MPsim, xf::XF, catXF::XF )

    if !XLSX.hassheet( xf, "Attributes" )
        @warn "Configuration file is missing an 'Attributes' sheet, cannot configure attributes."
        return
    end  # if !XLSX.hassheet( xf, "Attributes" )

    ws = xf[ "Attributes" ]
    nAttributes = ws[ "B4" ] isa Integer ? ws[ "B4" ] : 0
    lineNrs = 3 * (1:nAttributes) .+ 4

    if XLSX.hassheet( catXF, "Attributes" )
        catalogue = catXF[ "Attributes" ]
        attributes = readAttribute.( Ref( ws ), Ref( catalogue ),
            lineNrs )
    else
        attributes = readAttribute.( Ref( ws ), lineNrs )
    end  # if XLSX.hassheet( catXF, "Attributes" )

    setSimulationAttributes!( mpSim, attributes )

end  # readAttributes( mpSim, xf, catXF )


function readAttribute( ws::WS, catalogue::WS, sLine::Int )

    # Read the attribute's initial values.
    attribute = readAttribute( ws, sLine )

    # If it's in the catalogue, read the attribute's possible values.
    cLine = ws[ sLine, 2 ]

    if !( cLine isa Integer ) || ( cLine <= 0 )
        return attribute
    end  # if !( cLine isa Integer ) || ...

    cLine += 1

    if string( catalogue[ cLine, 1 ] ) != attribute.name
        return attribute
    end  # if string( catalogue[ cLine, 1 ] != attribute.name

    nValues = catalogue[ cLine, 5 ]
    
    if !( nValues isa Integer ) || ( nValues <= 0 )
        return attribute
    end  # if !( nValues isa Integer ) || ...

    values = String.( strip.( string.( catalogue[ CR( cLine, 6, cLine,
        5 + nValues ) ] ) ) )
    addPossibleAttributeValue!( attribute, values... )

    return attribute

end  # readAttribute( ws, catalogue, sLine )

function readAttribute( ws::WS, sLine::Int )

    attribute = Attribute( string( ws[ sLine, 1 ] ) )
    nInitialValues = ws[ sLine + 2, 2 ]

    # No need to process any further if there are no initial values given.
    if !( nInitialValues isa Integer )
        return attribute, false
    elseif ( nInitialValues <= 0 )
        return attribute, true
    end  # if !( nInitialValues isa Integer )

    initialValues = Dict{String, Float64}()
    values = strip.( string.( ws[ CR( sLine, 3, sLine,
        nInitialValues + 2 ) ] ) )
    weights = ws[ CR( sLine + 1, 3, sLine + 1, nInitialValues + 2 ) ]

    # Only process initial values with a given weight.
    for ii in 1:nInitialValues
        if weights[ ii ] isa Real
            initialValues[ values[ ii ] ] = weights[ ii ] +
                get( initialValues, values[ ii ], 0.0 )
        end  # if weights[ ii ] isa Real
    end  # for ii in 1:nInitialValues

    setInitialAttributeValues!( attribute, initialValues )
    return attribute

end  # readAttribute( ws, sLine )


function readAttributes( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    attributePars = DataFrame( SQLite.Query( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Attribute'" ) ) )

    attributes = map( eachindex( attributePars[ :parName ] ) ) do ii
        attribute = Attribute( attributePars[ ii, :parName ] )
        pars = split( attributePars[ ii, :parValue ], ";" )

        if length( pars[ 1 ] ) > 2
            setPossibleAttributeValues!( attribute, string.(
                split( pars[ 1 ][ 2:(end-1) ], "," ) ) )
        end  # if length( pars[ 1 ] ) > 2
        
        if length( pars[ 2 ] ) > 2
            initVals = split.( split( pars[ 2 ][ 2:(end-1) ], "," ), ":" )
            initValDict = Dict{String, Float64}()

            for initVal in initVals
                initValDict[ initVal[ 1 ] ] = parse( Float64, initVal[ 2 ] )
            end  # for initVal in initVals

            setInitialAttributeValues!( attribute, initValDict )
        end  # if length( pars[ 2 ] ) > 2

        return attribute
    end  # map( eachindex( attributePars[ :parName ] ) ) do ii

    setSimulationAttributes!( mpSim, attributes )

end  # readAttributes( mpSim, configDB, configName )