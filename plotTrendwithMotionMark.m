function plotTrendwithMotionMark(trend_base, trend_imp, fps, motion_arr, legend_arr, xrange, ax)
%%

% if isempty(trend_imp) || isempty(trend_base)
%   return
% end

legend_arr = {legend_arr{1}; legend_arr{2}; 'rotation rate (deg/fr)'; };
legend_idx = [];

sample_rate = 5;

% find rows with huge rotation
axang_arr = quat2axang(motion_arr(:, 5:8));

% xlim(ax, [min(motion_arr(:,1)) max(motion_arr(:,1))]);
if ~isempty(trend_base)
  plot(ax, ...
    trend_base(:, 1), ...
    trend_base(:, 2), '-o', 'MarkerSize', 3)
  legend_idx = [legend_idx 1];
end
%
if ~isempty(trend_imp)
  [AX, hLine1, hLine2] = plotyy(ax, ...
    trend_imp(:, 1), trend_imp(:, 2), ...
    motion_arr(1:sample_rate:end,1), rad2deg(abs(wrapToPi(axang_arr(1:sample_rate:end,4)))) / fps);
  legend_idx = [legend_idx 2];
  legend_idx = [legend_idx 3];
  
  hLine1.LineStyle = '-';
  hLine1.Marker = 'x';
  hLine1.MarkerSize = 3;
  %
  hLine2.LineStyle = '--';
  hLine2.Color = 'g';
  
end

%
% min_x = min([trend_base(:, 1); trend_imp(:, 1)]);
% max_x = max([trend_base(:, 1); trend_imp(:, 1)]);
set(AX(1),'xlim', [xrange(1) xrange(2)]);
set(AX(2),'xlim', [xrange(1) xrange(2)]);
% set(AX(2),'ylim', [-pi pi]);
set(AX(2),'ylim', [-6 6]);

% legend({legend_arr{1}; legend_arr{2}; 'rotation rate (deg/fr)'});
legend(legend_arr(legend_idx))

% ylim([0 1])
%%