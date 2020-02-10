function plotTrack(track_base, track_imp, track_ref, legend_arr, ax, plot_3D)
%%

legend_arr = {legend_arr{1}; legend_arr{2}; 'ground truth'; };
legend_idx = [];

if plot_3D == 1
  if ~isempty(track_base)
    plot3(ax, ...
      track_base(1, :), ...
      track_base(2, :), ...
      track_base(3, :), '-o', 'MarkerSize', 3)
    legend_idx = [legend_idx 1];
  end
  %
  if ~isempty(track_imp)
    plot3(ax, ...
      track_imp(1, :), ...
      track_imp(2, :), ...
      track_imp(3, :), '-x', 'MarkerSize', 3)
    legend_idx = [legend_idx 2];
  end
  %
  if ~isempty(track_ref)
    plot3(ax, ...
      track_ref(1, :), ...
      track_ref(2, :), ...
      track_ref(3, :), '-*', 'MarkerSize', 3)
    legend_idx = [legend_idx 3];
  end
  axis equal
  view([2,2,2])
else
  if ~isempty(track_base)
    plot(ax, ...
      track_base(1, :), ...
      track_base(3, :), '-o', 'MarkerSize', 3)
    legend_idx = [legend_idx 1];
  end
  %
  if ~isempty(track_imp)
    plot(ax, ...
      track_imp(1, :), ...
      track_imp(3, :), '-x', 'MarkerSize', 3)
    legend_idx = [legend_idx 2];
  end
  %
  if ~isempty(track_ref)
    plot(ax, ...
      track_ref(1, :), ...
      track_ref(3, :), '-*', 'MarkerSize', 3)
    legend_idx = [legend_idx 3];
  end
  axis equal
end

% legend(  );
legend(legend_arr(legend_idx))

end