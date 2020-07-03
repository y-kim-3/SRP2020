function out = pointOnCircle(centerCoord, radius, theta)

xcoords = centerCoord(1) + (radius * cosd(theta));
ycoords = centerCoord(2) + (radius * sind(theta));

out = [xcoords(:) ycoords(:)];