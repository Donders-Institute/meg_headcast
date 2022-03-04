function split = splitmesh(mesh, segmentation)

% SPLITMESH splits a mesh into its constituent objects, by looking at
%  - the segmentation, defined on the vertices, that reflect the individual
%  subparts, or
%  - the faces, returning the separate objects, i.e. chunk of faces that
%  are disconnected from one another

if nargin==1
  % split according to the structure in the triangles (this might not work
  % well)
  tri     = mesh.tri;
  pos     = mesh.pos;
  npos    = size(pos,1);
  indx    = zeros(npos,1);

  % extract the edges
  edge = [tri(:,[1 2]);tri(:,[1 3]);tri(:,[2 3])];
  edge = unique(sort(edge,2), 'rows');

  % create an adjacency matrix
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

else
  tri = mesh.tri;
  pos = mesh.pos;

  % use the information from the segmentation vector
  for k = 1:max(segmentation)
    sel = segmentation==k;
    thistri = tri(sum(ismember(tri, find(sel)),2)==3,:);
    sel = unique(thistri(:));
    split(k).tri = tri_reindex(thistri);
    split(k).pos = pos(sel,:);
  end
end


function [newtri] = tri_reindex(tri)

% this subfunction reindexes tri such that they run from 1:number of unique vertices
newtri       = tri;
[srt, indx]  = sort(tri(:));
tmp          = cumsum(double(diff([0;srt])>0));
newtri(indx) = tmp;




