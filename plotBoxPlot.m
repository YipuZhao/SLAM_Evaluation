function plotBoxPlot(stat_base, loss_rate_base, stat_imp, loss_rate_imp, ...
  round_num, err_type, track_loss_ratio, whisker_val, legend_arr, ax)
%%

err_box_orig = [];
for i=1:round_num
  err_met = summarizeMetricFromSeq(stat_base{i}, loss_rate_base(i), ...
    track_loss_ratio, err_type);
  if ~isempty(err_met)
    err_box_orig = [err_box_orig; err_met];
  end
end
%
err_box_gf = [];
for i=1:round_num
  err_met = summarizeMetricFromSeq(stat_imp{i}, loss_rate_imp(i), ...
    track_loss_ratio, err_type);
  if ~isempty(err_met)
    err_box_gf = [err_box_gf; err_met];
  end
end

if isempty(err_box_orig)
  disp 'no success track for 1st method!'
  %     return ;
end
if isempty(err_box_gf)
  disp 'no success track for 2nd method!'
  %     return ;
end

%
% origin{1} = ['orb-slam'];
% origin{2} = ['gf-orb-slam'];
% box_length = min(length(err_box_orig), length(err_box_gf));
% boxplot(ax, [err_box_orig(1:box_length), err_box_gf(1:box_length)], legend_arr, 'Whisker', whisker_val)
% hold on
% mean_err = [mean(err_box_orig(1:box_length)), mean(err_box_gf(1:box_length))];
% line([0.5, 1.5], [mean_err(1), mean_err(1)], 'LineStyle', '-.', 'Parent', ax);
% line([1.5, 2.5], [mean_err(2), mean_err(2)], 'LineStyle', '-.', 'Parent', ax);

grp = [];
err = [];

if ~isempty(err_box_orig)
  [grp_1{1:length(err_box_orig)}] = deal([legend_arr{1} ':' num2str(length(err_box_orig))]);
  grp = [grp, grp_1];
  err = [err; err_box_orig];
end
%
if ~isempty(err_box_gf)
  [grp_2{1:length(err_box_gf)}] = deal([legend_arr{2} ':' num2str(length(err_box_gf))]);
  grp = [grp, grp_2];
  err = [err; err_box_gf];
end
% grp = [grp_1, grp_2];
% grp = [ones(length(err_box_orig), 1); ones(length(err_box_gf), 1) * 2];

boxplot(ax, err, grp', 'Whisker', whisker_val)
hold on

if ~isempty(err_box_orig)
  line([0.5, 1.5], [mean(err_box_orig), mean(err_box_orig)], 'LineStyle', '-.', 'Parent', ax);
end
%
if ~isempty(err_box_gf)
  line([1.5, 2.5], [mean(err_box_gf), mean(err_box_gf)], 'LineStyle', '-.', 'Parent', ax);
end

end
