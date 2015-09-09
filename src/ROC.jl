module ROC

	using DataArrays
	using Winston

	export	ROCData,
		roc,
		AUC,
		PPV,
		cutoffs,
		plot

	include("rocdata.jl")
	include("roc_main.jl")
	include("rocplot.jl")

end # module
