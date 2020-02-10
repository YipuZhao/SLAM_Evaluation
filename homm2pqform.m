function [pqform] = homm2pqform(homm)
%%
% Generate a 3D point and unit quaterniona from 4x4 homogeneous transformation matrix.
% 
% Input:
% homm -- 4x4 homogeneous transformation matrix
% 
% Output:
% pqform -- tuple consisting of (tx,ty,tz,qx,qy,qz,qw) where
% (tx,ty,tz) is the 3D position and (qx,qy,qz,qw) is the unit quaternion.
%
pqform(1:3) = homm(1:3,4);
pqform([7, 4:6]) = tform2quat(homm);
