function fiducial = locatecoil(coil)

% this function aims to identify the location of the 'hole' in the coil

if numel(coil)>1
  for k = 1:numel(coil)
    tmp = locatecoil(coil(k));
    fiducial(k,:) = tmp;
  end
  return
end

% first determine the main axis of the coil
pos = coil.pos;
offset = mean(pos,1);
pos_centered = pos - repmat(offset, [size(pos,1),1]);
[u,s,v] = svd(pos_centered, 'econ');
pos_centered_rotated = pos_centered*v; 

% intersect with the y/z-plane
[vv,ftpath] = ft_version;
curr_dir   = pwd;
cd(fullfile(ftpath,'plotting/private'));

% this might fail if the coil is thicker than expected, leading to an empty
% C
[X,Y,Z] = intersect_plane(pos_centered_rotated,coil.tri,[0 0 0],[0 1 0],[1 0 0]);
C       = extractcircle(X,Y);
xy_ind  = [1 2];
if isempty(C)
  [X,Y,Z] = intersect_plane(pos_centered_rotated,coil.tri,[0 0 0],[0 0 1],[1 0 0]);
  C       = extractcircle(X,Z);
  xy_ind  = [1 3];
end
cd(curr_dir);

[xc,yc,R] = circfit(C(:,1),C(:,2));
origin    = zeros(1,3);
origin(xy_ind(1)) = xc;
origin(xy_ind(2)) = yc;

fiducial = origin*v' + offset;

function   [xc,yc,R,a] = circfit(x,y)

% FROM FILE EXCHANGE
%
%   [xc yx R] = circfit(x,y)
%
%   fits a circle  in x,y plane in a more accurate
%   (less prone to ill condition )
%  procedure than circfit2 but using more memory
%  x,y are column vector where (x(i),y(i)) is a measured point
%
%  result is center point (yc,xc) and radius R
%  an optional output is the vector of coeficient a
% describing the circle's equation
%
%   x^2+y^2+a(1)*x+a(2)*y+a(3)=0
%
%  By:  Izhak bucher 25/oct /1991, 

x = x(:); 
y = y(:);
a = [x y ones(size(x))]\[-(x.^2+y.^2)];
xc = -.5*a(1);
yc = -.5*a(2);
R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));

function C = extractcircle(X,Y)
   
% make connected line segments from X and Y, assuming that there's an inner
% circle to be created

assert(numel(unique(X(:))) == numel(X)./2);
assert(numel(unique(Y(:))) == numel(Y)./2); % if these conditions are not met
% then there might be some rounding issues

this_index = 1;
this_contour = [X(1,:)' Y(1,:)'];

cnt = 0;
while ~isempty(X)
  X(this_index,:) = [];
  Y(this_index,:) = [];
  this_index = find(X(:,1)==this_contour(end,1)&Y(:,1)==this_contour(end,2));
  if isempty(this_index)
    this_index = find(X(:,2)==this_contour(end,1)&Y(:,2)==this_contour(end,2));
    if isempty(this_index)
      % end of this contour
      cnt = cnt+1;
      C{cnt,1}= this_contour;
      if ~isempty(X)
        this_index = 1;
        this_contour = [X(1,:)' Y(1,:)'];
      end
      continue;
    end
    X(this_index,:) = X(this_index,[2 1]);
    Y(this_index,:) = Y(this_index,[2 1]);
  else
    % nothing needed
  end
  this_contour = cat(1,this_contour,[X(this_index,2) Y(this_index,2)]);
end

% now identify which one is the approximate circle
for k = 1:numel(C)
  this = C{k};
  this = this - repmat(mean(this),[size(this,1) 1]);
  this_D = sqrt(sum(this.^2,2));
  ok(k) = all(this_D<2.5); % assume a distance of at most 2.5 mm
end
if any(ok)
  C = C{ok};
else
  C = [];
end