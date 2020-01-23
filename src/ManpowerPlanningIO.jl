__precompile__()

module ManpowerPlanningIO

    using ManpowerPlanning
    using SQLite
    using XLSX

    version = v"0.1.1"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v",
        ManpowerPlanning.version, ") in Julia v", VERSION )

    MPsim = ManpowerSimulation
    WS = XLSX.Worksheet
    privPath = "private"

    include( "configSim.jl" )
    include( joinpath( privPath, "base.jl" ) )

end # module ManpowerPlanningIO
