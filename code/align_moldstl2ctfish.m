function [mold, transform_moldstl2ctfish] = align_moldstl2ctfish

% ALIGN_MOLDSTL2CTFISH aligns the stl-file of the helmet shaped mold to
% an ALS coordinate system that is defined by the screw holes that are
% used to fixate the printed head surface. This CTFISH coordinate system
% can also be unequivocally identified in the printed head surface, which
% allows for the coregistration between SURFACE and MOLD.

datadir = '/home/dyncon/jansch/projects/meg_headcast/models/orig';
mold    = ft_read_headshape(fullfile(datadir, 'dewar_mold.stl'));
mold.coordsys = 'als';

% cut off a few slices to be able to identify the screw holes that can be
% used for unambiguous coregistration, the recipe is hard coded based on
% inspection of the data, and only works for the file specified above.
maxpos = max(mold.pos, [], 1);
minpos = min(mold.pos, [], 1);

% for the nose:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(mold.pos, mold.tri, [270 0 0], [270 0 1], [270 1 0]);
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(pos, tri, [0 0 120], [1 0 120], [0 1 120]);
posorig = pos;
meanpos = mean(posorig);
pos     = pos - meanpos; % this actually not needed

% the tilted circle lies in the yz-plane between [-10 10], and [-36 -44]
sel = pos(:,2)>-10 & pos(:,2)<10 & pos(:,3)<-36 & pos(:,3)>-44;
pnt = pos(sel,:);
origin = mean(pnt);
pnt = pnt - origin;

% check whether the origin of the circle is indeed in the 'meanpnt', or can
% be improved a bit
[u, s, v]   = svd(pnt, 'econ');
[Oy, Oz, R] = circfit(pnt*v(:,1),pnt*v(:,2));
nas         = [0 Oy Oz];
nas         = nas + origin + meanpos

% for the lpa:
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(mold.pos, mold.tri, [0 245 0], [0 245 1], [1 245 0]);
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(pos, tri, [0 0 60], [0 1 60], [1 0 60]);
sel = pos(:,1)>130 & pos(:,1)<140 & pos(:,3)<50 & pos(:,3)>40;
pnt = pos(sel,:);
origin = mean(pnt);
pnt = pnt - origin;

% check whether the origin of the circle is indeed in the 'meanpnt', or can
% be improved a bit
[u, s, v]   = svd(pnt, 'econ');
[Ox, Oz, R] = circfit(pnt*v(:,1),pnt*v(:,2));
lpa         = [Ox 0 Oz];
lpa         = lpa + origin;

% for the rpa:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(mold.pos, mold.tri, [0 50 0], [0 50 1], [1 50 0]);
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(pos, tri, [0 0 60], [0 1 60], [1 0 60]);
sel = pos(:,1)>130 & pos(:,1)<140 & pos(:,3)<50 & pos(:,3)>40;
pnt = pos(sel,:);
origin = mean(pnt);
pnt = pnt - origin;

% check whether the origin of the circle is indeed in the 'meanpnt', or can
% be improved a bit
[u, s, v]   = svd(pnt, 'econ');
[Ox, Oz, R] = circfit(pnt*v(:,1),pnt*v(:,2));
rpa         = [Ox 0 Oz];
rpa         = rpa + origin;

transform_moldstl2ctfish = ft_headcoordinates(nas, lpa, rpa, 'ctf');
mold = ft_transform_geometry(transform_moldstl2ctfish, mold);

