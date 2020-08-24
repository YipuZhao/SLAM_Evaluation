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

% HACK load and use actual trajectory under perfect state estimation as GT
text_act_truth = [data_dir seq_name '/' imu_type '/ideal/Latency_0_Vel' ...
  num2str(fwd_vel, '%.01f') '/round1_arr_act.txt'];
text_plan_truth = [data_dir seq_name '/' imu_type '/ideal/Latency_0_Vel' ...
  num2str(fwd_vel, '%.01f') '/round1_arr_plan.txt'];
% text_act_truth = ['/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/pc/'...
%   seq_name '/' imu_type '/ideal/Latency_0.03_Vel' ...
%   num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_arr_act.txt'];
% text_plan_truth = ['/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/pc/'...
%   seq_name '/' imu_type '/ideal/Latency_0.03_Vel' ...
%   num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_arr_plan.txt'];

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
if ~exist(text_act_truth, 'file')
  disp(['ERROR! text file ' text_act_truth ' doesnt exist!' ])
  suspend = true;
end
if ~exist(text_plan_truth, 'file')
  disp(['ERROR! text file ' text_plan_truth ' doesnt exist!' ])
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
[arr_act_truth] = loadTrackTUM( text_act_truth, 0, inf );
[arr_plan_truth] = loadTrackTUM( text_plan_truth, 0, inf );

if length(arr_act) < 10 || length(arr_est) < 10 || length(arr_plan) < 10 || ...
    length(arr_act_truth) < 10 || length(arr_plan_truth) < 10
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
  return ;
end

%% solve the time offset between truth log and current log
if size(arr_plan_truth, 1) > 10 && size(arr_plan, 1) > 10
  % find the roughly starting point for arr_plan_truth & arr_plan
  arr_plan_truth_startIndex = findRowsWithBigNorm(arr_plan_truth(:, 2:4), 0.1);
  arr_plan_startIndex = findRowsWithBigNorm(arr_plan(:, 2:4), 0.1);
  % time current + timeOffsetInit = time truth
  timeOffsetInit = arr_plan_truth(arr_plan_truth_startIndex, 1) - arr_plan(arr_plan_startIndex, 1);
  
  options = optimset('Display','iter');
  timeOffsetAddon = fminbnd(@(x) ...
    trajErrorWithTimeOffset(x, timeOffsetInit, arr_plan, arr_plan_truth), -2, 2, options);
  %   options = optimset('PlotFcns',@optimplotfval);
  %   timeOffsetRefine = fminsearch(@(x) ...
  %     trajErrorWithTimeOffset(x, arr_plan, arr_plan_truth), ... % -3, 3, ...
  %     timeOffsetInit, options);
  
  % apply the offset to arr_act_truth
  arr_act_truth(:, 1) = arr_act_truth(:, 1) - (timeOffsetInit + timeOffsetAddon);
else
  arr_act_truth = [];
end

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

%% associate the actual results to the planned path with timestamp
err_nav = collectEvalMetrics(...
  err_nav, arr_act, arr_plan, ... arr_act_truth, ...
  asso_idx, max_asso_val, min_match_num, step_length, ...
  fps, rel_interval_list(1), benchmark_type, ...
  rm_iso_track, seq_start_time, valid_by_duration, rn);

%% associate the actual results to the estimated track with timestamp
err_est = collectEvalMetrics(...
  err_est, arr_est, arr_act, ...
  asso_idx, max_asso_val, min_match_num, step_length, ...
  fps, rel_interval_list(1), benchmark_type, ...
  rm_iso_track, seq_start_time, valid_by_duration, rn);

%% viz for debug
% figure;
% hold on
% plot3(arr_plan(:,2), arr_plan(:,3), arr_plan(:,4), '-.')
% plot3(arr_est(:,2), arr_est(:,3), arr_est(:,4), ':')
% plot3(arr_act(:,2), arr_act(:,3), arr_act(:,4), '-')
% axis equal
% legend({'planned track';'estimate track';'actual track'})

end
