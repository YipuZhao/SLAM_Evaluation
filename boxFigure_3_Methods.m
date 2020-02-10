function boxFigure_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  stat_type, err_orig, err_gf, err_mv, legend_arr)

%%
% axang_thres = 0.15;
whisker_val = 1.5; % 100; % 999; % 1.5; % 10
rn_plot = 2;
cn_plot = 3;

subplot(rn_plot, cn_plot, 1);
[err_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  'term_drift', stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val);
% legend(legend_arr);
set(gca, 'YScale', 'log');
xlabel('Ratio of lmk selected');
ylabel('L2 Error of Term. Trans. (m)');
% ylim([0 0.8])
disp '=================== L2 Error of Term. Trans. (m): ===================='
printErrStat(err_summ, legend_arr);

subplot(rn_plot, cn_plot, 2);
[err_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  'term_orient', stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val);
% legend(legend_arr);
set(gca, 'YScale', 'log');
xlabel('Ratio of lmk selected');
ylabel('L2 Error of Term. Orient. (deg)');
% ylim([0 5])
disp '================== L2 Error of Term. Orient. (deg): =================='
printErrStat(err_summ, legend_arr);

subplot(rn_plot, cn_plot, 3);
[err_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  'rel_drift', stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val);
% legend(legend_arr);
set(gca, 'YScale', 'log');
xlabel('Ratio of lmk selected');
ylabel('L2 Error of Rel. Trans. (m/s)');
% ylim([0 0.2])
disp '=================== L2 Error of Rel. Trans. (m/s): ===================='
printErrStat(err_summ, legend_arr);

subplot(rn_plot, cn_plot, 4);
[err_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  'rel_orient', stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val);
% legend(legend_arr);
set(gca, 'YScale', 'log');
xlabel('Ratio of lmk selected');
ylabel('L2 Error of Rel. Orient. (deg/s)');
% ylim([0 1.5])
disp '================== L2 Error of Rel. Orient. (deg/s): =================='
printErrStat(err_summ, legend_arr);

subplot(rn_plot, cn_plot, 5);
[err_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  'track_perc', stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val, 0);
% legend(legend_arr);
set(gca, 'YScale', 'log');
xlabel('Ratio of lmk selected');
ylabel('Frames Tracked Succeesfully (%)');
% ylim([0 5])
disp '================== Frames Tracked Succeesfully (%): ================='
printErrStat(err_summ, legend_arr);

end