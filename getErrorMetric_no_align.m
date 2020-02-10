function [abs_drift, abs_orient, rel_drift, rel_orient, track_loss_rate] = ...
  getErrorMetric_no_align(track_dat, track_ref, asso_dat_2_ref, ...
  asso_idx, min_match_num, fps, rel_interval, remove_iso_track)
%%

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
  rel_drift = [];
  rel_orient = [];
  track_loss_rate = 1.0;
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
  %     track_loss_rate = max(0, min(1, 1 - (dat_ed - dat_st + 1) / ((track_dat(dat_ed, 1) - track_dat(dat_st, 1)) * fps)));
  track_loss_rate = max(0, min(1, 1 - length(valid_dat_idx) / ((track_dat(dat_ed, 1) - track_dat(dat_st, 1)) * fps)));
  
  %% abs_drift
  % transition error
  abs_drift = zeros(length(valid_dat_idx), 2);
  for fn = 1 : length(abs_drift)
    drift_l2 = norm(track_dat(valid_dat_idx(fn), 2:4) - track_ref(valid_ref_idx(fn), 2:4));
    abs_drift(fn, :) = [track_dat(valid_dat_idx(fn), 1), drift_l2];
  end
  
  %% abs_orient
  % orientation error
  quat_dat = track_dat(valid_dat_idx, [8,5:7]);
  quat_ref= track_ref(valid_ref_idx, [8,5:7]);
  abs_orient = zeros(length(quat_ref), 2);
  for fn = 1 : length(abs_orient)
    % axis angle between quat_ref and quat_dat_aligned
    axang = quat2axang( quatmultiply( quat_ref(fn, :), ...
      quatinv( quat_dat(fn, :) ) ) );
    abs_orient(fn, :) = [track_dat(valid_dat_idx(fn), 1), abs(rad2deg(axang(4)))];
  end
  
  %% rel_transition & rel_rotation
  %
  %     k = fps * rel_interval;
  %     rel_drift = zeros(length(valid_dat_idx)-k, 2);
  %     rel_orient = zeros(length(valid_dat_idx)-k, 2);
  %
  rel_drift = [];
  rel_orient = [];
  for fn = 1 : length(valid_ref_idx)
    %
    do_integral = true;
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
        continue ;
      end
      %             motion_dat = scale( ominus( ...
      %                 transform44( track_dat(valid_dat_idx(fn + k), 2:end) ), ...
      %                 transform44( track_dat(valid_dat_idx(fn), 2:end) ) ), ...
      %                 reg_param.s );
      %
      % FOR ACCURATE CAPTURIGN THE RELATIVE DRIFT UNDER CERTAIN INTERGRAL TIME,
      % THE SCALE FACTOR SHOULD BE ADJUSTED AS TIME GOES BY; OTHERWISE THE SCALE
      % DRIFT ERROR GONNA DOMINATE OVER THE ACTUAL RELATIVE DRIFT ERROR
      if k > 4
%         [reg_param, ~, ~] = absor(...
%           track_dat(valid_dat_idx(fn : fn + k), 2:4)', ...
%           track_ref(valid_ref_idx(fn : fn + k), 2:4)', ...
%           'doScale', 1, ...
%           'weights', [1, 0.8, 0.6, 0.4, 0.2, zeros(1, k-4)]' ...
%           );
        [reg_param, ~, ~] = absor(...
          track_dat(valid_dat_idx(fn : fn + k), 2:4)', ...
          track_ref(valid_ref_idx(fn : fn + k), 2:4)', ...
          'doScale', 1 );
        
        if ~isfinite(reg_param.s)
          continue ;
        end
        
      else
        continue ;
      end
      
      motion_dat = ominus( ...
        transform44( track_dat(valid_dat_idx(fn), 2:8) ), ...
        transform44( track_dat(valid_dat_idx(fn + k), 2:8) ) );
      if isempty(motion_dat)
        continue ;
      end
      motion_dat = scale( motion_dat, reg_param.s );
      
      error44 = ominus( motion_dat, motion_ref );
      %         error44 = ominus( motion_ref, motion_dat );
      if isempty(error44)
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
  end
  %
  %     rel_rotation = sqrt(sum(ang_vel_err .* ang_vel_err) / length(ang_vel_err));
end