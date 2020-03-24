function readRetirement( mpSim::MPsim, xf::XF )

    if !XLSX.hassheet( xf, "Default retirement" )
        @warn "Configuration file is missing a 'Default retirement' sheet, cannot define a default, fallback retirement scheme for the organisation."
        return
    end  # if !XLSX.hassheet( xf, "Default retirement" )

    ws = xf[ "Default retirement" ]
    retirement = Retirement()

    # Set schedule of retirement.
    freq, offset = ws[ "B3" ], ws[ "B4" ]
    setRetirementSchedule!( retirement, freq isa Real ? freq : 0,
        offset isa Real ? offset : 0 )

    # Set retirement conditions.
    tenure, age = ws[ "B5" ], ws[ "B6" ]
    setRetirementCareerLength!( retirement,
        tenure isa Real ? tenure * 12.0 : 0.0 )
    setRetirementAge!( retirement, age isa Real ? age * 12.0 : 0.0 )
    setRetirementIsEither!( retirement, uppercase( ws[ "B7" ] ) == "EITHER" )

    setSimulationRetirement!( mpSim, retirement )

end  # readRetirement( mpSim, xf )