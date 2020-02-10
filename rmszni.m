% ------------------------------------------------------------- y = rmszni(x)
% RMSZNI(x) returns the root mean square of vector x, 
%           excluding the x = {0,NaN,+/-Inf} terms
%
% Outputs:
%           xx = x(find(isfinite(x) & x ~= 0));
%
%            y = sqrt(sum(xx.^2)/length(xx));
%
% -------------------------------------------------------------------------

function rmszni = rmszni(x)

% Remove zeros, NaN, and Inf
xx = x(find(isfinite(x) & x ~= 0));

y = sqrt(sum(xx.^2)/length(xx));



