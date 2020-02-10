for vn=1:length(Fwd_Vel_List)
  %
  subplot(1, length(Fwd_Vel_List), vn)
  hold on
  
  % plot the latency demo
  for fn = 1:length(Latency_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_delay{sn, vn, fn})
          continue ;
        end
        %
        track_raw = err_nav_delay{sn, vn, fn}.track_fit{rn};
      else
        if isempty(err_est_delay{sn, vn, fn})
          continue ;
        end
        %
        track_raw = err_est_delay{sn, vn, fn}.track_fit{rn};
      end
      %
      if err_est_delay{sn, vn, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.', ...
          'Color', marker_color{fn});
      end
    end
    %
  end
  
  if ii==1
    % plot the desired path
    fn = 1;
    %
    x = arr_plan{sn, vn, fn}(:, 2)';
    y = arr_plan{sn, vn, fn}(:, 3)';
    c = arr_plan{sn, vn, fn}(:, 1)';
    xx=[x;x];
    yy=[y;y];
    cc = [c;c];
    zz=zeros(size(xx));
    surf(xx,yy,zz,cc,'EdgeColor','interp','LineWidth', 2); %// color binded to "y" values
    colormap('hsv')
    view(2) %// view(0,90)
    xlim([-1 17])
    ylim([-5 15])
    %     plot3(arr_plan{sn, vn, fn}(:, 2), arr_plan{sn, vn, fn}(:, 3), arr_plan{sn, vn, fn}(:, 4), ...
    %       '-', 'LineWidth', 2);
  end
  
  %
  %   if vn==length(Fwd_Vel_List)
  legend_style = gobjects(length(Latency_List),1);
  legend_text = cell(length(Latency_List),1);
  for fn = 1:length(Latency_List)
    legend_style(fn) = plot(nan, nan, '-.', 'color', marker_color{fn});
    legend_text{fn} = legend_arr{fn};
  end
  %   legend_style
  %   legend_text
  legend(legend_style, legend_text, 'Location', 'best');
  %   end
  %       xlim([0 20])
  %       ylim([-10 10])
  xlim(figure_track_xylim{sn}(1:2));
  ylim(figure_track_xylim{sn}(3:4));
  %       axis equal
  %       title(['Vel_{' num2str(Fwd_Vel_List(vn), '%.01f') '}'])
  title(['Target Velocity ' num2str(Fwd_Vel_List(vn)) ' (m/s)'])
end