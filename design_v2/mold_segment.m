% observation: the mold seems to have an inner and outer surface, or rather
% seems to consist of the original chunks that can be taken apart. This
% causes the mesh to be a single entity, even after slicing off the bottom.
% In addition, the mold generation function 

% the triangles in the mold seem to be systematically ordered as to reflect
% the individual parts of the mold. 
pos = mold.pos; tri = mold.tri;
plane = [14.8 0 0; 14.8 1 0; 14.8 0 1]; % front back
[X, Y, Z, posa, tria, posp, trip] = intersect_plane(pos, tri, plane(1,:), plane(2,:), plane(3,:));
plane = [0 0 0; 1 0 0; 0 0 1]; % left right
[X, Y, Z, posar, triar, posal, trial] = intersect_plane(posa, tria, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, pospr, tripr, pospl, tripl] = intersect_plane(posp, trip, plane(1,:), plane(2,:), plane(3,:));
plane = [0 0 56; 0 1 56; 1 0 56]; % z-plane
[X, Y, Z, posar1, triar1, posar2, triar2] = intersect_plane(posar, triar, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, posal1, trial1, posal2, trial2] = intersect_plane(posal, trial, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, pospr1, tripr1, pospr2, tripr2] = intersect_plane(pospr, tripr, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, pospl1, tripl1, pospl2, tripl2] = intersect_plane(pospl, tripl, plane(1,:), plane(2,:), plane(3,:));
plane = [0 0 125; 0 1 125; 1 0 125]; % z-plane
[X, Y, Z, posar2, triar2, posar3, triar3] = intersect_plane(posar2, triar2, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, posar2, triar2, posal3, trial3] = intersect_plane(posal2, trial2, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, posar2, triar2, pospr3, tripr3] = intersect_plane(pospr2, tripr2, plane(1,:), plane(2,:), plane(3,:));
[X, Y, Z, posar2, triar2, pospl3, tripl3] = intersect_plane(pospl2, tripl2, plane(1,:), plane(2,:), plane(3,:));

seg = zeros(size(pos,1),3);
seg(pos(:,1)>14.8,1) = 1; % anterior
seg(pos(:,1)<14.8,1) = 2; % posterior
seg(pos(:,2)>0,2)    = 1; % left
seg(pos(:,2)<0,2)    = 2; % right
seg(pos(:,3)<56,3)   = 1; % bottom
seg(pos(:,3)>56 & pos(:,3)<123,3) = 2; % middle
seg(pos(:,3)>123,3)  = 3; % top

indx = (1:size(pos,1))';
triseg = zeros(size(tri,1), 1);
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==1&seg(:,3)==1)),2)>1) = 1; %anterior-left-bottom
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==1&seg(:,3)==1)),2)>1) = 2; %posterior-left-bottom
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==2&seg(:,3)==1)),2)>1) = 3; %anterior-right-bottom
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==2&seg(:,3)==1)),2)>1) = 4; %posterior-rigt-bottom
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==1&seg(:,3)==2)),2)>1) = 5; %anterior-left-middle
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==1&seg(:,3)==2)),2)>1) = 6; %posterior-left-middle
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==2&seg(:,3)==2)),2)>1) = 7; %anterior-right-middle
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==2&seg(:,3)==2)),2)>1) = 8; %posterior-right-middle
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==1&seg(:,3)==3)),2)>1) = 9; %anterior-left-top
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==1&seg(:,3)==3)),2)>1) = 10; %posterior-left-top
triseg(sum(ismember(tri, indx(seg(:,1)==1&seg(:,2)==2&seg(:,3)==3)),2)>1) = 11; %anterior-right-top
triseg(sum(ismember(tri, indx(seg(:,1)==2&seg(:,2)==2&seg(:,3)==3)),2)>1) = 12; %posterior-right-top

seg2 = zeros(size(pos,1), 12);
for k = 1:12
  tmp = unique(reshape(tri(triseg==k,:),[],1));
  seg2(tmp,k) = 1;
end
