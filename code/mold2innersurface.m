function [mold, innersurface] = mold2innersurface()

[mold, transform_moldstl2ctfish] = align_moldstl2ctfish;

%pos = mold.pos;
%tri = mold.tri;
[pos, tri] = remove_double_vertices(mold.pos, mold.tri);

[pnt, T] = mesh_sphere(10000);
shift    = 0.7;
pnt(:,3) = pnt(:,3) + shift;
r        = sqrt(pnt(:,1).^2 + pnt(:,2).^2); % distance to the z-axis
sel      = pnt(:,3) < shift; % points on the lower half sphere
pnt(sel, 1:2) = pnt(sel, 1:2)./r(sel); 

removepos = find(pnt(:,3) < 0);
[pnt, T]  = remove_vertices(pnt, T, removepos);
pnt       = pnt.*77;
pnt(:,3)  = pnt(:,3).*1.4;

sel = pnt(:,1) > 0;
pnt(sel,1) = pnt(sel,1).*1.2;

O        = pnt;
O(:,1:2) = 0;
O(:,3)   = O(:,3).*0.75 - 20;

bnd.pos = pnt;
bnd.tri = T;

figure;hold on; 
ft_plot_mesh(mold, 'facealpha', 0.4);
ft_plot_mesh(bnd, 'facecolor', 'r');
drawnow;
view([-90 0]);

for k = 1:size(pnt,1)
  if mod(k,100)==0
  fprintf('computing projection of point %d/%d\n',k,size(pnt,1));
  end

  [la0,mu0,d0,p0] = lmoutrn(pos(tri(:,1),:),pos(tri(:,2),:),pos(tri(:,3),:), O(k,:));
  d0=abs(d0);

  [la1,mu1,d1,p1] = lmoutrn(pos(tri(:,1),:),pos(tri(:,2),:),pos(tri(:,3),:),pnt(k,:));
  d1=abs(d1);

  deltad  = d0 - d1; % note: only the positive values make sense to further explore
  deltala = la1-la0;
  deltamu = mu1-mu0;
  deltap  = p1-p0;

  m = d0./deltad; % ratio with which the other deltas need to be multiplied

  L = la0 + deltala.*m; % this one should be larger or equal to 0
  M = mu0 + deltamu.*m; % this one should be larger or equal to 0, L+M<=1
  P = p0  + deltap.*m;

  dP = sqrt(sum((P-pnt(k,:)).^2,2));

  sel = find(deltad>0 & L>0 & M>0 & L+M<1);
  [minval, im] = min(dP(sel));
  if ~isempty(im)
    projdist(k,1) = dP(sel(im));
    projpnt(k,:)  = P(sel(im),:);
    seltri(k,1)   = sel(im);
  end

end

% check whether the projected points are far away from the average position
% of their neighbours
C = triangle2connectivity(T);
for k = 1:size(projpnt,1)
  c = (C(:,k)'*projpnt)./sum(C(:,k));
  D(k,1) = sqrt(sum( (projpnt(k,:) - c).^2, 2));
end

sel = find(D>8);
for k = 1:numel(sel)
  projpnt(sel(k),:) = (C(:,sel(k))'*projpnt)./sum(C(:,sel(k)));
end
innersurface.pos = projpnt;
innersurface.tri = T;
innersurface.origtri = seltri;
innersurface.projdist = projdist;
innersurface.coordsys = 'als';
innersurface.unit     = 'mm';
