@recipe function dummy(curve::ROCData)
    xlim := (0,1)
    ylim := (0,1)
    xlab := "false positive rate"
    ylab := "true positive rate"
    title --> "Receiver Operator Characteristic"
    @series begin
        color --> :black
        linestyle --> :dash
        label := ""
        [0, 1], [0, 1]
    end
    @series begin
        curve.FPR, curve.TPR
    end
end

