clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%%
path_data         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/simulation/low_perturb'
% path_data         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/simulation/high_perturb'
% path_data         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/simulation/tmp'
% path_data       = '/home/yipuzhao/ros_workspace/package_dir/GF_ORB_SLAM2/Thirdparty/SLAM++/bin/batch'

% subgraph_scales = [50, 75, 100, 125, 150, 175, 200];
% subgraph_scales = [50, 75, 100, 125];
subgraph_scales = [50, 100, 150, 200];
% subgraph_ratios = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
subgraph_ratios = [0.1, 0.2, 0.3, 0.4, 0.5];
round_num       = 10; % 30; %
save_path       = './output/RAL19/'

plot_surf       = false; % true; %
plot_box        = true; % false; %
plot_trend      = false; % true; %
print_table     = false; % true;  %

log_scale       = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), 4);
log_rmse        = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), 4);
log_sub         = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), 4);
log_opt         = zeros(length(subgraph_scales), round_num, length(subgraph_ratios), 4);

for sn=1:length(subgraph_scales)
  %% load subgraph scale
  path_scale    = [path_data '/logGraphScale_' num2str(subgraph_scales(sn)) '.txt'];
  log_scale(sn, :, :, :) = loadBASimuLog(path_scale, length(subgraph_ratios), round_num);
  %% load rmse
  path_rmse     = [path_data '/logRMSE_' num2str(subgraph_scales(sn)) '.txt'];
  log_rmse(sn, :, :, :) = loadBASimuLog(path_rmse, length(subgraph_ratios), round_num);
  %% load subgraph time
  path_sub      = [path_data '/logSubTime_' num2str(subgraph_scales(sn)) '.txt'];
  log_sub(sn, :, :, :) = loadBASimuLog(path_sub, length(subgraph_ratios), round_num);
  %% load optim time
  path_opt      = [path_data '/logOptTime_' num2str(subgraph_scales(sn)) '.txt'];
  log_opt(sn, :, :, :) = loadBASimuLog(path_opt, length(subgraph_ratios), round_num);
end

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
    {'Good Graph'; 'Covis'; 'Rand';}, ...
    'Location', 'best');
  view(-25, 28);
  
end

%%
if plot_box
  
  %   for sn=1:length(subgraph_scales)
  %     % length(subgraph_scales), round_num, length(subgraph_ratios), 4
  %     h = figure(3);
  %     clf
  %     hold on
  %
  %     ratio_plotted = length(subgraph_ratios);
  %     box_full = reshape(log_opt(sn, :, 1:ratio_plotted, 1), round_num, ratio_plotted);
  %     box_good = reshape(log_opt(sn, :, 1:ratio_plotted, 2), round_num, ratio_plotted);
  %     box_covi = reshape(log_opt(sn, :, 1:ratio_plotted, 3), round_num, ratio_plotted);
  %     box_rand = reshape(log_opt(sn, :, 1:ratio_plotted, 4), round_num, ratio_plotted);
  %
  %     box_summ = [];
  % %     box_summ = cat(1, box_summ, reshape(box_full, [1 size(box_full)]));
  %     box_summ = cat(1, box_summ, reshape(box_good, [1 size(box_good)]));
  %     box_summ = cat(1, box_summ, reshape(box_covi, [1 size(box_covi)]));
  %     box_summ = cat(1, box_summ, reshape(box_rand, [1 size(box_rand)]));
  %
  %     aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50]);
  %     %   aboxplot(log_opt(1, :, :, :));
  % %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
  %     legend({'Good Graph'; 'Covis'; 'Rand'});
  %      xlabel('Subgraph Percentage (% in KFs)')
  %     ylabel('Time Cost (s)')
  %
  %     export_fig(h, [save_path '/boxTimeOpt_graphscale_' num2str(subgraph_scales(sn)) '.png']);
  %     export_fig(h, [save_path '/boxTimeOpt_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  %   end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(4);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_full = reshape(log_rmse(sn, :, 1:ratio_plotted, 1), round_num, ratio_plotted);
    box_good = reshape(log_rmse(sn, :, 1:ratio_plotted, 2), round_num, ratio_plotted);
    box_covi = reshape(log_rmse(sn, :, 1:ratio_plotted, 3), round_num, ratio_plotted);
    box_rand = reshape(log_rmse(sn, :, 1:ratio_plotted, 4), round_num, ratio_plotted);
    
    box_summ = [];
    %     box_summ = cat(1, box_summ, reshape(box_full, [1 size(box_full)]));
    box_summ = cat(1, box_summ, reshape(box_good, [1 size(box_good)]));
    box_summ = cat(1, box_summ, reshape(box_covi, [1 size(box_covi)]));
    box_summ = cat(1, box_summ, reshape(box_rand, [1 size(box_rand)]));
    
    aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_rmse(sn, :, 1, 1), 2);
    upper_full = prctile(log_rmse(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_rmse(sn, :, 1, 1), 25, 2);
    line([0.5, 5.5], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 5.5], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 5.5], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend({'Good Graph'; 'Covis'; 'Rand'});
    xlabel('Subgraph Percentage (% in KFs)')
    ylabel('RMSE (m)')
    
    export_fig(h, [save_path '/boxRMSE_graphscale_' num2str(subgraph_scales(sn)) '.png']);
    export_fig(h, [save_path '/boxRMSE_graphscale_' num2str(subgraph_scales(sn)) '.fig']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(5);
    clf
    hold on
    
    ratio_plotted = length(subgraph_ratios);
    box_full = reshape(log_scale(sn, :, 1:ratio_plotted, 1), round_num, ratio_plotted);
    box_good = reshape(log_scale(sn, :, 1:ratio_plotted, 2), round_num, ratio_plotted);
    box_covi = reshape(log_scale(sn, :, 1:ratio_plotted, 3), round_num, ratio_plotted);
    box_rand = reshape(log_scale(sn, :, 1:ratio_plotted, 4), round_num, ratio_plotted);
    
    box_summ = [];
    %     box_summ = cat(1, box_summ, reshape(box_full, [1 size(box_full)]));
    box_summ = cat(1, box_summ, reshape(box_good, [1 size(box_good)]));
    box_summ = cat(1, box_summ, reshape(box_covi, [1 size(box_covi)]));
    box_summ = cat(1, box_summ, reshape(box_rand, [1 size(box_rand)]));
    
    aboxplot(box_summ, 'labels', [10, 20, 30, 40, 50], 'outliermarker', '*', 'outliermarkersize', 6);
    %   aboxplot(log_opt(1, :, :, :));
    
    mean_full = mean(log_scale(sn, :, 1, 1), 2);
    upper_full = prctile(log_scale(sn, :, 1, 1), 75, 2);
    lower_full = prctile(log_scale(sn, :, 1, 1), 25, 2);
    line([0.5, 5.5], [mean_full, mean_full], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 5.5], [upper_full, upper_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    line([0.5, 5.5], [lower_full, lower_full], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
    
    %     legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    legend({'Good Graph'; 'Covis'; 'Rand'});
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
    h = figure(6);
    clf
    hold on
    
    trend_full = reshape(mean(log_opt(sn, :, :, 1), 2), 1, length(subgraph_ratios));
    trend_good = reshape(mean(log_opt(sn, :, :, 2), 2), 1, length(subgraph_ratios));
    trend_covi = reshape(mean(log_opt(sn, :, :, 3), 2), 1, length(subgraph_ratios));
    trend_rand = reshape(mean(log_opt(sn, :, :, 4), 2), 1, length(subgraph_ratios));
    
    plot(trend_full)
    plot(trend_good)
    plot(trend_covi)
    plot(trend_rand)
    
    legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    xlabel('Subgraph Ratio')
    ylabel('Time Cost (s)')
    
    export_fig(h, [save_path '/trendTimeOpt_graphscale_' num2str(subgraph_scales(sn)) '.png']);
  end
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    h = figure(7);
    clf
    hold on
    
    trend_full = reshape(mean(log_rmse(sn, :, :, 1), 2), 1, length(subgraph_ratios));
    trend_good = reshape(mean(log_rmse(sn, :, :, 2), 2), 1, length(subgraph_ratios));
    trend_covi = reshape(mean(log_rmse(sn, :, :, 3), 2), 1, length(subgraph_ratios));
    trend_rand = reshape(mean(log_rmse(sn, :, :, 4), 2), 1, length(subgraph_ratios));
    
    plot(trend_full)
    plot(trend_good)
    plot(trend_covi)
    plot(trend_rand)
    
    legend({'Full BA'; 'Good Graph'; 'Covis'; 'Rand'});
    xlabel('Subgraph Ratio')
    ylabel('RMSE (m)')
    
    export_fig(h, [save_path '/trendRMSE_graphscale_' num2str(subgraph_scales(sn)) '.png']);
  end
end

%%
if print_table
  
  for sn=1:length(subgraph_scales)
    % length(subgraph_scales), round_num, length(subgraph_ratios), 4
    ratio_plotted = length(subgraph_ratios);
    mean_full = reshape(mean(log_opt(sn, :, :, 1), 2), 1, length(subgraph_ratios));
    mean_good = reshape(mean(log_opt(sn, :, :, 2), 2), 1, length(subgraph_ratios));
    mean_covi = reshape(mean(log_opt(sn, :, :, 3), 2), 1, length(subgraph_ratios));
    mean_rand = reshape(mean(log_opt(sn, :, :, 4), 2), 1, length(subgraph_ratios));
    %
    upper_full = reshape(prctile(log_opt(sn, :, :, 1), 75, 2), 1, length(subgraph_ratios));
    upper_good = reshape(prctile(log_opt(sn, :, :, 2), 75, 2), 1, length(subgraph_ratios));
    upper_covi = reshape(prctile(log_opt(sn, :, :, 3), 75, 2), 1, length(subgraph_ratios));
    upper_rand = reshape(prctile(log_opt(sn, :, :, 4), 75, 2), 1, length(subgraph_ratios));
    %
    lower_full = reshape(prctile(log_opt(sn, :, :, 1), 25, 2), 1, length(subgraph_ratios));
    lower_good = reshape(prctile(log_opt(sn, :, :, 2), 25, 2), 1, length(subgraph_ratios));
    lower_covi = reshape(prctile(log_opt(sn, :, :, 3), 25, 2), 1, length(subgraph_ratios));
    lower_rand = reshape(prctile(log_opt(sn, :, :, 4), 25, 2), 1, length(subgraph_ratios));
    
  end
  
end