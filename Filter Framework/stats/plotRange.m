function plotRange(xBinCenters, points, percentileRange ,color)

%plotRange(xBinCenters, points, percentileRange ,color)
%
%Bins the points and plots the median +- percentile as a shaded regions
%above and below the median line
%
%Inputs:
%xBinCenters: the center values of the bins used to compute the median and range
%points:  an n-by-2 matrix with all the data points [xvalues yvalues]
%percentileRange:  a 1-by-2 vector with the lower and upper percentiles between 0 and 100 (50 is the median value)
%color: the color to use in RGB, example [1 0 0] is red
%
%Example:
%plotRange([0:.1:1],rand(10000,2),[25 75], [1 0 0])
%

xBinCenters = xBinCenters(:);
xpoints = xBinCenters(lookup(points(:,1),xBinCenters));
plotinfo = [];
for i = 1:length(xBinCenters)
    tmpind = find(xpoints == xBinCenters(i));
    tmprange = prctile(points(tmpind,2),[percentileRange(1) 50 percentileRange(2)]);
    tmprange(2) = mean(points(tmpind,2));
    plotinfo(i,1:3) = tmprange;
end

fillXpoints = [xBinCenters;flipud(xBinCenters)];
fillYpoints = [plotinfo(:,1);flipud(plotinfo(:,3))];

fill(fillXpoints,fillYpoints,(color+[2 2 2])/3,'EdgeColor',color)
hold on
plot(xBinCenters,plotinfo(:,2),'color',color);

