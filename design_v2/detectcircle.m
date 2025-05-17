function [pos, O, R] = detectcircle(pos, r, n)

% detect the origin of the circle(s) that are in a 3D point cloud, assuming
% that 1) there are one or more circles hidden, and 2) that the radius of the
% circle is r, and that the circle is described by at least n points
%
% use as
%   [] = detectcircle(pos, r, n)

% identify the points that have at least n points closer than 2*r, because
% those most likely belong to the circle
q   = squareform(pdist(pos,'euclidean'));
sel = sum(q<2.*r) > n;

% if the point cloud describes more or less 2 circles, the origin will be
% in the middle, probably that is not too bad
pos = pos(sel,:);
[O, R, d] = spherefit(pos);
