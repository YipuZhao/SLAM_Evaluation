function [tErr_summ] = boxPlot_3_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  err_type, stat_type, err_orig, err_gf, err_mv, legend_arr, whisker_val, invalid_flg)
%%

if nargin < 12
  invalid_flg = NaN;
end

err_box_orig = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_orig, invalid_flg);

err_box_gf = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_gf, invalid_flg);

err_box_mv = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_mv, invalid_flg);

tErr_summ = [];
tErr_summ = cat(1, tErr_summ, reshape(err_box_orig, [1 size(err_box_orig)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_gf, [1 size(err_box_gf)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_mv, [1 size(err_box_mv)]));

aboxplot(tErr_summ', 'labels', legend_arr, 'OutlierMarker', 'x', ...
  'whisker', whisker_val); % Advanced box plot

end