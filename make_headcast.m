%% this is only done once and results in a number of mat files with the corresponding objects

% prepare_dewar
% prepare_headcoils
% prepare_combined_axes
% prepare_vertex_cylinder
% prepare_binoculars

%% First phase: construct scalp surface from MRI

%% - importing the DICOM images

% dicomfile = '../sub-jm/ses-001/007-gre_headcast_largeFOV_T1w_WaterExcite/PILOT_HAGGORT.MR.KRIARM_SKYRA.0007.0001.2019.04.11.09.36.04.649721.547271769.IMA';
% dicomfile = '../sub-jm/ses-001/008-gre_headcast_largeFOV_T1w_WaterExcite/PILOT_HAGGORT.MR.KRIARM_SKYRA.0008.0001.2019.04.11.09.36.04.649721.547273926.IMA';
% dicomfile = '../sub-jm/ses-001/009-gre_headcast_largeFOV_T1w_DistortCorrect_ND/PILOT_HAGGORT.MR.KRIARM_SKYRA.0009.0001.2019.04.11.09.36.04.649721.547288155.IMA';
% dicomfile = '../sub-jm/ses-001/010-gre_headcast_largeFOV_T1w_DistortCorrect/PILOT_HAGGORT.MR.KRIARM_SKYRA.0010.0001.2019.04.11.09.36.04.649721.547291918.IMA';
dicomfile = '../sub-bb/gre_headcast_largeFOV_T1w_DistortCorrect.nii';
% dicomfile = '../sub-bb/gre_headcast_largeFOV_T1w_DistortCorrect_ND.nii'
% dicomfile = '../sub-bb/t1_mprage_sag_ipat2_1p0iso.nii'


mri_orig = ft_read_mri(dicomfile);

cfg = [];
cfg.location = 'center';
ft_sourceplot(cfg, mri_orig);

%% Do a coarse alignment of the MRI to the CTF coordinate system

% Plotting the MRI slices allows for checking for left-right flips: there should be a
% vitamine E capsule visible at the right ear. The coarse alignment is also needed
% for the segmentation of the scalp surface.

% HERE AN INTERACTION IS REQUIRED IN FT_VOLUMEREALIGN

cfg = [];
cfg.coordsys = 'ctf';
mri_coreg1 = ft_volumerealign(cfg, mri_orig);

% flip it to get an approximate alignment of the ijk–axes to the xyz-axes
cfg = [];
cfg.method = 'flip';
mri_coreg1 = ft_volumereslice(cfg, mri_coreg1);

% Here you should check that the axes are pointing in the correct direction according to the CTF coordinate system with
% +x to the nose,
% +y to the right (where the vitamine E capsure is located),
% -y to the left.

ft_determine_coordsys(mri_coreg1, 'interactive', false);

save mri_coreg1 mri_coreg1

%% - segment the scalp surface

cfg = [];
cfg.output = 'scalp';
cfg.spmversion = 'spm12';
cfg.spmmethod = 'new';
seg_coreg1 = ft_volumesegment(cfg, mri_coreg1);

% fill the ears
before = sum(seg_coreg1.scalp(:)) * abs(det(seg_coreg1.transform(1:3,1:3)));
seg_coreg1.scalp = imclose(seg_coreg1.scalp, strel('sphere',6));
after = sum(seg_coreg1.scalp(:)) * abs(det(seg_coreg1.transform(1:3,1:3)));
fprintf('added %d ml around the ears\n', round((after-before)/1000)); 

cfg = [];
cfg.funparameter = 'scalp';
cfg.location = 'center';
ft_sourceplot(cfg, seg_coreg1, mri_coreg1);

save seg_coreg1 seg_coreg1

%% - construct the scalp surface

cfg = [];
cfg.method = 'isosurface';
cfg.numvertices = []; % do not retriangulate to a lower number of vertices
scalp_coreg1 = ft_prepare_mesh(cfg, seg_coreg1);

figure
ft_plot_mesh(scalp_coreg1);
ft_plot_axes(scalp_coreg1);
camlight

save scalp_coreg1 scalp_coreg1

%% second phase: coregistration with the MEG coordinates

%% - shift the scalp surface so that it is nicely aligned relative to the axes

% HERE AN INTERACTION IS REQUIRED IN FT_INTERACTIVEREALIGN

cfg = [];
cfg.template.axes = 'yes';
cfg.individual.headshape = scalp_coreg1;
cfg = ft_interactiverealign(cfg);

transform = cfg.m;

%% - apply the transformation from step 6 also to the anatomical MRI

mri_coreg2   = ft_transform_geometry(transform, mri_coreg1);
seg_coreg2   = ft_transform_geometry(transform, seg_coreg1);
scalp_coreg2 = ft_transform_geometry(transform, scalp_coreg1);

figure
ft_plot_mesh(scalp_coreg2);
ft_plot_axes(scalp_coreg2);
camlight

save mri_coreg2   mri_coreg2
save seg_coreg2   seg_coreg2
save scalp_coreg2 scalp_coreg2

%% - move the head localizer coils along the axes to the scalp surface

% these have the center of the outer surface of the coil in [0 0 0]
load headcoil_nas
load headcoil_lpa
load headcoil_rpa

% find the point on the surface nearest to where the axis intersects

pos = scalp_coreg2.pos(:,[2 3]);
sel = scalp_coreg2.pos(:,1) < 0; % select the back side of the head, where x<0
pos(sel,:) = inf; % move it completely out of the way
[d, indx] = min(sqrt(sum(pos.^2, 2)));
nas = scalp_coreg2.pos(indx,:);

pos = scalp_coreg2.pos(:,[1 3]);
sel = scalp_coreg2.pos(:,2) < 0; % select the right side of the head, where y<0
pos(sel,:) = inf; % move it completely out of the way
[d, indx] = min(sqrt(sum(pos.^2, 2)));
lpa = scalp_coreg2.pos(indx,:);

pos = scalp_coreg2.pos(:,[1 3]);
sel = scalp_coreg2.pos(:,2) > 0; % select the left side of the head, where y>0
pos(sel,:) = inf; % move it completely out of the way
[d, indx] = min(sqrt(sum(pos.^2, 2)));
rpa = scalp_coreg2.pos(indx,:);

figure
ft_plot_mesh(scalp_coreg2)
hold on

% plot the anatomical landmarks on teh scalp, this is where the coils will be placed

plot3(nas(1), nas(2), nas(3), 'b*');
plot3(lpa(1), lpa(2), lpa(3), 'b*');
plot3(rpa(1), rpa(2), rpa(3), 'b*');

% determine the distance from the origin to each anatomical landmark and shift the coil correspondingly
% the model coils are slightly thicker and "press" into the skin to prevent gaps between the coil and the skin
coilthickness = 3; % FIXME should be measured

headcoil_nas_coreg2 = headcoil_nas;
headcoil_lpa_coreg2 = headcoil_lpa;
headcoil_rpa_coreg2 = headcoil_rpa;

% first shift them by half the thickness
headcoil_nas_coreg2.pos = ft_warp_apply(translate([coilthickness/2 0 0]),  headcoil_nas_coreg2.pos);
headcoil_lpa_coreg2.pos = ft_warp_apply(translate([0 +coilthickness/2 0]), headcoil_lpa_coreg2.pos);
headcoil_rpa_coreg2.pos = ft_warp_apply(translate([0 -coilthickness/2 0]), headcoil_rpa_coreg2.pos);

% the coils can now be rotated around their center
headcoil_nas_coreg2.pos = ft_warp_apply(rotate([0 -30 0]), headcoil_nas_coreg2.pos);
headcoil_lpa_coreg2.pos = ft_warp_apply(rotate([0 0 0]), headcoil_lpa_coreg2.pos);
headcoil_rpa_coreg2.pos = ft_warp_apply(rotate([0 0 0]), headcoil_rpa_coreg2.pos);

% once more shift them by half the thickness
headcoil_nas_coreg2.pos = ft_warp_apply(translate([coilthickness/2 0 0]),  headcoil_nas_coreg2.pos);
headcoil_lpa_coreg2.pos = ft_warp_apply(translate([0 +coilthickness/2 0]), headcoil_lpa_coreg2.pos);
headcoil_rpa_coreg2.pos = ft_warp_apply(translate([0 -coilthickness/2 0]), headcoil_rpa_coreg2.pos);

% shift them to the anatomical landmarks
headcoil_nas_coreg2.pos = ft_warp_apply(translate([norm(nas) 0 0]),  headcoil_nas_coreg2.pos);
headcoil_lpa_coreg2.pos = ft_warp_apply(translate([0 +norm(lpa) 0]), headcoil_lpa_coreg2.pos);
headcoil_rpa_coreg2.pos = ft_warp_apply(translate([0 -norm(rpa) 0]), headcoil_rpa_coreg2.pos);

% add the coils to the figure with the scalp surface and the anatomical landmarks
% the center of the coils should correspond to the anatomical landmarks

ft_plot_mesh(headcoil_nas_coreg2, 'edgecolor', 'none', 'facecolor', 'r')
ft_plot_mesh(headcoil_lpa_coreg2, 'edgecolor', 'none', 'facecolor', 'g')
ft_plot_mesh(headcoil_rpa_coreg2, 'edgecolor', 'none', 'facecolor', 'g')
camlight

%% do a fine adjustment of the coordinate system alignment

% The CTF coordinate system has the origin exactly between LPA and RPA,
% whereas the LPA and RPA coil might be at slightly different distances to the initial origin.
% This can for example be the case if the subject has a slightly more chubby cheek on one side, or if the ears are not perfectly symmetrical.

transform = ft_headcoordinates(nas, lpa, rpa, 'ctf');

mri_coreg3   = ft_transform_geometry(transform, mri_coreg2);
seg_coreg3   = ft_transform_geometry(transform, seg_coreg2);
scalp_coreg3 = ft_transform_geometry(transform, scalp_coreg2);

headcoil_nas_coreg3 = ft_transform_geometry(transform, headcoil_nas_coreg2);
headcoil_lpa_coreg3 = ft_transform_geometry(transform, headcoil_lpa_coreg2);
headcoil_rpa_coreg3 = ft_transform_geometry(transform, headcoil_rpa_coreg2);

save mri_coreg3 mri_coreg3
save seg_coreg3 seg_coreg3
save scalp_coreg3 scalp_coreg3

save headcoil_nas_coreg3 headcoil_nas_coreg3
save headcoil_lpa_coreg3 headcoil_lpa_coreg3
save headcoil_rpa_coreg3 headcoil_rpa_coreg3

%% - export the aligned head surface as an STL file

% flip the triangles inside-out, otherwise the surface cannot be colored in MeshLab
% this is based on trial and error
scalp_coreg3.tri = fliplr(scalp_coreg3.tri);

ft_write_headshape('scalp_coreg3.stl', scalp_coreg3, 'format', 'stl');

%% - export the aligned head localizer coils

ft_write_headshape('headcoil_nas_coreg3.stl', headcoil_nas_coreg3, 'format', 'stl');
ft_write_headshape('headcoil_lpa_coreg3.stl', headcoil_lpa_coreg3, 'format', 'stl');
ft_write_headshape('headcoil_rpa_coreg3.stl', headcoil_rpa_coreg3, 'format', 'stl');

%% - export the geometrical model of the binoculars, the combined axes and the vertex cylinder

load binoculars
ft_write_headshape('binoculars.stl', binoculars, 'format', 'stl');

load combined_axes
ft_write_headshape('combined_axes.stl', combined_axes, 'format', 'stl');

load vertex_cylinder
ft_write_headshape('vertex_cylinder.stl', vertex_cylinder, 'format', 'stl');

load dewar
ft_write_headshape('dewar.stl', dewar, 'format', 'stl');

load earflap_left
ft_write_headshape('earflap_left.stl', earflap_left, 'format', 'stl');

load earflap_right
ft_write_headshape('earflap_right.stl', earflap_right, 'format', 'stl');

load earcanal_left
ft_write_headshape('earcanal_left.stl', earcanal_left, 'format', 'stl');

load earcanal_right
ft_write_headshape('earcanal_right.stl', earcanal_right, 'format', 'stl');

%% we can plot all geometrical objects together in MATLAB and in principle you could also adjust the position of the vertex cylinder and the binoculars in MATLAB. Since the alignment of these with the CTF coordinate system is not crucial, you can also shift them around in external 3D editing software (see the next step).

figure
ft_plot_mesh(scalp_coreg3, 'facealpha', 1, 'facecolor', 'skin')
ft_plot_mesh(headcoil_nas_coreg3, 'edgecolor', 'none', 'facecolor', 'r')
ft_plot_mesh(headcoil_lpa_coreg3, 'edgecolor', 'none', 'facecolor', 'g')
ft_plot_mesh(headcoil_rpa_coreg3, 'edgecolor', 'none', 'facecolor', 'g')
ft_plot_mesh(combined_axes, 'edgecolor', 'none', 'facecolor', 'm')
ft_plot_mesh(vertex_cylinder, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(binoculars, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(earflap_left, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(earflap_right, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(earcanal_left, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(earcanal_right, 'edgecolor', 'none', 'facecolor', 'y')
ft_plot_mesh(dewar, 'edgecolor', 'none', 'facecolor', 'darkgreen')
camlight

% note that the position of the dewar relative to the scalp will not be optimal yet


%% Third phase: this is implemented in MeshMixer

% The head surface and the localizer coils should not be moved any more, since that 
% invalidates the coregistration with the anatomical MRI and thereby with the source 
% models that you will construct from it, e.g., using FreeSurfer.

% - align the dewar, earflaps, and earcanals with the scalp 
% - if needed move the binoculars to match the subjects eye position and gaze direction
% - if needed move the vertex cylinder
% - combine/crop the model, this is implemented in MeshMixer
% - make the aggregate head model hollow
% - export the aggregate head model to an STL file to get it printed
