close all
clear all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

data_dir = '/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/laptop_onboard/';
% data_dir = '/media/yipuzhao/1399F8643500EDCD/ClosedLoop_Exp/Simulation/laptop_onboard';

% Batch Config
seq_list = {
  'loop';
  'long';
  'zigzag';
  'square';
  'two_circle';
  'infinite';
  };

imu_type =  'ADIS16448'; % 'mpu6000'; % 
slam_type = 'GF_gpu_skf_log'; % 'GF_v2';
num_feat = 100;
fwd_vel = '1.5'; % '1.0'; % '0.5'; % 

do_viz = 1;
%
ref_reload = 1;

round_num = 1 % 5;

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
  
  tn=6; % 1 %
  fn=1;
  log_tmp = [];
  for rn = 1:round_num
    disp(['Round ' num2str(rn)])
    % Load Log Files
    % ORB & GF
    disp(['Loading ORB & GF log...'])
    % load back end logging
    %     [log_tmp] = loadLogTUM_GoodBA_old([slam_path_list{tn} ...
    %       num2str(fast_mo_list(fn), '%.01f') '/' ...
    %       baseline_slam_list{table_index(tn)}], ...
    %       rn, seq_idx, log_tmp, 2);
    %         end
    log_fname = [data_dir '/' seq_idx ...
      '/' imu_type '/' slam_type '/ObsNumber_' num2str(num_feat) ...
      '_Vel' num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_Log_Mapping.txt'];
    %
    fid = fopen(log_fname, 'rt');
    if fid ~= -1
%       log_ = cell2mat(textscan(fid, ...
%         '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
      log_ = cell2mat(textscan(fid, ...
        '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
      %
      log_tmp.timeStampBack{rn}     = log_(:, 1);
      %
      log_tmp.timeNewKeyFrame{rn}   = log_(:, 2) * 1000;
      log_tmp.timeMapCulling{rn}    = log_(:, 3) * 1000;
      log_tmp.timeMapTriangulate{rn}= log_(:, 4) * 1000;
      log_tmp.timeSrhNeighbor{rn}   = log_(:, 5) * 1000;
      log_tmp.timeLocalBA{rn}       = log_(:, 6) * 1000;
      
      log_tmp.timeBackEnd{rn}         = log_tmp.timeNewKeyFrame{rn} + ...
        log_tmp.timeMapCulling{rn} + log_tmp.timeMapTriangulate{rn} + ...
        log_tmp.timeSrhNeighbor{rn} + log_tmp.timeLocalBA{rn};
      
      log_tmp.timePrediction{rn}    = log_(:, 7) * 1000;
      log_tmp.timeInsertVertex{rn}  = log_(:, 8) * 1000;
      log_tmp.timeJacobian{rn}      = log_(:, 9) * 1000;
      log_tmp.timeQuery{rn}         = log_(:, 10) * 1000;
      log_tmp.timeSchur{rn}         = log_(:, 11) * 1000;
      log_tmp.timePermute{rn}       = log_(:, 12) * 1000;
      log_tmp.timeCholesky{rn}      = log_(:, 13) * 1000;
      log_tmp.timePostProc{rn}      = log_(:, 14) * 1000;
      log_tmp.timeOptimization{rn}  = log_(:, 15) * 1000;
      log_tmp.timeBudget{rn}        = log_(:, 16) * 1000;
      
      % NOTE
      % only free KF contributes to the state space;
      % fixed ones serves as diagonal priors only
      %
      log_tmp.numPoseState{rn}      = log_(:, 18) * 6;
      log_tmp.numLmkState{rn}       = log_(:, 19) * 3;
    end
    
    fclose(fid);
    
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
xlabel('Graph Scale (KFs)');
ylim([0 1500]); ylabel('Local BA Budget (ms)');
title(seq_idx);

title('Total');