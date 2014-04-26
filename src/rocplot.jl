## Plotting ROC Curve

## using Winston

function plot(roc::ROCData) 
	p = FramedPlot(
	         aspect_ratio=1,
	         xrange=(0,1),
	         yrange=(0,1))
	setattr(p.x1, label="FPR")
	setattr(p.y1, label="TPR")
	add(p, Curve(roc.FPR, roc.TPR) )
	line = Slope(1, (0,0), kind="dotted")
	add(p, line)
end
