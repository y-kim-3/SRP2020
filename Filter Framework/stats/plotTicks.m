function plotTicks(spikeTimes, offset, height)

X = [spikeTimes(:)'; spikeTimes(:)'];
Y = ones(size(X))*offset;
Y(1,:) = Y(1,:)+(height/2);
Y(2,:) = Y(2,:)-(height/2);
line(X,Y,'Color',[0 0 0]);


