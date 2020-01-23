function readAttritionSchemes( mpSim::MPsim, catXF::XF )

    if !( XLSX.hassheet( catXF, "General" ) &&
        XLSX.hassheet( catXF, "Attrition" ) )
        @warn "Catalogue file is missing a 'General' and 'Attrition' sheet, cannot confiugre attrition schemes."
        return
    end  # if !( XLSX.hassheet( catXF, "General" ) && ...

    ws = catXF[ "General" ]
    nAttrition = ws[ "B4" ] isa Integer ? ws[ "B4" ] : 0
    ws = catXF[ "Attrition" ]
    clearSimulationAttrition!( mpSim )

    attritionSchemes = readAttritionScheme.( Ref( ws ), (1:nAttrition) .+ 1 )
    setSimulationAttrition!( mpSim, attritionSchemes )

end  # readAttritionSchemes( mpSim, catXF )


function readAttritionScheme( ws::WS, sLine::Int )

    # Get the name of the scheme.
    name = ws[ sLine, 1 ]
    name = name isa Missing ? "default" : name

    attrition = Attrition( name )

    period = ws[ sLine, 2 ]
    period = period isa Real ? period : 1.0
    setAttritionPeriod!( attrition, period )

    nPoints = ws[ sLine, 3 ]
    
    if ( nPoints isa Integer ) && ( nPoints > 1 )
        curve = Dict{Float64, Float64}( period * ws[ sLine, 2*ii + 2 ] =>
            ws[ sLine, 2*ii + 3 ] for ii in 1:nPoints )
        setAttritionCurve!( attrition, curve )
    end  # if ( nPoints isa Integer ) && ( nPoints > 1 )

    return attrition

end  # readAttritionScheme( ws, sLine )