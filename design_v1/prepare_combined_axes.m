% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

% start with a cylinder along the z-axis
[cylinder.pos, cylinder.tri] = mesh_cylinder(20, 2);
cylinder.unit = 'mm';

positive_xaxis = cylinder;
positive_xaxis.pos = ft_warp_apply(scale([2 2 75]),     positive_xaxis.pos);
positive_xaxis.pos = ft_warp_apply(translate([0 0 75]), positive_xaxis.pos);
positive_xaxis.pos = ft_warp_apply(rotate([0 90 0]),    positive_xaxis.pos);

negative_xaxis = cylinder;
negative_xaxis.pos = ft_warp_apply(scale([2 2 75]),     negative_xaxis.pos);
negative_xaxis.pos = ft_warp_apply(translate([0 0 75]), negative_xaxis.pos);
negative_xaxis.pos = ft_warp_apply(rotate([0 -90 0]),   negative_xaxis.pos);

positive_yaxis = cylinder;
positive_yaxis.pos = ft_warp_apply(scale([2 2 75]),     positive_yaxis.pos);
positive_yaxis.pos = ft_warp_apply(translate([0 0 75]), positive_yaxis.pos);
positive_yaxis.pos = ft_warp_apply(rotate([-90 0 0]),   positive_yaxis.pos);

negative_yaxis = cylinder;
negative_yaxis.pos = ft_warp_apply(scale([2 2 75]),     negative_yaxis.pos);
negative_yaxis.pos = ft_warp_apply(translate([0 0 75]), negative_yaxis.pos);
negative_yaxis.pos = ft_warp_apply(rotate([90 0 0]),   negative_yaxis.pos);

positive_zaxis = cylinder;
positive_zaxis.pos = ft_warp_apply(scale([2 2 75]),     positive_zaxis.pos);
positive_zaxis.pos = ft_warp_apply(translate([0 0 75]), positive_zaxis.pos);

negative_zaxis = cylinder;
negative_zaxis.pos = ft_warp_apply(scale([2 2 75]),     negative_zaxis.pos);
negative_zaxis.pos = ft_warp_apply(translate([0 0 75]), negative_zaxis.pos);
negative_zaxis.pos = ft_warp_apply(rotate([180 0 0]),   negative_zaxis.pos);

figure
ft_plot_mesh(positive_xaxis, 'edgecolor', 'none', 'facecolor', 'r');
ft_plot_mesh(negative_xaxis, 'edgecolor', 'none', 'facecolor', 'r');
ft_plot_mesh(positive_yaxis, 'edgecolor', 'none', 'facecolor', 'g');
ft_plot_mesh(negative_yaxis, 'edgecolor', 'none', 'facecolor', 'g');
ft_plot_mesh(positive_zaxis, 'edgecolor', 'none', 'facecolor', 'b');
ft_plot_mesh(negative_zaxis, 'edgecolor', 'none', 'facecolor', 'b');

xlabel('x');
ylabel('y');
zlabel('z');
axis on
axis vis3d
grid on

%% make a combination, only include the relevant ones
npos = size(cylinder.pos,1);
combined_axes = [];
combined_axes.unit = 'mm';
combined_axes.coordsys = 'ctf';
combined_axes.pos = [
  positive_xaxis.pos
  positive_yaxis.pos
  negative_yaxis.pos
  ];
combined_axes.tri = [
  positive_xaxis.tri + 0*npos
  positive_yaxis.tri + 1*npos
  negative_yaxis.tri + 2*npos
  ];

figure
ft_plot_mesh(combined_axes, 'edgecolor', 'none', 'facecolor', [0.5 0.5 0.5]);
ft_plot_axes(combined_axes); % it should be precisely aligned

xlabel('x');
ylabel('y');
zlabel('z');
axis on
axis vis3d
grid on

save combined_axes combined_axes
