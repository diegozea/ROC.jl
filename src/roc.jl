## ROC Analysis


function AUC(roc::ROCData)
	auc=zero(Float64)
	for i in 2:(roc.ni.stop)
		dx = roc.FPR[i] - roc.FPR[i-1]
		dy = roc.TPR[i] - roc.TPR[i-1]
		auc += ( (dx*roc.TPR[i-1]) + (0.5*dx*dy) )
	end
	auc
end

function AUC(roc::ROCData,FPRstop::Float64)
	auc=zero(Float64)
	if FPRstop <= 0 || FPRstop >= 1
		error("FPRstop should be in (0,1)")
	end
	for i in 2:(roc.ni.stop)
		if roc.FPR[i] > FPRstop
			dx = roc.FPR[i] - roc.FPR[i-1]
			dy = roc.TPR[i] - roc.TPR[i-1]
			dxstop = FPRstop - roc.FPR[i-1]
			dystop = (dy/dx)*dxstop
			auc += ( (dxstop*roc.TPR[i-1]) + (0.5*dxstop*dystop) )	
			break
		end
		dx = roc.FPR[i] - roc.FPR[i-1]
		dy = roc.TPR[i] - roc.TPR[i-1]
		auc += ( (dx*roc.TPR[i-1]) + (0.5*dx*dy) )
	end
	auc
end

PPV(roc::ROCData) = roc.TP ./ roc.ni 
PPV(roc::ROCData,n::Int) = roc.TP[roc.ni .== n ] / n

cutoffs(roc::ROCData) = roc.scores[roc.ni]

