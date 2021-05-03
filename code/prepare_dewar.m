% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

dewar = ft_read_headshape('orig/dewar.stl');

% fieldtrip/template/dewar contains a low resolution one, which is aligned with the
% device (aka dewar) coordinate system and used in real-time head location plotting

% this file contains the ctf_dewar_downsampled structure
[v, p] = ft_version;
load(fullfile(p, 'template', 'dewar', 'ctf.mat'));

% the following transform was determined using FT_INTERACTIVEREALIGN using 
% cfg = [];
% cfg.individual.headshape = ft_convert_units(dewar, 'mm');
% cfg.template.headshape = ft_convert_units(ctf_dewar_downsampled, 'mm');
% cfg.template.headshapestyle = 'vertex';
% cfg = ft_interactiverealign(cfg);
% 
% transform = cfg.m;

%%

transform = [
    0.7071   -0.7071   -0.0000 -197.0000
   -0.7071   -0.7071    0.0000  135.0000
   -0.0000         0   -1.0000  -90.0000
         0         0         0    1.0000
  ];

dewar.pos = ft_warp_apply(transform, dewar.pos);

%%

ft_plot_mesh(ctf_dewar_downsampled, 'unit', 'mm', 'vertexcolor', 'k', 'edgecolor', 'none', 'facecolor', 'none');
ft_plot_mesh(dewar)
ft_plot_axes(dewar)
xlabel('x');
xlabel('y');
xlabel('z');

% the 3D model of the dewar is now in dewar coordinates, which is one of the 
% two coordinate systems used to express the coil positions in the RES4 file

%%

% rotate it 45 degrees, shift it up, etc

dewar.pos = ft_warp_apply(rotate([0 0 -45]),        dewar.pos);
dewar.pos = ft_warp_apply(translate([-10 1.6 260]), dewar.pos); % also shift a little along the y-axis to make it left-right symmetric

% find the point on the surface nearest to where dewar intersects with the y-axis
pos = dewar.pos(:,[1 3]);
sel = dewar.pos(:,2) < 0; % select the right side of the head, where y<0
pos(sel,:) = inf; % move it completely out of the way
[d, indx] = min(sqrt(sum(pos.^2, 2)));
lpa = dewar.pos(indx,:);

pos = dewar.pos(:,[1 3]);
sel = dewar.pos(:,2) > 0; % select the left side of the head, where y>0
pos(sel,:) = inf; % move it completely out of the way
[d, indx] = min(sqrt(sum(pos.^2, 2)));
rpa = dewar.pos(indx,:);

% this should be close to zero
disp(rpa(2)+lpa(2)) 

%%

% the number of triangles and vertices can be significantly reduced
[dewar.tri, dewar.pos] = reducepatch(dewar.tri, dewar.pos, 0.05);

%%

figure
hold on
ft_plot_mesh(dewar, 'facecolor', 'blue', 'facealpha', 0.8, 'edgecolor', 'k')
% ft_plot_mesh(scalp_coreg3, 'facecolor', 'red', 'facealpha', 0.5)
ft_plot_axes(dewar)

plot3(lpa(1), lpa(2), lpa(3), 'g*');
plot3(rpa(1), rpa(2), rpa(3), 'g*');

xlabel('x');
xlabel('y');
xlabel('z');

% the dewar is now *approximately* in head coordinates
% so it does not have to be moved around that much any more


%%

% make a solid object out of it, with a wall thickness of about 2 mm

edge = mesh2edge(dewar);
dewar_inside  = dewar;
dewar_outside = dewar;

ntri = size(dewar.tri, 1);
npos = size(dewar.pos, 1);

bottom = min(dewar.pos(:,3));

dewar_outside.pos = ft_warp_apply(translate([0 0 -bottom]), dewar_outside.pos);
dewar_outside.pos = ft_warp_apply(scale([1.02 1.02 1.00]), dewar_outside.pos);
dewar_outside.pos = ft_warp_apply(translate([0 0 +bottom + 2]), dewar_outside.pos);

% flip it inside-out
dewar_inside.tri = fliplr(dewar_inside.tri );

figure
hold on
ft_plot_mesh(dewar_inside, 'facecolor', 'none', 'facealpha', 0.8, 'edgecolor', 'b')
ft_plot_mesh(dewar_outside, 'facecolor', 'none', 'facealpha', 0.8, 'edgecolor', 'r')

% concatenate the inside and outside
dewar_combined = [];
dewar_combined.pos = [dewar_inside.pos; dewar_outside.pos];
dewar_combined.tri = [dewar_inside.tri; dewar_outside.tri+npos];
dewar_combined.unit = 'mm';

%%

% stitch the two (identical) edges together
for i=1:size(edge.line,1)
  dewar_combined.tri(end+1,:) = [edge.line(i,1) edge.line(i,2)      edge.line(i,2)+npos];
  dewar_combined.tri(end+1,:)  = [edge.line(i,1) edge.line(i,2)+npos edge.line(i,1)+npos];
end

figure
hold on
ft_plot_mesh(dewar_combined, 'facecolor', 'white', 'facealpha', 1, 'edgecolor', 'k'); camlight

%%

dewar = dewar_combined;

save dewar dewar








