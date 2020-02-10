function plotBoxPlot3(stat_BA, stat_OL, stat_OLP, round_num, whisker_val, legend_arr, ax)
%%

err_box_BA = [];
for i=1:round_num
    if isempty(stat_BA{i})
        continue ;
    end
    valid_idx = ~isinf(stat_BA{i}(:, 2));
    err_arr = stat_BA{i}(valid_idx, 2);
    err_rms = sqrt(sum(err_arr .* err_arr) / length(err_arr));
    err_box_BA = [err_box_BA; err_rms];
end
%
err_box_OL = [];
for i=1:round_num
    if isempty(stat_OL{i})
        continue ;
    end
    valid_idx = ~isinf(stat_OL{i}(:, 2));
    err_arr = stat_OL{i}(valid_idx, 2);
    err_rms = sqrt(sum(err_arr .* err_arr) / length(err_arr));
    err_box_OL = [err_box_OL; err_rms];
end
%
err_box_OLP = [];
for i=1:round_num
    if isempty(stat_OLP{i})
        continue ;
    end
    valid_idx = ~isinf(stat_OLP{i}(:, 2));
    err_arr = stat_OLP{i}(valid_idx, 2);
    err_rms = sqrt(sum(err_arr .* err_arr) / length(err_arr));
    err_box_OLP = [err_box_OLP; err_rms];
end

if isempty(err_box_BA)
    disp 'no success track for 1st method!'
    return ;
end
if isempty(err_box_OL)
    disp 'no success track for 2nd method!'
    return ;
end
if isempty(err_box_OLP)
    disp 'no success track for 3rd method!'
    return ;
end

%%
[grp_1{1:length(err_box_BA)}] = deal([legend_arr{1} ':' num2str(length(err_box_BA))]);
[grp_2{1:length(err_box_OL)}] = deal([legend_arr{2} ':' num2str(length(err_box_OL))]);
[grp_3{1:length(err_box_OLP)}] = deal([legend_arr{3} ':' num2str(length(err_box_OLP))]);
grp = [grp_1, grp_2, grp_3];
%
boxplot(ax, [err_box_BA; err_box_OL; err_box_OLP], grp', 'Whisker', whisker_val)
hold on
mean_err = [mean(err_box_BA), mean(err_box_OL), mean(err_box_OLP)];
line([0.5, 1.5], [mean_err(1), mean_err(1)], 'LineStyle', '-.', 'Parent', ax);
line([1.5, 2.5], [mean_err(2), mean_err(2)], 'LineStyle', '-.', 'Parent', ax);
line([2.5, 3.5], [mean_err(3), mean_err(3)], 'LineStyle', '-.', 'Parent', ax);

