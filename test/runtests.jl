using ROC
using Base.Test
using DataFrames

data = readtable("ROCRdata.csv")

curve = roc(data[:,1],data[:,2],1);

@test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
@test abs( AUC(curve, 0.01) - 0.000329615 ) < 0.000000001 # ROCR 0.0003296151
@test abs( AUC(curve, 0.1) - 0.0278062 ) < 0.0000001 # ROCR 0.02780625

# Are AUC and ROC consistent after permutation of scores and labels?
let perm = randperm(100), scores = rand(100), labels = [-ones(50);ones(50)]

  @test AUC(roc(scores,labels,1.0)) == AUC(roc(scores[perm],labels[perm],1.0))
end
