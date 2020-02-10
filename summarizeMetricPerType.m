function [err_summ] = summarizeMetricPerType(lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct, invalid_flg)

err_summ = [];
%
for ln=1:length(lmk_ratio_list)
  %
  err_all_rounds = [];
  for i=1:round_num
    %
    switch err_type
      case 'abs_drift'
        err_raw = err_struct.abs_drift{i};
      case 'abs_orient'
        err_raw = err_struct.abs_orient{i};
      case 'term_drift'
        err_raw = err_struct.term_drift{i};
      case 'term_orient'
        err_raw = err_struct.term_orient{i};
      case 'rel_drift'
        err_raw = err_struct.rel_drift{i};
      case 'rel_orient'
        err_raw = err_struct.rel_orient{i};
      case 'track_perc'
        err_raw = 1 - err_struct.track_loss_rate(i);
        %       case 'abs_drift'
        %         err_raw = err_struct{ln}.seq{sn}.abs_drift{i};
        %       case 'abs_orient'
        %         err_raw = err_struct{ln}.seq{sn}.abs_orient{i};
        %       case 'term_drift'
        %         err_raw = err_struct{ln}.seq{sn}.term_drift{i};
        %       case 'term_orient'
        %         err_raw = err_struct{ln}.seq{sn}.term_orient{i};
        %       case 'rel_drift'
        %         err_raw = err_struct{ln}.seq{sn}.rel_drift{i};
        %       case 'rel_orient'
        %         err_raw = err_struct{ln}.seq{sn}.rel_orient{i};
        %       case 'track_perc'
        %         err_raw = 1 - err_struct{ln}.seq{sn}.track_loss_rate(i);
    end
    %
    if strcmp(err_type, 'track_perc')
      err_metric = err_raw;
      %     else if strcmp(err_type, 'term_drift') || strcmp(err_type, 'term_drift')
      %       err_met = err_arr;
    else
      err_metric = summarizeMetricFromSeq(err_raw, ...
        err_struct.track_loss_rate(i), ...
        track_loss_ratio, stat_type);
      %       err_metric = summarizeMetricFromSeq(err_raw, ...
      %         err_struct{ln}.seq{sn}.track_loss_rate(i), ...
      %         track_loss_ratio, stat_type);
    end
    if ~isempty(err_metric)
      err_all_rounds = [err_all_rounds; err_metric];
    else
      err_all_rounds = [err_all_rounds; invalid_flg];
    end
  end
  err_summ = [err_summ err_all_rounds];
  %
end

end