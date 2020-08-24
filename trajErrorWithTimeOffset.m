function [trajError] = trajErrorWithTimeOffset(x, timeOffsetInit, arr_data, arr_ref)

arr_ref(:, 1) = arr_ref(:, 1) -  (timeOffsetInit + x);

step_length = int32(-inf);
min_match_num = int32(100);
fps = 30;
seg_length = 1000000; % 150 % 800 %
asso_idx = int32(1);
max_asso_val = 0.03; % 0.01; %
rel_interval = 3; % [1, 3, 5, 10];
rm_iso_track = false;
valid_by_duration = false;
benchmark_type = 'TUM';
seq_start_time = arr_data(1,1);
seq_end_time = arr_data(end, 1);
valid_by_duration = false;

arr_asso  = associate_track(arr_data, arr_ref, 1, max_asso_val);

if sum(arr_asso~=0) < 100
  trajError = inf;
  return ;
else
  
  [abs_drift, abs_orient, ...
    ~, ~, ...
    ~, ~, ...
    ~, ~, ...
    ~] = ...
    getErrorMetric_align_mex(arr_data, arr_ref, arr_asso, ...
    asso_idx, min_match_num, step_length, fps, rel_interval, benchmark_type, ...
    rm_iso_track, seq_end_time, seq_start_time, valid_by_duration);
  
  trajError = 100 * rms(abs_drift(:,2));
  return ;
end

end