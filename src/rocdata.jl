## Data Preparation for ROC Analysis

struct _PreparedROCData{T<:Real}
	scores::Vector{T}
	labels::BitVector
end

function _create_preparedrocdata(scores, labels, reverseordered::Bool)
	if reverseordered || issorted(scores,rev=true)
		return( _PreparedROCData(scores,labels) )
	else
		order = sortperm(scores,rev=true)
		return( _PreparedROCData(scores[order], labels[order]) )
	end
end

function _vector2labels(labels, truelabel)
    if length(unique(labels)) == 2 && truelabel in labels 
	return labels .== truelabel
    else
	error("labels needs two levels and truelabel should be one of the levels")
    end
end

function _preparedrocdata(scores, labels, reverseordered::Bool)
	if length(scores) == length(labels)
		_create_preparedrocdata(scores,labels,reverseordered)
	else
		error("scores and labels should have the same length")
	end
end

struct ROCData{T<:Real}
	scores::Vector{T}
	labels::BitVector
	P::Int
	n::Int
	N::Int
	ni::UnitRange{Int}
	TP::Vector{Int}
	TN::Vector{Int}
	FP::Vector{Int}
	FN::Vector{Int}
	FPR::Vector{Float64}
	TPR::Vector{Float64}
end

function roc(_preparedrocdata::_PreparedROCData)
	P = sum(_preparedrocdata.labels)
	n = length(_preparedrocdata.labels)
	N = n - P
	ni = 1:(n-1)
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

# no missing values and bitvector labels:
function roc(scores::AbstractVector{T}, labels::BitVector;
             reverseordered::Bool=false) where T <: Real
    return roc( _preparedrocdata(scores, labels, reverseordered) )
end

# no missing values (but labels not bitvector):
function roc(scores::AbstractVector{T}, labels::AbstractVector{L},
             truelabel::L; reverseordered::Bool=false) where {T<:Real, L}
    bit_labels = _vector2labels(labels, truelabel)
    return roc( _preparedrocdata(scores, bit_labels, reverseordered) )
end

# missing labels:
function roc(scores::AbstractVector{T}, labels::AbstractVector{Union{L, Missing}},
             truelabel::L; reverseordered::Bool=false) where {T<:Real, L}
    good_indices = .!(ismissing.(labels))
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata(scores[good_indices],
                                 bit_labels, reverseordered) )
end

# missing scores:
function roc(scores::AbstractVector{Union{T,Missing}}, labels::AbstractVector{L},
             truelabel::L; reverseordered::Bool=false) where {T<:Real, L}
    good_indices = .!(ismissing.(scores))
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata([scores[good_indices]...],
                                 bit_labels, reverseordered) )
end

# missing labels and missing scores:
function roc(scores::AbstractVector{Union{T,Missing}},
             labels::AbstractVector{Union{L,Missing}},
             truelabel::L; reverseordered::Bool=false) where {T<:Real, L}
    good_indices = .!( ismissing.(scores) .| ismissing.(labels) )
    bit_labels = _vector2labels(labels[good_indices], truelabel)
    return roc( _preparedrocdata([scores[good_indices]...],
                                 bit_labels, reverseordered) )
end

