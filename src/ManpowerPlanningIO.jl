__precompile__()

module ManpowerPlanningIO

    using ManpowerPlanning
    using SQLite
    using XLSX

    version = v"0.1.4"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v",
        ManpowerPlanning.version, ") in Julia v", VERSION )

    MPsim = ManpowerSimulation
    CR = XLSX.CellRange
    WS = XLSX.Worksheet
    XF = XLSX.XLSXFile
    privPath = "private"

    include( "configSim.jl" )
    include( joinpath( privPath, "base.jl" ) )
    include( joinpath( privPath, "attrition.jl" ) )
    include( joinpath( privPath, "attribute.jl" ) )
    include( joinpath( privPath, "basenode.jl" ) )

end # module ManpowerPlanningIO
