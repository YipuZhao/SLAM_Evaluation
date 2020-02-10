function [motion_t_arr, motion_r_arr] = quantizeMotion(track)
%%

% motion_t_arr = zeros(size(track, 1)-1, 1);
% motion_r_arr = zeros(size(track, 1)-1, 1);
% motion_t_arr_cc = zeros(size(track, 1)-1, 3);

i=1;
for fn = 1 : size(track, 1)-1
    
    delta_t = track(fn+1, 1) - track(fn, 1);
    
    if delta_t > 0.5
      %
    else
      motion = ominus( ...
        transform44( track(fn+1, 2:end) ), ...
        transform44( track(fn, 2:end) ) );
      %
      motion_t_arr(i) = norm(motion(1:3, 4)) / delta_t;
      motion_r_arr(i) = rad2deg(acos(min(1, max(-1, (trace(motion(1:3, 1:3)) - 1)/2)))) / delta_t;
      i = i + 1;
    end

    
    %     homm_t2 = transform44(track(fn+1, 2:8));
    %     homm_t1 = transform44(track(fn, 2:8));
    %     homm_speed = homm_t2 * inv(homm_t1);
    %
    %     motion_t_arr(fn) = norm(homm_speed(1:3, 4)) / delta_t;
    %     %
    %     axang = rotm2axang(homm_speed(1:3, 1:3));
    %     motion_r_arr(fn) = rad2deg(axang(4)) / delta_t;
    
    % motion_t_arr_cc(fn, :) = quat2rotm(quatinv(track(fn, [8, 5:7]))) * (track(fn+1, 2:4) - track(fn, 2:4))';
    
%     motion_t_arr(fn) = norm(track(fn+1, 2:4) - track(fn, 2:4)) / delta_t;
%     %
%     axang = quat2axang( quatmultiply( track(fn+1, [8, 5:7]), ...
%         quatinv( track(fn, [8, 5:7]) ) ) );
%     motion_r_arr(fn) =  rad2deg(axang(4)) / delta_t;
end

% motion_t = mean(motion_t_arr);
% motion_r = mean(motion_r_arr);

% figure;
% scatter(track(:, 2), track(:, 4), ones(length(track), 1), track(:, 1))
% axis equal
%
% figure;
% plot(motion_t_arr);
% hold on;
% plot(motion_r_arr)