%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to construct generic transformations such as RAS2ALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = transform_generic(to, from)
% NOTE: the input argument order is different from the order as used in
% ft_convert_coordsys, which seems to be a bit inconsistent with respect to
% the expected behavior, see the xxx,yyy, order change in line 207 of that
% function

ap_in  = find(from=='a' | from=='p');
ap_out = find(to=='a'   | to=='p');
lr_in  = find(from=='l' | from=='r');
lr_out = find(to=='l'   | to=='r');
si_in  = find(from=='s' | from=='i');
si_out = find(to=='s'   | to=='i');

% index axis according to ap,lr,si
order_in  = [ap_in  lr_in  si_in];
order_out = [ap_out lr_out si_out];

% check whether one of the axis needs flipping
flip = 2.*(0.5-double(from(order_in)~=to(order_out)));

T = zeros(4);
for k = 1:3
  T(order_in(k),order_out(k)) = flip(k);
end
T(4,4) = 1;
