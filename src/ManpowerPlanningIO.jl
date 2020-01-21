__precompile__()

module ManpowerPlanningIO

    using ManpowerPlanning
    using XLSX

    version = v"0.1.0"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v",
        ManpowerPlanning.version, ") in Julia v", VERSION )

end # module ManpowerPlanningIO
