
ft_hastoolbox('fileexchange', 1);

%mold = align_moldstl2ctfish;

load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models', 'mold_innersurface.mat'));
load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models/singlesubject', 'helmet_dewar_mm.mat'));

orig = innersurface;
mpos = mean(innersurface.pos);
mpos(:,3) = max(innersurface.pos(:,3)) + 110;

T1 = eye(4);
T1(1:3,4) = -mpos;
innersurface = ft_transform_geometry(T1, innersurface);

R2 = eye(4);
R2([1 2],[1 2]) = [cos(pi/4) -sin(pi/4);sin(pi/4) cos(pi/4)];

innersurface = ft_transform_geometry(R2, innersurface);

x1 = helmet;
x1.nrm = normals(x1.pos, x1.tri);

x2 = innersurface;

% apply the icp algorithm for alignment, the mappning is from p to q (i.e.
% second point cloud onto the first one
params_fixed = {'Matching', 'kDtree', 'Minimize', 'plane'};
params_added = {'Triangulation', x1.tri, 'Normals', x1.nrm', 'WorstRejection', 0.05};
params       = cat(2,params_added,params_fixed);

[R,T,ER,t,info(1)] = icp(x1.pos', x2.pos', params{:});
M3                 = [R T; 0 0 0 1];
pos2               = ft_warp_apply(M3, x2.pos);

[R,T,ER,t,info(2)] = icp(x1.pos', pos2', params{:});
M4                 = [R T; 0 0 0 1];
pos2               = ft_warp_apply(M4, pos2);

Tfinal = M4*M3*R2*T1;

