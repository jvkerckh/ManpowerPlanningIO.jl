@testset "Transition configuration tests" begin
    mpSim = MPsim()
    filePath = joinpath( "base", "baseConfig" )
    fileName = string( filePath, ".xlsx" )
    catFileName = joinpath( "base", "catalogue.xlsx" )

    XLSX.openxlsx( fileName ) do xf
        XLSX.openxlsx( catFileName ) do catXF
            MPIO.readAttributes( mpSim, xf, catXF )
            MPIO.readBaseNodes( mpSim, xf, catXF )
            MPIO.readCompoundNodes( mpSim, xf, catXF )
        end  # XLSX.openXLSX( catFileName ) do xf

        MPIO.readTransitions( mpSim, xf )
    end  # XLSX.openxlsx( fileName ) do xf

    @test length( mpSim.transitionTypeOrder ) == 5
    @test ( length( mpSim.recruitmentByName ) == 1 ) &&
        ( length( mpSim.recruitmentByTarget ) == 3 )
    @test ( length( mpSim.transitionsByName ) == 4 ) &&
        ( length( mpSim.transitionsBySource ) == 6 ) &&
        ( length( mpSim.transitionsByTarget ) == 4 )

end  # @testset "Transition configuration tests"