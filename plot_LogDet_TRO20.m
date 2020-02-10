close all
clear all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%%
data_path = '/mnt/DATA/DropboxContainer/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/ORBv2_Stereo_LogDet_Demo/'
rn = 1
save_path = './output/TRO19/EuRoC/'
figure_size = [1 1 1000 1000];

%
slam_list = {
  'ObsNumber_80';
  'ObsNumber_100';
  'ObsNumber_130';
  'ObsNumber_160';
  'ObsNumber_200';
  %   'ObsNumber_240';
  %   'ObsNumber_280';
  %   'ObsNumber_320';
  %   'ObsNumber_360';
  'ObsNumber_1200';
  };

legend_arr = {
  'GF_{80}';
  'GF_{100}';
  'GF_{130}';
  'GF_{160}';
  'GF_{200}';
  'ALL';
  };

seq_list = {
  'MH_01_easy';
  'MH_02_easy';
  'MH_03_medium';
  'MH_04_difficult';
  'MH_05_difficult';
  'V1_01_easy';
  'V1_02_medium';
  'V1_03_difficult';
  'V2_01_easy';
  'V2_02_medium';
  %   'V2_03_difficult';
  };

seq_name_plot = {
  'MH\_01\_easy';
  'MH\_02\_easy';
  'MH\_03\_medium';
  'MH\_04\_difficult';
  'MH\_05\_difficult';
  'V1\_01\_easy';
  'V1\_02\_medium';
  'V1\_03\_difficult';
  'V2\_01\_easy';
  'V2\_02\_medium';
  %   'V2\_03\_difficult';
  };

seq_duration = [
  182;
  150;
  132;
  99;
  111;
  143;
  84;
  105;
  112;
  115;
  %   115;
  ];

for j=1:length(slam_list)
  arr_box_summ_1{j} = [];
  arr_box_summ_2{j} = [];
end

for i=1:length(seq_list)
  for j=1:length(slam_list)
    logGF{i,j} = [];
    logGF{i,j} = loadLogGF([data_path slam_list{j}], rn, seq_list{i}, logGF{i,j}, 1);
  end
  
  t_offset = logGF{i,1}.timeStamp{rn}(1);
  
  %%
  h = figure(1);
  clf
  subplot(3,1,1)
  hold on
  for j=1:length(slam_list)
    plot( logGF{i,j}.timeStamp{rn} - t_offset, logGF{i,j}.numLogDet{rn}, '-.' )
    xlim([0 seq_duration(i)])
    ylim([0 140])
    xlabel('Duration (sec)')
    ylabel('logDet')
    title(seq_name_plot{i})
  end
  
  subplot(3,1,2)
  hold on
  for j=1:length(slam_list)
    %   hold on
    %   plot( logGF{i}.timeStamp{rn} - logGF{i}.timeStamp{rn}(1), logGF{i}.lmkInitTrack{rn}, '-.' )
    plot( logGF{i,j}.timeStamp{rn} - t_offset, logGF{i,j}.lmkRefTrack{rn}, '-.' )
    xlim([0 seq_duration(i)])
    ylim([0 500])
    xlabel('Duration (sec)')
    ylabel('Tracked Feature')
    title(seq_name_plot{i})
    %
    legend(legend_arr);
  end
  
  subplot(3,1,3)
  hold on
  for j=1:length(slam_list)
    plot( logGF{i,j}.timeStamp{rn} - t_offset, logGF{i,j}.timeMapMatch{rn}, '-.' )
    xlim([0 seq_duration(i)])
    ylim([0 30])
    xlabel('Duration (sec)')
    ylabel('Frame-to-Map Matching Time (ms)')
    title(seq_name_plot{i})
  end
  
  set(h, 'Position', figure_size)
  export_fig(h, [save_path '/Prof_LogDet_' seq_list{i} '.png']); % , '-r 200');
  
  %%
  h = figure(2);
  clf
  subplot(2,1,1)
  arr_box = [];
  for j=1:length(slam_list)
    arr_box = [arr_box logGF{i,j}.numLogDet{rn}];
    arr_box_summ_1{j} = [arr_box_summ_1{j}; logGF{i,j}.numLogDet{rn}];
  end
  boxplot(arr_box, legend_arr, 'whisker', 4);
  %   xlim([0 seq_duration(i)])
  ylim([60 140])
  %   xlabel('Duration (sec)')
  ylabel('logDet')
  title(seq_name_plot{i})
  
  subplot(2,1,2)
  arr_box = [];
  for j=1:length(slam_list)
    arr_box = [arr_box logGF{i,j}.lmkRefTrack{rn}];
    arr_box_summ_2{j} = [arr_box_summ_2{j}; logGF{i,j}.lmkRefTrack{rn}];
  end
  boxplot(arr_box, legend_arr, 'whisker', 12);
  %   xlim([0 seq_duration(i)])
  ylim([0 500])
  %   xlabel('Duration (sec)')
  ylabel('Tracked Feature')
  title(seq_name_plot{i})
  
  %   set(h, 'Position', figure_size)
  export_fig(h, [save_path '/Box_LogDet_' seq_list{i} '.png']); % , '-r 200');
  
end

%%
h = figure(3);
clf
subplot(2,1,1)
arr_box = [];
for j=1:length(slam_list)
  arr_box = [arr_box arr_box_summ_1{j}];
end
boxplot(arr_box, legend_arr, 'whisker', 3);
%   xlim([0 seq_duration(i)])
ylim([60 140])
%   xlabel('Duration (sec)')
ylabel('logDet')
% title(seq_name_plot{i})

subplot(2,1,2)
arr_box = [];
for j=1:length(slam_list)
  arr_box = [arr_box arr_box_summ_2{j}];
end
boxplot(arr_box, legend_arr, 'whisker', 8);
%   xlim([0 seq_duration(i)])
ylim([0 500])
%   xlabel('Duration (sec)')
ylabel('Tracked Feature')
% title(seq_name_plot{i})

%   set(h, 'Position', figure_size)
export_fig(h, [save_path '/Summ_LogDet.png']); % , '-r 200');