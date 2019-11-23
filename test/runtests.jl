using ROC
using DataFrames
using CSV
using Test
using Random


@testset "ROCR data" begin
    data = CSV.read(joinpath(@__DIR__, "data", "ROCRdata.csv"))
    scores = data[!, :predictions]
    labels = data[!, :labels]

    curve = roc(scores, labels)
    @test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
    @test abs( AUC(curve, 0.01) - 0.000329615 ) < 0.000000001 # ROCR 0.0003296151
    @test abs( AUC(curve, 0.1) - 0.0278062 ) < 0.0000001 # ROCR 0.02780625

    @testset "Missings" begin
        na_scores = [missing, scores[2:end]...]
        na_labels = [missing, labels[2:end]...]

        @test abs( AUC(roc(na_scores, labels)) - 0.834187 ) < 0.001
        @test abs( AUC(roc(scores,  na_labels)) - 0.834187 ) < 0.001
        @test abs( AUC(roc(na_scores, na_labels)) - 0.834187 ) < 0.001
    end

    @testset "BitVector" begin
        curve = roc(scores, BitVector(labels))
        @test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
    end

    @testset "Distances" begin
        curve = roc(1.0 .- scores, labels, distances=true)
        @test abs( AUC(curve) - 0.834187 ) < 0.000001 # ROCR 0.8341875
    end
end

# Are AUC and ROC consistent after permutation of scores and labels?
@testset "Permutations" begin
    perm = randperm(100)
    scores = rand(100)
    labels = [-ones(50); ones(50)]

    @test AUC(roc(scores, labels)) == AUC(roc(scores[perm], labels[perm]))
end

@testset "ROC analysis: web-based calculator for ROC curves' example" begin
    scores = [1 , 2 , 3 , 4 , 6 , 5 , 7 , 8 , 9 , 10]
    labels = [0 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 1 , 1]
    res = roc(scores, labels, 1)

    @test AUC(res) ≈ 0.96
    @test res.TPR == [0.0, 0.2, 0.4, 0.6, 0.8, 0.8, 1.0, 1.0, 1.0, 1.0, 1.0]
    @test res.FPR == [0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.4, 0.6, 0.8, 1.0]
end

@testset "Ties" begin
    # Example from https://www.epeter-stats.de/roc-curves-and-ties/
    # This package uses the first strategy, i.e.  AUC is equivalent to the
    # Mann-Whitney U statistic

    label = vcat([true for _ in 1:1000], [false for _ in 1:1000])
    pred = vcat(rand(7:14, 1000), rand(1:8, 1000))
    roc_data = roc(pred, label)
    @test abs( round(AUC(roc_data), digits=2) - 0.97 ) ≤ 0.015


    # Example from https://github.com/brian-lau/MatlabAUC/issues/1
    data = [-1 1; 1 2; -1 3; -1 4; 1 5; -1 6; 1 7; -1 8; 1 9; 1 10;
            1 11; -1 13; 1 13; 1 14; 1 14]
    roc_data = roc(data[:,2], data[:,1], 1)
    spss = [1.000 1.000
            1.000 .833
             .889 .833
             .889 .667
             .889 .500
             .778 .500
             .778 .333
             .667 .333
             .667 .167
             .556 .167
             .444 .167
             .333 .167
             .222 .000
             .000 .000]
    @test size(spss, 1) == length(roc_data.TPR)
    @test size(spss, 1) == length(roc_data.FPR)
    for i in 1:size(spss, 1)
        @test isapprox(roc_data.TPR[end - i + 1], spss[i, 1], atol=1e-3)
        @test isapprox(roc_data.FPR[end - i + 1], spss[i, 2], atol=1e-3)
    end
end

@testset "Distances and Ties" begin

    labels = Bool[false, true, false, false, true, false, true, false, true,
                  true, true, false, true, true, true]
    normal = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 13, 14, 14] # 14 is better
    distances = 14 .- normal # 0 is better
    roc_normal = roc(normal, labels)
    roc_distances = roc(distances, labels, distances=true)

    # Same ROC curve:
    @test roc_normal.TPR ≈ roc_distances.TPR
    @test roc_normal.FPR ≈ roc_distances.FPR
    @test AUC(roc_normal) ≈ AUC(roc_distances)
end
