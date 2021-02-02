% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

% start with a cylinder along the z-axis
[vertex_cylinder.pos, vertex_cylinder.tri] = mesh_cylinder(20, 2);
vertex_cylinder.unit = 'mm';
vertex_cylinder.coordsys = 'ctf';

vertex_cylinder.pos = ft_warp_apply(scale([20 20 75]),   vertex_cylinder.pos);
vertex_cylinder.pos = ft_warp_apply(translate([0 0 75]), vertex_cylinder.pos);

figure
ft_plot_mesh(vertex_cylinder, 'edgecolor', 'none', 'facecolor', [0.5 0.5 0.5]);
ft_plot_axes(vertex_cylinder); % it should be precisely aligned

xlabel('x');
ylabel('y');
zlabel('z');
axis on
axis vis3d
grid on

save vertex_cylinder vertex_cylinder
