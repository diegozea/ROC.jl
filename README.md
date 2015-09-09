![The Book of Knowledge, The Grolier Society, 1911](https://dl.dropboxusercontent.com/u/6948655/ROC.jpg)

Linux, OSX: [![Build Status](https://travis-ci.org/diegozea/ROC.jl.svg)](https://travis-ci.org/diegozea/ROC.jl)

Windows: [![Build status](https://ci.appveyor.com/api/projects/status/0v9fnq2s3w2xnggj/branch/master?svg=true)](https://ci.appveyor.com/project/diegozea/roc-jl/branch/master)

Code Coverage: [![Coverage Status](https://coveralls.io/repos/diegozea/ROC.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/diegozea/ROC.jl?branch=master) [![codecov.io](http://codecov.io/github/diegozea/ROC.jl/coverage.svg?branch=master)](http://codecov.io/github/diegozea/ROC.jl?branch=master)


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

![Example](https://dl.dropboxusercontent.com/u/6948655/ROC.png)


