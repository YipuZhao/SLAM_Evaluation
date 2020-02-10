function [abs_drift, abs_orient, term_drift, term_orient, rel_drift, rel_orient, ...
  track_loss_rate, track_fit_dat, scale_fac] = getErrorMetric_align(track_dat, track_ref, ...
  asso_dat_2_ref, asso_idx, min_match_num, step_length, fps, rel_interval, ...
  benchmark_type, remove_iso_track, seq_end_time, seq_start_time, track_loss_by_duration)
%%

if isempty(track_dat) || isempty(track_ref)
  abs_drift = [];
  abs_orient = [];
  term_drift = [];
  term_orient = [];
  rel_drift = [];
  rel_orient = [];
  track_fit_dat = [];
  track_loss_rate = 1.0;
  scale_fac = 1.0;
  %   disp 'empty track input!'
  return ;
end

if nargin < 13
  track_loss_by_duration = false;
end

iso_frame_thres = 5; % 3; %

ref_st = 1;
ref_ed = size(track_ref, 1);

[tmp_val, tmp_idx] = min(abs(track_dat(:,asso_idx) - track_ref(ref_st,asso_idx)));
dat_st = tmp_idx;
[tmp_val, tmp_idx] = min(abs(track_dat(:,asso_idx) - track_ref(ref_ed,asso_idx)));
dat_ed = tmp_idx;

if dat_ed - dat_st < min_match_num
  abs_drift = [];
  abs_orient = [];
  term_drift = [];
  term_orient = [];
  rel_drift = [];
  rel_orient = [];
  track_fit_dat = [];
  track_loss_rate = 1.0;
  scale_fac = 1.0;
  disp 'too few match track records!'
else
  %
  valid_dat_idx =  intersect([dat_st:dat_ed], find(asso_dat_2_ref(:) > 0));
  % get rid of isolated re-localization records
  if remove_iso_track
    time_interval_arr = track_dat(2:end,asso_idx) - track_dat(1:end-1,asso_idx);
    iso_idx = find(time_interval_arr > 1/fps*iso_frame_thres) + 1;
    iso_idx = [dat_st; iso_idx; dat_ed+1];
    if length(iso_idx) > 2
      [~, max_track_seg] = max(iso_idx(2:end) - iso_idx(1:end-1));
      %
      %         valid_dat_idx = setdiff(valid_dat_idx, iso_idx);
      valid_dat_idx = intersect(valid_dat_idx, iso_idx(max_track_seg) : iso_idx(max_track_seg+1)-1);
    end
  end
  valid_ref_idx = asso_dat_2_ref( valid_dat_idx );
  
  %% track_loss_rate
  %TODO 
  %verify the logic here; for open-loop evaluations, seq_start_time
  %seems to be close to zero, therefore doesn't affect the track loss
  %estimation much.  For closed-loop gazebo simulation, however,
  %seq_start_time could be arbitrary.  Therefore seq_duation in this case
  %is really seq_end_time. 
  %TODO
  %
  %    track_loss_rate = max(0, min(1, 1 - (dat_ed - dat_st + 1) / ((track_dat(dat_ed, 1) - track_dat(dat_st, 1)) * fps)));
  %   track_loss_rate = max(0, min(1, ...
  %     1 - length(valid_dat_idx) / ((seq_duation - seq_start_time) * fps)));
  if track_loss_by_duration
    track_loss_rate = max(0, min(1, ...
      1 - ( track_dat(valid_dat_idx(end), 1) - track_dat(valid_dat_idx(1), 1) ) / (seq_end_time - seq_start_time) ));
  else
    track_loss_rate = max(0, min(1, ...
      1 - length(valid_dat_idx) / (fps * (seq_end_time - seq_start_time)) ) );
  end
  
  %% abs_terminal_drift
  % transition error
  if step_length > 0
    % estimate scale and alignment with a weighted sub-track
    %     weight_dat = [exp(-1 / length(valid_dat_idx) * ...
    %       [0 : step_length : step_length*length(valid_dat_idx)-1])];
    weight_dat = [ones(1, step_length), zeros(1, length(valid_dat_idx)-step_length)];
    %
    [reg_param, track_fit_dat, err_stat_dat] = absor(track_dat(valid_dat_idx, 2:4)', ...
      track_ref(valid_ref_idx, 2:4)', ...
      1, ...
      weight_dat ...
      );
  elseif step_length == 0
    % estimate scale and alignment with the full track
    [reg_param, track_fit_dat, err_stat_dat] = absor(track_dat(valid_dat_idx, 2:4)', ...
      track_ref(valid_ref_idx, 2:4)', ...
      1, ...
      [] ...
      );
  elseif step_length ~= int32(-inf)
    % estimate alignment with the full track
    % no scale correction
    [reg_param, track_fit_dat, err_stat_dat] = absor(track_dat(valid_dat_idx, 2:4)', ...
      track_ref(valid_ref_idx, 2:4)', ...
      0, ...
      [] ...
      );
  else
    % no alignment or scale correction
    reg_param.R = eye(3);
    reg_param.t = [0.0; 0.0; 0.0];
    reg_param.s = 1.0;
    reg_param.M = [1.0*reg_param.R, reg_param.t; [0 0 0 1] ];
    reg_param.q = [1.0; 0.0; 0.0; 0.0];
    %
    track_fit_dat = track_dat(valid_dat_idx, 2:4)';
    err_stat_dat.err_arr_orig = ...
      track_dat(valid_dat_idx, 2:4)' - track_ref(valid_ref_idx, 2:4)';
    if ~isempty(valid_dat_idx)
      err_stat_dat.err_arr_l2 = zeros(1, length(valid_dat_idx));
      for i=1:length(valid_dat_idx)
        err_stat_dat.err_arr_l2(i) = norm(...
          track_dat(valid_dat_idx(i), 2:4)' - track_ref(valid_ref_idx(i), 2:4)');
      end
    else
      err_stat_dat.err_arr_l2 = [];
    end
  end
  abs_drift = [track_dat(valid_dat_idx, 1), err_stat_dat.err_arr_l2'];
  term_drift = [track_dat(valid_dat_idx(end), 1), err_stat_dat.err_arr_l2(end)'];
  scale_fac = reg_param.s;
  
  %% abs_terminal_orient
  % orientation error
  quat_dat_2_ref = reg_param.q'; % rotm2quat(reg_param.R);
  quat_dat_aligned = quatmultiply(quat_dat_2_ref, track_dat(valid_dat_idx, [8,5:7]));
  quat_ref = track_ref(valid_ref_idx, [8,5:7]);
  abs_orient = zeros(length(quat_ref), 2);
  for fn = 1 : length(quat_ref)
    % axis angle between quat_ref and quat_dat_aligned
%     fn
    axang = quat2axang( quatmultiply( quat_ref(fn, :), ...
      quatinv( quat_dat_aligned(fn, :) ) ) );
    abs_orient(fn, :) = [track_dat(valid_dat_idx(fn), 1), abs(rad2deg(axang(4)))];
  end
  term_orient = abs_orient(length(quat_ref), :);
  
  %% rel_transition & rel_rotation
  %
  %   reg_param = [];
  %
  %   if step_length >= 0
  %     % estimate the global scale factor for relative pose error estimation
  %     [reg_param, ~, ~] = absor(track_dat(valid_dat_idx, 2:4)', ...
  %       track_ref(valid_ref_idx, 2:4)', ...
  %       1, ...
  %       [] ...
  %       );
  %   else
  %     [reg_param, ~, ~] = absor(track_dat(valid_dat_idx, 2:4)', ...
  %       track_ref(valid_ref_idx, 2:4)', ...
  %       0, ...
  %       [] ...
  %       );
  %   end
  rel_drift = [];
  rel_orient = [];
  %   for fn = 1 : length(valid_ref_idx)
  fn = int32(1);
  while fn < length(valid_ref_idx)
    
    %         fn
    do_integral = true;
    k = int32(1);
    for k = 1 : length(valid_ref_idx)
      if fn + k > length(valid_ref_idx)
        do_integral = false;
        break ;
      end
      if track_ref(valid_ref_idx(fn + k), 1) - track_ref(valid_ref_idx(fn), 1) > rel_interval
        break ;
      end
    end
    %
    if do_integral == true
      delta_t = track_ref(valid_ref_idx(fn + k), 1) - track_ref(valid_ref_idx(fn), 1);
      
      motion_ref = ominus( ...
        transform44( track_ref(valid_ref_idx(fn), 2:end) ), ...
        transform44( track_ref(valid_ref_idx(fn + k), 2:end) ) );
      if isempty(motion_ref)
        switch benchmark_type
          case {'KITTI'}
            fn = fn + max(1, int32(k/2));
          otherwise
            fn = fn + 1;
            % fn = fn + max(1, int32(k/2));
        end
        continue ;
      end
      
      switch benchmark_type
        %
        case {'KITTI'}
          % FOR ACCURATE CAPTURIGN THE RELATIVE DRIFT UNDER CERTAIN INTERGRAL TIME,
          % THE SCALE FACTOR SHOULD BE ADJUSTED AS TIME GOES BY; OTHERWISE THE SCALE
          % DRIFT ERROR GONNA DOMINATE OVER THE ACTUAL RELATIVE DRIFT ERROR
          if k > 10
            [reg_param, ~, ~] = absor(...
              track_dat(valid_dat_idx(fn : fn + k), 2:4)', ...
              track_ref(valid_ref_idx(fn : fn + k), 2:4)', ...
              1, ...
              [] ...
              );
            
            if ~isfinite(reg_param.s)
              fn = fn + max(1, int32(k/2));
              continue ;
            end
            
          else
            fn = fn + max(1, int32(k/2));
            continue ;
          end
          %
      end
      
      motion_dat = ominus( ...
        transform44( track_dat(valid_dat_idx(fn), 2:end) ), ...
        transform44( track_dat(valid_dat_idx(fn + k), 2:end) ) );
      if isempty(motion_dat)
        switch benchmark_type
          case {'KITTI'}
            fn = fn + max(1, int32(k/2));
          otherwise
            fn = fn + 1;
            % fn = fn + max(1, int32(k/2));
        end
        continue ;
      end
      motion_dat = scale( motion_dat, reg_param.s );
      
      %       % skip the sudden "jump" in pose optimation; mostly due to
      %       % instablility of pose optimazation (PL-SLAM has a lot of such
      %       % issues)
      %       if norm( motion_dat(1:3, 4) ) / delta_t > 2 * norm( motion_ref(1:3, 4) )
      %         %         disp 'skip jump error!'
      %         %         fn = fn + max(1, int32(k/4));
      %         fn = fn + 1;
      %         continue ;
      %       end
      
      error44 = ominus( motion_dat, motion_ref );
      %         error44 = ominus( motion_ref, motion_dat );
      if isempty(error44)
        switch benchmark_type
          case {'KITTI'}
            fn = fn + max(1, int32(k/2));
          otherwise
            fn = fn + 1;
            % fn = fn + max(1, int32(k/2));
        end
        continue ;
      end
      
      %
      rel_drift = [rel_drift; ...
        track_dat(valid_dat_idx(fn + k), 1), ...
        norm(error44(1:3, 4)) / delta_t];
      rel_orient = [rel_orient; ...
        track_dat(valid_dat_idx(fn + k), 1), ...
        rad2deg(acos(min(1, max(-1, (trace(error44(1:3, 1:3)) - 1)/2)))) / delta_t];
    end
    %
    switch benchmark_type
      case {'KITTI'}
        fn = fn + max(1, int32(k/2));
      otherwise
        fn = fn + 1;
        % fn = fn + max(1, int32(k/2));
    end
    
  end
  %
  %     rel_rotation = sqrt(sum(ang_vel_err .* ang_vel_err) / length(ang_vel_err));
end