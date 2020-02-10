function [matrix] = transform44(l)
%%
% Generate a 4x4 homogeneous transformation matrix from a 3D point and unit quaternion.
% 
% Input:
% l -- tuple consisting of (tx,ty,tz,qx,qy,qz,qw) where
% (tx,ty,tz) is the 3D position and (qx,qy,qz,qw) is the unit quaternion.
% 
% Output:
% matrix -- 4x4 homogeneous transformation matrix

t = l(1:3);
q = l(4:7);
nq = q * q';

if nq < eps
  matrix = [
    1, 0, 0, t(1);
    0, 1, 0, t(2);
    0, 0, 1, t(3);
    0, 0, 0, 1.0;
    ];
  return ;
else
  q = q * sqrt(2 / nq);
  q = q' * q;
  matrix = [
    1 - q(2,2) - q(3,3), q(1,2) - q(3,4), q(1,3) + q(2,4), t(1);
    q(1,2) + q(3,4), 1 - q(1,1) - q(3,3), q(2,3) - q(1,4), t(2);
    q(1,3) - q(2,4), q(2,3) + q(1,4), 1 - q(1,1) - q(2,2), t(3);
    0, 0, 0, 1.0;
    ];
  return ;
end