module ROC

        using DataArrays,
              Missings
    

	export	ROCData,
		roc,
		AUC,
		PPV,
		cutoffs

	include("rocdata.jl")
	include("roc_main.jl")

end # module
