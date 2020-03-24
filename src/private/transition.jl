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