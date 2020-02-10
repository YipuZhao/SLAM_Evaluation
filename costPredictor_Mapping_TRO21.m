close all
clear all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'Hololens_RAL19_FastMo_OnlFAST'
% 'EuRoC_RAL19_FastMo_OnlFAST' % 'EuRoC_RAL19_Jetson' % 
% 'FPV_RAL19_FastMo_OnlFAST' % 
% 'EuRoC_Mono_RAL19_FastMo_OnlFAST' 
 
setParam

do_viz = 1;
%
ref_reload = 1;

round_num = 10;

% plot_total_time_stat = true;
% plot_lmk_num = false; % true; %
% plot_gf_time_trend = false; % true; %
% plot_gf_time_stat = true; % false; %

total_time_summ = cell(1, 6);

xx = [];
yy = [];
zz = [];

figure;
clf

for sn = 1:length(seq_list) % [1,5,10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  tn=3 % 4 % 6; % 1 % 
  fn=1;
  log_tmp = [];
  for rn = 1:round_num
    disp(['Round ' num2str(rn)])
    % Load Log Files
    % ORB & GF
    disp(['Loading ORB & GF log...'])
    % load front end logging
    [log_tmp] = loadLogTUM_hash_stereo([slam_path_list{tn} ...
      num2str(fast_mo_list(fn), '%.01f') '/' ...
      baseline_slam_list{table_index(tn)}], ...
      rn, seq_idx, log_tmp, 2);
    log_tmp.timeFrontEnd{rn} = log_tmp.timeTotal{rn};
    log_tmp.numMeasur{rn}    = log_tmp.lmkLocalMap{rn};
    % load back end logging
    %     [log_tmp] = loadLogTUM_GoodBA_old([slam_path_list{tn} ...
    %       num2str(fast_mo_list(fn), '%.01f') '/' ...
    %       baseline_slam_list{table_index(tn)}], ...
    %       rn, seq_idx, log_tmp, 2);
    %         end
    [log_tmp] = loadLogTUM_GoodBA_v2([slam_path_list{tn} ...
      num2str(fast_mo_list(fn), '%.01f') '/' ...
      baseline_slam_list{table_index(tn)}], ...
      rn, seq_idx, log_tmp, 2);
  end
  
  x = [];
  y = [];
  z = [];
  for rn = 1:round_num
    x = [x; log_tmp.numPoseState{rn}(2:end)/6];
    y = [y; (log_tmp.numLmkState{rn}(2:end)/3) ./ (log_tmp.numPoseState{rn}(2:end)/6)];
    z = [z; log_tmp.timeBackEnd{rn}(2:end)];
  end
  
  vld_idx = find(z > 0);
  x = x(vld_idx);
  y = y(vld_idx);
  z = z(vld_idx);
  
  xx = [xx; x];
  yy = [yy; y];
  zz = [zz; z];
  
  subplot(3, 4, sn)
  plot(x,z)
  scatter(x,z,'x')
  A=[x .* x .* x x .* x x repmat(1, length(x), 1)]
  coe = A\z
  hold on
  u=[1:250];
  v=coe(1) * (u .* u .* u) + coe(2) * (u .* u) + coe(3) * u + coe(4);
  plot(u, v, 'r--')
  xlim([0 250]); xlabel('free KF num');
  ylim([0 1500]); ylabel('BA time cost (ms)');
  
  %   subplot(3, 4, sn)
  %   scatter3(x,y,z,'x')
  %   A=[x.*x.*x x.*x x y.*y y ones(length(x), 1)]
  %   coe = A\z
  %   hold on
  %   u=repmat([1:200]', 1, 71);
  %   v=repmat([50:5:400], 200, 1);
  %   w=coe(1) * (u.*u.*u) + coe(2) * (u.*u) + coe(3) * u + ...
  %     coe(4) * (v.*v) + coe(5) * v + coe(6);
  %   surf(u, v, w, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
  %   xlim([0 250]); xlabel('free KF num');
  %   ylim([50 400]); ylabel('lmk num per frame');
  %   zlim([0 1500]); zlabel('BA time cost (ms)');
  
  title(seq_idx);
end

subplot(3, 4, 12)
scatter(xx,zz,'x')
A=[xx .* xx .* xx xx .* xx xx repmat(1, length(xx), 1)]
coe = A\zz
hold on
u=[1:250];
v=coe(1) * (u .* u .* u) + coe(2) * (u .* u) + coe(3) * u + coe(4);
plot(u, v, 'r--')

% scatter3(xx,yy,zz,'x')
% A=[xx.*xx.*xx xx.*xx xx yy.*yy yy ones(length(xx), 1)]
% coe = A\zz
% hold on
% u=repmat([1:200]', 1, 71);
% v=repmat([50:5:400], 200, 1);
% w=coe(1) * (u.*u.*u) + coe(2) * (u.*u) + coe(3) * u + ...
%   coe(4) * (v.*v) + coe(5) * v + coe(6);
% surf(u, v, w, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
% xlim([0 250]); xlabel('free KF num');
% ylim([50 400]); ylabel('lmk num per frame');
% zlim([0 1500]); zlabel('BA time cost (ms)');

title(seq_idx);

title('Total');