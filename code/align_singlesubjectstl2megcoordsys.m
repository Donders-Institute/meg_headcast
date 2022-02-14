% this script intends to align the single subject data, as stored in the
% below 'datadir' to the MEG dewar coordinate system. This results in a
% helmet mesh that is coregistered to the sensors, using the head
% localization coils (rather than geometric information provided by the CTF
% engineers). 

datadir  = '/home/dyncon/jansch/projects/meg_headcast/models/singlesubject';
subjname = 'pil-002';  

% obtain sensor specification
sens     = ft_read_sens('pil-002_20220211_01.ds', 'senstype', 'meg');
sens_dew = ft_read_sens('pil-002_20220211_01.ds', 'senstype', 'meg', 'coordsys', 'dewar');

sens     = ft_convert_units(sens, 'mm');
sens_dew = ft_convert_units(sens_dew, 'mm');

% transformation matrix from head (dataset dependent), to dewar (dataset
% independent)
transform_ctf2dewar = [sens_dew.chanpos ones(296,1)]'/[sens.chanpos ones(296,1)]';

% get the location of the fiducials, expressed in coordinates of the meshes
[nas, lpa, rpa] = getfiducials_castwithcoils(datadir, subjname);
[transform_headshape2ctf, coordsys] = ft_headcoordinates(nas, lpa, rpa, 'ctf');

[ftver, ftpath] = ft_version;
pw_dir = pwd;

transform_headshape2dewar = transform_ctf2dewar * transform_headshape2ctf;

head_and_helmet = ft_read_headshape('pil-002_placement.stl');
head_and_helmet.coordsys = 'ras';
cd(fullfile(ftpath,'private'));
[head_and_helmet.pos, head_and_helmet.tri, keeppos] = remove_double_vertices(head_and_helmet.pos, head_and_helmet.tri);
cd(pw_dir);

split = splitmesh(head_and_helmet);

% hardcoded: head = 1, some coil = 2, helmet = 3;
head   = split(1);
helmet = split(3);

helmet = ft_transform_geometry(transform_headshape2dewar, helmet);
helmet.coordsys = 'dewar';

filename = fullfile(datadir, 'helmet_dewar_mm');
save(filename, 'helmet');

filename = fullfile(datadir, 'sens_dewar_mm');
sens = sens_dew;
save(filename, 'sens');



