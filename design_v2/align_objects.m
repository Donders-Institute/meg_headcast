function align_objects(stlfile1, stlfile2, dsfile, mrifile1, mrifile2, align2hs)

% Alignment function that computes a bunch of transformations that intend to
% align relevant geometries to one another, and to express them in
% different coordinate systems. The end goal is to express a
% headmodel/sourcemodel/grad in the dewar coordinate system, and in
% register with each other, where the registration between sensors and
% head/sourcemodel is based on the headcast, and not on the head
% localization coils. 

% filenames for the files that represent the models of the head
% surface, stlfile1 is the decorated version of stlfile2, dsfile points to an
% MEG dataset for the subject (to obtain the grad), mrifile1 points to the
% MRI image used to obtain the stl-file for the headcast, mrifile2 points
% to the MRI image used that served as an input into the freesurfer scripts
% % FIXME: the below filename handling is hard-coded for now, and should
% % ideally go elsewhere
% switch subjname
%   case 'sub-001'
%     stlfile1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-001/Headcore 3D-print file_Sub001.STL';
%     stlfile2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-001/20210722-sub-001_headshape.stl';
%     dsfile   = '/project/3023009.06/raw/sub-001/ses-meg01/meg/run-01/sub001ses01_3023009.06_20211025_01.ds';
%     mrifile1 = '/project/3023009.06/data/sub-001/ses-mri01/gre_headcast_largeFOV_T1w_DistortCorrect.nii'; % image that served for the the extraction of the stl-headsurface
%     mrifile2 = '/project/3023009.06/data/sub-001/ses-mri01/sub-001.mgz'; % image that served as input to the freesurfer (and workbench) processing pipelines
%   case 'sub-002'
%     stlfile1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-002/Headcore 3D-print file_Sub002.STL';
%     stlfile2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-002/20210913_sub-002_headshape.stl';
%     dsfile = '/project/3023009.06/raw/sub-002/ses-meg01/meg/run-01/sub002ses01_3023009.06_20211026_01.ds';
%   case 'sub-003'  
%     stlfile1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-003/Headcore 3D-print file_Sub003.STL';
%     stlfile2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-003/sub-003_headshape.stl';
%     dsfile = '/project/3023009.06/raw/sub-003/ses-meg01run01/meg/sub003ses01run01_3023009.06_20220118_01.ds';
%   case 'sub-004'
%     stlfile1 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-004/Headcore 3D-print file_Sub004.STL';
%     stlfile2 = '/project/3023009.06/4JM/files_TG_headcasts/Sub-004/sub-004_headshape.stl';
%     dsfile = '/project/3023009.06/raw/sub-004/ses-meg01/meg/run-01/sub004ses01run1_3023009.06_20220113_01.ds';
%   otherwise
% end

if nargin < 5 || isempty(align2hs)
  align2hs = true;
end

[figdir,f,e] = fileparts(stlfile1);

sens = ft_read_sens(dsfile,'coordsys','dewar','coilaccuracy', 1); % this is expressed in the target coordinate system
save(fullfile(figdir, sprintf('%s_sens.mat', f(1:7))));
sens = ft_convert_units(sens, 'mm'); % for visualization, for computations it's probably best to express in 'm'

s1 = ft_read_headshape(stlfile1);
s2 = ft_read_headshape(stlfile2);

%s1 = ft_determine_coordsys(s1);
%s2 = ft_determine_coordsys(s2);
s1.coordsys = 'lip'; % hard coded
s2.coordsys = 'ras';

% align the decorated surface to the ctf-like ALS coordinate system
[s1b, T1, hfig] = align_surfacestl2ctfish(s1);
exportgraphics(hfig, fullfile(figdir, 'headcore_realigned.png'));

% align the original MRI-based surface to the decorated surface
[s1c, s2b, T2] = align_surface2surface_icp(s1b, s2);
figure; 
ax1 = subplot(1,2,1);ft_plot_headshape(s2b, 'vertexcolor', s2b.distancein);  clim([-1 1].*max(abs(s2b.distanceout)));
ax2 = subplot(1,2,2);ft_plot_headshape(s2b, 'vertexcolor', s2b.distanceout); clim([-1 1].*max(abs(s2b.distanceout)));
ll  = linkprop([ax1, ax2], {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
setappdata(gcf, 'StoreTheLink', ll);

[helmet, innersurface, T3, hfig2] = align_moldstl2dewar;
exportgraphics(hfig2, fullfile(figdir, 'mold_realigned.png'));

s2c = ft_transform_geometry(T3, s2b);

figure; hold on
ft_plot_mesh(s2c); light; lighting gouraud; material dull
ft_plot_sens(sens);
view([90 0]);
exportgraphics(gcf, fullfile(figdir, 'headshape_realigned.png'));

% align the two relevant MRI images to each other
[mri1, mri2, T4, hfig3] = align_mri2mri(mrifile1, mrifile2, s2, align2hs);
exportgraphics(hfig3(1), fullfile(figdir, 'stl_stl_realigned.png'));
exportgraphics(hfig3(2), fullfile(figdir, 'stl_mri_realigned.png'));

transform_mri1tomri2   = T4;
transform_mold2dewar   = T3;
transform_surface2mold = T2;
transform_final        = T3*T2*T4; % transforms freesurfer extracted surfaces to dewar space

[p,f,e] = fileparts(mrifile2);
save(fullfile(p, sprintf('%s_transform', f(1:7))), 'transform_mri1tomri2', 'transform_mold2dewar', 'transform_surface2mold', 'transform_final');
