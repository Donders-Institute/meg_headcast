% The goal of this script is to make two additiounal 3D objects that can be used 
% to "cut off" the parts of the nose and the neck that stick out from the compiled 
% 3D model. 
%
% It only needs to run once, and the results have already been saved as "neckslab" 
% and "noseslab". This script is kept here for reference.

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
% make a slab to remove the nose and neck

prevdir = pwd();

cd ~/matlab/fieldtrip/plotting/private/

neckslab = [];
[neckslab.pos, neckslab.tri] = mesh_cube;
% convert from 2x2x2 into 300x300x100 mm
neckslab.pos(:,1) = neckslab.pos(:,1)*150;
neckslab.pos(:,2) = neckslab.pos(:,2)*150;
neckslab.pos(:,3) = neckslab.pos(:,3)*50;
% shift down, so that the top plane is at -5 mm
neckslab.pos(:,3) = neckslab.pos(:,3) - max(neckslab.pos(:,3)) - 5;

noseslab = [];
[noseslab.pos, noseslab.tri] = mesh_cube;
% convert from 2x2x2 into 50x300x150 mm
noseslab.pos(:,1) = noseslab.pos(:,1)*25;
noseslab.pos(:,2) = noseslab.pos(:,2)*150;
noseslab.pos(:,3) = noseslab.pos(:,3)*75;
% shift forward and up
noseslab.pos(:,1) = noseslab.pos(:,1) - min(noseslab.pos(:,1)) + 109.699;
noseslab.pos(:,3) = noseslab.pos(:,3) - min(noseslab.pos(:,3)) - 5;

figure
% ft_plot_mesh(dewar, 'facecolor', 'r', 'edgecolor', 'none');
ft_plot_mesh(headcore, 'facecolor', 'g', 'edgecolor', 'none');
ft_plot_mesh(moldcore, 'facecolor', 'b', 'edgecolor', 'none');
ft_plot_mesh(neckslab, 'facecolor', 'lightgray', 'axes', 1)
ft_plot_mesh(noseslab, 'facecolor', 'lightgray', 'axes', 1)
ft_headlight

%% go back to the previous directory to save the slabs as STL files

cd(prevdir)

ft_write_headshape('models/stl/neckslab.stl', neckslab, 'format', 'stl');
ft_write_headshape('models/stl/noseslab.stl', noseslab, 'format', 'stl');