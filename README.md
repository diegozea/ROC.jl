![The Book of Knowledge, The Grolier Society, 1911](hhttps://dl.dropboxusercontent.com/u/6948655/ROC.jpg)

[![Build Status](https://travis-ci.org/diegozea/ROC.jl.svg)](https://travis-ci.org/diegozea/ROC.jl)

##ROC.jl

An implementation of [ROC curves](http://en.wikipedia.org/wiki/Receiver_operating_characteristic) for [Julia](http://julialang.org/).


# Installation

```
Pkg.clone("https://github.com/diegozea/ROC.jl.git")
```

# Use

```
roc(scores, labels::BitVector; reverseordered::Bool=false)
roc(scores, labels, truelabel; reverseordered::Bool=false)
```

This functions return a ```ROCData``` object
```ROCData``` can be used on ```AUC```, ```PPV``` and ```plot```

# Example

![Example](https://www.dropbox.com/s/v7xen8cwunwt8p4/ROC.png)


