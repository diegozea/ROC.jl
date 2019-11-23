## Data Preparation for ROC Analysis

struct ROCData{T <: Real}
	thresholds::Vector{T}
	P::Int
	N::Int
	TP::Vector{Int}
	TN::Vector{Int}
	FP::Vector{Int}
	FN::Vector{Int}
	FPR::Vector{Float64}
	TPR::Vector{Float64}
end

function _thresholds(used_scores, distances::Bool)
	unique_scores = unique(used_scores)
	if distances
		push!(unique_scores, -∞)
		sort!(unique_scores, rev=false)
	else
		push!(unique_scores, ∞)
		sort!(unique_scores, rev=true)
	end
end

_is_valid_score(score) = isa(score, Number) ? !isnan(score) : false

function _prepare_data(scores, labels, distances::Bool, is_positive::Function)
	n_labels = length(labels)
	if length(scores) != n_labels
		throw(ArgumentError("scores and labels should have the same length."))
	end
	bit_labels = falses(n_labels)
	used_scores_type = promote_type(Missings.nonmissingtype(eltype(scores)), Infinite)
	used_scores = Vector{used_scores_type}(undef, n_labels)
	n_used = 0
	for (score, label) in zip(scores, labels)
		if _is_valid_score(score) && !ismissing(label)
			n_used += 1
			@inbounds bit_labels[n_used] = is_positive(label)
			@inbounds used_scores[n_used] = score
		end
	end
	resize!(bit_labels, n_used)
	resize!(used_scores, n_used)
	thresholds = _thresholds(used_scores, distances)
	(scores=used_scores, labels=bit_labels, thresholds=thresholds)
end

function _roc(scores, labels, thresholds, distances)
	P = sum(labels)
	N = length(labels) - P
	n_thresholds = length(thresholds)
	TP = Array{Int}(undef, n_thresholds)
	TN = Array{Int}(undef, n_thresholds)
	FP = Array{Int}(undef, n_thresholds)
	FN = Array{Int}(undef, n_thresholds)
	FPR = Array{Float64}(undef, n_thresholds)
	TPR = Array{Float64}(undef, n_thresholds)
	for (i, threshold) in enumerate(thresholds)
		if distances
			mask = scores .<= threshold
		else
			mask = scores .>= threshold
		end
		predicted_positive = labels[mask]
		predicted_negative = labels[.!mask]
		TPi = sum(predicted_positive)
		TNi = sum(.!predicted_negative)
        TP[i] = TPi
		TN[i] = TNi
		FP[i] =	length(predicted_positive) - TPi
		FN[i] = length(predicted_negative) - TNi
		FPR[i] = FP[i] / (FP[i] + TNi)
		TPR[i] = TPi / (TPi + FN[i])
	end
	ROCData{eltype(thresholds)}(thresholds, P, N, TP, TN, FP, FN, FPR, TPR)
end

function roc(scores, labels, is_positive::Function; distances::Bool=false)
	data =  _prepare_data(scores, labels, distances, is_positive)
	_roc(data.scores, data.labels, data.thresholds, distances)
end

function roc(scores, labels, positive_label; distances::Bool=false)
	roc(scores, labels, ==(positive_label); distances=distances)
end

function _get_positive_label(labels)
	unique_labels = unique(skipmissing(labels))
	try
		sort!(unique_labels)
	catch err
		if isa(err, MethodError)
			@warn "$unique_labels cannot be sorted. Positive: The last element."
		else
			rethrow(err)
		end
	end
	n_labels = length(unique_labels)
	if n_labels == 0
		throw(ArgumentError("There are not unique labels."))
	end
	positive = unique_labels[end]
	if n_labels == 1
		@warn "There is only one unique label. Positive: $positive"
	elseif n_labels > 2
		@warn "There are more than two unique labels. Positive: $positive"
	end
	positive
end

function roc(scores, labels; distances::Bool=false)
	if Missings.nonmissingtype(eltype(labels)) === Bool
		roc(scores, labels, identity; distances=distances)
	else
		positive =  _get_positive_label(labels)
		roc(scores, labels, ==(positive); distances=distances)
	end
end
