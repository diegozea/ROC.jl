## GENERATE SYNTHETIC DATA:

function noisy(label; λ=0.0)
    if label
        return 1 - λ*rand()
    else
        return λ*rand()
    end
end

labels = rand(Bool, 200);

scores(λ) = map(labels) do label
    noisy(label, λ=λ)
end

## COMPARE AUC

using ROC

roc_good = roc(scores(0.6), labels, true);
roc_bad = roc(scores(1.0), labels, true);
area_good = AUC(roc_good)
area_bad =  AUC(roc_bad)


## PLOT THE ROC's

using Plots
pyplot()

plot(roc_good, label="good");
plot!(roc_bad, label="bad")

savefig("rocs.png")
