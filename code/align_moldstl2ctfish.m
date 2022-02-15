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

pwdir = pwd;
[ftver, ftdir] = ft_version;

cd(fullfile(ftdir, 'private'));
[mold.pos, mold.tri] = remove_double_vertices(mold.pos, mold.tri);

cd(fullfile(ftdir, 'plotting/private'));
% for the nose:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(mold.pos, mold.tri, [270 0 0], [270 0 1], [270 1 0]);
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(pos, tri, [0 0 120], [1 0 120], [0 1 120]);
posorig = pos;
pos     = pos - mean(pos); % this actually not needed
% by construction, the 'circle' lies in the yz-plane between [-10 10], and [-36 -44]
sel = pos(:,2)>-10 & pos(:,2)<10 & pos(:,3)<-36 & pos(:,3)>-44;
nas = mean(posorig(sel,:)); % it might be better to do a circfit here

% for the lpa:
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(mold.pos, mold.tri, [0 245 0], [0 245 1], [1 245 0]);
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(pos, tri, [0 0 60], [0 1 60], [1 0 60]);
sel = pos(:,1)>130 & pos(:,1)<140 & pos(:,3)<50 & pos(:,3)>40;
lpa = mean(pos(sel,:)); % it might be better to do a circfit here

% for the rpa:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(mold.pos, mold.tri, [0 50 0], [0 50 1], [1 50 0]);
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(pos, tri, [0 0 60], [0 1 60], [1 0 60]);
sel = pos(:,1)>130 & pos(:,1)<140 & pos(:,3)<50 & pos(:,3)>40;
rpa = mean(pos(sel,:)); % it might be bettter to do a circfit here

transform_moldstl2ctfish = ft_headcoordinates(nas, lpa, rpa, 'ctf');
mold = ft_transform_geometry(transform_moldstl2ctfish, mold);

cd(pwdir);

