
ft_hastoolbox('fileexchange', 1);

mold = align_moldstl2ctfish;

[dew, sens] = align_singlesubjectstl2megcoordsys;

[ftver, ftpath] = ft_version;
curr_dir = pwd;
cd(fullfile(ftpath, 'plotting/private'));
pos = mold.pos; tri = mold.tri;
[X, Y, Z, pos1, tri1, pos2, tri2] = intersect_plane(pos,  tri,  [132 0 0], [132 0 1], [132 1 0]);
[X, Y, Z, pos1, tri1, pos2, tri2] = intersect_plane(pos1, tri1, [0 0 3],   [0 1 3],   [1 0 3]);

