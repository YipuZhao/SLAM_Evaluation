function [homm_diff] = ominus(homm_a, homm_b)
%%
%
invalid_idx = find(~isfinite(homm_a), 1);
if isempty(invalid_idx)
  if cond(homm_a) < 1/(max(size(homm_a))*eps)
    %   homm_diff = inv(homm_a) * homm_b;
    homm_diff = homm_a \ homm_b;
  else
    homm_diff = [];
  end
else
  homm_diff = [];
end
% quat = quatmultiply(pose_t1([8, 5:7]), quatinv( pose_t0([8, 5:7]) ) );
% ax_ang = quat2axang( quat );
% eul_ang = quat2eul( quat );