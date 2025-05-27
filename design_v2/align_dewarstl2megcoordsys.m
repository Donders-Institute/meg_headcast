function [dew, sens] = align_dewarstl2megcoordsys

% this function intends to align the helmet description as in the dewar.stl
% file to the device coordinate system of the MEG. The helmet is upside
% down in the stl-file, and needs to be rotated by 45 degrees. Also, a
% shift in the z-direction needs to be applied, of 107.31 mm, as per the
% information obtained from the CTF-engineers.

datadir = '/home/dyncon/jansch/projects/meg_headcast/models/singlesubject'; % change if needed
sens    = ft_read_sens(fullfile(datadir, 'pil-002_20220211_01.ds'), 'coordsys', 'dewar', 'senstype', 'meg');

datadir = '/home/dyncon/jansch/projects/meg_headcast/models/orig'; % change if needed
dew     = ft_read_headshape(fullfile(datadir, 'dewar.stl'));

shift   = mean(dew.pos); shift(3) = min(dew.pos(:,3)); % upside down, shift top of helmet to 0
dew.pos = dew.pos - shift;

R1 = eye(4);
R1([2 3],[2 3]) = [cos(pi) -sin(pi);sin(pi) cos(pi)];

R2 = eye(4);
R2([1 2],[1 2]) = [cos(-pi/4) -sin(-pi/4);sin(-pi/4) cos(-pi/4)];

T = eye(4);
T(3,4) = -107.31;% this number is based on a communication with the CTF engineers;

dew = ft_transform_geometry(T*R2*R1, dew);
dew = ft_convert_units(dew, 'cm');

figure; hold on;
ft_plot_mesh(dew);
ft_plot_axes(dew);
ft_plot_sens(sens);
h=light; lighting gouraud

