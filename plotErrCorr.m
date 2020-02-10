function plotErrCorr(stat_base, loss_rate_base, stat_imp, loss_rate_imp, ...
  round_num, track_loss_ratio, max_asso_val, legend_arr, ax)
%%

err_corr = [];
for i=1:round_num
  if isempty(stat_base{i}) || loss_rate_base(i) > track_loss_ratio || ...
      isempty(stat_imp{i}) || loss_rate_imp(i) > track_loss_ratio
    continue ;
  end
  %
  asso_base_2_imp = associate_track(stat_base{i}, stat_imp{i}, 1, max_asso_val);
  valid_base_idx =  intersect([1:length(stat_base{i})], find(asso_base_2_imp(:) > 0));
  valid_imp_idx = asso_base_2_imp( valid_base_idx );
  %
  err_corr = [err_corr; stat_base{i}(valid_base_idx, 2), stat_imp{i}(valid_imp_idx, 2)];
end

if isempty(err_corr)
  disp 'no valid data for heatmap!'
  return ;
end

heatscatter(ax, err_corr(:,1), err_corr(:,2), 50, 1, '.', 0, 0, legend_arr{1}, legend_arr{2});
% xlabel('orb-slam');
% ylabel('gf-orb-slam');
hold on;
max_val = max(err_corr(:));
l = line([0 max_val], [0 max_val], 'Parent', ax);
set(l, 'Color', 'r');
xlim([0 max_val])
ylim([0 max_val])