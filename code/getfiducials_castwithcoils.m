function [NAS, RPA, LPA] = getfiducials_castwithcoils(datadir, subjname)

% this is the headshape without coils
filename = fullfile(datadir, sprintf('%s_headshape.stl',subjname));
hs       = ft_read_headshape(filename);

% this is the headshape with coils
filename = fullfile(datadir, sprintf('%s_fiducials.stl',subjname));
hs_coils = ft_read_headshape(filename);

% this is the headshape with coils and dewar
filename = fullfile(datadir, sprintf('%s_placement.stl',subjname));
hs_dewar = ft_read_headshape(filename);

% get the meshes for the fiducial coils
coils = extractcoils(hs_coils, hs);

% get the coordinates of the centre of the coils
fiducial = locatecoil(coils);

fprintf('Fiducial coils:\n');
display(fiducial);
fprintf('Type row:\n')
nasid = input('nas = ');
rpaid = input('rpa = ');
lpaid = input('lpa = ');

% now, the order of the coils may vary, so inspect the coordinates
% the ones where the coordinates are most similar are LPA and RPA, the
% other one is the NAS. For subject sub-001 the order is RPA,NAS,LPA
RPA = fiducial(rpaid, :);
NAS = fiducial(nasid, :);
LPA = fiducial(lpaid, :);

% check whether the extracted headsurface and the image with the coils are
% aligned.
% [x1, x2, T] = align_heads(hs_coils, hs);
% assert(T-eye(4)<1e-3);
