clear all
close all

%%
addpath('/mnt/DATA/SDK/ColorBrewer')
addpath('/mnt/DATA/SDK/altmany-export_fig');

%% load lmk log
log_path_list = {
  '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_CDC19/landmark_life_histogram/ORB2_Stereo_Baseline/ObsNumber_800_Round1/';
  '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_CDC19/landmark_life_histogram/SVO2_Stereo_Baseline/ObsNumber_400_Round1/';
  '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_CDC19/landmark_life_histogram/msckf_Stereo_Baseline/ObsNumber_80_Round1/';
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
save_path = './output/RAS19/';

legend_arr = {
  'ORB - feature matching';
  'SVO - direct';
  'MSCKF - KLT';
  };

map = brewermap(length(log_path_list), 'Set1');
h = figure(1);
hold on
for ln=1:length(log_path_list)
  histogram(logLmk_summ{ln}.rec(:,2), [0:50:3500], ...
    'Normalization', 'probability', ...
    'facecolor',map(ln,:),'facealpha',1.0,'edgecolor','none')
  %   hist(logLmk_summ{ln}.rec(:,2))
end
legend(legend_arr)
xlabel('Life (frames)')
ylabel('Probability')
%
set(gca, 'YScale', 'log')
fname = 'Landmark_life_joint';
export_fig(h, [save_path '/' fname '.fig']);
export_fig(h, [save_path '/' fname '.png']);

h = figure(2);
for ln=1:length(log_path_list)
  subplot(1,3,ln)
  histogram(logLmk_summ{ln}.rec(:,2), 100, ...
    'Normalization', 'probability', ...
    'facecolor',map(ln,:),'facealpha',.5,'edgecolor','none')
  %   hist(logLmk_summ{ln}.rec(:,2))
  title(legend_arr{ln})
  xlabel('Life (frames)')
  ylabel('Probability')
end
%
fname = 'Landmark_life_indiv';
export_fig(h, [save_path '/' fname '.fig']);
export_fig(h, [save_path '/' fname '.png']);
