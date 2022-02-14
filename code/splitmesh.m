function split = splitmesh(mesh)

% SPLITMESH splits a mesh into its constitutent objects, by looking at the
% faces, returning the separate objects.

tri     = mesh.tri;
pos     = mesh.pos;
npos    = size(pos,1);
indx    = zeros(npos,1);

% create an adjacency matrix
edge = [tri(:,[1 2]);tri(:,[1 3]);tri(:,[2 3])];
edge = unique([edge; edge(:,[2 1])], 'rows');
edge = [edge; edge(:,[2 1])];
C    = sparse(edge(:,1), edge(:,2), true(size(edge,1),1));

% grow objects, starting from the first vertex
sel_prev = 1;
done = false;
cnt = 1;
while ~done
  sel = sum(C(:,sel_prev),2)>0;
  if sum(sel)==sum(sel_prev)
    indx(sel) = cnt;
    cnt = cnt+1;
    sel = false(npos,1);
    sel(find(indx==0, 1, 'first')) = true;
    if(sum(sel)==0)
      done = true;
    end
  end
  sel_prev = sel;
end

for k = 1:max(indx)
  split(k) = mesh;
  split(k).pos = mesh.pos(indx==k, :);
  
  seltri = any(ismember(mesh.tri, find(indx==k)), 2);
  split(k).tri = tri_reindex(mesh.tri(seltri, :));
end

function [newtri] = tri_reindex(tri)

% this subfunction reindexes tri such that they run from 1:number of unique vertices
newtri       = tri;
[srt, indx]  = sort(tri(:));
tmp          = cumsum(double(diff([0;srt])>0));
newtri(indx) = tmp;




