@testset "Subpopulation plots" begin

subpop1 = Subpopulation( "Subpop 1" )
subpop2 = Subpopulation( "Subpop 2" )
subpop3 = Subpopulation( "Subpop 3" )

setSubpopulationSourceNode!.( [ subpop1, subpop2, subpop3 ], [ "", "Master",
    "Branch B" ] )

addSubpopulationCondition!( subpop1, MPcondition( "tenure", >=, 60 ) )
addSubpopulationCondition!( subpop2, MPcondition( "started as", ==,
    "A junior" ) )
addSubpopulationCondition!( subpop3, MPcondition( "isCareer", ==, "yes" ) )

subpopPlot( mpSim, 12, subpop1, subpop2, subpop3 )
subpopAgePlot( mpSim, 12, 12, :age, subpop1, subpop2, subpop3 )
subpopAgePlot( mpSim, 12, 12, :tenure, subpop1, subpop2, subpop3 )
subpopAgePlot( mpSim, 12, 12, :timeInNode, subpop1, subpop2, subpop3 )
#=
subpopPlot( mpSim, 12, subpop1, subpop2, subpop3, showPlot=false,
    filename="plot/subpop plot test" )
subpopAgePlot( mpSim, 12, 12, :age, subpop1, subpop2, subpop3, showPlot=false,
    filename="plot/subpop age plot test 1" )
subpopAgePlot( mpSim, 12, 12, :tenure, subpop1, subpop2, subpop3,
    showPlot=false, filename="plot/subpop age plot test 2" )
subpopAgePlot( mpSim, 12, 12, :timeInNode, subpop1, subpop2, subpop3,
    showPlot=false, filename="plot/subpop age plot test 3" )
=#
end  # @testset "Subpopulation plots"