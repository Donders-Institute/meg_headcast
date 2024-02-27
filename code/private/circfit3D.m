function [O,R,d] = spherfit(pos)

%   [O,R,d] = spherefit(pos)
%
%   fits a sphere to a xyz point cloud
%
%  result is center point O and radius R
%  and the distance vector d of the points to the origin

mpos = mean(pos,1);
pos  = pos - mpos;
pos  = [pos ones(size(pos,1), 1)];

if rank(pos)==3
  % points are already in a plane, compute solution on the plane, and
  % project back
  pos     = pos(:,1:3);
  [u,s,v] = svd(pos, 'econ');
  pos  = pos * v(:,1:2);
  
  pos = [pos ones(size(pos,1),1)];
  a = inv(pos'*pos)*pos'*(-(sum(pos(:,1:2).^2,2)));
  O = [(-0.5.*a(1:2)') 0]*v' + mpos;
  %N = [0 0 1]*v';
  R = sqrt((a(1)^2+a(2)^2)/4-a(3));

  d = sqrt(sum((pos(:,1:3)+mpos-O).^2,2));
else
  a = inv(pos'*pos)*pos'*(-(sum(pos(:,1:3).^2,2)));
  O = -0.5.*a(1:3)' + mpos;
  R = sqrt((a(1)^2+a(2)^2+a(3)^2)/4-a(4));

  d = sqrt(sum((pos(:,1:3)+mpos-O).^2,2));
end

