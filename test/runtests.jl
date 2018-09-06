using ROC
using Base.Test
using DataFrames
using CSV
using Missings

data = CSV.read("ROCRdata.csv")
scores = data[1]
labels = data[2]


# purify types incorrectly parsed by CSV.read as Union{T,Missing}:
scores = [scores...]
labels = [labels...]

curve = roc(scores, labels, 1);

@test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
@test abs( AUC(curve, 0.01) - 0.000329615 ) < 0.000000001 # ROCR 0.0003296151
@test abs( AUC(curve, 0.1) - 0.0278062 ) < 0.0000001 # ROCR 0.02780625

# Are AUC and ROC consistent after permutation of scores and labels?
let perm = randperm(100), scores = rand(100), labels = [-ones(50);ones(50)]

  @test AUC(roc(scores,labels,1.0)) == AUC(roc(scores[perm],labels[perm],1.0))
end

## TEST DISPATCH ON MISSING VALUE TYPES

bad_scores = [missing, scores[2:end]...]
bad_labels = [missing, labels[2:end]...]

curve = roc(bad_scores, labels, 1);
@test abs( AUC(curve) - 0.834187 ) < 0.001

curve = roc(scores,  bad_labels, 1);
@test abs( AUC(curve) - 0.834187 ) < 0.001

curve = roc(bad_scores, bad_labels, 1);
@test abs( AUC(curve) - 0.834187 ) < 0.001

bit_labels = BitVector(labels)
curve = roc(scores, bit_labels);
@test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
