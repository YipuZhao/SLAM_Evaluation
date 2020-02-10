clear all
close all

addpath('~/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark =  'EuRoC_ICRA_18'
setParam
do_viz = 1;
%
ref_reload = 1;

gn = 1;
for sn = 1:length(seq_list) % [1:6, 9:10] % 
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %
  for rn = 1:round_num
    disp(['Round ' num2str(rn)])
    
    %% Load Log Files
    % ref
    disp(['Loading ORB-SLAM log...'])
    [log_orb_slam{sn}] = loadLogTUM(orb_slam_path, rn, seq_idx);
    disp(['Loading Inlier ORB-SLAM log...'])
    [log_orb_inlier{sn}] = loadLogTUM(orb_inlier_path, rn, seq_idx);
    
    %%
    disp(['Loading Quality log...'])
    [log_quality{sn}] = loadLogTUM([quality_path gf_slam_list{gn}], rn, seq_idx);
    disp(['Loading Bucket log...'])
    [log_bucket{sn}] = loadLogTUM([bucket_path gf_slam_list{gn}], rn, seq_idx);
    
    % GF
    disp(['Loading Obs-GF log...'])
    [log_obs_gf{sn}] = loadLogTUM([obs_gf_path gf_slam_list{gn}], rn, seq_idx);
    disp(['Loading Obs-MV log...'])
    [log_obs_mv{sn}] = loadLogTUM([obs_mv_path gf_slam_list{gn}], rn, seq_idx);
    disp(['Loading Cond-MV log...'])
    [log_cond_mv{sn}] = loadLogTUM([cond_mv_path gf_slam_list{gn}], rn, seq_idx);
    
    % Comb
    disp(['Loading Comb Obs-GF log...'])
    [log_comb_obs_gf{sn}] = loadLogTUM([comb_obs_gf_path gf_slam_list{gn}], rn, seq_idx);
    disp(['Loading Comb Obs-MV log...'])
    [log_comb_obs_mv{sn}] = loadLogTUM([comb_obs_mv_path gf_slam_list{gn}], rn, seq_idx);
    disp(['Loading Comb Cond-MV log...'])
    [log_comb_cond_mv{sn}] = loadLogTUM([comb_cond_mv_path gf_slam_list{gn}], rn, seq_idx);
    
  end
  
end


%% print stat
disp 'time used in pose tracking:'
printAverageTimeCost(log_quality, sn, round_num, 'timeTrack')
printAverageTimeCost(log_bucket, sn, round_num, 'timeTrack')
%
printAverageTimeCost(log_obs_gf, sn, round_num, 'timeTrack')
printAverageTimeCost(log_obs_mv, sn, round_num, 'timeTrack')
printAverageTimeCost(log_cond_mv, sn, round_num, 'timeTrack')
%
printAverageTimeCost(log_comb_obs_gf, sn, round_num, 'timeTrack')
printAverageTimeCost(log_comb_obs_mv, sn, round_num, 'timeTrack')
printAverageTimeCost(log_comb_cond_mv, sn, round_num, 'timeTrack')
%
printAverageTimeCost(log_orb_inlier, sn, round_num, 'timeTrack')
printAverageTimeCost(log_orb_slam, sn, round_num, 'timeTrack')
fprintf(' \n')

disp 'time used in outlier rejection:'
printAverageTimeCost(log_quality, sn, round_num, 'timeInl')
printAverageTimeCost(log_bucket, sn, round_num, 'timeInl')
%
printAverageTimeCost(log_obs_gf, sn, round_num, 'timeInl')
printAverageTimeCost(log_obs_mv, sn, round_num, 'timeInl')
printAverageTimeCost(log_cond_mv, sn, round_num, 'timeInl')
%
printAverageTimeCost(log_comb_obs_gf, sn, round_num, 'timeInl')
printAverageTimeCost(log_comb_obs_mv, sn, round_num, 'timeInl')
printAverageTimeCost(log_comb_cond_mv, sn, round_num, 'timeInl')
%
printAverageTimeCost(log_orb_inlier, sn, round_num, 'timeInl')
printAverageTimeCost(log_orb_slam, sn, round_num, 'timeInl')
fprintf(' \n')

disp 'time used in inlier selection:'
printAverageTimeCost(log_quality, sn, round_num, 'timeObs')
printAverageTimeCost(log_bucket, sn, round_num, 'timeObs')
%
printAverageTimeCost(log_obs_gf, sn, round_num, 'timeObs')
printAverageTimeCost(log_obs_mv, sn, round_num, 'timeObs')
printAverageTimeCost(log_cond_mv, sn, round_num, 'timeObs')
%
printAverageTimeCost(log_comb_obs_gf, sn, round_num, 'timeObs')
printAverageTimeCost(log_comb_obs_mv, sn, round_num, 'timeObs')
printAverageTimeCost(log_comb_cond_mv, sn, round_num, 'timeObs')
%
printAverageTimeCost(log_orb_inlier, sn, round_num, 'timeObs')
printAverageTimeCost(log_orb_slam, sn, round_num, 'timeObs')
fprintf(' \n')

disp 'time used in pose optimization:'
printAverageTimeCost(log_quality, sn, round_num, 'timeOpt')
printAverageTimeCost(log_bucket, sn, round_num, 'timeOpt')
%
printAverageTimeCost(log_obs_gf, sn, round_num, 'timeOpt')
printAverageTimeCost(log_obs_mv, sn, round_num, 'timeOpt')
printAverageTimeCost(log_cond_mv, sn, round_num, 'timeOpt')
%
printAverageTimeCost(log_comb_obs_gf, sn, round_num, 'timeOpt')
printAverageTimeCost(log_comb_obs_mv, sn, round_num, 'timeOpt')
printAverageTimeCost(log_comb_cond_mv, sn, round_num, 'timeOpt')
%
printAverageTimeCost(log_orb_inlier, sn, round_num, 'timeOpt')
printAverageTimeCost(log_orb_slam, sn, round_num, 'timeOpt')
fprintf(' \n')
