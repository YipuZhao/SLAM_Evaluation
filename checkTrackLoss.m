function [err_est] = checkTrackLoss(err_est, rn, duration_plan, track_loss_ratio)

if isfield(err_est, 'abs_drift') && length(err_est.abs_drift) >= rn && ~isempty(err_est.abs_drift{rn})
  err_est.track_loss_rate(rn) = max(0, min(1, 1 - ...
    ( err_est.abs_drift{rn}(end,1)-err_est.abs_drift{rn}(1,1) ) / duration_plan));
else
  err_est.track_loss_rate(rn) = 1.0;
end
%
err_est.valid_flg{rn} = ...
  err_est.track_loss_rate(rn) < track_loss_ratio;

end