using ROC
using Base.Test  
using DataFrames

data = readtable("ROCRdata.csv")

curve = roc(data[:,1],data[:,2],1);

@test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
@test abs( AUC(curve, 0.01) - 0.000329615 ) < 0.000000001 # ROCR 0.0003296151
@test abs( AUC(curve, 0.1) - 0.0278062 ) < 0.0000001 # ROCR 0.02780625

