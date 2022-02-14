function [x1,x2,T] = align_meshes(filename1, filename2)

% function to align two surface models of a head, obtained e.g. with the
% 3D-scanner. The purpose is that filename1 and filename2 point to a scan
% of the same person, where filename2 (for instance) has the headcast in place.

ft_hastoolbox('fileexchange',1);

if ischar(filename1)
  x1 = ft_read_headshape(filename1);
  x1 = ft_determine_coordsys(x1);
else
  x1 = filename1;
end

if ischar(filename2)
  x2 = ft_read_headshape(filename2);
  x2 = ft_determine_coordsys(x2);
else
  x2 = filename2;
end

assert(isfield(x1, 'coordsys'));
assert(isfield(x2, 'coordsys'));

% the vertex positions are not guaranteed to be unique, leading to
% degenerate normals later on, fix this
[v,ftpath] = ft_version;
curr_dir   = pwd;
cd(fullfile(ftpath,'private'));

[x1.pos, x1.tri, x1keep] = remove_double_vertices(x1.pos, x1.tri);
[x2.pos, x2.tri, x2keep] = remove_double_vertices(x2.pos, x2.tri);

% compute the normals, needed for a good icp
x1.nrm = normals(x1.pos,x1.tri);
cd(curr_dir);

% make a local copy of the positions
pos1 = x1.pos;
pos2 = x2.pos;

% compute the mean
x1m = mean(pos1);
x2m = mean(pos2);

% center
pos1_c = pos1-x1m;
pos2_c = pos2-x2m;

% % svd
% [u1,s1,v1] = svd(pos1_c, 'econ');
% [u2,s2,v2] = svd(pos2_c, 'econ');
% 
% % ensure v1 and v2 not to cause a handedness flip.
% for k = 1:3
%   [~,ix1] = max(abs(v1(:,k)));
%   [~,ix2] = max(abs(v2(:,k)));
%   sv1(k) = sign(v1(ix1,k));
%   sv2(k) = sign(v2(ix2,k));
% end
% v1(:,sv1<0) = -v1(:,sv1<0);
% v2(:,sv2<0) = -v2(:,sv2<0);
% 
% % rotate the coordinate axes -> the first axis is now (hopefully) the
% % positive z-axis
% pos1_c = pos1_c*v1;
% pos2_c = pos2_c*v2;
% M3     = [v1 x1m(:);0 0 0 1]; % from x1's pca space to x1 original space
% M0     = inv([v2 x2m(:);0 0 0 1]); % from x2's space to x2's pca space
M3 = [eye(3) x1m(:);0 0 0 1];
M0 = inv([eye(3) x2m(:);0 0 0 1]);

% % cut off the shoulders, all points below 25 cm below the top of the head
% cd(fullfile(ftpath,'plotting','private'));
% maxpoint1 = max(pos1_c,[],1);
% [X,Y,Z,pos1a,tri1a,pos1b,tri1b] = intersect_plane(pos1_c, x1.tri,[maxpoint1(1)-0.25 0 0],[maxpoint1(1)-0.25 1 0],[maxpoint1(1)-0.25 0 1]);
% 
% n1a = size(pos1a,1);
% n1b = size(pos1b,1);
% if n1a>n1b
%   x1tmp.pos = pos1a;
%   x1tmp.tri = tri1a;
% else
%   x1tmp.pos = pos1b;
%   x1tmp.tri = tri1b;
% end
% cd(fullfile(ftpath,'private'));
% x1tmp.nrm = normals(x1tmp.pos,x1tmp.tri);
% cd(curr_dir);
% 
% sel2c = pos2_c(:,1)>max(pos2_c(:,1))-0.25; % cut off the shoulders
x1tmp = x1;
sel2c = 1:size(pos2_c,1);

% apply the icp algorithm for alignment, the mappning is from p to q (i.e.
% second point cloud onto the first one
params_fixed = {'Matching', 'kDtree', 'Minimize', 'plane'};
params_added = {'Triangulation', x1tmp.tri, 'Normals', x1tmp.nrm', 'WorstRejection', 0.2};
params       = cat(2,params_added,params_fixed);
[R,T,ER,t,info(1)] = icp(x1tmp.pos',pos2_c(sel2c,:)', params{:});
M1                 = [R T; 0 0 0 1];
pos2_c             = ft_warp_apply(M1, pos2_c);

[R,T,ER,t,info(2)] = icp(x1tmp.pos',pos2_c(sel2c,:)', params{:});
M2                 = [R T; 0 0 0 1];
pos2_c             = ft_warp_apply(M2, pos2_c);

T = M3*M2*M1*M0; % final transformation matrix that maps the second mesh onto the first.

% target        = rmfield(x1tmp,'nrm');
% target.pos    = x1tmp.pos(info(2).q_idx,:);
% target.orig   = x1;
% target.orig.pos = pos1_c;
% target.inside = true(size(target.pos,1),1);
%       
% functional          = rmfield(target, 'orig');
% functional.distance = info(2).distanceout(:);
% functional.pos      = target.pos;
%       
% tmpcfg              = [];
% tmpcfg.parameter    = 'distance';
% tmpcfg.interpmethod = 'smudge';
% tmpcfg.sphereradius = 10;
% tmpcfg.feedback     = 'none';
% smoothdist          = ft_sourceinterpolate(tmpcfg, functional, target);
% 
