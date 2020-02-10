function [quat, ax_ang, eul_ang] = getRotationParam(pose_t1, pose_t0)
%%
%
quat = quatmultiply(pose_t1([8, 5:7]), quatinv( pose_t0([8, 5:7]) ) );
ax_ang = quat2axang( quat );
eul_ang = quat2eul( quat );