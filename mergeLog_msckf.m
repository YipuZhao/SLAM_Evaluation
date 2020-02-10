close all
clear all

%% msckf EuRoC config
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/msckf_Stereo_Baseline_v2/';
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/msckf_Stereo_Speedx2.0/';
%
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx1.0/';
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx2.0/';
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx3.0/';
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx4.0/';
log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx5.0/';

bag_name = {
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
  'V2_03_difficult';
  };

T_stereo_2_base = SE3([0 0 0], eye(3));

%% msckf TUM VI config
% log_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/msckf_Stereo_Baseline_v2/';
%
% bag_name = {
%   'room1_512_16';
%   'room2_512_16';
%   'room3_512_16';
%   'room4_512_16';
%   'room5_512_16';
%   'room6_512_16';
%   };
%
% T_stereo_2_base = SE3([0 0 0], eye(3));

%%
bugdet_num = [200] % [70, 150, 200, 400]; % [400, 600, 800, 1000, 1500, 2000];

round_num = 10;

for fn = 1:length(bugdet_num)
  for bn = 1:length(bag_name)
    for rn = 1 : round_num
      
      log_path = [log_dir 'ObsNumber_' num2str(bugdet_num(fn)) '_Round' num2str(rn) ...
        '/' bag_name{bn} '_Log'];
      
      % front end
      if ~exist([log_path '_front.txt'], 'file')
        continue ;
      end
      
      fid = fopen([log_path '_front.txt'], 'rt');
      if fid ~= -1
        log_front = cell2mat(textscan(fid, '%f %f %f', 'HeaderLines', 1));
        fclose(fid);
      end
      
      % back end
      if ~exist([log_path '_back.txt'], 'file')
        continue ;
      end
      
      fid = fopen([log_path '_back.txt'], 'rt');
      if fid ~= -1
        log_back = cell2mat(textscan(fid, '%f %f %f', 'HeaderLines', 1));
        fclose(fid);
      end
      
      % associate the data to the model quat with timestamp
      asso_fr_2_bk  = associate_track(log_front, log_back, 1, 0.001, 1);
      fprintf('found %d front-back match from %d records! \n', ...
        sum(asso_fr_2_bk>0), max(length(log_front), length(log_back)))
      
      %       % merge both
      %       min_len = min(length(log_front), length(log_back));
      %       %       asso_front_2_back = associate_track(log_front, log_back, 1, 0.005);
      %       fprintf('found %d front-back match from %d records! \n', ...
      %         min_len, max(length(log_front), length(log_back)))
      %
      %       if length(log_front) > length(log_back)
      %         log_full = [log_back(:, 1) log_front(1:min_len, 2) log_front(1:min_len, 2) + log_back(:, 2)];
      %       else
      %         log_full = [log_front log_front(:, 2) + log_back(1:min_len, 2)];
      %       end
      for i=1:length(asso_fr_2_bk)
        if asso_fr_2_bk(i) > 0
          log_full(i, :) = [log_front(i, 1) log_front(i, 2) log_back(asso_fr_2_bk(i), 2) log_front(i, 3) log_back(asso_fr_2_bk(i), 3)];
        else
          log_full(i, :) = [log_front(i, 1) log_front(i, 2) -1 log_front(i, 3) -1];
        end
      end
      
      % save the merged log
      saveLogSVO([log_path '.txt'], log_full);
      
    end
  end
end
