function plotDriftSummary(plot_3D, track_type, rn, round_num, ...
  track_ref, err_orig, err_gf, legend_arr)

%%
err_type = 'rms';

%% 3D track plot
ax1 = subplot(4,5,[1,2,6,7,11,12,16,17]);
title(['tracks - ' track_type ' round ' num2str(rn)])
hold on
if plot_3D == 1
  %
  if ~isempty(err_orig.track_fit{rn})
    plot3(ax1, ...
      err_orig.track_fit{rn}(1, :), ...
      err_orig.track_fit{rn}(2, :), ...
      err_orig.track_fit{rn}(3, :), '-o')
  end
  %
  if ~isempty(err_gf.track_fit{rn})
    plot3(ax1, ...
      err_gf.track_fit{rn}(1, :), ...
      err_gf.track_fit{rn}(2, :), ...
      err_gf.track_fit{rn}(3, :), '-x')
  end
  %
  if ~isempty(track_ref)
    plot3(ax1, ...
      track_ref(:, 2), ...
      track_ref(:, 3), ...
      track_ref(:, 4), '-*')
  end
  %
  axis equal
  view([5,5,5])
else
  %
  if ~isempty(err_orig.track_fit{rn})
    plot(ax1, ...
      err_orig.track_fit{rn}(1, :), ...
      err_orig.track_fit{rn}(3, :), '-o')
  end
  %
  if ~isempty(err_gf.track_fit{rn})
    plot(ax1, ...
      err_gf.track_fit{rn}(1, :), ...
      err_gf.track_fit{rn}(3, :), '-x')
  end
  %
  if ~isempty(track_ref)
    plot(ax1, ...
      track_ref(:, 2), ...
      track_ref(:, 4), '-*')
  end
  %
  axis equal
end
legend({legend_arr{1}; legend_arr{2}; 'ground truth'; });

%% error trend
ax2 = subplot(4,5,[3,4]);
title(['abs transition err (m) - ' track_type ' round ' num2str(rn)])
hold on
if ~isempty(err_orig.abs_drift{rn})
  plot(ax2, ...
    err_orig.abs_drift{rn}(:, 1), ...
    err_orig.abs_drift{rn}(:, 2), '-o')
end
%
if ~isempty(err_gf.abs_drift{rn})
  plot(ax2, ...
    err_gf.abs_drift{rn}(:, 1), ...
    err_gf.abs_drift{rn}(:, 2), '-x')
end
legend(legend_arr);
% ylim([0 1])
ax3 = subplot(4,5,[8,9]);
title(['abs rotation err (deg) - ' track_type ' round ' num2str(rn)])
hold on
if ~isempty(err_orig.abs_orient{rn})
  plot(ax3, ...
    err_orig.abs_orient{rn}(:, 1), ...
    err_orig.abs_orient{rn}(:, 2), '-o')
end
%
if ~isempty(err_gf.abs_orient{rn})
  plot(ax3, ...
    err_gf.abs_orient{rn}(:, 1), ...
    err_gf.abs_orient{rn}(:, 2), '-x')
end
legend(legend_arr);
%
ax4 = subplot(4,5,[13,14]);
title(['rel transition err (m/sec) - ' track_type ' round ' num2str(rn)])
hold on
if ~isempty(err_orig.rel_drift{rn})
  plot(ax4, ...
    err_orig.rel_drift{rn}(:, 1), ...
    err_orig.rel_drift{rn}(:, 2), '-o')
end
%
if ~isempty(err_gf.rel_drift{rn})
  plot(ax4, ...
    err_gf.rel_drift{rn}(:, 1), ...
    err_gf.rel_drift{rn}(:, 2), '-x')
end
legend(legend_arr);
% ylim([0 0.8])
%
ax5 = subplot(4,5,[18,19]);
title(['rel rotation err (deg/sec) - ' track_type ' round ' num2str(rn)])
hold on
if ~isempty(err_orig.rel_orient{rn})
  plot(ax5, ...
    err_orig.rel_orient{rn}(:, 1), ...
    err_orig.rel_orient{rn}(:, 2), '-o')
end
%
if ~isempty(err_gf.rel_orient{rn})
  plot(ax5, ...
    err_gf.rel_orient{rn}(:, 1), ...
    err_gf.rel_orient{rn}(:, 2), '-x')
end
legend(legend_arr);
% ylim([0 30])

%% error box plot
% abs drift
err_box_orig = [];
for i=1:round_num
  %
  if isempty(err_orig.abs_drift{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_orig.abs_drift{i}(:, 2));
    err_arr = err_orig.abs_drift{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_orig(i) = err_sum;
end
%
err_box_gf = [];
for i=1:round_num
  %
  if isempty(err_gf.abs_drift{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_gf.abs_drift{i}(:, 2));
    err_arr = err_gf.abs_drift{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_gf(i) = err_sum;
end
%
ax6 = subplot(4,5,5);
title(['abs transition err (m) - ' track_type])
hold on
origin{1} = legend_arr{1};
origin{2} = legend_arr{2};
boxplot(ax6, [err_box_orig; err_box_gf]', origin)

% abs rotation
err_box_orig = [];
for i=1:round_num
  %
  if isempty(err_orig.abs_orient{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_orig.abs_orient{i}(:, 2));
    err_arr = err_orig.abs_orient{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_orig(i) = err_sum;
end
%
err_box_gf = [];
for i=1:round_num
  %
  if isempty(err_gf.abs_orient{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_gf.abs_orient{i}(:, 2));
    err_arr = err_gf.abs_orient{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_gf(i) = err_sum;
end
%
ax7 = subplot(4,5,10);
title(['abs rotation err (deg) - ' track_type])
hold on
origin{1} = legend_arr{1};
origin{2} = legend_arr{2};
boxplot(ax7, [err_box_orig; err_box_gf]', origin)

% rel transition
err_box_orig = [];
for i=1:round_num
  %
  if isempty(err_orig.rel_drift{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_orig.rel_drift{i}(:, 2));
    err_arr = err_orig.rel_drift{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_orig(i) = err_sum;
end
%
err_box_gf = [];
for i=1:round_num
  %
  if isempty(err_gf.rel_drift{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_gf.rel_drift{i}(:, 2));
    err_arr = err_gf.rel_drift{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_gf(i) = err_sum;
end
%
ax8 = subplot(4,5,15);
title(['rel transition err (m/sec) - ' track_type])
hold on
origin{1} = legend_arr{1};
origin{2} = legend_arr{2};
boxplot(ax8, [err_box_orig; err_box_gf]', origin)

% rel rotation
err_box_orig = [];
for i=1:round_num
  %
  if isempty(err_orig.rel_orient{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_orig.rel_orient{i}(:, 2));
    err_arr = err_orig.rel_orient{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_orig(i) = err_sum;
end
%
err_box_gf = [];
for i=1:round_num
  %
  if isempty(err_gf.rel_orient{i})
    err_sum = NaN;
  else
    valid_idx = ~isinf(err_gf.rel_orient{i}(:, 2));
    err_arr = err_gf.rel_orient{i}(valid_idx, 2);
    switch err_type
      case 'rms'
        err_sum = sqrt(sum(err_arr .* err_arr) / length(err_arr));
      case 'mean'
        err_sum = mean(err_arr);
      case 'median'
        err_sum = median(err_arr);
      case 'max'
        err_sum = max(abs(err_arr));
    end
  end
  err_box_gf(i) = err_sum;
end
%
ax9 = subplot(4,5,20);
title(['rel rotation err (deg/sec) - ' track_type])
hold on
origin{1} = legend_arr{1};
origin{2} = legend_arr{2};
boxplot(ax9, [err_box_orig; err_box_gf]', origin)

end