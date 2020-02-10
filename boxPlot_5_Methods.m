function [tErr_summ] = boxPlot_5_Methods(sn, lmk_ratio_list, track_loss_ratio, round_num, ...
  err_type, stat_type, err_struct_1, err_struct_2, err_struct_3, err_struct_4, ...
  err_struct_5, legend_arr, whisker_val, invalid_flg)
%%

if nargin < 14
  invalid_flg = NaN;
end

err_box_1 = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct_1, invalid_flg);

err_box_2 = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct_2, invalid_flg);

err_box_3 = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct_3, invalid_flg);

err_box_4 = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct_4, invalid_flg);

err_box_5 = summarizeMetricPerType(sn, lmk_ratio_list, track_loss_ratio, ...
  round_num, err_type, stat_type, err_struct_5, invalid_flg);

tErr_summ = [];
tErr_summ = cat(1, tErr_summ, reshape(err_box_1, [1 size(err_box_1)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_2, [1 size(err_box_2)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_3, [1 size(err_box_3)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_4, [1 size(err_box_4)]));
tErr_summ = cat(1, tErr_summ, reshape(err_box_5, [1 size(err_box_5)]));

% label_summ = rep

% aboxplot(tErr_summ', 'labels', legend_arr, 'OutlierMarker', 'x', ...
%   'whisker', whisker_val); % Advanced box plot

end