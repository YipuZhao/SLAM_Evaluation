clear all
close all

%% the evaluation method used here is equivalent to the following TUM-eval command
% python evaluate_rpe.py GT.txt EST.txt --verbose --plot tmp.png --fixed_delta --delta 0.1

%%
addpath('~/SDK/altmany-export_fig');

%% KITTI
% seq_list = {'00_tum'; '02_tum'; '06_tum'; '07_tum'; '08_tum'; '09_tum';};
%% TUM
% seq_list = {
%   'freiburg1_desk';
% %   'freiburg1_desk2';
% %   'freiburg1_floor';
% %   'freiburg2_desk';
% %   'freiburg2_desk_with_person';
% %   'freiburg2_pioneer_slam';
% %   'freiburg2_pioneer_slam3';
%   'freiburg2_xyz';
%   'freiburg3_long_office_household';
%   'freiburg3_walking_halfsphere';};
%%
seq_list = {
  'MH_01_easy_tum';
  'MH_02_easy_tum';
  'MH_03_medium_tum';
  'MH_04_difficult_tum';
  'MH_05_difficult_tum';
  'V1_01_easy_tum';
  'V1_02_medium_tum';
  'V1_03_difficult_tum';
  'V2_01_easy_tum';
  'V2_02_medium_tum';
  'V2_03_difficult_tum';
  };

ref_path = ['~/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT']

%%
for sn = 1:length(seq_list)
  seq_idx = seq_list{sn}
  
  %% load the ground truth track
  fid = fopen([ref_path '/' seq_idx '.txt'], 'rt');
  track_ref = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
  fclose(fid);
  
% figure;plot(track_ref(2:end,1)-track_ref(1:end-1,1))

  [motion_t, motion_r] = quantizeMotion(track_ref);
  
  figure;
  hold on
  plot(motion_t);
  plot(motion_r);
  legend({'transition';'rotation'});
  xlabel('sec')
  ylabel('m/sec(deg/sec)')
  
  saveas(gcf, [ref_path '/' seq_idx '_motion.png']);
  
end
