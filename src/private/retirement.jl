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


function readRetirement( mpSim::MPsim, configDB::SQLite.DB,
    configName::String )

    retirePars = DataFrame( DBInterface.execute( configDB,
        string( "SELECT * FROM `", configName,
        "` WHERE parType IS 'Retirement'" ) ) )
    
    if !isempty( retirePars )
        retirement = Retirement()
        pars = split( retirePars[ 1, :parValue ], ";" )

        if ( tryparse( Float64, pars[ 1 ] ) isa Float64 ) &&
            ( tryparse( Float64, pars[ 2 ] ) isa Float64 )
            setRetirementSchedule!( retirement, parse( Float64, pars[ 1 ] ),
                parse( Float64, pars[ 2 ] ) )
        end  # if ( tryparse( Float64, pars[ 1 ] ) isa Float64 ) && ...

        if tryparse( Float64, pars[ 3 ] ) isa Float64
            setRetirementCareerLength!( retirement,
                parse( Float64, pars[ 3 ] ) )
        end  # if tryparse( Float64, pars[ 3 ] ) isa Float64

        if tryparse( Float64, pars[ 4 ] ) isa Float64
            setRetirementAge!( retirement, parse( Float64, pars[ 4 ] ) )
        end  # if tryparse( Float64, pars[ 4 ] ) isa Float64

        if tryparse( Bool, pars[ 5 ] ) isa Bool
            setRetirementIsEither!( retirement, parse( Bool, pars[ 5 ] ) )
        end  # if tryparse( Bool, pars[ 5 ] ) isa Bool

        setSimulationRetirement!( mpSim, retirement )
    end  # if !isempty( retirePars )

end  # readRetirement( mpSim, configDB, configName )