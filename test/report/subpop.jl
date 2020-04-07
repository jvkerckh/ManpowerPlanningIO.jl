@testset "Subpopulation report" begin

fName = "report/subpop"

subpop1 = Subpopulation( "Subpop 1" )
subpop2 = Subpopulation( "Subpop 2" )
subpop3 = Subpopulation( "Subpop 3" )

setSubpopulationSourceNode!.( [ subpop1, subpop2, subpop3 ], [ "", "Master",
    "Branch B" ] )

addSubpopulationCondition!( subpop1, MPcondition( "tenure", >=, 60 ) )
addSubpopulationCondition!( subpop2, MPcondition( "started as", ==,
    "A junior" ) )
addSubpopulationCondition!( subpop3, MPcondition( "isCareer", ==, "yes" ) )

excelSubpopReport( mpSim, 12, subpop1, subpop2, subpop3, filename = fName )
excelSubpopAgeReport( mpSim, 12, 12, :age, subpop1, subpop2, subpop3,
    filename = fName, overwrite = false )
excelSubpopAgeReport( mpSim, 12, 12, :tenure, subpop1, subpop2, subpop3,
    filename = fName, overwrite = false )
excelSubpopAgeReport( mpSim, 12, 12, :timeInNode, subpop1, subpop2, subpop3,
    filename = fName, overwrite = false )

end  # @testset "Subpopulation report"