## Data Preparation for ROC Analysis

struct _PreparedROCData{T<:Real}
	scores::Vector{T}
	labels::Vector{Bool}
	thresholds::Vector{T}
	distances::Bool
end

function _create_preparedrocdata(scores::AbstractVector{T},
								 labels,
								 distances::Bool) where {T <: Real}
	thresholds = unique(scores)
	if distances
		sort!(thresholds, rev=false)
		push!(thresholds, typemax(T))
	else
		sort!(thresholds, rev=true)
		push!(thresholds, typemin(T))
	end
	_PreparedROCData(
		convert(Vector{T}, scores),
		convert(Vector{Bool}, labels),
		convert(Vector{T}, thresholds),
		distances)
end

function _vector2labels(labels::AbstractVector{T}, truelabel::T) where T
	binary = Vector{Bool}(undef, length(labels))
	unique_labels = Set{T}()
	for (i, label) in enumerate(labels)
		push!(unique_labels, label)
		if length(unique_labels) > 2
			error("There is more than two labels.")
		end
		binary[i] = label == truelabel
	end
	if !(truelabel in unique_labels)
		error("The truelabel is not in labels.")
	end
	binary
end

function _preparedrocdata(scores, labels, distances)
	if length(scores) == length(labels)
		_create_preparedrocdata(scores,labels,distances)
	else
		error("scores and labels should have the same length")
	end
end

struct ROCData{T<:Real}
	scores::Vector{T}
	labels::Union{Vector{Bool},BitVector}
	thresholds::Vector{T}
	P::T
	N::Int
	TP::Vector{Int}
	TN::Vector{Int}
	FP::Vector{Int}
	FN::Vector{Int}
	FPR::Vector{Float64}
	TPR::Vector{Float64}
end

function roc(data::_PreparedROCData)
	P = sum(data.labels)
	N = length(data.labels) - P
	n_thresholds = length(data.thresholds)
	TP = Array{Int}(undef, n_thresholds)
	TN = Array{Int}(undef, n_thresholds)
	FP = Array{Int}(undef, n_thresholds)
	FN = Array{Int}(undef, n_thresholds)
	FPR = Array{Float64}(undef, n_thresholds)
	TPR = Array{Float64}(undef, n_thresholds)
	for (i, threshold) in enumerate(data.thresholds)
		if data.distances
			mask = data.scores .<= threshold
		else
			mask = data.scores .>= threshold
		end
		predicted_positive = data.labels[mask]
		predicted_negative = data.labels[.!mask]
		TPi = sum(predicted_positive)
		TNi = sum(.!predicted_negative)
        TP[i] = TPi
		TN[i] = TNi
		FP[i] =	length(predicted_positive) - TPi
		FN[i] = length(predicted_negative) - TNi
		FPR[i] = FP[i] / (FP[i] + TNi)
		TPR[i] = TPi / (TPi + FN[i])
	end
	ROCData{eltype(data.scores)}(
		data.scores,
		data.labels,
		data.thresholds, P, N, TP, TN, FP, FN, FPR, TPR)
end

# no missing values and AbstractVector{Bool} labels:
function roc(scores::AbstractVector{T}, labels::AbstractVector{Bool};
             distances::Bool=false) where T <: Real
    return roc( _preparedrocdata(scores, labels, distances) )
end

# no missing values (but labels not AbstractVector{Bool}):
function roc(scores::AbstractVector{T}, labels::AbstractVector{L},
             truelabel::L; distances::Bool=false) where {T<:Real, L}
    bit_labels = _vector2labels(labels, truelabel)
    return roc( _preparedrocdata(scores, bit_labels, distances) )
end

# missing labels:
function roc(scores::AbstractVector{T}, labels::AbstractVector{Union{L, Missing}},
             truelabel::L; distances::Bool=false) where {T<:Real, L}
    good_indices = .!(ismissing.(labels))
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata(scores[good_indices],
                                 bit_labels, distances) )
end

# missing scores:
function roc(scores::AbstractVector{Union{T,Missing}}, labels::AbstractVector{L},
             truelabel::L; distances::Bool=false) where {T<:Real, L}
    good_indices = .!(ismissing.(scores))
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata([scores[good_indices]...],
                                 bit_labels, distances) )
end

# missing labels and missing scores:
function roc(scores::AbstractVector{Union{T,Missing}},
             labels::AbstractVector{Union{L,Missing}},
             truelabel::L; distances::Bool=false) where {T<:Real, L}
    good_indices = .!( ismissing.(scores) .| ismissing.(labels) )
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata([scores[good_indices]...],
                                 bit_labels, distances) )
end
