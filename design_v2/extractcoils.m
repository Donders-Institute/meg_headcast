function coil = extractcoils(stl_withcoils, stl)

% EXTRACTCOILS extracts from a set of 2 stl files the coil meshes.
% 
% Use as
%
%  coil = extractcoils(stl_withcoils, stl)
%
% where stl_withcoils and stl are filenames of stl files. It is assumed
% that:
%
% stl and stl_withcoils represent the same mesh: the points are thus
% identical, up to the orientation of the triangles. With the triangles
% being differently oriented, the order of the 3 points per triangle may
% differ between the 2 representations.
%
% The stl format has the vertices of each triangle separately represented,
% which either leads to points being duplicated, or non-closed meshes. It
% will be checked whether the number of points will be 3x the number of
% triangles (which is not the case if the duplicated points are combined).

if ischar(stl_withcoils)
  mesh1 = ft_read_headshape(stl_withcoils);
else
  mesh1 = stl_withcoils;
end
if ischar(stl)
  mesh2 = ft_read_headshape(stl);
else
  mesh2 = stl;
end
assert(size(mesh1.pos,1)/3==size(mesh1.tri,1));
assert(size(mesh2.pos,1)/3==size(mesh2.tri,1));
assert(size(mesh1.pos,1)>size(mesh2.pos,1));

allcoils = mesh1;
allcoils.pos = allcoils.pos(size(mesh2.pos,1)+1:end,:);
allcoils.tri = allcoils.tri(1:size(allcoils.pos,1)/3,:);

delta = diff(allcoils.pos);
delta = mean(abs(delta./std(delta(:))),2);
[srt,ix] = sort(delta,'descend');
ix = sort(ix(1:2));

coil(1) = allcoils;
coil(1).pos = coil(1).pos(1:ix(1),:);
coil(1).tri = coil(1).tri(1:(size(coil(1).pos,1)./3),:);
coil(2) = allcoils;
coil(2).pos = coil(2).pos((ix(1)+1):ix(2),:);
coil(2).tri = coil(2).tri(1:(size(coil(2).pos,1)./3),:);
coil(3) = allcoils;
coil(3).pos = coil(3).pos((ix(2)+1):end,:);
coil(3).tri = coil(3).tri(1:(size(coil(3).pos,1)./3),:);







