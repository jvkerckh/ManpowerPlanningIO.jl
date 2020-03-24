distTypes = Dict( "Pointwise" => :disc,
    "Piecewise Uniform" => :pUnif,
    "Piecewise Linear" => :pLin )


function readRecruitment( mpSim::MPsim, xf::XF )

    if !XLSX.hassheet( xf, "IN Transitions" )
        @warn "Configuration file is missing a 'IN Transitions' sheet, cannot read recruitment."
        return
    end  # if !XLSX.hassheet( xf, "IN Transitions" )

    ws = xf[ "IN Transitions" ]
    nTrans = ws[ "B3" ] isa Integer ? max( ws[ "B3" ], 0 ) : 0

    # Read the recruitment schemes.
    for dataColNr in (1:nTrans) * 5 .- 3

        # Retrieve basic recruitment scheme information.
        name = ws[ 5, dataColNr ]

        if name isa Missing
            continue
        end  # if name isa Missing

        recruitment = Recruitment( string( name ) )
        freq, offset = ws[ 6, dataColNr ], ws[ 7, dataColNr ]
        setRecruitmentSchedule!( recruitment, freq, offset )
        targetNode = ws[ 8, dataColNr ]

        if targetNode isa Missing
            @warn string( "No target given for recruitment scheme ", name, ",
                skipping." )
            continue
        end  # if targetNode isa Missing

        setRecruitmentTarget!( recruitment, targetNode )
        addSimulationRecruitment!( mpSim, recruitment )
        
        # Retrieve number to recruit.
        isAdaptive = ws[ 11, dataColNr ] == "YES"
        isRandom = ws[ 12, dataColNr ] == "YES"
        nRow = 16
        numNodes = ws[ nRow + 1, dataColNr ]

        if isAdaptive
            minRec, maxRec = ws[ 9, dataColNr ], ws[ 10, dataColNr ]
            minRec = minRec isa Integer ? max( minRec, 0 ) : 0
            maxRec = maxRec isa Integer ? maxRec : -1
            setRecruitmentAdaptiveRange!( recruitment, minRec, MaxRec )
        elseif isRandom
            distType = get( distTypes, ws[ nRow, dataColNr ], :disc )
            minNodes = distType === :disc ? 1 : 2
            recDist = Dict{Int, Float64}()
    
            for ii in (1:numNodes) .+ 2
                node = ws[ nRow + ii, dataColNr ]
                weight = ws[ nRow + ii, dataColNr + 1 ]
    
                if ( node isa Integer ) && !haskey( recDist, node ) &&
                    ( node >= 0 ) && ( weight >= 0 )
                    recDist[ node ] = weight
                end  # if ( node isa Integer ) && ...
            end  # for ii in (1:numNodes) .+ 2
    
            if length( recDist ) < minNodes
                @warn string( "Insufficient number of valid nodes defined for ",
                    "the distribution of the number of people to recruit ",
                    "using recruitment scheme ", name, ", skipping." )
                continue
            end  # if length( recDist ) < minNodes
    
            setRecruitmentDist!( recruitment, distType, recDist )
        else
            nRecruit = ws[ 10, dataColNr ]
            nRecruit = nRecruit isa Integer ? max( nRecruit, 0 ) : 0
            setRecruitmentFixed!( recruitment, nRecruit )
        end  # if isAdaptive

        # Retrieve recruitment age.
        if ws[ 13, dataColNr ] == "YES"
            recAge = ws[ 14, dataColNr ]
            recAge = recAge isa Real ? max( recAge * 12.0, 0.0 ) : 0.0
            setRecruitmentAgeFixed!( recruitment, recAge )
        else
            # Get to the start of the age distribution
            nRow += numNodes + 4
            distType = get( distTypes, ws[ nRow, dataColNr ], :disc )
            minNodes = distType === :disc ? 1 : 2
            numNodes = sheet[ nRow + 1, dataColNr ]
            ageDist = Dict{Float64, Float64}()
    
            for ii in (1:numNodes) .+ 2
                age = sheet[ XLSX.CellRef( nRow + ii, dataColNr ) ]
                pMass = sheet[ XLSX.CellRef( nRow + ii, dataColNr + 1 ) ]
    
                # Only add the entry if it makes sense.
                if ( age isa Real ) && !haskey( ageDist, age ) &&
                    ( age >= 0 ) && ( pMass >= 0 )
                    ageDist[ age * 12.0 ] = pMass
                end  # if ( age isa Real ) && ...
            end  # for ii in (1:numNodes) .+ 2
    
            if length( ageDist ) < minNodes
                @warn string( "Insufficient number of valid nodes defined for ",
                    "the distribution of the recruitment age of recruitment ",
                    "scheme ", name, ", skipping." )
                continue
            end  # if length( ageDist ) < minNodes
    
            setRecruitmentAgeDist!( recruitment, distType, ageDist )
        end  # if ws[ 13, dataColNr ] == "YES"
    end  # for dataColNr in (1:nTrans) * 5 .- 3

end  # readRecruitment( mpSim, xf )