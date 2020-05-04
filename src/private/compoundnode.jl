function readCompoundNodes( mpSim::MPsim, xf::XF, catXF::XF )

    if !XLSX.hassheet( xf, "Compound Nodes" )
        @warn "Configuration file is missing a 'Compound Nodes' sheet, cannot configure compound nodes."
        return
    end  # if !XLSX.hassheet( xf, "Compound Nodes" )

    ws = xf[ "Compound Nodes" ]
    clearSimulationCompoundNodes!( mpSim )

    if XLSX.hassheet( catXF, "States" )
        catalogue = catXF[ "States" ]
        nodes = generateHierarchyNodes( mpSim, ws, catalogue )
        append!( nodes, readCatalogueNodes( mpSim, ws, catalogue ) )
        # append!( nodes, readCustomNodes( mpSim, ws, catalogue ) )
    else
        nodes = generateHierarchyNodes( mpSim, ws )
        # append!( nodes, readCustomNodes( mpSim, ws ) )
    end  # if XLSX.hassheet( catXF, "States" )

    addSimulationCompoundNode!( mpSim, nodes... )
    readCustomNodes!( mpSim, ws )

end  # readCompoundNodes( mpSim, xf, catXF )


function generateHierarchyNodes( mpSim::MPsim, ws::WS, catalogue::WS )

    nodes = generateHierarchyNodes( mpSim, ws )

    # Find names for compound nodes in catalogue.
    names = readCatalogueNodeNames( catalogue::WS )
    catSize = length( names )
    combs = Int.( catalogue[ CR( 2, 7, catSize + 1, 7 ) ] )[ : ]

    for node in nodes
        attrVals = split.( split( node.name, "/" ), ":" )
        nReqs = length( attrVals )
        attrVals = string.( collect( Iterators.flatten( attrVals ) ) )
        eligibleLines = findall( combs .== nReqs )
        
        isMatch = map( eligibleLines ) do lineNr
            comb = string.( catalogue[ CR( lineNr + 1, 8, lineNr + 1,
                nReqs * 2 + 7 ) ] )[ : ]
            return all( comb .== attrVals )
        end  # map( eligibleLines ) do lineNr

        matchNr = findfirst( isMatch )

        if !( matchNr isa Nothing )
            setCompoundNodeName!( node, names[ eligibleLines[ matchNr ] ] )
        end  # if !( matchNr isa Nothing )
    end  # for node in nodes

    return nodes

end  # generateHierarchyNodes( mpSim, ws, catalogue )

function generateHierarchyNodes( mpSim::MPsim, ws::WS )

    nLevels = ws[ "F4" ] isa Integer ? ws[ "F4" ] : 0

    if nLevels <= 0
        return Vector{CompoundNode}()
    end  # if nLevels <= 0

    # Get the list of attributes to generate the hierarchy.
    attributeNames = string.( ws[ CR( 7, 5, 6 + nLevels, 5 ) ] )
    attributeNames = attributeNames[ haskey.( Ref( mpSim.attributeList ),
        attributeNames ) ]
    attributes = get.( Ref( mpSim.attributeList ), attributeNames, missing )
    attributes = attributes[ length.( getfield.( attributes,
        :possibleValues ) ) .> 1 ]

    if isempty( attributes )
        return Vector{CompoundNode}()
    end  # if isempty( attributes )

    unique!( attributes )

    # Get the list of all base nodes on each level and create compound nodes
    #   where needed.
    baseNodes = get.( Ref( mpSim.baseNodeList ),
        collect( keys( mpSim.baseNodeList ) ), missing )
    baseNodesByLevel = Vector{Array{Vector{BaseNode}}}( undef,
        length( attributes ) + 1 )
    compoundNodes = Vector{CompoundNode}()

    for ii in reverse( eachindex( baseNodesByLevel ) )
        # Generate base nodes by level.
        tmpAttrs = attributes[ 1:( ii > length( attributes ) ? end : ii ) ]
        op = ii > length( attributes ) ? Base.:(>=) : Base.:(==)
        tmpNodes = filter( node -> op( length( node.requirements ), ii ),
            baseNodes )
        attrCombs = collect( Iterators.product( getfield.( tmpAttrs,
            :possibleValues )... ) )

        baseNodesByLevel[ ii ] = map( attrCombs ) do attrComb
            return filter( tmpNodes ) do node
                return all( haskey.( Ref( node.requirements ),
                        attributeNames ) ) &&
                    all( get.( Ref( node.requirements ), attributeNames,
                        missing ) .== attrComb )
            end  # filter( baseNodes ) do node
        end  # map( attrCombs ) do attrComb
        
        if ii <= length( attributes )
            # Generate compound nodes.
            makeCompound = map( eachindex( baseNodesByLevel[ ii ] ) ) do jj
                return ( length( baseNodesByLevel[ ii ][ jj ] ) > 1 ) ||
                    ( length( baseNodesByLevel[ ii + 1 ][ jj ] ) > 0 )
            end  # map( eachindex( baseNodesByLevel ) ) do jj
            makeCompound = findall( makeCompound )

            baseNodesByLevel[ ii ] = vcat.( baseNodesByLevel[ ii ],
                baseNodesByLevel[ ii + 1 ] )
            
            compoundNames = map( makeCompound ) do jj
                return join( string.( attributeNames[ 1:ii ], ":",
                    attrCombs[ jj ] ), "/" )
            end  # map( makeCompound ) do jj
            tmpCompounds = CompoundNode.( compoundNames )
            setCompoundNodeComponents!.( tmpCompounds,
                map( nodeList -> getfield.( nodeList, :name ),
                baseNodesByLevel[ ii ][ makeCompound ] ) )
            append!( compoundNodes, tmpCompounds )

            # Collapse base node array over last dimension.
            baseNodesByLevel[ ii ] = vcat.( map( jj -> getindex(
                baseNodesByLevel[ ii ], fill( Colon(), ii - 1 )..., jj ),
                axes( baseNodesByLevel[ ii ], ii ) )... )
            # ? This line creates a vector of dim-1 arrays of the length of the
            #   final dimension, and then performs an element-wise
            #   concatenation.
        end  # if ii < length( attributes )
    end  # for ii in reverse( eachindex( baseNodesByLevel ) )

    return compoundNodes

end  # generateHierarchyNodes( mpSim, ws )


function readCatalogueNodeNames( catalogue::WS )

    # Find names for compound nodes in catalogue.
    nStates = 2

    while !( catalogue[ nStates, 1 ] isa Missing )
        nStates += 1
    end  #  while !( catalogue[ nStates, 1 ] isa Missing )

    nStates -= 2
    return string.( catalogue[ CR( 2, 1, nStates + 1, 1 ) ] )[ : ]

end  # readCatalogueNodeNames( catalogue )


function readCatalogueNodes( mpSim::MPsim, ws::WS, catalogue::WS )

    names = readCatalogueNodeNames( catalogue::WS )
    catSize = length( names )

    # Find the compound node definitions in the catalogue.
    nNodes = ws[ "B4" ]
    nodeNames = string.( ws[ CR( 7, 1, 6 + nNodes, 1 ) ] )[ : ]
    catLines = map( name -> findfirst( names .== name ), nodeNames )
    isInCat = .!isa.( catLines, Nothing )
    nodeNames = nodeNames[ isInCat ]
    catLines = catLines[ isInCat ] .+ 1
    nodes = Vector{CompoundNode}( undef, length( nodeNames ) )

    for ii in eachindex( nodeNames )
        jj = catLines[ ii ]
        nReqs = catalogue[ jj, 7 ]
        reqs = Dict( catalogue[ jj, kk * 2 + 6 ] =>
            catalogue[ jj, kk * 2 + 7 ] for kk in 1:nReqs )

        baseNodes = filter( collect( keys( mpSim.baseNodeList ) ) ) do name
            node = mpSim.baseNodeList[ name ]
            return all( map( collect( keys( reqs ) ) ) do attr
                return haskey( node.requirements, attr ) &&
                    ( node.requirements[ attr ] == reqs[ attr ] )
            end  # map( collect( keys( reqs ) ) ) do attr
            ) 
        end  # filter( collect( keys( mpSim.baseNodeList ) ) ) do name

        if !isempty( baseNodes )
            nodes[ ii ] = CompoundNode( nodeNames[ ii ] )
            setCompoundNodeComponents!( nodes[ ii ], baseNodes )
        end  # if !isempty( baseNodes )
    end  # for ii in eachindex( nodeNames )

    return nodes[ map( ii -> isassigned( nodes, ii ), 1:length( nodes ) ) ]

end  # readCatalogueNodes( mpSim, ws, catalogue )


function readCustomNodes!( mpSim::MPsim, ws::WS )

    nNodes = ws[ "I4" ]
    nodeNames = string.( ws[ CR( 7, 8, 6 + nNodes, 8 ) ] )[ : ]
    sLine = 6

    for name in nodeNames
        sLine += 1
        nComps = ws[ sLine, 10 ]

        if !( nComps isa Integer ) || ( nComps <= 0 )
            continue
        end  # if !( nComps isa Integer ) || ...

        # Resolve all components to the base nodes.
        comps = string.( ws[ CR( sLine, 11, sLine, 10 + nComps ) ] )[ : ]
        compNodes = filter( comp -> haskey( mpSim.baseNodeList, comp ), comps )
        otherNodes = filter( comp -> haskey( mpSim.compoundNodeList, comp ),
            comps )
        append!( compNodes,
            vcat( map( cNode -> mpSim.compoundNodeList[ cNode ].baseNodeList,
            otherNodes )... ) )
        
        # Add compound node if the list of base nodes isn't empty.
        if !isempty( compNodes )
            node = CompoundNode( name )
            setCompoundNodeComponents!( node, compNodes )
            addSimulationCompoundNode!( mpSim, node )
        end  # if !isempty( compNodes )
    end  # for ii in eachindex( nodeNames )

end  # readCustomNodes!( mpSim::MPsim, ws::WS )


function readCompoundNodes( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    nodePars = DataFrame( DBInterface.execute( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Compound Node'" ) ) )

    if isempty( nodePars )
        return
    end  # if isempty( nodePars )

    nodes = map( eachindex( nodePars[ :, :parName ] ) ) do ii
        node = CompoundNode( nodePars[ ii, :parName ] )
        pars = split( nodePars[ ii, :parValue ], ";" )

        if length( pars[ 1 ] ) > 2
            setCompoundNodeComponents!( node, string.(
                split( pars[ 1 ][ 2:(end-1) ], "," ) ) )
        end  # if length( pars[ 1 ] ) > 2

        if tryparse( Int, pars[ 2 ] ) isa Int
            setCompoundNodeTarget!( node, parse( Int, pars[ 2 ] ) )
        end  # if tryparse( Int, pars[ 2 ] ) isa Int

        return node
    end  # map( eachindex( nodePars[ :parName ] ) ) do ii

    setSimulationCompoundNodes!( mpSim, nodes )

end  # readCompoundNodes( mpSim, configDB, configName )