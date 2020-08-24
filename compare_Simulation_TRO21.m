clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%%
% path_data         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/simulation/low_perturb'
% path_data         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/simulation/high_perturb'
% path_data         = '/home/yipuzhao/ros_workspace/package_dir/GF_ORB_SLAM2/Thirdparty/SLAM++/bin'
% path_data       = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/simulation/circular_track/gg_eps'
% path_data       = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/simulation/circular_track/gg_covPool'
path_data       = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/simulation/circular_track/p60_vinf_50kf_max';

% subgraph_scales = [50, 75, 100, 125, 150, 175, 200];
% subgraph_scales = [50, 75, 100, 125];
subgraph_scales = [50] % [100]; %
subgraph_ratios = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
% subgraph_ratios = [0.1, 0.2, 0.3, 0.4, 0.5];
round_num       = 100 % 10; %
save_path       = './output/TRO21/'

plot_surf       = false; % true; %
plot_box        = false; % true; %
plot_trend      = false; % true; %
print_table     = false; % true;  %

method_num = 9; % 5; % 4; %
% method_name = {
%   'Full BA';
%   'Good Graph $\eps=1e-3$';
%   'Good Graph $\eps=5e-3$';
%   'Good Graph $\eps=1e-2$';
%   'Good Graph $\eps=5e-2$';
%   'Good Graph $\eps=1e-1$';
%   'Good Graph $\eps=5e-1$';
%   'Covis';
%   'Rand';}
method_name = {
  'Full BA';
  'Good Graph full';
  'Good Graph 3.0x';
  'Good Graph 2.5x';
  'Good Graph 2.0x';
  'Good Graph 1.5x';
  %   'Good Graph 1.2x';
  'Good Graph auto';
  'Covis';
  'Rand';}

max_view_per_lmk = 15 % 10 % 5 % 150 % 40 % 30 % 20 %
path_data = [path_data num2str(max_view_per_lmk)];

log_scale       = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);
log_rmse        = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);
log_sub         = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);
log_opt         = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);
log_logDet_raw  = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);
log_logDet_ref  = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), method_num);


%% merge results from each round
for sn=1:length(subgraph_scales)
  for rn=1:round_num
    %% load subgraph scale
    path_scale = [path_data '/simu_r' num2str(rn-1) '/logGraphScale_' num2str(subgraph_scales(sn)) '.txt'];
    log_scale(sn, rn, :, :) = loadBASimuLog(path_scale, length(subgraph_ratios), 1, method_num);
    %% load rmse
    path_rmse = [path_data '/simu_r' num2str(rn-1) '/logRMSE_' num2str(subgraph_scales(sn)) '.txt'];
    log_rmse(sn, rn, :, :) = loadBASimuLog(path_rmse, length(subgraph_ratios), 1, method_num);
    %% load subgraph time
    path_sub = [path_data '/simu_r' num2str(rn-1) '/logSubTime_' num2str(subgraph_scales(sn)) '.txt'];
    log_sub(sn, rn, :, :) = loadBASimuLog(path_sub, length(subgraph_ratios), 1, method_num);
    %% load optim time
    path_opt = [path_data '/simu_r' num2str(rn-1) '/logOptTime_' num2str(subgraph_scales(sn)) '.txt'];
    log_opt(sn, rn, :, :) = loadBASimuLog(path_opt, length(subgraph_ratios), 1, method_num);
    %% load raw logDet
    path_logDet_raw = [path_data '/simu_r' num2str(rn-1) '/logLogDetRaw_' num2str(subgraph_scales(sn)) '.txt'];
    log_logDet_raw(sn, rn, :, :) = loadBASimuLog(path_logDet_raw, length(subgraph_ratios), 1, method_num);
    %% load ref logDet
    path_logDet_ref = [path_data '/simu_r' num2str(rn-1) '/logLogDetRef_' num2str(subgraph_scales(sn)) '.txt'];
    log_logDet_ref(sn, rn, :, :) = loadBASimuLog(path_logDet_ref, length(subgraph_ratios), 1, method_num);
  end
end

%% OR directly loading from batch result
% for sn=1:length(subgraph_scales)
%   %% load subgraph scale
%   path_scale    = [path_data '/logGraphScale_' num2str(subgraph_scales(sn)) '.txt'];
%   log_scale(sn, :, :, :) = loadBASimuLog(path_scale, length(subgraph_ratios), round_num);
%   %% load rmse
%   path_rmse     = [path_data '/logRMSE_' num2str(subgraph_scales(sn)) '.txt'];
%   log_rmse(sn, :, :, :) = loadBASimuLog(path_rmse, length(subgraph_ratios), round_num);
%   %% load subgraph time
%   path_sub      = [path_data '/logSubTime_' num2str(subgraph_scales(sn)) '.txt'];
%   log_sub(sn, :, :, :) = loadBASimuLog(path_sub, length(subgraph_ratios), round_num);
%   %% load optim time
%   path_opt      = [path_data '/logOptTime_' num2str(subgraph_scales(sn)) '.txt'];
%   log_opt(sn, :, :, :) = loadBASimuLog(path_opt, length(subgraph_ratios), round_num);
% end

%%
if plot_surf
  
  [X, Y] = meshgrid(subgraph_scales, subgraph_ratios);
  
  % surface plot of mean time cost
  h = figure(1);
  clf
  hold on
  set(gca,'FontSize',12);
  s1 = surf(X, Y, ...
    reshape(mean(log_opt(:, :, :, 1), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', 'r', 'FaceAlpha', 0.5);
  s2 = surf(X, Y, ...
    reshape(mean(log_opt(:, :, :, 2), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0 0.75 0.8], 'FaceAlpha', 0.5);
  s3 = surf(X, Y, ...
    reshape(mean(log_opt(:, :, :, 3), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0 1 0], 'FaceAlpha', 0.5);
  s4 = surf(X, Y, ...
    reshape(mean(log_opt(:, :, :, 4), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0.6 0.1 0.6], 'FaceAlpha', 0.5);
  %   set(gca, 'ZScale', 'log')
  ylabel('Subgraph Ratio')
  xlabel('BA Scale')
  zlabel('Time Cost (s)')
  grid on
  %
  legend([s1, s2, s3, s4], ...
    {'Full BA'; 'Good Graph'; 'Covis'; 'Rand';}, ...
    'Location', 'best');
  view(-25, 28);
  
  % surface plot of mean rmse
  h = figure(2);
  clf
  hold on
  set(gca,'FontSize',12);
  %   s1 = surf(X, Y, ...
  %     reshape(mean(log_rmse(:, :, :, 1), 2), length(subgraph_scales), length(subgraph_ratios))', ...
  %     'FaceColor', 'r', 'FaceAlpha', 0.5);
  s2 = surf(X, Y, ...
    reshape(mean(log_rmse(:, :, :, 2), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0 0.75 0.8], 'FaceAlpha', 0.5);
  s3 = surf(X, Y, ...
    reshape(mean(log_rmse(:, :, :, 3), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0 1 0], 'FaceAlpha', 0.5);
  s4 = surf(X, Y, ...
    reshape(mean(log_rmse(:, :, :, 4), 2), length(subgraph_scales), length(subgraph_ratios))', ...
    'FaceColor', [0.6 0.1 0.6], 'FaceAlpha', 0.5);
  %   set(gca, 'ZScale', 'log')
  ylabel('Subgraph Ratio')
  xlabel('BA Scale')
  zlabel('RMSE (m)')
  grid on
  %
  %   legend([s1, s2, s3, s4], ...
  %     {'Full BA'; 'Good Graph'; 'Covis'; 'Rand';}, ...
  %     'Location', 'best');
  legend([s2, s3, s4], ...
    method_name, ...
    'Location', 'best');
  view(-25, 28);
  
end

%%
if plot_box
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(3);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_summ = [];
    for mn=2:method_num
      box_tmp = reshape(log_sub(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
      box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
    end
    
    aboxplot(box_summ, 'labels', subgraph_ratios, 'outliermarker', '.');
    %     aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_sub(sn, :, 1, 1), 2);
    upper_full = prctile(log_sub(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_sub(sn, :, 1, 1), 25, 2);
    line([0.5, 0.5+length(subgraph_ratios)], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend(method_name(2:end));
    xlabel('Subgraph Percentage (% in KFs)')
    ylabel('Time Cost (s)')
    
    export_fig(h, [save_path '/boxTimeSel_graphscale_' num2str(subgraph_scales(sn)) '.png']);
    export_fig(h, [save_path '/boxTimeSel_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(4);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_summ = [];
    for mn=2:method_num
      box_tmp = reshape(log_sub(sn, :, 1:ratio_plotted, mn)+log_opt(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
      box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
    end
    
    aboxplot(box_summ, 'labels', subgraph_ratios, 'outliermarker', '.');
    %     aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1), 2);
    upper_full = prctile(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1), 25, 2);
    line([0.5, 0.5+length(subgraph_ratios)], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend(method_name(2:end));
    xlabel('Subgraph Percentage (% in KFs)')
    ylabel('Time Cost (s)')
    
    export_fig(h, [save_path '/boxTime_graphscale_' num2str(subgraph_scales(sn)) '.png']);
    export_fig(h, [save_path '/boxTime_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(5);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_summ = [];
    for mn=2:method_num
      box_tmp = reshape(log_rmse(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
      box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
    end
    
    aboxplot(box_summ, 'labels', subgraph_ratios, 'outliermarker', '.');
    %     aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_rmse(sn, :, 1, 1), 2);
    upper_full = prctile(log_rmse(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_rmse(sn, :, 1, 1), 25, 2);
    line([0.5, 0.5+length(subgraph_ratios)], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend(method_name(2:end));
    xlabel('Subgraph Percentage (% in KFs)')
    ylabel('RMSE (m)')
    
    export_fig(h, [save_path '/boxRMSE_graphscale_' num2str(subgraph_scales(sn)) '.png']);
    export_fig(h, [save_path '/boxRMSE_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(6);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_summ = [];
    for mn=2:method_num
      box_tmp = reshape(log_scale(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
      box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
    end
    
    aboxplot(box_summ, 'labels', subgraph_ratios, 'outliermarker', '.');
    %     aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_scale(sn, :, 1, 1), 2);
    upper_full = prctile(log_scale(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_scale(sn, :, 1, 1), 25, 2);
    line([0.5, 0.5+length(subgraph_ratios)], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 0.5+length(subgraph_ratios)], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend(method_name(2:end));
    xlabel('Subgraph Percentage (% in KFs)')
    ylabel('Points Num.')
    
    export_fig(h, [save_path '/boxScale_graphscale_' num2str(subgraph_scales(sn)) '.png']);
    export_fig(h, [save_path '/boxScale_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  end
end

%%
if plot_trend
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(7);
    clf
    hold on
    
    for mn=1:method_num
      trend_tmp = reshape(mean(log_opt(sn, :, :, mn), 2), 1, length(subgraph_ratios));
      plot(trend_tmp);
    end
    
    legend(method_name);
    xlabel('Subgraph Ratio')
    ylabel('Time Cost (s)')
    
    export_fig(h, [save_path '/trendTimeOpt_graphscale_' num2str(subgraph_scales(sn)) '.png']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(8);
    clf
    hold on
    
    for mn=1:method_num
      trend_tmp = reshape(mean(log_rmse(sn, :, :, mn), 2), 1, length(subgraph_ratios));
      plot(trend_tmp);
    end
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend(method_name);
    xlabel('Subgraph Ratio')
    ylabel('RMSE (m)')
    
    export_fig(h, [save_path '/trendRMSE_graphscale_' num2str(subgraph_scales(sn)) '.png']);
  end
end

%% plot time cost vs rmse
ratio_plotted = length(subgraph_ratios);
marker_styl = {
  'x';
  '--s';
  '--s';
  '--s';
  };
line_color = hsv(4);
marker_color = {
  line_color(1, :);
  line_color(2, :);
  line_color(3, :);
  line_color(4, :);
  };

h = figure;
i = 1;
clf
hold on;
timeCost_full = mean(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1));
rmse_full = mean(log_rmse(sn, :, 1, 1));
% scatter(timeCost_full, rmse_full, 'x', 'LineWidth', 1.5, 'MarkerEdgeColor', 'r');
scatter(timeCost_full, rmse_full, marker_styl{i}, 'LineWidth', 1.5, 'MarkerEdgeColor', marker_color{i});
i = i + 1;
%
for mn=[method_num-1, method_num, 3] % 1:method_num
  for sn=1:length(subgraph_scales)
    timeCost_arr = [];
    mean_arr = [];
    p25_arr = [];
    p75_arr = [];
    for rn=1:ratio_plotted
      if sum(abs(log_opt(sn, :, rn, mn)) < 1e-7) > 0
        % at least 1 opt failed, drop the test
      else
        timeCost_tmp = log_sub(sn, :, rn, mn)+log_opt(sn, :, rn, mn);
        rmse_tmp = log_rmse(sn, :, rn, mn);
        timeCost_arr = [timeCost_arr mean(timeCost_tmp)];
        %         mean_arr = [mean_arr median(rmse_tmp)];
        mean_arr = [mean_arr mean(rmse_tmp)];
        p25_arr = [p25_arr prctile(rmse_tmp, 25)];
        p75_arr = [p75_arr prctile(rmse_tmp, 75)];
      end
    end
    %
    plot(timeCost_arr, mean_arr, marker_styl{i}, 'LineWidth', 1.5, 'Color', marker_color{i});
    plot(timeCost_arr, p25_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    plot(timeCost_arr, p75_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    %     errorbar(timeCost_arr, mean_arr, mean_arr-p25_arr, p75_arr-mean_arr,':s', 'LineWidth', 1.5);
  end
  i = i + 1;
end
line([0, timeCost_full], [rmse_full, rmse_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
line([timeCost_full, timeCost_full], [0, rmse_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
% legend(method_name([1, method_num-1, method_num, 3]));
% add legend and other stuff
%
legend_style = gobjects(length(marker_color),1);
for i=1:length(marker_color)
  legend_style(i) = plot(nan, nan, marker_styl{i}, ...
    'color', marker_color{i});
end
%
legend(legend_style, method_name([1, method_num-1, method_num, 3]), 'Location', 'best')

xlabel('Time Cost (sec)')
ylabel('RMSE (m)')
% ylim([0.15 0.35])
export_fig(h, [save_path '/time_rmse_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.fig']);
export_fig(h, [save_path '/time_rmse_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.png']);



h = figure;
i = 1;
clf
hold on;
timeCost_full = mean(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1));
ptNum_full = mean(log_scale(sn, :, 1, 1));
% scatter(timeCost_full, ptNum_full, 'x', 'LineWidth', 1.5);
scatter(timeCost_full, ptNum_full, marker_styl{i}, 'LineWidth', 1.5, 'MarkerEdgeColor', marker_color{i});
i = i + 1;
%
for mn=[method_num-1, method_num, 3] % 1:method_num
  for sn=1:length(subgraph_scales)
    timeCost_arr = [];
    mean_arr = [];
    p25_arr = [];
    p75_arr = [];
    for rn=1:ratio_plotted
      if sum(abs(log_opt(sn, :, rn, mn)) < 1e-7) > 0
        % at least 1 opt failed, drop the test
      else
        timeCost_tmp = log_sub(sn, :, rn, mn)+log_opt(sn, :, rn, mn);
        ptNum_tmp = log_scale(sn, :, rn, mn);
        timeCost_arr = [timeCost_arr mean(timeCost_tmp)];
        mean_arr = [mean_arr mean(ptNum_tmp)];
        p25_arr = [p25_arr prctile(ptNum_tmp, 25)];
        p75_arr = [p75_arr prctile(ptNum_tmp, 75)];
      end
    end
    %
    plot(timeCost_arr, mean_arr, marker_styl{i}, 'LineWidth', 1.5, 'Color', marker_color{i});
    plot(timeCost_arr, p25_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    plot(timeCost_arr, p75_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
  end
  i = i + 1;
end
line([0, timeCost_full], [ptNum_full, ptNum_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
line([timeCost_full, timeCost_full], [0, ptNum_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
%legend(method_name([1,method_num-1, method_num, 3]));
% add legend and other stuff
%
legend_style = gobjects(length(marker_color),1);
for i=1:length(marker_color)
  legend_style(i) = plot(nan, nan, marker_styl{i}, ...
    'color', marker_color{i});
end
%
legend(legend_style, method_name([1, method_num-1, method_num, 3]), 'Location', 'best')

xlabel('Time Cost (sec)')
ylabel('Point Number')
% ylim([1000 3500])
export_fig(h, [save_path '/time_ptNum_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.fig']);
export_fig(h, [save_path '/time_ptNum_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.png']);






h = figure;
i = 1;
clf
hold on;
scatter(ptNum_full, rmse_full, marker_styl{i}, 'LineWidth', 1.5, 'MarkerEdgeColor', marker_color{i});
i = i + 1;
%
for mn=[method_num-1, method_num, 3] % 1:method_num
  for sn=1:length(subgraph_scales)
    ptNum_arr = [];
    mean_arr = [];
    p25_arr = [];
    p75_arr = [];
    for rn=1:ratio_plotted
      if sum(abs(log_opt(sn, :, rn, mn)) < 1e-7) > 0
        % at least 1 opt failed, drop the test
      else
        ptNum_tmp = log_scale(sn, :, rn, mn);
        rmse_tmp = log_rmse(sn, :, rn, mn);
        ptNum_arr = [ptNum_arr mean(ptNum_tmp)];
        %         mean_arr = [mean_arr median(rmse_tmp)];
        mean_arr = [mean_arr mean(rmse_tmp)];
        p25_arr = [p25_arr prctile(rmse_tmp, 25)];
        p75_arr = [p75_arr prctile(rmse_tmp, 75)];
      end
    end
    %
    plot(ptNum_arr, mean_arr, marker_styl{i}, 'LineWidth', 1.5, 'Color', marker_color{i});
    plot(ptNum_arr, p25_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    plot(ptNum_arr, p75_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    %     errorbar(timeCost_arr, mean_arr, mean_arr-p25_arr, p75_arr-mean_arr,':s', 'LineWidth', 1.5);
  end
  i = i + 1;
end
line([0, ptNum_full], [rmse_full, rmse_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
line([ptNum_full, ptNum_full], [0, rmse_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
% legend(method_name([1, method_num-1, method_num, 3]));
% add legend and other stuff
%
legend_style = gobjects(length(marker_color),1);
for i=1:length(marker_color)
  legend_style(i) = plot(nan, nan, marker_styl{i}, ...
    'color', marker_color{i});
end
%
legend(legend_style, method_name([1, method_num-1, method_num, 3]), 'Location', 'best')

xlabel('Point Number')
ylabel('RMSE (m)')
% ylim([0.15 0.35])
export_fig(h, [save_path '/ptNum_rmse_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.fig']);
export_fig(h, [save_path '/ptNum_rmse_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.png']);





h = figure;
i = 1;
clf
hold on;
timeCost_full = mean(log_sub(sn, :, 1, 1)+log_opt(sn, :, 1, 1));
logDet_full = mean(log_logDet_ref(sn, :, 1, 1));
% scatter(timeCost_full, logDet_full, 'x', 'LineWidth', 1.5);
scatter(timeCost_full, logDet_full, marker_styl{i}, 'LineWidth', 1.5, 'MarkerEdgeColor', marker_color{i});
i = i + 1;
%
for mn=[method_num-1, method_num, 3] % 1:method_num
  for sn=1:length(subgraph_scales)
    timeCost_arr = [];
    mean_arr = [];
    p25_arr = [];
    p75_arr = [];
    for rn=1:ratio_plotted
      if sum(abs(log_opt(sn, :, rn, mn)) < 1e-7) > 0
        % at least 1 opt failed, drop the test
      else
        timeCost_tmp = log_sub(sn, :, rn, mn)+log_opt(sn, :, rn, mn);
        logDet_tmp = log_logDet_ref(sn, :, rn, mn);
        timeCost_arr = [timeCost_arr mean(timeCost_tmp)];
        mean_arr = [mean_arr mean(logDet_tmp)];
        p25_arr = [p25_arr prctile(logDet_tmp, 25)];
        p75_arr = [p75_arr prctile(logDet_tmp, 75)];
      end
    end
    %
    plot(timeCost_arr, mean_arr, marker_styl{i}, 'LineWidth', 1.5, 'Color', marker_color{i});
    plot(timeCost_arr, p25_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
    plot(timeCost_arr, p75_arr, ':', 'LineWidth', 1.0, 'Color', marker_color{i});
  end
  i = i + 1;
end
line([0, timeCost_full], [logDet_full, logDet_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
line([timeCost_full, timeCost_full], [0, logDet_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
%legend(method_name([1,method_num-1, method_num, 3]));
% add legend and other stuff
%
legend_style = gobjects(length(marker_color),1);
for i=1:length(marker_color)
  legend_style(i) = plot(nan, nan, marker_styl{i}, ...
    'color', marker_color{i});
end
%
legend(legend_style, method_name([1, method_num-1, method_num, 3]), 'Location', 'best')

xlabel('Time Cost (sec)')
ylabel('logDet')
% ylim([1000 3500])
export_fig(h, [save_path '/time_logDet_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.fig']);
export_fig(h, [save_path '/time_logDet_scale' num2str(subgraph_scales(sn)) '_view' num2str(max_view_per_lmk) '.png']);


h = figure;
clf
hold on

mean_full = mean(log_logDet_ref(sn, :, 1, 1), 2);
upper_full = prctile(log_logDet_ref(sn, :, 1, 1), 75, 2);
lower_full = prctile(log_logDet_ref(sn, :, 1, 1), 25, 2);
line([0.5, 0.5+length(subgraph_ratios)], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
% line([0.5, 0.5+length(subgraph_ratios)], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
% line([0.5, 0.5+length(subgraph_ratios)], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');

box_summ = [];
for mn=[method_num-1, method_num] % 2:method_num
  box_tmp = reshape(log_logDet_ref(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
  box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
end
% add original logDet (before dropping priors)
for mn=[3] % 2:method_num
  box_tmp = reshape(log_logDet_raw(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted);
  box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
end
%
for mn=[3] % 2:method_num
  box_tmp = reshape(log_logDet_ref(sn, :, 1:ratio_plotted, mn), round_num, ratio_plotted) + 20;
  box_summ = cat(1, box_summ, reshape(box_tmp, [1 size(box_tmp)]));
end
aboxplot(box_summ, 'labels', subgraph_ratios * 100, 'outliermarker', '.');

% legend({'Full BA'; 'Covis'; 'Rand'; 'Unbounded GG'; 'Covis-bounded GG'; });
legend({'Full BA'; 'Covis'; 'Rand'; 'GG w\ prior'; 'GG w\o prior'});
% legend(method_name([1,method_num-1, method_num, 2, 3]));
% set(gca,'TickLabelInterpreter','latex')
% set(gca,'Interpreter','Latex')
xlabel('Subgraph Scale (% in KFs)')
ylabel('logDet')
% ylabel('$\log \det(\mathbf{\Lambda}(\mathbf{S}))$')
export_fig(h, [save_path '/boxLogDet_graphscale_50.png']);
export_fig(h, [save_path '/boxLogDet_graphscale_50.fig']);


%%
% if print_table
%
%   for sn=1:length(subgraph_scales)
%     % length(subgraph_scales), round_num, length(subgraph_ratios), 4
%     ratio_plotted = length(subgraph_ratios);
%     mean_full = reshape(mean(log_opt(sn, :, :, 1), 2), 1, length(subgraph_ratios));
%     mean_good = reshape(mean(log_opt(sn, :, :, 2), 2), 1, length(subgraph_ratios));
%     mean_good_v2 = reshape(mean(log_opt(sn, :, :, 3), 2), 1, length(subgraph_ratios));
%     mean_covi = reshape(mean(log_opt(sn, :, :, 4), 2), 1, length(subgraph_ratios));
%     mean_rand = reshape(mean(log_opt(sn, :, :, 5), 2), 1, length(subgraph_ratios));
%     %
%     upper_full = reshape(prctile(log_opt(sn, :, :, 1), 75, 2), 1, length(subgraph_ratios));
%     upper_good = reshape(prctile(log_opt(sn, :, :, 2), 75, 2), 1, length(subgraph_ratios));
%     upper_good_v2 = reshape(prctile(log_opt(sn, :, :, 3), 75, 2), 1, length(subgraph_ratios));
%     upper_covi = reshape(prctile(log_opt(sn, :, :, 4), 75, 2), 1, length(subgraph_ratios));
%     upper_rand = reshape(prctile(log_opt(sn, :, :, 5), 75, 2), 1, length(subgraph_ratios));
%     %
%     lower_full = reshape(prctile(log_opt(sn, :, :, 1), 25, 2), 1, length(subgraph_ratios));
%     lower_good = reshape(prctile(log_opt(sn, :, :, 2), 25, 2), 1, length(subgraph_ratios));
%     lower_good_v2 = reshape(prctile(log_opt(sn, :, :, 3), 25, 2), 1, length(subgraph_ratios));
%     lower_covi = reshape(prctile(log_opt(sn, :, :, 4), 25, 2), 1, length(subgraph_ratios));
%     lower_rand = reshape(prctile(log_opt(sn, :, :, 5), 25, 2), 1, length(subgraph_ratios));
%
%   end
%
% end
