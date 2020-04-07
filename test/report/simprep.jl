mpSim, isOkay = initialiseFromDB( "db/simDB", showInfo = false )
run( mpSim )
@test now( mpSim ) == 300.0