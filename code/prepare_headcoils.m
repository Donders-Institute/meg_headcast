% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

% the original 3D model for coil1, coil2, and coil3 was taken from the STL model of pil002

% !mv coil1.stl orig/headcoil_rpa.stl
% !mv coil2.stl orig/headcoil_lpa.stl
% !mv coil3.stl orig/headcoil_nas.stl

% the following code takes these coils and translate + rotate them to the standard position at the origin

%%
headcoil_nas = ft_read_headshape('orig/headcoil_nas.stl');
headcoil_nas.unit = 'mm';
headcoil_nas.coordsys = 'ctf';

% subsequently I used ft_plot_mesh, placed a MATLAB tooltip in the figure, and got the coordinates with
% dt = findobj(gca,'Type','datatip')

% here I pretend that the coil is a head, with an ear on either side of the hole and with the nose along the stick
% this gives me the homogenous transformation that allows me to align the coil to the origin
nas = [ -3.46007, 87.0776, -28.851];
lpa = [ -5.08725, 88.6305, -6.63868];
rpa = [ -2.13764, 88.5881, -6.61553];
transform = ft_headcoordinates(nas, lpa, rpa, 'ctf');

headcoil_nas.pos = ft_warp_apply(transform, headcoil_nas.pos);
headcoil_nas.pos = ft_warp_apply(translate([0 0 -6.5692]), headcoil_nas.pos);
headcoil_nas.pos = ft_warp_apply(rotate([0 90 0]), headcoil_nas.pos);

% the midpoint of the coil is at [0 0 0]
% the outer surface of the coil is flush with the plane x=0
% the tail is pointing to -z

figure
ft_plot_mesh(headcoil_nas);
ft_plot_axes(headcoil_nas);
camlight

%%
headcoil_lpa = ft_read_headshape('orig/headcoil_lpa.stl');
headcoil_lpa.unit = 'mm';
headcoil_lpa.coordsys = 'ctf';

nas = [ -74.8742, 4.59204, -45.7824];
lpa = [ -74.7788, -4.77388, -28.4838];
rpa = [ -74.5162, -2.0915, -27.2845];
transform = ft_headcoordinates(nas, lpa, rpa, 'ctf');

headcoil_lpa.pos = ft_warp_apply(transform, headcoil_lpa.pos);
headcoil_lpa.pos = ft_warp_apply(translate([0 0 -5.1733]), headcoil_lpa.pos);
headcoil_lpa.pos = ft_warp_apply(rotate([0 90 0]), headcoil_lpa.pos);
headcoil_lpa.pos = ft_warp_apply(rotate([0 0 90]), headcoil_lpa.pos);

% the midpoint of the coil is at [0 0 0]
% the outer surface of the coil is flush with the plane y=0
% the tail is pointing to -z

% the coil is on the RIGHT of y=0, and should be moved to the LEFT along the negative y-axis

figure
ft_plot_mesh(headcoil_lpa);
ft_plot_axes(headcoil_lpa);
camlight

%%
headcoil_rpa = ft_read_headshape('orig/headcoil_rpa.stl');
headcoil_rpa.unit = 'mm';
headcoil_rpa.coordsys = 'ctf';

nas = [72.8282, 8.60544, -40.161];
lpa = [73.0614, 1.73365, -21.6571];
rpa = [73.065, -0.947313, -22.888];

transform = ft_headcoordinates(nas, lpa, rpa, 'ctf');

headcoil_rpa.pos = ft_warp_apply(transform, headcoil_rpa.pos);

headcoil_rpa.pos = ft_warp_apply(translate([0 0 -5.1217]), headcoil_rpa.pos);
headcoil_rpa.pos = ft_warp_apply(rotate([0 90 0]), headcoil_rpa.pos);
headcoil_rpa.pos = ft_warp_apply(rotate([0 0 -90]), headcoil_rpa.pos);

% the midpoint of the coil is at [0 0 0]
% the outer surface of the coil is flush with the plane y=0
% the tail is pointing to -z

% the coil is on the LEFT of y=0, and should be moved to the RIGHT along the positive y-axis

figure
ft_plot_mesh(headcoil_rpa);
ft_plot_axes(headcoil_rpa);
camlight

%%

save headcoil_nas headcoil_nas
save headcoil_lpa headcoil_lpa
save headcoil_rpa headcoil_rpa
