
%
hold on

if plot_msc
  % plot msf
  for fn = 1 % 1:length(Number_MF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_msc{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_msc{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_msc{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_msc{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_msc{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.b');
      end
    end
    %
  end
end

if plot_vif
  % plot vins-fusion
  for fn = 1 % 1:length(Number_MF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_vif{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_vif{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_vif{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_vif{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_vif{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.g');
      end
    end
    %
  end
end

if plot_svo
  % plot svo
  for fn = 1 % 1:length(Number_AF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_svo{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_svo{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_svo{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_svo{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_orb{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.r');
      end
    end
    %
  end
end

if plot_orb
  % plot orb
  for fn = 1 % 1:length(Number_AF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_orb{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_orb{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_orb{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_orb{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_orb{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.c');
      end
    end
    %
  end
end

if plot_lazy
  % plot orb lazy
  for fn = 1 % 1:length(Number_AF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_lazy{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_lazy{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_lazy{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_lazy{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_lazy{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.m');
      end
    end
    %
  end
end

if plot_gf
  % plot the gf
  for fn = 3 % 4 % 1:length(Number_GF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_gf{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_gf{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_gf{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_gf{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_gf{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.k');
      end
    end
    %
  end
end

if plot_gg
  % plot the gg
  for fn = 3 % 4 % 1:length(Number_GF_List)
    for rn = 1 : round_num
      if ii==1
        if isempty(err_nav_gg{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_nav_gg{sn, vn_summ, fn}.track_fit{rn};
      else
        if isempty(err_est_gg{sn, vn_summ, fn})
          continue ;
        end
        %
        track_raw = err_est_gg{sn, vn_summ, fn}.track_fit{rn};
      end
      %
      if err_est_gg{sn, vn_summ, fn}.valid_flg{rn} == true
        plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.y');
      end
    end
    %
  end
end

% if ii==1
%     % plot the desired path
%     fn = 1;
%     %
%     x = arr_plan{sn, vn_summ, fn}(:, 2)';
%     y = arr_plan{sn, vn_summ, fn}(:, 3)';
%     c = arr_plan{sn, vn_summ, fn}(:, 1)';
%     xx=[x;x];
%     yy=[y;y];
%     cc = [c;c];
%     zz=zeros(size(xx));
%     surf(xx,yy,zz,cc,'EdgeColor','interp','LineWidth', 2); %// color binded to "y" values
%     colormap('hsv')
%     view(2) %// view(0,90)
%     xlim([-1 17])
%     ylim([-5 15])
%     %     plot3(arr_plan{sn, vn_summ, fn}(:, 2), arr_plan{sn, vn_summ, fn}(:, 3), arr_plan{sn, vn_summ, fn}(:, 4), ...
%     %       '-', 'LineWidth', 2);
% end

%
%   if vn_summ==length(Fwd_Vel_List)
legend_style = gobjects(plot_msc+plot_vif+plot_svo+plot_orb+plot_lazy+plot_gf,1);
legend_text = cell(plot_msc+plot_vif+plot_svo+plot_orb+plot_lazy+plot_gf,1);
cnt = 1;
if plot_msc
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'b');
  legend_text{cnt} = 'MSC';
  cnt = cnt + 1;
end
if plot_vif
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'g');
  legend_text{cnt} = 'VIF';
  cnt = cnt + 1;
end
if plot_svo
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'r');
  legend_text{cnt} = 'SVO';
  cnt = cnt + 1;
end
if plot_orb
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'c');
  legend_text{cnt} = 'ORB';
  cnt = cnt + 1;
end
if plot_lazy
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'm');
  legend_text{cnt} = 'Lazy';
  cnt = cnt + 1;
end
if plot_gf
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'k');
  legend_text{cnt} = 'GF';
  cnt = cnt + 1;
end
if plot_gg
  legend_style(cnt) = plot(nan, nan, '-.', 'color', 'y');
  legend_text{cnt} = 'GF+GG';
  cnt = cnt + 1;
end
%   legend_style
%   legend_text
legend(legend_style, legend_text, 'Location', 'best');
%   end
%       xlim([0 20])
%       ylim([-10 10])
xlim(figure_track_xylim{sn}(1:2));
ylim(figure_track_xylim{sn}(3:4));
xlabel('x (m)');
ylabel('y (m)');
%       axis equal
% title(['Target Velocity ' num2str(Fwd_Vel_List(vn_summ)) ' (m/s)'])
