% Scale the translational components of a 4x4 homogeneous matrix by a scale factor.
function as = scale(a,scalar)
as = a;
as(1:3,4) = a(1:3,4) * scalar;
