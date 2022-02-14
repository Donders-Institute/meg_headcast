%function scalp_coreg1 = do_make_scalpstl(dicomfile)

%% - importing the DICOM images

% dicomfile = 'sub-jm/ses-001/007-gre_headcast_largeFOV_T1w_WaterExcite/PILOT_HAGGORT.MR.KRIARM_SKYRA.0007.0001.2019.04.11.09.36.04.649721.547271769.IMA';
% dicomfile = 'sub-jm/ses-001/008-gre_headcast_largeFOV_T1w_WaterExcite/PILOT_HAGGORT.MR.KRIARM_SKYRA.0008.0001.2019.04.11.09.36.04.649721.547273926.IMA';
% dicomfile = 'sub-jm/ses-001/009-gre_headcast_largeFOV_T1w_DistortCorrect_ND/PILOT_HAGGORT.MR.KRIARM_SKYRA.0009.0001.2019.04.11.09.36.04.649721.547288155.IMA';
% dicomfile = 'sub-jm/ses-001/010-gre_headcast_largeFOV_T1w_DistortCorrect/PILOT_HAGGORT.MR.KRIARM_SKYRA.0010.0001.2019.04.11.09.36.04.649721.547291918.IMA';
%dicomfile = 'sub-bb/gre_headcast_largeFOV_T1w_DistortCorrect.nii';
% dicomfile = 'sub-bb/gre_headcast_largeFOV_T1w_DistortCorrect_ND.nii'
% dicomfile = 'sub-bb/t1_mprage_sag_ipat2_1p0iso.nii'

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
cfg.scalpsmooth = 'no';
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

%save seg_coreg1 seg_coreg1

%% - construct the scalp surface

cfg = [];
cfg.method = 'isosurface';
cfg.numvertices = []; % do not retriangulate to a lower number of vertices
scalp_coreg1 = ft_prepare_mesh(cfg, seg_coreg1);

figure
ft_plot_mesh(scalp_coreg1);
ft_plot_axes(scalp_coreg1);
camlight

%save scalp_coreg1 scalp_coreg1
