function [err_nav, err_est, arr_plan] = processClosedLoopBag(...
  data_dir, seq_name, imu_type, slam_type, num_feat, fwd_vel, rn, ...
  err_nav, err_est)

bag_tmp = [data_dir seq_name '/' imu_type '_imu/' slam_type ...
  '/ObsNumber_' num2str(num_feat) ...
  '_Vel' num2str(fwd_vel, '%.01f') ...
  '/round' num2str(rn) '.bag'];
if ~exist(bag_tmp, 'file')
  disp 'ERROR! bag file doesnt exist!'
  return ;
end

benchMark = 'whatever';
setParam
step_length = int32(-inf);
min_match_num = int32(100);
fps = 30;

%% load the ros bag

bag = rosbag(bag_tmp);
%
% bag_vis = select(bag ,'Topic', '/ORB_SLAM/camera_pose_in_imu');
% msgs_vis = readMessages(bag_vis);
bag_est = select(bag ,'Topic', '/visual/odom');
msgs_est = readMessages(bag_est);
bag_act = select(bag ,'Topic', '/odom_sparse');
msgs_act = readMessages(bag_act);
%
bag_tmp = select(bag ,'Topic', '/desired_path');
msgs_plan = readMessages(bag_tmp);
%       bag_traj = select(bag ,'Topic', '/turtlebot_controller/trajectory_controller/desired_trajectory');
%       msgs_traj = readMessages(bag_traj);

%
arr_est = odomMsgParser(msgs_est);
arr_act = odomMsgParser(msgs_act);
arr_plan = poseMsgParser(msgs_plan{1}.Poses);
%       arr_traj = odomMsgParser(msgs_traj);

% End_Point_List{sn} = arr_path(end, 2:3);

seq_start_time = arr_est(1, 1);
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
  err_nav, arr_plan, arr_act, ...
  asso_idx, max_asso_val, min_match_num, step_length, ...
  fps, rel_interval_list(1), benchmark_type, ...
  rm_iso_track, seq_start_time, valid_by_duration, rn);

%% associate the actual results to the estimated track with timestamp
err_est = collectEvalMetrics(...
  err_est, arr_act, arr_est, ...
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
% legend({'planned track';'estimate track';'actual track'})

end
