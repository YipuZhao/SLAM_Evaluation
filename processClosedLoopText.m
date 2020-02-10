function [err_nav, err_est, arr_plan] = processClosedLoopText(...
  data_dir, seq_name, imu_type, slam_type, prefix, num_feat, fwd_vel, rn, ...
  err_nav, err_est)

text_act = [data_dir seq_name '/' imu_type '/' slam_type ...
  '/' prefix num2str(num_feat) ...
  '_Vel' num2str(fwd_vel, '%.01f') ...
  '/round' num2str(rn) '_arr_act.txt'];
text_est = [data_dir seq_name '/' imu_type '/' slam_type ...
  '/' prefix num2str(num_feat) ...
  '_Vel' num2str(fwd_vel, '%.01f') ...
  '/round' num2str(rn) '_arr_est.txt'];
text_plan = [data_dir seq_name '/' imu_type '/' slam_type ...
  '/' prefix num2str(num_feat) ...
  '_Vel' num2str(fwd_vel, '%.01f') ...
  '/round' num2str(rn) '_arr_plan.txt'];
%
suspend = false;
if ~exist(text_act, 'file')
  disp(['ERROR! text file ' text_act ' doesnt exist!' ])
  suspend = true;
end
if ~exist(text_est, 'file')
  disp(['ERROR! text file ' text_est ' doesnt exist!' ])
  suspend = true;
end
if ~exist(text_plan, 'file')
  disp(['ERROR! text file ' text_plan ' doesnt exist!' ])
  suspend = true;
end
if suspend
  %
  err_nav.abs_drift{rn} = [];
  err_nav.abs_orient{rn} = [];
  err_nav.term_drift{rn} = [];
  err_nav.term_orient{rn} = [];
  err_nav.rel_drift{rn} = [];
  err_nav.rel_orient{rn} = [];
  err_nav.track_loss_rate(rn) = 1;
  err_nav.track_fit{rn} = [];
  err_nav.scale_fac(rn) = 1;
  %
  err_est.abs_drift{rn} = [];
  err_est.abs_orient{rn} = [];
  err_est.term_drift{rn} = [];
  err_est.term_orient{rn} = [];
  err_est.rel_drift{rn} = [];
  err_est.rel_orient{rn} = [];
  err_est.track_loss_rate(rn) = 1;
  err_est.track_fit{rn} = [];
  err_est.scale_fac(rn) = 1;
  %
  arr_plan = [];
  return ;
end

benchMark = 'whatever';
setParam
step_length = int32(-inf);
min_match_num = int32(100);
fps = 30;

%% load the text
[arr_act] = loadTrackTUM( text_act, 0, inf );
[arr_est] = loadTrackTUM( text_est, 0, inf );
[arr_plan] = loadTrackTUM( text_plan, 0, inf );

% NOTE
% when simulating with multi-machine, the transmission latency could lead 
% to inferior odom records at the beginning of arr_act.  uncomment the line
% below to chop the inferior records off
vld_begin_idx = 1;
while vld_begin_idx < size(arr_act, 1) && norm( arr_act(vld_begin_idx,2:4) ) > 0.1
    vld_begin_idx = vld_begin_idx + 1;
end
arr_act = arr_act(vld_begin_idx:end, :);

% End_Point_List{sn} = arr_path(end, 2:3);

seq_start_time = arr_plan(1,1); % arr_est(1, 1);
% seq_start_time = 0;

%% load orb results
% arr_orb = loadTrackTUM([data_dir seq_name '/' imu_type '/' slam_type ...
%   '/ObsNumber_' num2str(num_feat) ...
%   '_Vel' num2str(fwd_vel, '%.01f') '/round' num2str(rn) ...
%   '_AllFrameTrajectory.txt' ], 1, maxNormTrans);


%% associate the msf results to the desired path with timestamp
%       err_msf_baseline{sn, vn} = collectEvalMetrics(err_msf_baseline{sn, vn}, arr_msf, arr_odom, ...
%         asso_idx, max_asso_val, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
%         rm_iso_track, seq_start_time, valid_by_duration, rn);
%% associate the actual results to the planned path with timestamp
err_nav = collectEvalMetrics(...
  err_nav, arr_act, arr_plan, ...
  asso_idx, max_asso_val, min_match_num, step_length, ...
  fps, rel_interval_list(1), benchmark_type, ...
  rm_iso_track, seq_start_time, valid_by_duration, rn);

%% associate the actual results to the estimated track with timestamp
err_est = collectEvalMetrics(...
  err_est, arr_est, arr_act, ...
  asso_idx, max_asso_val, min_match_num, step_length, ...
  fps, rel_interval_list(1), benchmark_type, ...
  rm_iso_track, seq_start_time, valid_by_duration, rn);

%             %% associate the orb results to the desired path with timestamp
%             err_orb_baseline{sn, vn} = collectEvalMetrics(err_orb_baseline{sn, vn}, arr_orb, arr_path, ...
%               asso_idx, max_asso_val, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
%               rm_iso_track, seq_start_time, valid_by_duration, rn);

%         log_orb_baseline{sn, vn, fn} = [];
%         [log_orb_baseline{sn, vn, fn}] = loadLogTUM_closeLoop([data_dir ...
%           seq_name '/' imu_type '/ORB/ObsNumber_' num2str(num_feat) ...
%           '_Vel' num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_Log.txt' ], ...
%           rn, log_orb_baseline{sn, vn, fn}, 1);

%% viz for debug
% figure;
% hold on
% plot3(arr_plan(:,2), arr_plan(:,3), arr_plan(:,4), '-.')
% plot3(arr_est(:,2), arr_est(:,3), arr_est(:,4), ':')
% plot3(arr_act(:,2), arr_act(:,3), arr_act(:,4), '-')
% axis equal
% legend({'planned track';'estimate track';'actual track'})

end
