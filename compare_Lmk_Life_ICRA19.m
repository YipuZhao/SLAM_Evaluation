clear all
close all

%%
addpath('/mnt/DATA/SDK/ColorBrewer')
addpath('/mnt/DATA/SDK/altmany-export_fig');

%% load lmk log
log_path_list = {
  '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/Demo/Demo_Baseline/ObsNumber_800_Round1/';
%   '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/Demo/Demo_Random_2000/ObsNumber_800_Round1/';
%   '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/Demo/Demo_Longlive_2000/ObsNumber_800_Round1/';
%   '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/Demo/Demo_MH_v1/ObsNumber_800_Round1/';
  '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/Demo/Demo_MH_v2/ObsNumber_800_Round1/';
  };

for ln=1:length(log_path_list)
  
  logLmk_summ{ln}.rec = [];
  
  listing = dir([log_path_list{ln} '*_Log_lmk.txt']);
  for sn=1:length(listing)
    logLmk_tmp = [];
    logLmk_tmp = loadLogLmk([log_path_list{ln} listing(sn).name], logLmk_tmp, 1);
    logLmk_summ{ln}.rec = [logLmk_summ{ln}.rec; logLmk_tmp.rec];
  end
  
  % remove negative life records
  logLmk_summ{ln}.rec = logLmk_summ{ln}.rec(logLmk_summ{ln}.rec(:, 2) >= 0, :);
  
end

%% plot hist
save_path = './output/ICRA19/';

legend_arr = {
  'ORB';
%   'Random';
%   'Long-life';
  'Maphash - x/32';
%   'Maphash - x/32 - v2';
  };

map = brewermap(length(log_path_list), 'Set1');

% h = figure(1);
% hold on
% for ln=1:length(log_path_list)
%   histogram(logLmk_summ{ln}.rec(:,2), [0:30:2600], ...
%     'Normalization', 'probability', ...
%     'facecolor',map(ln,:),'facealpha',.5,'edgecolor','none')
%   %   hist(logLmk_summ{ln}.rec(:,2))
% end
% set(gca, 'YScale', 'log')
% legend(legend_arr)
% xlabel('Baseline of Feature Matchings (frames)')
% ylabel('Probability')
% xlim([0, 2600])
% ylim([10e-7, 1])
% %
% fname = 'Landmark_life_prob';
% export_fig(h, [save_path '/' fname '.fig']);
% export_fig(h, [save_path '/' fname '.png']);


h = figure(2);
hold on
for ln=1:length(log_path_list)
  histogram(logLmk_summ{ln}.rec(:,2), [0:30:2600], ...
    'Normalization', 'count', ...
    'facecolor',map(ln,:),'facealpha',.5,'edgecolor','none')
  %   hist(logLmk_summ{ln}.rec(:,2))
end
set(gca, 'YScale', 'log')
legend(legend_arr)
xlabel('Baseline of Feature Matchings (frames)')
ylabel('Count')
xlim([0, 2600])
% ylim([10e-7, 1])
%
fname = 'Landmark_life_count';
export_fig(h, [save_path '/' fname '.fig']);
export_fig(h, [save_path '/' fname '.png']);



% h = figure(2);
% for ln=1:length(log_path_list)
%   subplot(1,length(log_path_list),ln)
%   histogram(logLmk_summ{ln}.rec(:,2), [0:20:2500], ...
%     'Normalization', 'probability', ...
%     'facecolor',map(ln,:),'facealpha',.5,'edgecolor','none')
%   %   hist(logLmk_summ{ln}.rec(:,2))
%   title(legend_arr{ln})
%   xlabel('Life (frames)')
%   ylabel('Probability')
%   set(gca, 'YScale', 'log')
%   ylim([10e-7, 1])
% end
% %
% fname = 'Landmark_life_indiv';
% export_fig(h, [save_path '/' fname '.fig']);
% export_fig(h, [save_path '/' fname '.png']);
