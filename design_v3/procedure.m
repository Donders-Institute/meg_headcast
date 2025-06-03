mri = ft_read_mri('../design_v2/examplesubject/pil-002_anatomical.mat');

%%

cfg = [];
cfg.output = 'scalp';
mri_segmented = ft_volumesegment(cfg, mri);

%%

cfg = [];
cfg.method = 'isosurface';
cfg.numvertices = inf;
headshape = ft_prepare_mesh(cfg, mri_segmented);

ft_plot_mesh(headshape, 'edgecolor', 'none')
ft_headlight;

%%
% read the STL objects

dewar = ft_read_headshape('models/stl/dewar.stl');
headcore = ft_read_headshape('models/stl/headcore.stl');
moldcore = ft_read_headshape('models/stl/moldcore.stl');

%%

figure
ft_plot_mesh(dewar, 'facecolor', 'r', 'edgecolor', 'none');
ft_plot_mesh(headcore, 'facecolor', 'g', 'edgecolor', 'none');
ft_plot_mesh(moldcore, 'facecolor', 'b', 'edgecolor', 'none');
alpha 0.5
ft_headlight

%%

figure
ax(1) = subplot(1, 3, 1); ft_plot_mesh(dewar, 'facecolor', 'r', 'edgecolor', 'none'); ft_headlight;
ax(2) = subplot(1, 3, 2); ft_plot_mesh(headcore, 'facecolor', 'g', 'edgecolor', 'none'); ft_headlight;
ax(3) = subplot(1, 3, 3); ft_plot_mesh(moldcore, 'facecolor', 'b', 'edgecolor', 'none'); ft_headlight;

linkprop(ax,{'CameraPosition','CameraUpVector'});

%%
% combine them into one mesh, triangle indices have to shift

n1 = size(dewar.pos,1);
n2 = size(headcore.pos,1);
n3 = size(moldcore.pos,1);

combined.pos = [
  dewar.pos
  headcore.pos
  moldcore.pos
  ];
combined.tri = [
  dewar.tri
  headcore.tri + n1
  moldcore.tri + n1 + n2
  ];

figure
ft_plot_mesh(combined)
alpha 0.5
ft_headlight

%%

cfg = [];
cfg.template.mesh = combined; 
cfg.template.meshstyle.cutlocation = [0 0 0];
cfg.individual.headshape = headshape;
cfg.showcutplane = 'yes';
cfg = ft_interactiverealign(cfg);

% try this
% rotate    = 0 0 -90
% scale     = 1 1 1 (always)
% translate = 15 0 90

%%

headshape_aligned = ft_transform_geometry(cfg.m, headshape);

figure
ft_plot_mesh(headshape_aligned, 'facecolor', 'w', 'edgecolor', 'none');
ft_plot_mesh(headcore, 'facecolor', 'w', 'edgecolor', 'none');
ft_plot_mesh(moldcore, 'facecolor', 'w', 'edgecolor', 'none');
ft_headlight
