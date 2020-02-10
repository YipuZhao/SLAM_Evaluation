clear all
close all

%% create random sym psd matrix
% random sym matrix
N=100;
d = 10*rand(N,1); % The diagonal values
t = triu(bsxfun(@min,d,d.').*rand(N),1); % The upper trianglar random values
Q = diag(d)+t+t.'; % Put them together in a symmetric matrix
% make sure it's psd
Q = Spd_Mat(Q);

rank(Q)
det(Q)
figure;
subplot(2,2,1)
imagesc(Q)
colorbar
title('Original Matrix Q')
% axis equal

%% verify cholesky
R_0 = chol(Q);
assert(sum(sum(abs(Q - R_0' * R_0))) < 1e-5)
D_0 = diag(R_0);
disp(['det(Q) = ' num2str(det(Q))])

s_idx = [1:N-1];
R_1 = chol(Q(s_idx,s_idx));
assert(sum(sum(abs(Q(s_idx,s_idx) - R_1' * R_1))) < 1e-5)
disp(['det(Q_1) = ' num2str(det(Q(s_idx,s_idx))) ...
  '; prod(D_0(s_idx))^2 = ' num2str(prod(D_0(s_idx))^2)])
%
subplot(2,2,2);
R_diff = R_0(s_idx, s_idx)-R_1;
% R_diff = R_0-[[R_1 zeros(N-1,1)]; zeros(1,N)];
imagesc(R_diff)
colorbar
title('Diff. in Cholesky R, after removing last column')

r = max(1, floor(rand() * N))
s_idx = [1:r-1, r+1:N];
R_2 = chol(Q(s_idx,s_idx));
assert(sum(sum(abs(Q(s_idx,s_idx) - R_2' * R_2))) < 1e-5)
disp(['det(Q_2) = ' num2str(det(Q(s_idx,s_idx))) ...
  '; prod(D_0(s_idx))^2 = ' num2str(prod(D_0(s_idx))^2)])
%
subplot(2,2,3);
R_diff = R_0(s_idx, s_idx)-R_2;
imagesc(R_diff)
colorbar
title(['Diff. in Cholesky R, after removing column ' num2str(r)])

r1 = max(1, floor(rand() * (N-10)))
r2 = min(N, r1 + 10)
s_idx = [1:r1,r2:N];
R_3 = chol(Q(s_idx,s_idx));
assert(sum(sum(abs(Q(s_idx,s_idx) - R_3' * R_3))) < 1e-5)
disp(['det(Q_3) = ' num2str(det(Q(s_idx,s_idx))) ...
  '; prod(D_0(s_idx))^2 = ' num2str(prod(D_0(s_idx))^2)])
%
subplot(2,2,4);
R_diff = R_0(s_idx, s_idx)-R_3;
imagesc(R_diff)
colorbar
title(['Diff. in Cholesky R, after removing columns ' num2str(r1) ' to ' num2str(r2)])

% figure;
% subplot(2,2,1)
% imagesc(R_0)
% subplot(2,2,2)
% imagesc(R_1)
% subplot(2,2,3)
% imagesc(R_2)
% subplot(2,2,4)
% imagesc(R_3)