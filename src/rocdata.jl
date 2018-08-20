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

function _vector2labels(labels::Vector{T},truelabel::T) where T
	if length(unique(labels)) == 2 && truelabel in labels
		labels .== truelabel
	else
		error("labels needs two levels and truelabel should be one of the levels")
	end
end

function _preparedrocdata(scores::Vector{T}, labels::BitVector, reverseordered::Bool) where T <: Real
	if length(scores) == length(labels)
		_create_preparedrocdata(scores,labels,reverseordered)
	else
		error("scores and labels should have the same length")
	end
end

function _preparedrocdata(scores::Vector{T}, labels::Vector{L}, truelabel::L, reverseordered::Bool) where {T<:Real,L}
	if length(scores) == length(labels)
		bitlabels = _vector2labels(labels,truelabel)
		_create_preparedrocdata(scores,bitlabels,reverseordered)
	else
		error("scores and labels should have the same length")
	end
end

## using DataArrays

function _vector2labels(labels::PooledDataArray{T},truelabel::T) where T
	indexvalue = findin(labels.pool,[truelabel])[1]
	if length(labels.pool) == 2 && indexvalue != 0
		labels.refs .== indexvalue
	else
		error("labels needs two levels and truelabel should be one of the levels")
	end
end

function _preparedrocdata(scores::Vector{T}, labels::PooledDataArray{L}, truelabel::L, reverseordered::Bool) where {T<:Real,L}
	na = ismissing.(labels)
	if length(scores) == length(labels)
		bitlabels = _vector2labels(labels,truelabel)
		_create_preparedrocdata(scores[!na],bitlabels[!na],reverseordered)
	else
		error("scores and labels should have the same length")
	end
end

function _preparedrocdata(scores::DataArray{T}, labels::DataArray{L}, truelabel::L, reverseordered::Bool) where {T<:Real,L}
	na = ismissing.(labels) | ismissing.(scores)
	_preparedrocdata(convert(Vector{T},scores[!na]),convert(Vector{L},labels[!na]),truelabel,reverseordered)
end

function _preparedrocdata(scores::DataArray{T}, labels::PooledDataArray{L}, truelabel::L,
                          reverseordered::Bool) where {T<:Real,L}
	na = ismissing.(labels) | ismissing.(scores)
	_preparedrocdata(convert(Vector{T},scores[!na]),labels[!na],truelabel,reverseordered)
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
	TP = Array{Int}(ni.stop)
	TN = Array{Int}(ni.stop)
	FP = Array{Int}(ni.stop)
	FN = Array{Int}(ni.stop)
	FPR = Array{Float64}(ni.stop)
	TPR = Array{Float64}(ni.stop)
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

roc(scores::AbstractVector{T}, labels::BitVector; reverseordered::Bool=false) where T <: Real =
    roc( _preparedrocdata(scores, labels, reverseordered) )
roc(scores::AbstractVector{T}, labels::AbstractVector{L}, truelabel::L; reverseordered::Bool=false) where {T<:Real, L} =
    roc( _preparedrocdata(scores, labels, truelabel, reverseordered) )

