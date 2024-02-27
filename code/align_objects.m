%% 
% Alignment script that computes a bunch of transformations that intend to
% align relevant geometries to one another, and to express them in
% different coordinate systems. The end goal is to express a
% headmodel/sourcemodel/grad in the dewar coordinate system, and in
% register with each other, where the registration between sensors and
% head/sourcemodel is based on the headcast, and not on the head
% localization coils. 

% filename for the files that represent the models of the head
% surface, fname1 is the decorated version of fname2, fname3 points to an
% MEG dataset for the subject (to obtain the grad), mrifile1 points to the
% MRI image used to obtain the stl-file for the headcast, mrifile2 points
% to the MRI image used that served as an input into the freesurfer scripts
switch subjname
  case 'sub-001'
    fname1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-001/Headcore 3D-print file_Sub001.STL';
    fname2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-001/20210722-sub-001_headshape.stl';
    fname3 = '/project/3023009.06/raw/sub-001/ses-meg01/meg/run-01/sub001ses01_3023009.06_20211025_01.ds';
    mrifile1 = '/project/3023009.06/data/sub-001/ses-mri01/gre_headcast_largeFOV_T1w_DistortCorrect.nii'; % image that served for the the extraction of the stl-headsurface
    mrifile2 = '/project/3023009.06/data/sub-001/ses-mri01/sub-001.mgz'; % image that served as input to the freesurfer (and workbench) processing pipelines
  case 'sub-002'
    fname1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-002/Headcore 3D-print file_Sub002.STL';
    fname2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-002/20210913_sub-002_headshape.stl';
    fname3 = '/project/3023009.06/raw/sub-002/ses-meg01/meg/run-01/sub002ses01_3023009.06_20211026_01.ds';
  case 'sub-003'  
    fname1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-003/Headcore 3D-print file_Sub003.STL';
    fname2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-003/sub-003_headshape.stl';
    fname3 = '/project/3023009.06/raw/sub-003/ses-meg01run01/meg/sub003ses01run01_3023009.06_20220118_01.ds';
  case 'sub-004'
    fname1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-004/Headcore 3D-print file_Sub004.STL';
    fname2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-004/sub-004_headshape.stl';
    fname3 = '/project/3023009.06/raw/sub-004/ses-meg01/meg/run-01/sub004ses01run1_3023009.06_20220113_01.ds';
  otherwise
end

sens = ft_read_sens(fname3,'coordsys','dewar','coilaccuracy', 1); % this is expressed in the target coordinate system
sens = ft_convert_units(sens, 'mm'); % for visualization, for computations it's probably best to express in 'm'

s1 = ft_read_headshape(fname1);
s2 = ft_read_headshape(fname2);

%s1 = ft_determine_coordsys(s1);
%s2 = ft_determine_coordsys(s2);
s1.coordsys = 'lip'; % hard coded
s2.coordsys = 'ras';

% align the decorated surface to the ctf-like ALS coordinate system
[s1b, T1]     = align_surfacestl2ctfish(s1);

% align the original MRI-based surface to the decorated surface
[s1c, s2b, T2] = align_surface2surface_icp(s1b, s2);

[helmet, innersurface, T3] = align_moldstl2dewar;
s2c = ft_transform_geometry(T3, s2b);

figure; hold on
ft_plot_mesh(s2c); light; lighting gouraud; material dull
ft_plot_sens(sens);

% align the two relevant MRI images to each other
[mri1, mri2, T4] = align_mri2mri(mrifile1, mrifile2, s2);

transform_mri1tomri2   = T4;
transform_mold2dewar   = T3;
transform_surface2mold = T2;
transform_final        = T3*T2*T4; % transforms freesurfer extracted surfaces to dewar space

[p,f,e] = fileparts(mrifile2);
save(fullfile(p, sprintf('%s_transform', subjname)), 'transform_mri1tomri2', 'transform_mold2dewar', 'transform_surface2mold', 'transform_final');
