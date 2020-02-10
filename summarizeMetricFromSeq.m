function [metric] = summarizeMetricFromSeq(seq, loss, track_loss_ratio, mtype)

if isempty(seq) || loss > track_loss_ratio
  metric = nan;
  return ;
end

valid_idx = ~isinf(seq(:, 2));
err_arr = seq(valid_idx, 2);
switch mtype
  case 'rms_robust'
%     metric = trimmean(err_arr, 5);
    err_arr_trimed = prctile(err_arr, [0 90]);
    metric = rms(err_arr_trimed); % sqrt(sum(err_arr_trimed .* err_arr_trimed) / length(err_arr_trimed));
  case 'rms'
    metric = rms(err_arr); % sqrt(sum(err_arr .* err_arr) / length(err_arr));
  case 'mean'
    metric = mean(err_arr);
  case 'max'
    metric = max(abs(err_arr));
  case 'all'
    metric = err_arr;
end

end