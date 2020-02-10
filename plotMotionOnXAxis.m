function plotMotionOnXAxis(motion_arr, ax)
%%

% find rows with huge rotation
axang_arr = quat2axang(motion_arr(:, 5:8));
% plot_idx = find(axang_arr(:, 4) > axang_thres);

% y=get(ax, 'ylim');
% plot(ax, [motion_arr(plot_idx(:), 1), motion_arr(plot_idx(:), 1)], y, '--g');
% yyaxis right
plot(ax, motion_arr(:,1), axang_arr(:,4), '--g');