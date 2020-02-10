function seg = getTrackSegment(track, time_idx, time_st, time_ed)

seg = [];

if time_st == -1 && time_ed == -1
  return ;
end

seg_idx = find(track(:, time_idx) >= time_st & track(:, time_idx) <= time_ed);

seg = track(seg_idx, :);

% figure;
% plot3(seg(:,2),seg(:,3),seg(:,4));
% axis equal

end