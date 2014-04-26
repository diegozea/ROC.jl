!["The Book of Knowledge, The Grolier Society, 1911"](https://drive.google.com/file/d/0B3LhAPLJWKt9ZWNyalF4VjFTTWM/edit?usp=sharing)

[![Build Status](https://travis-ci.org/diegozea/ROC.jl.svg)](https://travis-ci.org/diegozea/ROC.jl)

**ROC.jl** is an implementation of [ROC curves](http://en.wikipedia.org/wiki/Receiver_operating_characteristic) for [Julia](http://julialang.org/).


# Installation

```Pkg.clone("https://github.com/diegozea/ROC.jl.git")```

# Use

```roc(scores, labels::BitVector; reverseordered::Bool=false)
roc(scores, labels, truelabel; reverseordered::Bool=false)```

This functions return a ```ROCData``` object
```ROCData``` can be used on ```AUC```, ```PPV``` and ```plot```

# Example

![Example](https://drive.google.com/file/d/0B3LhAPLJWKt9b3pzTFBtYXVQVzA/edit?usp=sharing)


