% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%


[cylinder.pos, cylinder.tri]  = mesh_cylinder(40, 2);  % d=2, height=2, z from -1 to +1
[cylinder.pos, cylinder.tri] = refine(cylinder.pos, cylinder.tri);
[cylinder.pos, cylinder.tri] = refine(cylinder.pos, cylinder.tri);
[cylinder.pos, cylinder.tri] = refine(cylinder.pos, cylinder.tri);

[cube.pos, cube.tri] = mesh_cube;                     % from -1 to +1 along each axis
[cube.pos, cube.tri] = refine(cube.pos, cube.tri);
[cube.pos, cube.tri] = refine(cube.pos, cube.tri);
[cube.pos, cube.tri] = refine(cube.pos, cube.tri);
[cube.pos, cube.tri] = refine(cube.pos, cube.tri);
[cube.pos, cube.tri] = refine(cube.pos, cube.tri);


cylinder1 = cylinder;
cylinder1.pos = ft_warp_apply(scale([10 10 80]),      cylinder1.pos);
cylinder1.pos = ft_warp_apply(translate([10 -30 0]),   cylinder1.pos);

cylinder2 = cylinder;
cylinder2.pos = ft_warp_apply(scale([10 10 80]),      cylinder2.pos);
cylinder2.pos = ft_warp_apply(translate([10 30 0]),   cylinder2.pos);

cube1 = cube;
cube1.pos = ft_warp_apply(scale([20 30 80]),      cube1.pos);
cube1.pos = ft_warp_apply(translate([20 0 0]),    cube1.pos);

cube2 = cube;
cube2.pos = ft_warp_apply(scale([15 40 80]),      cube2.pos);
cube2.pos = ft_warp_apply(translate([25 0 0]),    cube2.pos);


% this is required for meshmixer, it was trial and error
% cylinder1.tri = fliplr(cylinder1.tri );
% cylinder2.tri = fliplr(cylinder2.tri );
% cube1.tri = fliplr(cube1.tri );
% cube2.tri = fliplr(cube2.tri );

% figure
% ft_plot_axes(cylinder1);
% ft_plot_mesh(cylinder1);
% ft_plot_mesh(cylinder2);
% ft_plot_mesh(cube1, 'facecolor', 'b');
% ft_plot_mesh(cube2, 'facecolor', 'r');

%%

n1 = size(cylinder1.pos,1);
n2 = size(cylinder2.pos,1);
n3 = size(cube1.pos,1);
n4 = size(cube2.pos,1);

earflap_outside = [];
earflap_outside.pos = [
  cylinder1.pos
  cylinder2.pos
  cube1.pos
  cube2.pos
  ];

earflap_outside.tri = [
  cylinder1.tri
  cylinder2.tri + n1
  cube1.tri     + n1 + n2
  cube2.tri     + n1 + n2 + n3
  ];
  

% make this one 3 mm smaller along the length (y), and a bit taller for visualisation
earflap_inside     = earflap_outside;
earflap_inside.pos = ft_warp_apply(scale([1 75/80 166/160]),   earflap_inside.pos);
earflap_inside.pos = ft_warp_apply(translate([2 0 0]),  earflap_inside.pos);

figure
ft_plot_axes(earflap_outside);
ft_plot_mesh(earflap_outside, 'facecolor', 'b');
ft_plot_mesh(earflap_inside, 'facecolor', 'r');

%%

% both the red one and the blue one need to be made "solid"
% and then the red one is to be subtracted from the blue one

ft_write_headshape('orig/earflap_part1.stl', cylinder1, 'format', 'stl');
ft_write_headshape('orig/earflap_part2.stl', cylinder2, 'format', 'stl');
ft_write_headshape('orig/earflap_part3.stl', cube1, 'format', 'stl');
ft_write_headshape('orig/earflap_part4.stl', cube2, 'format', 'stl');

%%

earflap_left  = ft_read_headshape('orig/earflap_hollow.stl');
earflap_right = ft_read_headshape('orig/earflap_hollow.stl');

earcanal_left  = ft_read_headshape('orig/earflap_solid.stl');
earcanal_right = ft_read_headshape('orig/earflap_solid.stl');

earflap_left.pos         = ft_warp_apply(rotate([0 0 +90]),   earflap_left.pos);
earflap_right.pos        = ft_warp_apply(rotate([0 0 -90]),   earflap_right.pos);

earflap_left.pos  = ft_warp_apply(translate([-25 +73 -60]),   earflap_left.pos);
earflap_right.pos = ft_warp_apply(translate([-25 -73 -60]),   earflap_right.pos);

earcanal_left.pos  = ft_warp_apply(rotate([0 0 -90]),    earcanal_left.pos); % just the other way around
earcanal_right.pos = ft_warp_apply(rotate([0 0 +90]),    earcanal_right.pos);
earcanal_left.pos  = ft_warp_apply(scale([0.5 0.35 1]), earcanal_left.pos);
earcanal_right.pos = ft_warp_apply(scale([0.5 0.35 1]), earcanal_right.pos);

% shift it with the thickness to make it alligned with the hollow part
dy = range(earcanal_left.pos(:,2));
earcanal_left.pos  = ft_warp_apply(translate([0 +dy 0]),   earcanal_left.pos);
earcanal_right.pos = ft_warp_apply(translate([0 -dy 0]),   earcanal_right.pos);

% shift to the final position
earcanal_left.pos  = ft_warp_apply(translate([-25 +73 -60]),   earcanal_left.pos);
earcanal_right.pos = ft_warp_apply(translate([-25 -73 -60]),   earcanal_right.pos);

figure
ft_plot_axes([], 'unit', 'mm');
% ft_plot_mesh(dewar, 'facecolor', 'b', 'facealpha', 0.8);
% ft_plot_mesh(scalp_coreg3, 'facecolor', 'skin', 'facealpha', 0.8);
ft_plot_mesh(earflap_left, 'facecolor', 'r');
ft_plot_mesh(earflap_right, 'facecolor', 'g');
ft_plot_mesh(earcanal_left, 'facecolor', 'r');
ft_plot_mesh(earcanal_right, 'facecolor', 'g');
camlight

%%

save earflap_left  earflap_left
save earflap_right earflap_right

save earcanal_left  earcanal_left
save earcanal_right earcanal_right


