function plotTrend3(trend_BA, trend_OL, trend_OLP, motion_arr, legend_arr, xrange, ax)
%%

sample_rate = 5;

% find rows with huge rotation
axang_arr = quat2axang(motion_arr(:, 5:8));

% xlim(ax, [min(motion_arr(:,1)) max(motion_arr(:,1))]);
plot(ax, ...
    trend_BA(:, 1), ...
    trend_BA(:, 2), '-o', 'MarkerSize', 3)
plot(ax, ...
    trend_OL(:, 1), ...
    trend_OL(:, 2), '-x', 'MarkerSize', 3)
[AX, hLine1, hLine2] = plotyy(ax, ...
    trend_OLP(:, 1), trend_OLP(:, 2), ...
    motion_arr(1:sample_rate:end,1), abs(wrapToPi(axang_arr(1:sample_rate:end,4))));

hLine1.LineStyle = '-';
hLine1.Marker = '*';
hLine1.MarkerSize = 3;
%
hLine2.LineStyle = '--';
hLine2.Color = 'g';
%
% min_x = min([trend_base(:, 1); trend_imp(:, 1)]);
% max_x = max([trend_base(:, 1); trend_imp(:, 1)]);
set(AX(1),'xlim', [xrange(1) xrange(2)]);
set(AX(2),'xlim', [xrange(1) xrange(2)]); 
set(AX(2),'ylim', [-pi pi]); 

legend({legend_arr{1}; legend_arr{2}; legend_arr{3}; 'axis angle (rad)'});
% ylim([0 1])
%%