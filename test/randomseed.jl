rm( "base/baseConfig2", recursive=true, force=true )
mpSim, isOkay = runFromExcel( joinpath( "base", "baseConfig2" ),
    showInfo=false )
report = nodePopReport( mpSim, 12, "Junior" )
results = Int.( report[:, "Junior"] )
@test all( results .== [189, 187, 123, 124, 100, 151, 164, 138, 145, 115, 160,
    157, 150, 139, 100, 181, 169, 111, 140, 122, 121, 124, 121, 154, 162, 106] )

rm( "base/baseConfig2b", recursive=true, force=true )
mpSim, isOkay = runFromExcel( joinpath( "base", "baseConfig2b" ),
    showInfo=false )
report = nodePopReport( mpSim, 12, "Junior" )
@test all( Int.( report[:, "Junior"] ) .== results )

rm( "base/baseConfig3", recursive=true, force=true )
mpSim, isOkay = runFromExcel( joinpath( "base", "baseConfig3" ),
    showInfo=false )
report = nodePopReport( mpSim, 12, "Junior" )
@test Int.( report[:, "Junior"] ) != results

rm( "base/baseConfig4", recursive=true, force=true )
mpSim, isOkay = runFromExcel( joinpath( "base", "baseConfig4" ),
    showInfo=false )
report = nodePopReport( mpSim, 12, "Junior" )
@test Int.( report[:, "Junior"] ) != results

rm( "base/baseConfig5", recursive=true, force=true )
mpSim, isOkay = runFromExcel( joinpath( "base", "baseConfig5" ),
    showInfo=false )
report = nodePopReport( mpSim, 12, "Junior" )
@test Int.( report[:, "Junior"] ) != results