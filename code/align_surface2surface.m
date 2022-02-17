function [surface1, surface2] = align_surface2surface(surface1, surface2)

% ALIGN_SURFACE2SURFACE aligns two surface models of a head, which represents the
% which represents the to-be-printed surface in the first input argument, 
% and the original surface from the anatomy in the second input argument.
%
% Use as
%   [s1, s2, T] = align_surface2surface(surface1, surface2)
%
% where surface2 = a mesh obtained from an anatomical MRI
% where surface1 = a decorated (and possibly resampled) version of surface2,
% with extensions attached that serve as placeholders for the to be created
% headcast. It is assumed that surface2 is to be (among others) rotated by 
% about 15 degrees in the xz-plane in order to pre-align with surface1,
% before ICP is used for a refined coregistration.

% this is needed for the ICP function that is used below
ft_hastoolbox('fileexchange',1);

if ischar(surface1)
  x1 = ft_read_headshape(surface1);
else
  x1 = surface1;
end

if ischar(surface2)
  x2 = ft_read_headshape(surface2);
  x2 = ft_determine_coordsys(x2);
else
  x2 = surface2;
end

if ~isfield(x1, 'coordsys')
  x1 = ft_determine_coordsys(x1);
end
if ~isequal(x1.coordsys, 'als')
  M4 = transform_generic('als', x1.coordsys); % transform back to input coordsys
  x1 = ft_convert_coordsys(x1, 'als');
else
  M4 = eye(4);
end
if ~isfield(x2, 'coordsys')
  x2 = ft_determine_coordsys(x2);
end
if ~isequal(x2.coordsys, 'als')
  M00 = transform_generic(x2.coordsys, 'als'); % transform into ALS
  x2  = ft_convert_coordsys(x2, 'als');
else
  M00 = eye(4);
end

% rotate the MRI based surface with 15 degrees in the xz-plane, as per what is done at DCC
R = eye(4);
R([1 3],[1 3]) = [cos(-pi/12) -sin(-pi/12);sin(-pi/12) cos(-pi/12)];
x2 = ft_transform_geometry(R, x2);

M00 = R*M00; % keep track of the rotation as well

% the vertex positions are not guaranteed to be unique, leading to degenerate normals later on, fix this
[v,ftpath] = ft_version;
curr_dir   = pwd;
cd(fullfile(ftpath,'private'));

[x1.pos, x1.tri] = remove_double_vertices(x1.pos, x1.tri);
[x2.pos, x2.tri] = remove_double_vertices(x2.pos, x2.tri);

% compute the normals, needed for a good icp
x1.nrm = normals(x1.pos,x1.tri);

% make a local copy of the positions
pos1 = x1.pos;
pos2 = x2.pos;

% compute the mean
x1m = mean(pos1);
x2m = mean(pos2);

x1m(3) = max(pos1(:,3));
x2m(3) = max(pos2(:,3));

% center
pos1_c = pos1-x1m;
pos2_c = pos2-x2m;

M3 = [eye(3) x1m(:);0 0 0 1];
M0 = inv([eye(3) x2m(:);0 0 0 1]);

% apply the icp algorithm for alignment, the mappning is from p to q (i.e.
% second point cloud onto the first one
params_fixed = {'Matching', 'kDtree', 'Minimize', 'plane'};
params_added = {'Triangulation', x1.tri, 'Normals', x1.nrm', 'WorstRejection', 0.2};
params       = cat(2,params_added,params_fixed);

sel                = pos2_c(:,3)>=min(pos1_c(:,3));
[R,T,ER,t,info(1)] = icp(pos1_c',pos2_c(sel,:)', params{:});
M1                 = [R T; 0 0 0 1];
pos2_c             = ft_warp_apply(M1, pos2_c);

[R,T,ER,t,info(2)] = icp(pos1_c',pos2_c(sel,:)', params{:});
M2                 = [R T; 0 0 0 1];
pos2_c             = ft_warp_apply(M2, pos2_c);

T      = M3*M2*M1*M0; % transformation matrix that excludes the already applied steps
x2     = ft_transform_geometry(T, x2);
Tfinal = M4*T*M00; % final transformation matrix that maps the second mesh onto the first.

surface2 = ft_transform_geometry(Tfinal, surface2);
[surface1.pos, surface1.tri] = remove_double_vertices(surface1.pos, surface1.tri);
[surface2.pos, surface2.tri] = remove_double_vertices(surface2.pos, surface2.tri);
surface2.coordsys = surface1.coordsys;

cd(curr_dir);
