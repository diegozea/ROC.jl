## Data Preparation for ROC Analysis

struct _PreparedROCData{T<:Real}
	scores::AbstractVector{T}
	labels::AbstractVector{Bool}
end

function _create_preparedrocdata(scores, labels, distances::Bool)
	if distances
        order = sortperm(scores,rev=false)
		return( _PreparedROCData(scores[order],labels[order]) )
	else
		order = sortperm(scores,rev=true)
		return( _PreparedROCData(scores[order],labels[order]) )
	end
end

function _vector2labels(labels, truelabel)
    if length(unique(labels)) == 2 && truelabel in labels 
	return labels .== truelabel
    else
	error("labels needs two levels and truelabel should be one of the levels")
    end
end

function _preparedrocdata(scores, labels, distances)
	if length(scores) == length(labels)
		_create_preparedrocdata(scores,labels,distances)
	else
		error("scores and labels should have the same length")
	end
end

struct ROCData{T<:Real}
	scores::AbstractVector{T}
	labels::AbstractVector{Bool}
	P::Int
	n::Int
	N::Int
	ni::UnitRange{Int}
	TP::AbstractVector{Int}
	TN::AbstractVector{Int}
	FP::AbstractVector{Int}
	FN::AbstractVector{Int}
	FPR::AbstractVector{Float64}
	TPR::AbstractVector{Float64}
end

function roc(_preparedrocdata::_PreparedROCData)
	P = sum(_preparedrocdata.labels)
	n = length(_preparedrocdata.labels)+1 # ROC curve has one more point than length of labels
	N = n - P
	ni = 1:n
	TP = Array{Int}(undef,ni.stop)
	TN = Array{Int}(undef,ni.stop)
	FP = Array{Int}(undef,ni.stop)
	FN = Array{Int}(undef,ni.stop)
	FPR = Array{Float64}(undef,ni.stop)
	TPR = Array{Float64}(undef,ni.stop)
	for i in ni
		Pi = sum(_preparedrocdata.labels[1:i])
		TP[i] = Pi
		TN[i] = N - i + Pi
		FP[i] =	i - Pi
		FN[i] = P - Pi
		FPR[i] = ( i - Pi ) / N
		TPR[i] = Pi / P
	end
	ROCData(_preparedrocdata.scores, _preparedrocdata.labels, P, n, N, ni, TP, TN, FP, FN, FPR, TPR)
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

