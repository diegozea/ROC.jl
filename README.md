![The Book of Knowledge, The Grolier Society, 1911](https://dl.dropboxusercontent.com/u/6948655/ROC.jpg)

Linux, OSX: [![Build Status](https://travis-ci.org/diegozea/ROC.jl.svg)](https://travis-ci.org/diegozea/ROC.jl)

Windows: [![Build status](https://ci.appveyor.com/api/projects/status/0v9fnq2s3w2xnggj/branch/master?svg=true)](https://ci.appveyor.com/project/diegozea/roc-jl/branch/master)

Code Coverage: [![Coverage Status](https://coveralls.io/repos/diegozea/ROC.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/diegozea/ROC.jl?branch=master) [![codecov.io](http://codecov.io/github/diegozea/ROC.jl/coverage.svg?branch=master)](http://codecov.io/github/diegozea/ROC.jl?branch=master)


# ROC.jl

An implementation of [ROC curves](http://en.wikipedia.org/wiki/Receiver_operating_characteristic) for [Julia](http://julialang.org/).

![](docs/rocs.png)

### Installation

```
Pkg.clone("https://github.com/diegozea/ROC.jl.git")
```

### Use

```
roc(scores::AbstractVector{T}, labels::AbstractVector{U}, truelabel::L; distancescored::Bool=false)
```

Here `T` is `R` or `Union{R,Missing}` for some type `R<:Real` and `U`
is `L` or `Union{L,Missing}` for some type `L<:Any`. The `labels`
vector must take exactly two non-`missing` values.

`distancescored` defines whether the `scores` values are distance-scored i.e. a higher score value means a larger difference. The default is `false` indicating the more typical case where a higher score value means a better match

```
roc(scores::AbstractVector{R}, labels::AbstractVector{Bool}; distancescored::Bool=false)
```

Alternative method for optimal performance (no `missing` values allowed).


The methods above return a `ROCData` object, whose fields `FPR` and
`TPR` are the vectors of true positive and false positive rates,
respectively. 

```
AUC(curve::ROCData)
```

Area under the curve.

```
PPV(curve::ROCData)
```
Positive predictive value.


### Example

Generate synthetic data:

````julia
julia> function noisy(label; λ=0.0)
           if label
               return 1 - λ*rand()
           else
               return λ*rand()
           end
       end

julia> labels = rand(Bool, 200);

julia> scores(λ) = map(labels) do label
           noisy(label, λ=λ)
       end
````

Compare area under ROC curves:

````julia
julia> using ROC

julia> roc_good = roc(scores(0.6), labels, true);
julia> roc_bad = roc(scores(1.0), labels, true);

julia> area_good = AUC(roc_good)
0.9436237564063913

julia> area_bad =  AUC(roc_bad)
0.5014571399859311
````

Use `Plots.jl` to plot the receiver operator characteristics:

````julia
julia> using Plots
julia> pyplot() # python backend

julia> plot(roc_good, label="good");
julia> plot!(roc_bad, label="bad")
````

This generates the plot appearing at the top of the page.



