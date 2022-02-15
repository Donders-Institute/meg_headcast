% this script intends to align the helmet description as in the dewar.stl
% file to the dewar_mold.stl file. The latter is in ALS coordinates, the
% former is in LPI

datadir = '/home/dyncon/jansch/projects/meg_headcast/models/singlesubject';
load(fullfile(datadir, 'sens_dewar_mm'));
sens = ft_convert_units(sens, 'cm');

load(fullfile(datadir, 'helmet_dewar_mm'));
helmet = ft_convert_units(helmet, 'cm');

datadir = '/home/dyncon/jansch/projects/meg_headcast/models/orig';
dew     = ft_read_headshape(fullfile(datadir, 'dewar.stl'));
dew.coordsys = 'lpi';
shift_dew = mean(dew.pos); shift_dew(3) = min(dew.pos(:,3)); % put the 'top' at z=0
dew.pos   = dew.pos - shift_dew;

% dewar_mold seems in register with dewar_ctf
dewm          = ft_read_headshape(fullfile(datadir, 'dewar_mold.stl'));
dewm.coordsys = 'als';

dewc          = ft_read_headshape(fullfile(datadir, 'dewar_ctf.stl'));
dewc.coordsys = 'als';

shift    = mean(dewc.pos); shift(3) = max(dewc.pos(:,3));
dewc.pos = dewc.pos - shift;
dewc     = ft_convert_coordsys(dewc, 'lpi');

dewm.pos = dewm.pos - shift; 
dewm     = ft_convert_coordsys(dewm, 'lpi');

R1 = eye(4);
R1([2 3],[2 3]) = [cos(pi) -sin(pi);sin(pi) cos(pi)];

R2 = eye(4);
R2([1 2],[1 2]) = [cos(-pi/4) -sin(-pi/4);sin(-pi/4) cos(-pi/4)];

T = eye(4);
T(3,4) = -107.31;%-214.62;

dew = ft_transform_geometry(T*R2*R1, dew);
dew = ft_convert_units(dew, 'cm');

figure; hold on;
ft_plot_mesh(dew);
ft_plot_axes(dew);
ft_plot_sens(sens);

