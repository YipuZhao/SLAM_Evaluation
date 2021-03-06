function plotErrorPropagation(sn, rn, round_num, track_ref, err_BA, err_OL, err_OLP, legend_arr)

%%
% axang_thres = 0.15;
whisker_val = 10; % 1.5; % 
rn_plot = 4;
cn_plot = 5;

motion_arr = estimateMotion(track_ref);

%% 3D track plot
ax0 = subplot(rn_plot, cn_plot, [1,2, cn_plot+1,cn_plot+2, 2*cn_plot+1,2*cn_plot+2]);
title(['tracks - ' ' round ' num2str(rn)])
hold on
plot3(ax0, ...
    err_BA.seq{sn}.track_fit{rn}(1, :), ...
    err_BA.seq{sn}.track_fit{rn}(2, :), ...
    err_BA.seq{sn}.track_fit{rn}(3, :), '-o', 'MarkerSize', 3)
plot3(ax0, ...
    err_OL.seq{sn}.track_fit{rn}(1, :), ...
    err_OL.seq{sn}.track_fit{rn}(2, :), ...
    err_OL.seq{sn}.track_fit{rn}(3, :), '-x', 'MarkerSize', 3)
plot3(ax0, ...
    err_OLP.seq{sn}.track_fit{rn}(1, :), ...
    err_OLP.seq{sn}.track_fit{rn}(2, :), ...
    err_OLP.seq{sn}.track_fit{rn}(3, :), '-*', 'MarkerSize', 3)
plot3(ax0, ...
    track_ref(:, 2), ...
    track_ref(:, 3), ...
    track_ref(:, 4), '-.k', 'MarkerSize', 3)
axis equal
view([2,2,2])
legend({legend_arr{1}; legend_arr{2}; legend_arr{3}; 'ground truth'});

%% track loss rate
ax1 = subplot(rn_plot, cn_plot, [3*cn_plot+1,3*cn_plot+2]);
title(['frame tracked %'])
hold on
bar(ax1, 3*(1:round_num)-2, (1 - err_BA.seq{sn}.track_loss_rate) * 100, 0.25, 'b');
bar(ax1, 3*(1:round_num)-1, (1 - err_OL.seq{sn}.track_loss_rate) * 100, 0.25, 'r');
bar(ax1, 3*(1:round_num), (1 - err_OLP.seq{sn}.track_loss_rate) * 100, 0.25, 'y');
xlim([0 3*round_num+1])
ylim([0 100])
legend(legend_arr);

xrange(1) = min([err_OL.seq{sn}.abs_drift{rn}(:, 1); err_OL.seq{sn}.abs_drift{rn}(:, 1)]);
xrange(2) = max([err_OL.seq{sn}.abs_drift{rn}(:, 1); err_OL.seq{sn}.abs_drift{rn}(:, 1)]);

%% error trend
ax2 = subplot(rn_plot, cn_plot, [3, 4]);
title(['abs transition err (m) - '  ' round ' num2str(rn)])
hold on
plotTrend3(err_BA.seq{sn}.abs_drift{rn}, ...
    err_OL.seq{sn}.abs_drift{rn}, ...
    err_OLP.seq{sn}.abs_drift{rn}, ...
    motion_arr, legend_arr, xrange, ax2);

ax3 = subplot(rn_plot, cn_plot, [cn_plot+3, cn_plot+4]);
title(['abs rotation err (deg) - '  ' round ' num2str(rn)])
hold on
plotTrend3(err_BA.seq{sn}.abs_orient{rn}, ...
    err_OL.seq{sn}.abs_orient{rn}, ...
    err_OLP.seq{sn}.abs_orient{rn}, ...
    motion_arr, legend_arr, xrange, ax3);

ax4 = subplot(rn_plot, cn_plot, [2*cn_plot+3, 2*cn_plot+4]);
title(['rel transition err (m/sec) - '  ' round ' num2str(rn)])
hold on
plotTrend3(err_BA.seq{sn}.rel_drift{rn}, ...
    err_OL.seq{sn}.rel_drift{rn}, ...
    err_OLP.seq{sn}.rel_drift{rn}, ...
    motion_arr, legend_arr, xrange, ax4);

ax5 = subplot(rn_plot, cn_plot, [3*cn_plot+3, 3*cn_plot+4]);
title(['rel rotation err (deg/sec) - '  ' round ' num2str(rn)])
hold on
plotTrend3(err_BA.seq{sn}.rel_orient{rn}, ...
    err_OL.seq{sn}.rel_orient{rn}, ...
    err_OLP.seq{sn}.rel_orient{rn}, ...
    motion_arr, legend_arr, xrange, ax5);

%% error box plot
% abs drift
ax6 = subplot(rn_plot, cn_plot, 5);
title(['abs transition err (m)' ])
hold on
plotBoxPlot3(err_BA.seq{sn}.abs_drift, ...
    err_OL.seq{sn}.abs_drift, ...
    err_OLP.seq{sn}.abs_drift, ...
    round_num, whisker_val, legend_arr, ax6);

% abs rotation
ax7 = subplot(rn_plot, cn_plot, cn_plot+5);
title(['abs rotation err (deg)' ])
hold on
plotBoxPlot3(err_BA.seq{sn}.abs_orient, ...
    err_OL.seq{sn}.abs_orient, ...
    err_OLP.seq{sn}.abs_orient, ...
    round_num, whisker_val, legend_arr, ax7);

% rel transition
ax8 = subplot(rn_plot, cn_plot, 2*cn_plot+5);
title(['rel transition err (m/sec)' ])
hold on
plotBoxPlot3(err_BA.seq{sn}.rel_drift, ...
    err_OL.seq{sn}.rel_drift, ...
    err_OLP.seq{sn}.rel_drift, ...
    round_num, whisker_val, legend_arr, ax8);

% rel rotation
ax9 = subplot(rn_plot, cn_plot, 3*cn_plot+5);
title(['rel rotation err (deg/sec)' ])
hold on
plotBoxPlot3(err_BA.seq{sn}.rel_orient, ...
    err_OL.seq{sn}.rel_orient, ...
    err_OLP.seq{sn}.rel_orient, ...
    round_num, whisker_val, legend_arr, ax9);
