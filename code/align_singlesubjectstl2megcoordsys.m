function [helmet, sens] = align_singlesubjectstl2megcoordsys

% ALIGN_SINGLESUBJECTSTL2MEGCOORDSYS aligns the single subject data, as stored 
% in the below 'datadir' to the MEG dewar coordinate system. This results in a
% helmet mesh that is coregistered to the sensors, using the head
% localization coils (rather than geometric information provided by the CTF
% engineers). The coregistered sensor-array and helmet shape are saved as
% mat-files. The coordinate system is 'dewar' and the units are in 'mm'.
% The coregistration is based on a measurement, where the subject wore a
% head cast with fixed coils.
% 
% Use as 
%   [helmet, sens] = align_singlesubjectstl2megcoordsys

datadir  = '/home/dyncon/jansch/projects/meg_headcast/models/singlesubject';
subjname = 'pil-002';  
  
if 0
  % the code below has once been ran, and the output has been saved to
  % disk, skip

  % obtain sensor specification
  sens     = ft_read_sens(fullfile(datadir, 'pil-002_20220211_01.ds'), 'senstype', 'meg');
  sens_dew = ft_read_sens(fullfile(datadir, 'pil-002_20220211_01.ds'), 'senstype', 'meg', 'coordsys', 'dewar');
  
  sens     = ft_convert_units(sens, 'mm');
  sens_dew = ft_convert_units(sens_dew, 'mm');
  
  % transformation matrix from head (dataset dependent), to dewar (dataset
  % independent)
  transform_ctf2dewar = [sens_dew.chanpos ones(296,1)]'/[sens.chanpos ones(296,1)]';
  
  % get the location of the fiducials, expressed in coordinates of the meshes
  [nas, lpa, rpa] = getfiducials_castwithcoils(datadir, subjname);
  [transform_headshape2ctf, coordsys] = ft_headcoordinates(nas, lpa, rpa, 'ctf');
  
  transform_headshape2dewar = transform_ctf2dewar * transform_headshape2ctf;
  
  head_and_helmet = ft_read_headshape(fullfile(datadir, 'pil-002_placement.stl'));
  head_and_helmet.coordsys = 'ras';
  [head_and_helmet.pos, head_and_helmet.tri] = remove_double_vertices(head_and_helmet.pos, head_and_helmet.tri);
  
  split = splitmesh(head_and_helmet);
  
  % hardcoded: head = 1, some coil = 2, helmet = 3;
  head   = split(2);
  helmet = split(1);
  
  helmet = ft_transform_geometry(transform_headshape2dewar, helmet);
  helmet.coordsys = 'dewar';
end

filename = fullfile(datadir, 'helmet_dewar_mm');
%save(filename, 'helmet');
load(filename)

filename = fullfile(datadir, 'sens_dewar_mm');
%sens = sens_dew;
%save(filename, 'sens');
load(filename);

figure; hold on;
ft_plot_mesh(helmet);
ft_plot_axes(helmet);
ft_plot_sens(sens);
h=light; lighting gouraud
