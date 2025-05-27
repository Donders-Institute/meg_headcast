function [surface1, surface2, T] = align_surface2surface_fid(surface1, surface2, flag)

% ALIGN_SURFACE2SURFACE_FID aligns two surface models, not necessarily
% describing the same object, based on the fiducial location information
% present. 
%
% Use as
%   [s1, s2, T] = align_surface2surface_icp(surface1, surface2, flag)
%
% where surface1 and surface2 contain a subfield fid, that contains
% matching fiducials.
%
% The output surfaces s1 and s2 are aligned (to s1), and the transformation
% matrix T maps the input surface2 to surface1.

fid1 = surface1.fid;
fid2 = surface2.fid;

[ix1,ix2] = match_str(fid1.label, fid2.label);
pos1 = fid1.pos(ix1,:);
pos2 = fid2.pos(ix2,:);

[R, t] = getRt(pos2', pos1');
T      = [R t; 0 0 0 1];
surface2 = ft_transform_geometry(T, surface2);

function [R, t] = getRt(A, B) 

% This function finds the optimal Rigid/Euclidean transform in 3D space
% It expects as input a 3xN matrix of 3D points.
% It returns R, t, which transforms A into B

% find mean column wise, this should not be needed, because the fiducials
% are equivalent
centroid_A = mean(A, 2);
centroid_B = mean(B, 2);

% subtract mean
Am = A - repmat(centroid_A, 1, size(A, 2));
Bm = B - repmat(centroid_B, 1, size(B, 2));

% calculate covariance matrix
H = Am * Bm';

% find rotation
[U,S,V] = svd(H);
R = V*U';

if det(R) < 0
  fprintf('det(R) < R, reflection detected!, correcting for it ...\n');
  V(:,3) = V(:,3) * -1;
  R = V*U';
end

t = -R*centroid_A + centroid_B;
