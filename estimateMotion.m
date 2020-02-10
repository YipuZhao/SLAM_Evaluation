function motion_arr = estimateMotion(track)
%%
motion_arr = [];
if size(track,1) < 2
  disp 'too few track records for motion estimation!'
  return ;
end
%
for i=2:size(track,1)
  time_interval = track(i, 1) - track(i-1, 1);
  if time_interval < 0 || time_interval > 5
    continue ;
  else
    cur_motion(1) = track(i, 1);
    %
    %     homm_motion = ominus( ...
    %       transform44( track(i, 2:8) ), ...
    %       transform44( track(i-1, 2:8) ) );
    homm_motion = ominus( ...
      transform44( track(i-1, 2:8) ), ...
      transform44( track(i, 2:8) ));
    
    cur_motion(2:4) = homm_motion(1:3, 4) / time_interval;
    ax_ang = rotm2axang(homm_motion(1:3, 1:3));
    ax_ang(4) = ax_ang(4) / time_interval;
    %
    cur_motion(5:8) = axang2quat(ax_ang);
    %
    motion_arr = [motion_arr; cur_motion];
  end
end