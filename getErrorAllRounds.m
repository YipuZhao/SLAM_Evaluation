function [err_all_rounds] = getErrorAllRounds(err_nav, err_est, ii, sn, vn, fn, ...
  metric_type, round_num)
%
switch metric_type
  case 'abs\_drift'
    err_all_rounds = [];
    for rn = 1 : round_num
      if ii==1
        track_raw = err_nav{sn, vn, fn}.abs_drift{rn};
      else
        track_raw = err_est{sn, vn, fn}.abs_drift{rn};
      end
      err_metric = summarizeMetricFromSeq(track_raw, ...
        0, 1.0, 'rms');
      if err_est{sn, vn, fn}.valid_flg{rn} == true
        err_all_rounds = [err_all_rounds; err_metric];
      else
        err_all_rounds = [err_all_rounds; nan];
      end
    end
  case 'term\_drift'
    err_all_rounds = [];
    for rn = 1 : round_num
      if ii==1
        track_raw = err_nav{sn, vn, fn}.term_drift{rn};
      else
        track_raw = err_est{sn, vn, fn}.term_drift{rn};
      end
      err_metric = track_raw(1, 2);
      if err_est{sn, vn, fn}.valid_flg{rn} == true
        err_all_rounds = [err_all_rounds; err_metric];
      else
        err_all_rounds = [err_all_rounds; nan];
      end
    end
  case 'rel\_drift'
    err_all_rounds = [];
    for rn = 1 : round_num
      if ii==1
        track_raw = err_nav{sn, vn, fn}.rel_drift{rn};
      else
        track_raw = err_est{sn, vn, fn}.rel_drift{rn};
      end
      err_metric = summarizeMetricFromSeq(track_raw, ...
        0, 1.0, 'rms');
      if err_est{sn, vn, fn}.valid_flg{rn} == true
        err_all_rounds = [err_all_rounds; err_metric];
      else
        err_all_rounds = [err_all_rounds; nan];
      end
    end
  case 'latency'
    err_all_rounds = [];
    for rn = 1 : round_num
      track_raw = log_svo_baseline{sn, vn, fn}.timeTotal{rn};
      %               err_metric = summarizeMetricFromSeq(err_raw, ...
      %                 0, 1.0, 'mean');
      err_all_rounds = [err_all_rounds; track_raw];
    end
end

end