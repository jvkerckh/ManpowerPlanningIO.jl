__precompile__()

module ManpowerPlanningIO

    using ManpowerPlanning
    using SQLite
    using XLSX

    MP = ManpowerPlanning
    version = v"0.1.7"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v", MP.version,
        ") in Julia v", VERSION )

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
    include( joinpath( privPath, "compoundnode.jl" ) )
    include( joinpath( privPath, "recruitment.jl" ) )
    include( joinpath( privPath, "transition.jl" ) )
    include( joinpath( privPath, "retirement.jl" ) )

end # module ManpowerPlanningIO
