__precompile__()
module ROC

using 	Missings,
		RecipesBase # for creating a Plots.jl recipe

export	ROCData,
		roc,
		AUC,
		PPV,
		cutoffs

include("rocdata.jl")
include("roc_main.jl")
include("rocplot.jl")

end # module
