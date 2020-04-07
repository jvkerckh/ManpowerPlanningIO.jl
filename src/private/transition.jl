const operatorList = Dict{String, Function}( "IS" => Base.:(==),
    "IS NOT" => Base.:(!=), "IN" => Base.:∈, "NOT IN" => Base.:∉,
    ">" => Base.:>, ">=" => Base.:(>=), "<" => Base.:<, "<=" => Base.:(<=) )


function readTransitions( mpSim::MPsim, xf::XF )

    if !XLSX.hassheet( xf, "Transition types" )
        @warn "Configuration file is missing a 'Base Nodes' sheet, cannot set preferred transition order."
    else
        ws = xf[ "Transition types" ]
        nTrans = ws[ "B4" ] isa Integer ? ws[ "B4" ] : 0

        # Set the preferred transition order.
        transitions = ws[ CR( 7, 1, 6 + nTrans, 1 ) ]
        order = ws[ CR( 7, 2, 6 + nTrans, 2 ) ]
        isValid = .!isa.( transitions, Missing ) .& isa.( order, Integer )
        transitions = string.( transitions[ isValid ] )
        order = Vector{Int}( order[ isValid ] )
        setSimulationTransitionTypeOrder!( mpSim, transitions, order )
    end  # if !XLSX.hassheet( xf, "Transition types" )

    readRecruitment( mpSim, xf )
    readTransitionsThrough( mpSim, xf )
    readTransitionsOut( mpSim, xf )

end  # readTransitions( mpSim, xf )


function readTransitionsThrough( mpSim::MPsim, xf::XF )

    if !XLSX.hassheet( xf, "THROUGH Transitions" )
        @warn "Configuration file is missing a 'THROUGH Transitions' sheet, cannot read transitions within the organisation."
        return
    end  # if !XLSX.hassheet( xf, "THROUGH Transitions" )

    ws = xf[ "THROUGH Transitions" ]
    nTrans = ws[ "B4" ] isa Integer ? max( ws[ "B4" ], 0 ) : 0

    for sLine in (1:nTrans) * 4 .+ 3
        sLine1 = sLine + 1
        sLine2 = sLine + 2

        # Read transition base information.
        name = ws[ sLine, 1 ]
        sourceNode, targetNode = ws[ sLine, 2 ], ws[ sLine, 3 ]

        if ( name isa Missing ) || ( sourceNode isa Missing ) ||
            ( targetNode isa Missing )
            continue
        end  # if ( name isa Missing ) || ...

        transition = Transition( name, sourceNode, targetNode )
        freq, offset = ws[ sLine, 4 ], ws[ sLine, 5 ]
        setTransitionSchedule!( transition, freq, offset )

        # Read time conditions of transition.
        sCol = 7
        nTimeConds = ws[ sLine, sCol ]

        for ii in (1:nTimeConds) .+ sCol
            newCond, isCondOkay = processCondition( ws[ sLine, ii ],
                ws[ sLine1, ii ], ws[ sLine2, ii ] )
    
            if isCondOkay
                addTransitionCondition!( transition, newCond )
            end  # if isCondOkay
        end  # for ii in (1:nTimeConds) .+ sCol

        # Read other conditions of transitions.
        sCol += nTimeConds + 2
        nOtherConds = ws[ sLine, sCol ]

        for ii in (1:nOtherConds) .+ sCol
            newCond, isCondOkay = processCondition( ws[ sLine, ii ],
                ws[ sLine1, ii ], ws[ sLine2, ii ] )
    
            if isCondOkay
                addTransitionCondition!( transition, newCond )
            end  # if isCondOkay
        end  # for ii in (1:nOtherConds) .+ sCol

        # Set transition flux limits.
        sCol += nOtherConds + 2
        minFlux = ws[ sLine, sCol ] isa Integer ? ws[ sLine, sCol ] : 0
        maxFlux = ws[ sLine, sCol + 1 ] isa Integer ? ws[ sLine, sCol + 1 ] : 0
        setTransitionFluxLimits!( transition, minFlux, maxFlux )
        setTransitionHasPriority!( transition,
            strip( string( ws[ sLine, sCol + 2 ] ) ) == "NO" )

        # Set transition attempts and probabilities.
        nAttempts = ws[ sLine, sCol + 3 ] isa Integer ? ws[ sLine, sCol + 3 ] :
            -1
        setTransitionMaxAttempts!( transition, nAttempts )

        sCol += 4
        nProbs = ws[ sLine, sCol ]
        transitionProbs = Float64.( ws[ CR( sLine, sCol + 1, sLine,
            sCol + nProbs ) ] )[ : ]
        setTransitionProbabilities!( transition, transitionProbs )

        # Set extra transition changes.
        sCol += nProbs + 2
        nChanges = ws[ sLine, sCol ]
        attributes = Vector{String}()
        values = Vector{String}()

        for ii in (1:nChanges) .+ sCol
            if !any( isa.( [ ws[ sLine, ii ], ws[ sLine + 1, ii ] ], Missing ) )
                push!( attributes, strip( string( ws[ sLine, ii ] ) ) )
                push!( values, strip( string( ws[ sLine1, ii ] ) ) )
            end  # if !any( isa.( ... ) )
        end  # for ii in 1:nChanges

        setTransitionAttributeChanges!( transition, attributes, values )
        addSimulationTransition!( mpSim, transition )
    end  # for sLine (1:nTrans) * 4 .+ 3

end  # readTransitionsThrough( mpSim, xf )


function readTransitionsOut( mpSim::MPsim, xf::XF )

    if !XLSX.hassheet( xf, "OUT Transitions" )
        @warn "Configuration file is missing a 'OUT Transitions' sheet, cannot read transitions within the organisation."
        return
    end  # if !XLSX.hassheet( xf, "OUT Transitions" )

    ws = xf[ "OUT Transitions" ]
    nTrans = ws[ "B4" ] isa Integer ? max( ws[ "B4" ], 0 ) : 0

    for sLine in (1:nTrans) * 4 .+ 3
        sLine1 = sLine + 1
        sLine2 = sLine + 2

        # Read transition base information.
        name = ws[ sLine, 1 ]
        sourceNode = ws[ sLine, 2 ]

        if ( name isa Missing ) || ( sourceNode isa Missing )
            continue
        end  # if ( name isa Missing ) || ...

        transition = Transition( name, sourceNode )
        freq, offset = ws[ sLine, 3 ], ws[ sLine, 4 ]
        setTransitionSchedule!( transition, freq, offset )

        # Read time conditions of transition.
        sCol = 6
        nTimeConds = ws[ sLine, sCol ]

        for ii in (1:nTimeConds) .+ sCol
            newCond, isCondOkay = processCondition( ws[ sLine, ii ],
                ws[ sLine1, ii ], ws[ sLine2, ii ] )
    
            if isCondOkay
                addTransitionCondition!( transition, newCond )
            end  # if isCondOkay
        end  # for ii in (1:nTimeConds) .+ sCol

        # Read other conditions of transitions.
        sCol += nTimeConds + 2
        nOtherConds = ws[ sLine, sCol ]

        for ii in (1:nOtherConds) .+ sCol
            newCond, isCondOkay = processCondition( ws[ sLine, ii ],
                ws[ sLine1, ii ], ws[ sLine2, ii ] )
    
            if isCondOkay
                addTransitionCondition!( transition, newCond )
            end  # if isCondOkay
        end  # for ii in (1:nOtherConds) .+ sCol
        
        # Set transition flux limits.
        sCol += nOtherConds + 2
        minFlux = ws[ sLine, sCol ] isa Integer ? ws[ sLine, sCol ] : 0
        maxFlux = ws[ sLine, sCol + 1 ] isa Integer ? ws[ sLine, sCol + 1 ] : 0
        setTransitionFluxLimits!( transition, minFlux, maxFlux )

        # Set transition attempts and probabilities.
        nAttempts = ws[ sLine, sCol + 2 ] isa Integer ? ws[ sLine, sCol + 2 ] :
            -1
        setTransitionMaxAttempts!( transition, nAttempts )

        sCol += 3
        nProbs = ws[ sLine, sCol ]
        transitionProbs = Float64.( ws[ CR( sLine, sCol + 1, sLine,
            sCol + nProbs ) ] )[ : ]
        setTransitionProbabilities!( transition, transitionProbs )    
        addSimulationTransition!( mpSim, transition )    
    end  # for sLine (1:nTrans) * 4 .+ 3

end  # readTransitionsOut( mpSim, xf )


function processCondition( attribute::Union{String, Missing},
    operator::Union{String, Missing}, value::Union{Real, String, Missing} )

    # Check if any of the fields are missing.
    if any( isa.( [ attribute, operator, value ], Missing ) )
        return MPcondition( "condition", Base.:!=, "okay" ), false
    end  # if any( isa.( [ attribute, operator, value ], Missing ) )

    attribute = string( strip( attribute ) )
    operator = uppercase( string( strip( operator ) ) )

    # Check if the operator is valid.
    if !haskey( operatorList, operator )
        return MPcondition( "condition", Base.:!=, "okay" ), false
    end  # if !haskey( operatorList, operator )

    operator = operatorList[ operator ]

    # Time conditions must have a number value.
    if attribute ∈ MP.timeAttributes
        if ( value isa String ) || ( operator ∈ [ ∈ , ∉ ] )
            return MPcondition( "condition", Base.:!=, "okay" ), false
        end  # if ( value isa String ) || ...

        return MPcondition( attribute, operator, value * 12.0 ), true
    end  # if attribute ∈ MP.timeAttributes

    value = strip( string( value ) )

    if operator ∈ [ "IN", "NOT IN" ]
        value = Vector{String}( strip.( split( value, "," ) ) )
    end  # if operator ∈ [ "IN", "NOT IN" ]

    return MPcondition( attribute, operator, value ), true

end  # processCondition( attribute, operator, value )


function readTransitions( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    transitionPars = DataFrame( SQLite.Query( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Transition'" ) ) )

    transitions = map( eachindex( transitionPars[ :parName ] ) ) do ii
        pars = string.( split( transitionPars[ ii, :parValue ], ";" ) )
        transition = uppercase( pars[ 2 ] ) == "OUT" ?
            Transition( transitionPars[ ii, :parName ], pars[ 1 ] ) :
            Transition( transitionPars[ ii, :parName ], pars[ 1 ], pars[ 2 ] )
        
        if ( tryparse( Float64, pars[ 3 ] ) isa Float64 ) &&
            ( tryparse( Float64, pars[ 4 ] ) isa Float64 )
            setTransitionSchedule!( transition, parse( Float64, pars[ 3 ] ),
                parse( Float64, pars[ 4 ] ) )
        end  # if ( tryparse( Float64, pars[ 3 ] ) isa Float64 ) && ...

        if tryparse( Int, pars[ 5 ] ) isa Int
            setTransitionMaxAttempts!( transition, parse( Int, pars[ 5 ] ) )
        end  # if tryparse( Int, pars[ 5 ] ) isa Int

        if ( tryparse( Int, pars[ 6 ] ) isa Int ) &&
            ( tryparse( Int, pars[ 7 ] ) isa Int )
            setTransitionFluxLimits!( transition, parse( Int, pars[ 6 ] ),
                parse( Int, pars[ 7 ] ) )
        end  # if ( tryparse( Int, pars[ 6 ] ) isa Int ) && ...

        if tryparse( Bool, pars[ 8 ] ) isa Bool
            setTransitionHasPriority!( transition, parse( Bool, pars[ 8 ] ) )
        end  # if tryparse( Bool, pars[ 8 ] ) isa Bool

        if length( pars[ 9 ] ) > 2
            conditionPars = split.( split( pars[ 9 ][ 2:(end-1) ], "," ), ":" )
            conditions = map( conditionPars ) do condPars
                if length( condPars ) == 3
                    attrVal = tryparse( Float64, condPars[ 3 ] )
                    attrVal = attrVal isa Nothing ? string( condPars[ 3 ] ) :
                        attrVal / 12.0
                        # To ensure proper reading of conditions.
                else
                    attrVal = join( condPars[ 3:end ], "," )
                end  # if length( condPars ) == 3

                condition, isOkay = processCondition( string( condPars[ 1 ] ),
                    string( condPars[ 2 ] ), attrVal )
                return condition
            end  # map( conditionPars ) do condPars

            setTransitionConditions!( transition, conditions )
        end  # if length( pars[ 9 ] ) > 2

        if length( pars[ 10 ] ) > 2
            changes = split.( split( pars[ 10 ][ 2:(end-1) ], "," ), ":" )
            changesDict = Dict{String, String}()

            for change in changes
                changesDict[ change[ 1 ] ] = change[ 2 ]
            end  # for nodeReq in nodeReqs

            setTransitionAttributeChanges!( transition, changesDict )
        end  # if length( pars[ 10 ] ) > 2

        if length( pars[ 11 ] ) > 2
            setTransitionProbabilities!( transition,
                parse.( Float64, split( pars[ 11 ][ 2:(end-1) ] ) ) )
        end  # if length( pars[ 11 ] ) > 2

        return transition
    end  # map( eachindex( transitionPars[ :parName ] ) ) do ii

    setSimulationTransitions!( mpSim, transitions )

    transOrder = DataFrame( SQLite.Query( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Transition Order'" ) ) )

    if !isempty( transOrder ) && ( length( transOrder[ 1, :parValue ] ) > 2 )
        order = split.( split( transOrder[ 1, :parValue ], ";" ), ":" )
        orderDict = Dict{String, Int}()

        for orderPair in order
            orderDict[ orderPair[ 1 ] ] = parse( Int, orderPair[ 2 ] )
        end  # for orderPair in order

        setSimulationTransitionTypeOrder!( mpSim, orderDict )
    end  # if !isempty( nodeOrder ) && ...

end  # readTransitions( mpSim, configDB, configName )