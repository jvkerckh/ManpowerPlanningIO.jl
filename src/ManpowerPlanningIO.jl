__precompile__()

module ManpowerPlanningIO

    using DataFrames
    using Dates
    using ManpowerPlanning
    using Plots
    using SQLite
    # using WebIO
    using XLSX

    MP = ManpowerPlanning
    version = v"0.6.0"

    export versionMPIO
    versionMPIO() = @info string( "Running version ", version,
        " of ManpowerPlanningIO module (ManpowerPlanning v", MP.version,
        ") in Julia v", VERSION )

    MPsim = ManpowerSimulation
    CR = XLSX.CellRange
    WS = XLSX.Worksheet
    XF = XLSX.XLSXFile
    privPath = "private"
    plotly()

    include( "configSim.jl" )
    include( joinpath( privPath, "base.jl" ) )
    include( joinpath( privPath, "attrition.jl" ) )
    include( joinpath( privPath, "attribute.jl" ) )
    include( joinpath( privPath, "basenode.jl" ) )
    include( joinpath( privPath, "compoundnode.jl" ) )
    include( joinpath( privPath, "recruitment.jl" ) )
    include( joinpath( privPath, "transition.jl" ) )
    include( joinpath( privPath, "retirement.jl" ) )
    include( joinpath( privPath, "initpop.jl" ) )
    include( "reporting/excelreports.jl" )
    include( "plotting/simulationplots.jl" )
    include( "excelrequest/exceloutputrequests.jl" )

end # module ManpowerPlanningIO
