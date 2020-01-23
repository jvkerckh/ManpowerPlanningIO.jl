__precompile__()

module ManpowerPlanningIO

    using ManpowerPlanning
    using SQLite
    using XLSX

    version = v"0.1.2"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v",
        ManpowerPlanning.version, ") in Julia v", VERSION )

    MPsim = ManpowerSimulation
    CR = XLSX.CellRef
    WS = XLSX.Worksheet
    XF = XLSX.XLSXFile
    privPath = "private"

    include( "configSim.jl" )
    include( joinpath( privPath, "base.jl" ) )
    include( joinpath( privPath, "attrition.jl" ) )

end # module ManpowerPlanningIO
