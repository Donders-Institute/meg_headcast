function [helmet, innersurface] = align_moldstl2dewar

% ALIGN_MOLDSTL2DEWAR aligns the helmet's mold innersurface to the MEG helmet.
% The MEG helmet is expressed in the dewar's coordinate system, and
% coregistered to the sensors using the procedure in
% ALIGN_SINGLESUBJECTSTL2MEGCOORDSYS
%
% Use as 
%   [helmet, innersurface] = align_moldstl2dewar

if 1
  ft_hastoolbox('fileexchange', 1);
  load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models/singlesubject', 'helmet_dewar_mm.mat'));
  load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models', 'mold_innersurface.mat'));

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

  % apply the icp algorithm for alignment, the mapping is from p to q (i.e.
  % second point cloud onto the first one
  params_fixed = {'Matching', 'kDtree', 'Minimize', 'plane'};
  params_added = {'Triangulation', x1.tri, 'Normals', x1.nrm', 'WorstRejection', 0.05};
  params       = cat(2,params_added,params_fixed);

  [R,T,ER,t,info(1)] = icp(x1.pos', x2.pos', params{:});
  M3                 = [R T; 0 0 0 1];
  x2.pos             = ft_warp_apply(M3, x2.pos);
  x2.distancein      = zeros(size(x2.pos,1),1);
  x2.distancein(info(1).p_idx) = info(1).distancein;
  x2.distanceout     = zeros(size(x2.pos,1),1);
  x2.distanceout(info(1).p_idx) = info(1).distanceout;
  
  [R,T,ER,t,info(2)] = icp(x1.pos', x2.pos', params{:}); %this last step just leads to an identy matrix
  M4                 = [R T; 0 0 0 1];
  x2.pos             = ft_warp_apply(M4, x2.pos); 
  innersurface = x2;
  innersurface.coordsys = 'dewar';

  save(fullfile('/home/dyncon/jansch/projects/meg_headcast/models', 'mold_innersurface_dewar.mat'), 'innersurface');

  % Tfinal = M4*M3*R2*T1;
else
  % just load the data
  load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models/singlesubject', 'helmet_dewar_mm.mat'));
  load(fullfile('/home/dyncon/jansch/projects/meg_headcast/models', 'mold_innersurface_dewar.mat'), 'innersurface');
end

figure; hold on;
ft_plot_mesh(helmet, 'facealpha', 0.5);
ft_plot_axes(helmet);
ft_plot_mesh(innersurface, 'vertexcolor', innersurface.distanceout);
h=light; lighting gouraud
