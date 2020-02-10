function [tErr_summ] = boxPlot_2_Methods(lmk_ratio_list, track_loss_ratio, round_num, ...
  err_type, stat_type, err_orig, err_gf, legend_arr, whisker_val, invalid_flg)
%%

if nargin < 10
  invalid_flg = NaN;
end

err_box_orig = summarizeMetricPerType(lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_orig, invalid_flg);

err_box_gf = summarizeMetricPerType(lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_gf, invalid_flg);

tErr_summ = [];
tErr_summ = cat(1, tErr_summ, reshape(err_box_orig, [1 size(err_box_orig)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_gf, [1 size(err_box_gf)]));

aboxplot(tErr_summ', 'labels', legend_arr, 'OutlierMarker', 'x', ...
  'whisker', whisker_val); % Advanced box plot

end