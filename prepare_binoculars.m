% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

[cyclopic_eye.pos, cyclopic_eye.tri] = mesh_cone(20);
[cyclopic_eye.pos, cyclopic_eye.tri] = mesh_cone(20);

cyclopic_eye.unit = 'mm';
cyclopic_eye.coordsys = 'ctf';

% ft_plot_mesh(cyclopic_eye);
%
% xlabel('x');
% ylabel('y');
% zlabel('z');
% axis on
% axis vis3d
% grid on

cyclopic_eye.pos = ft_warp_apply(scale([40 40 200]),    cyclopic_eye.pos);
cyclopic_eye.pos = ft_warp_apply(translate([0 0 -200]), cyclopic_eye.pos);
cyclopic_eye.pos = ft_warp_apply(rotate([0 -90 0]),     cyclopic_eye.pos);

% ft_plot_mesh(cyclopic_eye);
% ft_plot_axes(cyclopic_eye);

left_eye  = cyclopic_eye;
right_eye = cyclopic_eye;

% rotate (around the origin) prior to the translation
left_eye.pos  = ft_warp_apply(rotate([0 10 0]), left_eye.pos);
right_eye.pos = ft_warp_apply(rotate([0 10 0]), right_eye.pos);

% move the two cones to the left and right, and a bit up
left_eye.pos  = ft_warp_apply(translate([0 +34 8]), left_eye.pos);
right_eye.pos = ft_warp_apply(translate([0 -34 8]), right_eye.pos);

ft_plot_mesh(mesh_coreg3)
ft_plot_mesh(left_eye);
ft_plot_mesh(right_eye);
ft_plot_axes(cyclopic_eye); % either one is ok

% combine the left and right side of the binoculars

npos = size(cyclopic_eye.pos,1);
binoculars = [];
binoculars.unit = 'mm';
binoculars.coordsys = 'ctf';
binoculars.pos = [
  left_eye.pos
  right_eye.pos
  ];
binoculars.tri = [
  left_eye.tri + 0*npos
  right_eye.tri + 1*npos
  ];

save binoculars binoculars
