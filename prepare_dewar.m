% This code only needs to be executed once, the result is saved as a mat file.
% The code here is just for reference, and to allow some optional refinements.

%%

dewar = ft_read_headshape('orig/dewar.stl');

% TODO: improve the alignment with the CTF coordinate system
% so that it is already close to the target location.

save dewar dewar
