function readBaseNodes( mpSim::MPsim, xf::XF, catXF::XF )

    if !XLSX.hassheet( xf, "Base Nodes" )
        @warn "Configuration file is missing a 'Base Nodes' sheet, cannot configure base nodes."
        return
    end  # if !XLSX.hassheet( xf, "Base Nodes" )

    ws = xf[ "Base Nodes" ]
    nNodes = ws[ "B4" ] isa Integer ? ws[ "B4" ] : 0
    lineNrs = (1:nNodes) .+ 6

    if XLSX.hassheet( catXF, "States" )
        catalogue = catXF[ "States" ]
        nodes = readBaseNode.( Ref( mpSim ), Ref( ws ), Ref( catalogue ),
            lineNrs )
    else
        @warn "Catalogue file is missing a 'States' sheet, cannot configure attributes defining base nodes."
        nodes = readBaseNode.( Ref( ws ), lineNrs )
    end  # if XLSX.hassheet( catXF, "States" )

    setSimulationBaseNodes!( mpSim, nodes )

    # Set the preferred node order.
    nodes = ws[ CR( 7, 1, 6 + nNodes, 1 ) ]
    order = ws[ CR( 7, 4, 6 + nNodes, 4 ) ]
    isValid = .!isa.( nodes, Missing ) .& isa.( order, Integer )
    nodes = string.( nodes[ isValid ] )
    order = Vector{Int}( order[ isValid ] )
    setSimulationBaseNodeOrder!( mpSim, nodes, order )

end  # readBaseNodes( mpSim, wf, catWF )


function readBaseNode( mpSim::MPsim, ws::WS, catalogue::WS, sLine::Int )

    # Read the base node's target.
    node = readBaseNode( ws, sLine )

    # If it's in the catalogue, read the base node's attribute requirements and
    #   associated attrition scheme.
    cLine = ws[ sLine, 3 ]

    if !( cLine isa Integer )
        return node
    end  # if !( cLine isa Integer )

    cLine += 1

    # Set the node's attrition scheme.
    isAttritionFixed = catalogue[ cLine, 3 ] isa Missing ? "YES" :
        string( catalogue[ cLine, 3 ] )
    isAttritionFixed = isAttritionFixed != "NO"

    if isAttritionFixed
        attrition = Attrition( string( node.name, " attrition" ) )
        period = catalogue[ cLine, 4 ] isa Real ? catalogue[ cLine, 4 ] : 12.0
        rate = catalogue[ cLine, 5 ] isa Real ? catalogue[ cLine, 5 ] : 0.0
        setAttritionPeriod!( attrition, period )
        setAttritionRate!( attrition, rate )
        setNodeAttritionScheme!( node, attrition.name )
    else
        nodeAttrition = catalogue[ cLine, 6 ] isa Missing ? "default" :
            string( catalogue[ cLine, 6 ] )
        setNodeAttritionScheme!( node, nodeAttrition )
    end  # if isAttritionFixed

    # Set the node's attributes.
    nRequirements = catalogue[ cLine, 7 ] isa Real ?
        floor( Int, catalogue[ cLine, 7 ] ) : 0
    requirements = Dict{String, String}(
        string( catalogue[ cLine, 6 + 2 * ii ] ) =>
        string( catalogue[ cLine, 7 + 2 * ii ] ) for ii in 1:nRequirements )
    setNodeRequirements!( node, requirements )

    return node

end  # readBaseNode( ws, catalogue, sLine )


function readBaseNode( ws::WS, sLine::Int )

    node = BaseNode( string( ws[ sLine, 1 ] ) )
    nodeTarget = ws[ sLine, 2 ]

    if nodeTarget isa Integer
        setNodeTarget!( node, nodeTarget )
    end  # if nodeTarget isa Integer

    return node

end  # function readBaseNode( ws, sLine )


function readBaseNodes( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    nodePars = DataFrame( DBInterface.execute( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Base Node'" ) ) )

    if !isempty( nodePars )
        nodes = map( eachindex( nodePars[ :, :parName ] ) ) do ii
            node = BaseNode( nodePars[ ii, :parName ] )
            pars = split( nodePars[ ii, :parValue ], ";" )

            if tryparse( Int, pars[ 1 ] ) isa Int
                setNodeTarget!( node, parse( Int, pars[ 1 ] ) )
            end  # if tryparse( Int, pars[ 1 ] )

            setNodeAttritionScheme!( node, string( pars[ 2 ] ) )

            if length( pars[ 3 ] ) > 2
                nodeReqs = split.( split( pars[ 3 ][ 2:(end-1) ], "," ), ":" )
                nodeReqDict = Dict{String, String}()

                for nodeReq in nodeReqs
                    nodeReqDict[ nodeReq[ 1 ] ] = nodeReq[ 2 ]
                end  # for nodeReq in nodeReqs

                setNodeRequirements!( node, nodeReqDict )
            end  # if length( pars[ 3 ] ) > 2

            return node
        end  # map( eachindex( nodePars[ :parName ] ) ) do ii

        setSimulationBaseNodes!( mpSim, nodes )
    end  # if !isempty( nodePars )

    nodeOrder = DataFrame( DBInterface.execute( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Base Node Order'" ) ) )

    if !isempty( nodeOrder ) && ( length( nodeOrder[ 1, :parValue ] ) > 2 )
        order = split.( split( nodeOrder[ 1, :parValue ], ";" ), ":" )
        orderDict = Dict{String, Int}()

        for orderPair in order
            orderDict[ orderPair[ 1 ] ] = parse( Int, orderPair[ 2 ] )
        end  # for orderPair in order

        setSimulationBaseNodeOrder!( mpSim, orderDict )
    end  # if !isempty( nodeOrder ) && ...

end  # readBaseNodes( mpSim, configDB, configName )