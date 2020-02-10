clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');

%% simu results
% data_path = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Lazier_Greedy_Simulation';
data_path = '/home/yipuzhao/ros_workspace/package_dir/GF_ORB_SLAM/tools/simu';
% [X, Y] = meshgrid(100:200:3000, 10:10:80);
[X, Y] = meshgrid(500:250:2500, 40:20:180);
errBound = [0.9, 0.5, 0.2, 0.1, 0.05, 0.025, 0.01, 0.005];
timeCost_base = zeros(8, 9);
for i=1:length(errBound)
  timeCost_lazier{i} = zeros(8, 9);
end
%
ii = 4
jj = 9 %  8 % 

plot_box =  true; % false; % 
plot_surf = false; % true; % 

% timeVec_base = [];
for i=1:length(errBound)
  timeVec{i} = [];
end
for i=1:length(errBound)
  diffVec{i} = [];
end

%%
for wn = 1:100
  %
  timeCost_path = [data_path '/world_' num2str(wn) '_TimeCost.txt']
  fid = fopen(timeCost_path, 'rt');
  timeCost_dat = cell2mat(textscan(fid, '%f'));
  fclose(fid);
  %
  logDet_path = [data_path '/world_' num2str(wn) '_LogDet.txt']
  fid = fopen(logDet_path, 'rt');
  logDet_dat = cell2mat(textscan(fid, '%f'));
  fclose(fid);
  %
  diffFeat_path = [data_path '/world_' num2str(wn) '_DiffFeat.txt']
  fid = fopen(diffFeat_path, 'rt');
  diffFeat_dat = cell2mat(textscan(fid, '%f'));
  fclose(fid);
  
  %%
  timeCost_mat  = reshape(timeCost_dat, 20*length(errBound)+1, 8, 9);
  logDet_mat    = reshape(logDet_dat, 20*length(errBound)+1, 8, 9);
  diffFeat_mat  = reshape(diffFeat_dat, 20*length(errBound)+1, 8, 9);
  
  %% grab average time cost
  timeCost_base = timeCost_base + squeeze(mean(timeCost_mat(1, :, :), 1));
  for i=1:length(errBound)
    timeCost_lazier{i} = timeCost_lazier{i} + squeeze(mean(timeCost_mat((i-1)*20+2:i*20+1, :, :), 1));
  end
  
  %% grab rms of logDet
  %   std_logDet = squeeze(std(logDet_mat(2:end, :, :) - repmat(logDet_mat(1, :, :), 20, 1, 1), 1));
  %   cv_logDet = std_logDet ./ squeeze(logDet_mat(1, :, :));
  
  %% grab rms of subset index
  for i=1:length(errBound)
    std_diffFeat{i} = squeeze(rms(diffFeat_mat((i-1)*20+2:i*20+1, :, :), 1)) ./ (X .* Y / 100);
  end
  
  %% grab the time cost under specifc config
  %   timeVec_base         = [timeVec_base      timeCost_mat(1, ii, jj)];
  for i=1:length(errBound)
    timeVec{i} = [timeVec{i}; squeeze(timeCost_mat((i-1)*20+2:i*20+1, ii, jj)) * 1000];
  end
  
  %% grab the rms of subset index under specific config
  for i=1:length(errBound)
    diffVec{i} = [diffVec{i}; squeeze(diffFeat_mat((i-1)*20+2:i*20+1, ii, jj))  ./ (X(ii, jj) * Y(ii, jj) / 100)];
  end
end

if plot_surf
  %% surface plot of mean time cost
  h = figure(1);
  clf
  hold on
  set(gca,'FontSize',12)
  s0 = surf(X, Y, 30 * ones(8, 9), 'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
  s1 = surf(X, Y, 1000 * timeCost_base / wn, 'FaceColor', 'r', 'FaceAlpha', 0.5);
  s2 = surf(X, Y, 1000 * timeCost_lazier{3} / wn, 'FaceColor', [0 0.75 0.8], 'FaceAlpha', 0.5);
  s3 = surf(X, Y, 1000 * timeCost_lazier{4} / wn, 'FaceColor', [0 1 0], 'FaceAlpha', 0.5);
  s4 = surf(X, Y, 1000 * timeCost_lazier{5} / wn, 'FaceColor', [0.6 0.1 0.6], 'FaceAlpha', 0.5);
  set(gca, 'ZScale', 'log')
  xlabel('Full Set Size')
  ylabel('Subset Size')
  zlabel('Time Cost (ms)')
  grid on
  %
  bgt1 = 60;
  l1 = plot3([500, 2500], [bgt1, bgt1], [1, 1], 'linewidth', 1.5);
  bgt2 = 100;
  l2 = plot3([500, 2500], [bgt2, bgt2], [1, 1], 'linewidth', 1.5);
  bgt3 = 160;
  l3 = plot3([500, 2500], [bgt3, bgt3], [1, 1], 'linewidth', 1.5);
  %
  legend([s1, s2, s3, s4, s0, l1, l2, l3], ...
    {'Greedy'; ...
    ['Lazier Greedy: \epsilon = ' num2str(errBound(3))]; ...
    ['Lazier Greedy: \epsilon = ' num2str(errBound(4))]; ...
    ['Lazier Greedy: \epsilon = ' num2str(errBound(5))]; ...
    ['Time Cost = 30ms' ]; ...
    ['Line of 60-subset']; ...
    ['Line of 100-subset']; ...
    ['Line of 160-subset'] }, ...
    'Location', 'best');
  view(-25, 28);
  % view(52.4000, 37.2000);
  % export_fig(h, ['~/Codes/VSLAM/SLAM_Evaluation/output/TRO18/Simulation/TimeCost.fig']);
  % export_fig(h, ['~/Codes/VSLAM/SLAM_Evaluation/output/TRO18/Simulation/TimeCost.png']);
  
  % %%
  % h = figure(2);
  % clf
  % hold on
  % % surf(X, Y, 10 * ones(8, 5), 'FaceAlpha', 0.5, 'EdgeColor', 'none')
  % surf(X, Y, std_logDet, 'FaceColor', 'r', 'FaceAlpha', 0.5);
  % % set(gca, 'ZScale', 'log')
  % xlabel('Feature Number')
  % ylabel('Subset Percentage (%)')
  % zlabel('rms of logDet from lazier greedy')
  % grid on
  % % view(-38.8000, 14.8000);
  % view(49.2000, 20.4000);
  
  %%
  h = figure(2);
  clf
  hold on
  set(gca,'FontSize',12)
  s0 = surf(X, Y, 0.01 * ones(8, 9), 'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
  s1 = surf(X, Y, std_diffFeat{3}, 'FaceColor', [0 0.75 0.8], 'FaceAlpha', 0.5);
  s2 = surf(X, Y, std_diffFeat{4}, 'FaceColor', [0 1 0], 'FaceAlpha', 0.5);
  s3 = surf(X, Y, std_diffFeat{5}, 'FaceColor', [0.6 0.1 0.6], 'FaceAlpha', 0.5);
  % surf(X, Y, std_diffFeat, 'FaceAlpha', 0.8);
  % set(gca, 'ZScale', 'log')
  xlabel('Full Set Size')
  ylabel('Subset Size')
  % zlabel('C.V. of Diff. Feature Selected')
  zlabel('Error Rate ([0, 1])')
  grid on
  %
  bgt1 = 60;
  l1 = plot3([500, 2500], [bgt1, bgt1], [0, 0], 'linewidth', 1.5);
  bgt2 = 100;
  l2 = plot3([500, 2500], [bgt2, bgt2], [0, 0], 'linewidth', 1.5);
  bgt3 = 160;
  l3 = plot3([500, 2500], [bgt3, bgt3], [0, 0], 'linewidth', 1.5);
  %
  legend([s1 s2 s3 s0, l1, l2, l3], ...
    {['Lazier Greedy: \epsilon = ' num2str(errBound(3))]; ...
    ['Lazier Greedy: \epsilon = ' num2str(errBound(4))]; ...
    ['Lazier Greedy: \epsilon = ' num2str(errBound(5))]; ...
    ['Error Rate = 0.01' ]; ...
    ['Line of 60-subset']; ...
    ['Line of 100-subset']; ...
    ['Line of 160-subset'] }, ...
    'Location', 'best');
  % view(49.2000, 20.4000);
%   view(-38.8000, 14.8000);
  view(-25, 28);
end

if plot_box
  %%
  timeTrend = [];
  for i=1:length(errBound)
    timeTrend = [timeTrend timeVec{i}];
    errGroup{i} = ['$$\epsilon = ' num2str(errBound(i)) '$$'];
  end
  h = figure(3);
  clf
  subplot(2,1,1)
  hold on
  set(gca,'FontSize',12)
  bp = boxplot(timeTrend, 'labels', errGroup);
  plot([0.5 8.5], [30 30], '--b');
  h.CurrentAxes.XAxis.TickLabelInterpreter = 'latex';
  % xlabel('Lazier Greedy with Diff. \epsilon')
  ylabel('Time Cost (ms)')
  grid on
%   title(['Total Number = ' num2str((jj-1)*500 + 500) ...
%     '; Subset Number = '  num2str((ii-1)*20 + 40) ])
  title(['Full Set Size = ' num2str((jj-1)*250 + 500) ...
    '; Subset Size = '  num2str((ii-1)*20 + 40) ])
  
  %%
  diffTrend = [];
  for i=1:length(errBound)
    diffTrend = [diffTrend diffVec{i}];
  end
  subplot(2,1,2)
  hold on
  set(gca,'FontSize',12)
  bp = boxplot(diffTrend, 'labels', errGroup);
  plot([0.5 8.5], [0.01 0.01], '--b');
  h.CurrentAxes.XAxis.TickLabelInterpreter = 'latex';
  % xlabel('Lazier Greedy with Diff. \epsilon')
  % ylabel('C.V. of Diff. Feature Selected')
  ylabel('Error Rate ([0, 1])')
  grid on
    
end
