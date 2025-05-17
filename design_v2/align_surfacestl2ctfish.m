function [surface, transform_surfacestl2ctfish, hfig] = align_surfacestl2ctfish(surface)

% ALIGN_SURFACESTL2CTFISH aligns the to-be-printed surface model of the head
% that is decorated with earflaps, visor and screwholes to a CTF'ish coordinate
% system, which is defined by the screwholes. The innersurface of the mold
% (i.e. the surface that describes the outside of the head cast) has
% similar screwholes, which can be used to register those 2 objects, using
% the fiducial location information from both objects

if nargin<1
  datadir = '/project/3015999.02/jansch_sandbox/bobbra/stl';
  surface = ft_read_headshape(fullfile(datadir, 'Headcore 3D-print file_Sub-004.STL'));
  %surface = ft_determine_coordsys(surface);
  surface.coordsys = 'lip'; % this is the case for the above file
end
if ischar(surface)
  surface = ft_read_headshape(surface);
end
if ~isfield(surface, 'coordsys')
  surface = ft_determine_coordsys(surface);
end
if ~isequal(surface.coordsys, 'als')
  M0      = transform_generic(surface.coordsys, 'als');
  surface = ft_convert_coordsys(surface, 'als');
else
  M0      = eye(4);
end

% shift the surface to the origin
mpos = mean(surface.pos);
surface.pos = surface.pos - mpos;
T = eye(4); T(1:3, 4) = -mpos;

% cut off a few slices to be able to identify the screw holes that can be
% used for unambiguous coregistration, the recipe is hard coded based on
% inspection of the data, and may only work for the file specified above.
maxpos = max(surface.pos, [], 1);
minpos = min(surface.pos, [], 1);

[surface.pos, surface.tri] = remove_double_vertices(surface.pos, surface.tri);

r = 2.5;
n = 30;


% for the nose:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(surface.pos, surface.tri, [118 0 0], [118 0 1], [118 1 0]);

[posnas, nas, R] = detectcircle(pos, r, n);
%sel = pos(:,2)>-4 & pos(:,2)<4 & pos(:,3)<-62 & pos(:,3)>-70;
%nas = mean(pos(sel,:));
%nas = O;

% for the lpa:
[X, Y, Z, pos, tri, pos1, tri1] = intersect_plane(surface.pos, surface.tri, [0 92 0], [0 92 1], [1 92 0]);
[poslpa, lpa, R] = detectcircle(pos, r, n);

%sel = pos(:,1)>-17.5 & pos(:,1)<-11 & pos(:,3)<-63 & pos(:,3)>-69;
%lpa = mean(pos(sel,:));

% for the rpa:
[X, Y, Z, pos1, tri1, pos, tri] = intersect_plane(surface.pos, surface.tri, [0 -92 0], [0 -92 1], [1 -92 0]);
[posrpa, rpa, R] = detectcircle(pos, r, n);

%sel = pos(:,1)>-17.5 & pos(:,1)<-11 & pos(:,3)<-63 & pos(:,3)>-69;
%rpa = mean(pos(sel,:));

M       = ft_headcoordinates(nas, lpa, rpa, 'ctf'); % T has already been applied
surface = ft_transform_geometry(M, surface);
surface.fid.pos   = ft_warp_apply(M, [nas;lpa;rpa]);
surface.fid.label = {'nas';'lpa';'rpa'};

pos = ft_warp_apply(M, [posnas;poslpa;posrpa]);
fid = ft_warp_apply(M, [nas;lpa;rpa]);

hfig = figure; hold on; % for evaluation
ft_plot_mesh(surface, 'edgecolor', 'none', 'facecolor', [0.8 0.8 0.8], 'facealpha', 0.4);
ft_plot_axes(surface);
h = light; lighting gouraud; material dull
view([32 14]);

figure; hold on;
ft_plot_dipole(fid(1,:)./10,[1 0 0]);
ft_plot_dipole(fid(2,:)./10,[0 1 0]);
ft_plot_dipole(fid(3,:)./10,[0 -1 0]);
plot3(pos(:,1)./10, pos(:,2)./10, pos(:,3)./10, 'marker', 'o', 'linestyle', 'none', 'markeredgecolor', [.8 .8 .8]);
set(gcf, 'color', 'w');
view([32 14]);

% create the final transformation matrix, including the 2ALS alignment and the shift of the origin.
transform_surfacestl2ctfish = M*T*M0;
