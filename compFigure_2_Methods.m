function compFigure_2_Methods(plot_3D, sn, tn, track_type, track_loss_ratio, ...
  rn, round_num, fps, err_type, track_ref, err_orig, err_gf, max_asso_val, ...
  legend_arr)

%%
% axang_thres = 0.15;
whisker_val = 999; % 1.5; % 10
rn_plot = 4;
cn_plot = 6;

motion_arr = estimateMotion(track_ref);

%% 3D track plot
ax0 = subplot(rn_plot, cn_plot, [1,2, cn_plot+1,cn_plot+2, 2*cn_plot+1,2*cn_plot+2]);
title(['tracks - ' track_type{tn} ' round ' num2str(rn)])
hold on
plotTrack(err_orig{tn}.seq{sn}.track_fit{rn}, err_gf{tn}.seq{sn}.track_fit{rn}, ...
  track_ref(:, 2:4)', legend_arr, ax0, plot_3D);

%% track loss rate
ax1 = subplot(rn_plot, cn_plot, [3*cn_plot+1,3*cn_plot+2]);
title(['frame tracked %'])
hold on
bar(ax1, 2*(1:round_num)-1, (1 - err_orig{tn}.seq{sn}.track_loss_rate) * 100, 0.25, 'b');
bar(ax1, 2*(1:round_num), (1 - err_gf{tn}.seq{sn}.track_loss_rate) * 100, 0.25, 'r');
plot(ax1, [0 2*round_num+1], [1-track_loss_ratio(tn) 1-track_loss_ratio(tn)] * 100, '--g');
xlim([0 2*round_num+1])
ylim([0 120]) % leave some room for legend
legend({legend_arr{1}; legend_arr{2}; 'Track success threshold'});
% legend(legend_arr);

time_arr_tmp = [];
if ~isempty(err_orig{tn}.seq{sn}.abs_drift{rn})
  time_arr_tmp = [time_arr_tmp; err_orig{tn}.seq{sn}.abs_drift{rn}(:, 1)];
end
if ~isempty(err_gf{tn}.seq{sn}.abs_drift{rn})
  time_arr_tmp = [time_arr_tmp; err_gf{tn}.seq{sn}.abs_drift{rn}(:, 1)];
end
xrange(1) = min(time_arr_tmp);
xrange(2) = max(time_arr_tmp);

%% error trend
ax2 = subplot(rn_plot, cn_plot, [3, 4]);
title(['abs transition err (m) - ' track_type{tn} ' round ' num2str(rn)])
hold on
% plotTrend(err_orig{tn}.seq{sn}.abs_drift{rn}, err_gf{tn}.seq{sn}.abs_drift{rn}, legend_arr, ax2);
% plotMotionOnXAxis(motion_arr, ax2);
plotTrendwithMotionMark(err_orig{tn}.seq{sn}.abs_drift{rn}, err_gf{tn}.seq{sn}.abs_drift{rn}, ...
  fps, motion_arr, legend_arr, xrange, ax2);

ax3 = subplot(rn_plot, cn_plot, [cn_plot+3, cn_plot+4]);
title(['abs rotation err (deg) - ' track_type{tn} ' round ' num2str(rn)])
hold on
% plotTrend(err_orig{tn}.seq{sn}.abs_orient{rn}, err_gf{tn}.seq{sn}.abs_orient{rn}, legend_arr, ax3);
% plotMotionOnXAxis(motion_arr, ax3);
plotTrendwithMotionMark(err_orig{tn}.seq{sn}.abs_orient{rn}, err_gf{tn}.seq{sn}.abs_orient{rn}, ...
  fps, motion_arr, legend_arr, xrange, ax3);

ax4 = subplot(rn_plot, cn_plot, [2*cn_plot+3, 2*cn_plot+4]);
title(['rel transition err (m/sec) - ' track_type{tn} ' round ' num2str(rn)])
hold on
% plotTrend(err_orig{tn}.seq{sn}.rel_drift{rn}, err_gf{tn}.seq{sn}.rel_drift{rn}, legend_arr, ax4);
% plotMotionOnXAxis(motion_arr, ax4);
plotTrendwithMotionMark(err_orig{tn}.seq{sn}.rel_drift{rn}, err_gf{tn}.seq{sn}.rel_drift{rn}, ...
  fps, motion_arr, legend_arr, xrange, ax4);

ax5 = subplot(rn_plot, cn_plot, [3*cn_plot+3, 3*cn_plot+4]);
title(['rel rotation err (deg/sec) - ' track_type{tn} ' round ' num2str(rn)])
hold on
% plotTrend(err_orig{tn}.seq{sn}.rel_orient{rn}, err_gf{tn}.seq{sn}.rel_orient{rn}, legend_arr, ax5);
% plotMotionOnXAxis(motion_arr, ax5);
plotTrendwithMotionMark(err_orig{tn}.seq{sn}.rel_orient{rn}, err_gf{tn}.seq{sn}.rel_orient{rn}, ...
  fps, motion_arr, legend_arr, xrange, ax5);

%% error box plot
% abs drift
ax6 = subplot(rn_plot, cn_plot, 5);
title(['abs transition err (m) - ' track_type{tn}])
hold on
plotBoxPlot(err_orig{tn}.seq{sn}.abs_drift, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.abs_drift, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, err_type, track_loss_ratio(tn), whisker_val, legend_arr, ax6);

% abs rotation
ax7 = subplot(rn_plot, cn_plot, cn_plot+5);
title(['abs rotation err (deg) - ' track_type{tn}])
hold on
plotBoxPlot(err_orig{tn}.seq{sn}.abs_orient, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.abs_orient, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, err_type, track_loss_ratio(tn), whisker_val, legend_arr, ax7);

% rel transition
ax8 = subplot(rn_plot, cn_plot, 2*cn_plot+5);
title(['rel transition err (m/sec) - ' track_type{tn}])
hold on
plotBoxPlot(err_orig{tn}.seq{sn}.rel_drift, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.rel_drift, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, err_type, track_loss_ratio(tn), whisker_val, legend_arr, ax8);

% rel rotation
ax9 = subplot(rn_plot, cn_plot, 3*cn_plot+5);
title(['rel rotation err (deg/sec) - ' track_type{tn}])
hold on
plotBoxPlot(err_orig{tn}.seq{sn}.rel_orient, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.rel_orient, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, err_type, track_loss_ratio(tn), whisker_val, legend_arr, ax9);

%% ORB error vs. GF error
ax10 = subplot(rn_plot, cn_plot, 6);
title(['abs transition err (m) - ' track_type{tn}])
hold on
plotErrCorr(err_orig{tn}.seq{sn}.abs_drift, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.abs_drift, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, track_loss_ratio(tn), max_asso_val, legend_arr, ax10);

% abs rotation
ax11 = subplot(rn_plot, cn_plot, cn_plot+6);
title(['abs rotation err (deg) - ' track_type{tn}])
hold on
plotErrCorr(err_orig{tn}.seq{sn}.abs_orient, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.abs_orient, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, track_loss_ratio(tn), max_asso_val, legend_arr, ax11);

% rel transition
ax12 = subplot(rn_plot, cn_plot, 2*cn_plot+6);
title(['rel transition err (m/sec) - ' track_type{tn}])
hold on
plotErrCorr(err_orig{tn}.seq{sn}.rel_drift, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.rel_drift, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, track_loss_ratio(tn), max_asso_val, legend_arr, ax12);

% rel rotation
ax13 = subplot(rn_plot, cn_plot, 3*cn_plot+6);
title(['rel rotation err (deg/sec) - ' track_type{tn}])
hold on
plotErrCorr(err_orig{tn}.seq{sn}.rel_orient, err_orig{tn}.seq{sn}.track_loss_rate, ...
  err_gf{tn}.seq{sn}.rel_orient, err_gf{tn}.seq{sn}.track_loss_rate, ...
  round_num, track_loss_ratio(tn), max_asso_val, legend_arr, ax13);

end
