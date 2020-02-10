close all
clear all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%% Close Loop Simu Config
benchMark = 'whatever'
setParam

% data_dir = '/home/yipuzhao/Codes/VSLAM/SLAM_Evaluation/';
data_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/gazebo_simulation/pc/';
% data_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/gazebo_simulation/laptop_onboard/';
% data_dir = '/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/pc/';
% data_dir = '/media/yipuzhao/1399F8643500EDCD/ClosedLoop_Exp/Simulation/laptop_onboard/';


%% Batch Config
Seq_Name_List = {
  'loop';
  'long';
  'zigzag';
  'square';
  'two_circle';
  'infinite';
  };

End_Point_List = {
  [0 0];
  [18 -14.5];
  [0 0];
  [0 0];
  [0 0];
  [0 0];
  };

Fwd_Vel_List = [
  0.5;
  1.0;
  1.5;
  % 2.0;
  ];

Number_AF_List = [
  800;
  1200;
  ];

Number_SF_List = [
  600;
  1200;
  ];

Number_MF_List = [
  120;
  240;
  ];

Number_GF_List = [
  %   40;
  60;
  80;
  100;
  120;
  %   160;
  ];

Vis_Latency_List = [
  0;
  0.03;
  ];

round_num = 5; % 10;
step_length = int32(-inf);
min_match_num = int32(100);

track_loss_ratio = [0.4 0.98]; % [0.9 0.98];

fps = 30;
imu_type = 'ADIS16448'; % 'mpu6000'; % 

vn_summ = 1;

%
plot_msc        = true; % false; % 
plot_vif        = true; % false; % 
plot_svo        = true; % false; % 
plot_orb        = true;
plot_lazy       = false; % true;
plot_gf         = true;
plot_gg         = true; % false; % 
plot_truth      = true; % false; % 
%
append_msc        = false; % true; % 
append_vif        = false; % true; % 
append_svo        = false; % true; % 
append_orb        = false; % true; % 
append_lazy       = false; % 
append_gf         = false; % 
append_gg         = true; % false; % 
append_truth      = false; % true; % 
%
plot_errBox         = true; % false; % 
plot_actTrack       = false; % true; % 
plot_planTrack      = false; % true; %
plot_actTrack_summ	= false; % true; % 

legend_arr = {};
count = 0;
%
if plot_msc
  legend_arr{count+1} = 'MSC_{120}';
  legend_arr{count+2} = 'MSC_{240}';
  count = count + 2;
end
if plot_vif
  legend_arr{count+1} = 'VIF_{120}';
  legend_arr{count+2} = 'VIF_{240}';
  count = count + 2;
end
if plot_svo
  legend_arr{count+1} = 'SVO_{600}';
  legend_arr{count+2} = 'SVO_{1200}';
  count = count + 2;
end
if plot_orb
  legend_arr{count+1} = 'ORB_{800}';
  legend_arr{count+2} = 'ORB_{1200}';
  count = count + 2;
end
if plot_lazy
  legend_arr{count+1} = 'Lazy_{800}';
  legend_arr{count+2} = 'Lazy_{1200}';
  count = count + 2;
end
if plot_gf
  legend_arr{count+1} = 'GF_{60}';
  legend_arr{count+2} = 'GF_{80}';
  legend_arr{count+3} = 'GF_{100}';
  legend_arr{count+4} = 'GF_{120}';
  count = count + 4;
end
if plot_gg
  legend_arr{count+1} = 'GF+GG_{60}';
  legend_arr{count+2} = 'GF+GG_{80}';
  legend_arr{count+3} = 'GF+GG_{100}';
  legend_arr{count+4} = 'GF+GG_{120}';
  count = count + 4;
end
if plot_truth
  legend_arr{count+1} = 'Perfect_{0}';
  legend_arr{count+2} = 'Perfect_{30}';
  count = count + 2;
end

boxplot_figure_size = [1 1 1700 356];
track_figure_size   = [338 190 1600 560];

figure_track_xylim = {
  [-1 15 -12 4]; % loop
  [-1 19 -19 1]; % long
  [-2 18 -16 4]; % zigzag
  [-2 18 -16 4]; % square
  [-2 20 -16 6]; % two_circle
  [-4 18 -18 4]; % infinite
  };

%
metric_type = {
  %   'track\_loss\_rate';
  'abs\_drift';
  %   'term\_drift';
  %   'scale\_fac';
  %   'rel\_drift';
  %   'rel\_orient';
  %   'latency';
  }

% save_path       = './output/RAS19/lowpower/'
save_path       = './output/RAS19/goodgraph/'

%% Load data from rosbag
% loadClosedLoopRes_rosbag

%% Load data from text
% loadClosedLoopRes_text

%% Load data from matlab
loadClosedLoopRes_matlab
% err_nav_gg = err_nav_ggv2;
% err_est_gg = err_est_ggv2;

%
appendGoodGraphRes_text

%% Plot the results
for sn=1:length(Seq_Name_List)
  
  %% label invalid results
  for vn=1:length(Fwd_Vel_List)
    for fn = 1:length(Number_AF_List)
      %
      duration_plan = arr_plan{sn, vn, fn}(end,1)-arr_plan{sn, vn, fn}(1,1);
      for rn = 1 : round_num
        %
        if plot_msc
          err_est_msc{sn, vn, fn} = checkTrackLoss(...
            err_est_msc{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        if plot_vif
          err_est_vif{sn, vn, fn} = checkTrackLoss(...
            err_est_vif{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        if plot_svo
          err_est_svo{sn, vn, fn} = checkTrackLoss(...
            err_est_svo{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        if plot_orb
          err_est_orb{sn, vn, fn} = checkTrackLoss(...
            err_est_orb{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        if plot_lazy
          err_est_lazy{sn, vn, fn} = checkTrackLoss(...
            err_est_lazy{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        if plot_truth
          err_est_truth{sn, vn, fn} = checkTrackLoss(...
            err_est_truth{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        %
        %         odom_end = err_est_msc{sn, vn, fn}.track_fit{rn}(1:3, end);
        %         if norm(odom_end(1:2) - End_Point_List{sn}') < 20.0
        %           err_est_msc{sn, vn, fn}.valid_flg{rn} = true;
        %         else
        %           err_est_msc{sn, vn, fn}.valid_flg{rn} = false;
        %         end
        %         %
        %         odom_end = err_est_svo{sn, vn, fn}.track_fit{rn}(1:3, end);
        %         if norm(odom_end(1:2) - End_Point_List{sn}') < 20.0
        %           err_est_svo{sn, vn, fn}.valid_flg{rn} = true;
        %         else
        %           err_est_svo{sn, vn, fn}.valid_flg{rn} = false;
        %         end
        %         %
        %         odom_end = err_est_orb{sn, vn, fn}.track_fit{rn}(1:3, end);
        %         if norm(odom_end(1:2) - End_Point_List{sn}') < 20.0
        %           err_est_orb{sn, vn, fn}.valid_flg{rn} = true;
        %         else
        %           err_est_orb{sn, vn, fn}.valid_flg{rn} = false;
        %         end
        %
        %         err_est_msc{sn, vn, fn}.valid_flg{rn} = true;
        %         err_est_vif{sn, vn, fn}.valid_flg{rn} = true;
        %         err_est_svo{sn, vn, fn}.valid_flg{rn} = true;
        %         err_est_orb{sn, vn, fn}.valid_flg{rn} = true;
        %         err_est_lazy{sn, vn, fn}.valid_flg{rn} = true;
      end
    end
    %
    for fn = 1:length(Number_GF_List)
      %       err_est_gf{sn, vn, fn}.track_loss_rate
      for rn = 1 : round_num
        
        if plot_gf
          err_est_gf{sn, vn, fn} = checkTrackLoss(...
            err_est_gf{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        
        if plot_gg
          err_est_gg{sn, vn, fn} = checkTrackLoss(...
            err_est_gg{sn, vn, fn}, rn, duration_plan, track_loss_ratio(1));
        end
        
        %         odom_end = err_est_gf{sn, vn, fn}.track_fit{rn}(1:3, end);
        %         if norm(odom_end(1:2) - End_Point_List{sn}') < 20.0
        %           err_est_gf{sn, vn, fn}.valid_flg{rn} = true;
        %         else
        %           err_est_gf{sn, vn, fn}.valid_flg{rn} = false;
        %         end
        %
        %         err_est_gf{sn, vn, fn}.valid_flg{rn} = true;
      end
    end
  end
  
  if plot_errBox
    %% viz err distribution
    h = figure(1);
    clf
    ii=1
    %     createBoxPlot_closedLoop
    createBoxPlot_closedLoop_singleRow
    
    fname = ['Navigation Error: ' Seq_Name_List{sn} ' scene; ' imu_type];
    suptitle(fname);
    set(h, 'Position', boxplot_figure_size)
    
    export_fig(h, [save_path '/' fname '.fig']);
    export_fig(h, [save_path '/' fname '.png']);
    
    %     %
    %     h = figure(2);
    %     clf
    %     ii=2
    % %     createBoxPlot_closedLoop
    % createBoxPlot_closedLoop_singleRow
    %
    %     fname = ['Visual Drift: ' Seq_Name_List{sn} ' scene; ' imu_type];
    %     suptitle(fname);
    %     set(h, 'Position', figure_size)
    %
    %     export_fig(h, [save_path '/' fname '.fig']);
    %     export_fig(h, [save_path '/' fname '.png']);
  end
  
  if plot_actTrack
    %% viz traj distribution
    h = figure(3);
    clf
    %   subplot(1, length(Fwd_Vel_List)+1, 1)
    %   plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '-b');
    %   xlim(figure_track_xylim{sn}(1:2));
    %   ylim(figure_track_xylim{sn}(3:4));
    %   %       axis equal
    %   %       title(['Vel_{' num2str(Fwd_Vel_List(vn), '%.01f') '}'])
    %   title(['Target Velocity ' num2str(Fwd_Vel_List(vn)) ' (m/s)'])
    
    ii=1
    createTrackPlot_closedLoop
    
    fname = ['Actual Track: ' Seq_Name_List{sn} ' scene; ' imu_type];
    suptitle(fname);
    %     set(h, 'Position', [338 190 800 283])
    set(h, 'Position', track_figure_size)
    
    export_fig(h, [save_path '/' fname '.fig']);
    export_fig(h, [save_path '/' fname '.png']);
  end
  
  if plot_planTrack
    %% viz traj planned
    h = figure(4);
    subplot(2, 3, sn)
    %   plot(arr_plan{sn, 1, 1}(:, 2), arr_plan{sn, 1, 1}(:, 3), ...
    %     '-m', 'LineWidth', 2);
    x = arr_plan{sn, 2, 1}(:, 2)';
    y = arr_plan{sn, 2, 1}(:, 3)';
    c = arr_plan{sn, 2, 1}(:, 1)';
    xx=[x;x];
    yy=[y;y];
    cc = [c;c];
    zz=zeros(size(xx));
    surf(xx,yy,zz,cc,'EdgeColor','interp','LineWidth',2); %// color binded to "y" values
    colormap('hsv')
    view(2) %// view(0,90)
    xlim([-1 17])
    ylim([-15 5])
    
    %   %       axis equal
    %   %       title(['Vel_{' num2str(Fwd_Vel_List(vn), '%.01f') '}'])
    %   title(['Target Velocity ' num2str(Fwd_Vel_List(vn)) ' (m/s)'])
  end
  
  if plot_actTrack_summ
    h = figure(5);
    subplot(2, 3, sn)
    ii=1
    createTrackSummaryPlot_closedLoop
    %         fname = ['Actual Track: ' Seq_Name_List{sn} ' scene; ' imu_type];
    %         suptitle(fname);
  end
  
  
  %% viz traj distribution
  %   h = figure(4);
  %   clf
  %   ii=2
  %   createTrackPlot_closedLoop
  %
  %   fname = ['Actual Track: ' Seq_Name_List{sn} ' scene; ' imu_type ];
  %   suptitle(fname);
  %   set(h, 'Position', [338 190 800 283])
  %
  %   export_fig(h, [save_path '/' fname '.fig']);
  %   export_fig(h, [save_path '/' fname '.png']);
  
  
  %% viz traj example animation
  %   vn=2
  %   rn=6
  %   offset = 10
  %   tail_length = 60;
  %   %
  %   h = figure(7);
  %   %
  %   for ii=1:length(err_nav_orb{sn, vn, 1}.track_fit{rn})
  %     clf
  %     hold on
  %     % plot desired path
  %     track_raw = arr_path{sn, vn, 1};
  %     plot3(track_raw(:, 2), track_raw(:, 3), track_raw(:, 4), '-b');
  %     idx_viz = [max(1,ii-tail_length):ii];
  %     % plot orb estimated track
  %     track_raw = err_nav_orb{sn, vn, 1}.track_fit{rn};
  %     plot3(track_raw(1, idx_viz+offset), track_raw(2, idx_viz+offset), track_raw(3, idx_viz+offset), '-r');
  %     % plot gf estimated track
  %     track_raw = err_nav_gf{sn, vn, 3}.track_fit{rn};
  %     plot3(track_raw(1, idx_viz), track_raw(2, idx_viz), track_raw(3, idx_viz), '-k');
  %
  %     legend_style = gobjects(3,1);
  %     legend_style(1) = plot(nan, nan, '-', 'color', 'b');
  %     legend_style(2) = plot(nan, nan, '-.', 'color', 'r');
  %     legend_style(3) = plot(nan, nan, '-.', 'color', 'k');
  %     legend(legend_style, {'Desired Path';'ORB Estimation';'GF Estimation';}, 'Location', 'best');
  %
  %     %     xlim([0 15])
  %     %     ylim([-10 2])
  %     xlim(figure_track_xylim{sn}(1:2));
  %     ylim(figure_track_xylim{sn}(3:4));
  %     zlim([-1 1])
  %     xlabel('X (m)')
  %     ylabel('Y (m)')
  %
  %     pause(0.001)
  %   end
  %
  %
  %   vn=2
  %   rn=3 % 6
  %   offset = 0%10
  %   tail_length = 60;
  %   %
  %   h = figure(8);
  %   %
  %   for ii=1:length(err_nav_orb{sn, vn, 1}.track_fit{rn})
  %     clf
  %     hold on
  %     % plot desired path
  %     track_raw = arr_path{sn, vn, 1};
  %     plot3(track_raw(:, 2), track_raw(:, 3), track_raw(:, 4), '-b');
  %     idx_viz = [max(1,ii-tail_length):ii];
  %     % plot orb actual track
  %     track_raw = err_est_orb{sn, vn, 1}.track_fit{rn};
  %     plot3(track_raw(1, idx_viz), track_raw(2, idx_viz), track_raw(3, idx_viz), '--.r');
  %     % plot gf actual track
  %     track_raw = err_est_gf{sn, vn, 3}.track_fit{rn};
  %     plot3(track_raw(1, idx_viz+offset), track_raw(2, idx_viz+offset), track_raw(3, idx_viz+offset), '--.k');
  %
  %     legend_style = gobjects(3,1);
  %     legend_style(1) = plot(nan, nan, '-', 'color', 'b');
  %     legend_style(2) = plot(nan, nan, '-.', 'color', 'r');
  %     legend_style(3) = plot(nan, nan, '-.', 'color', 'k');
  %     legend(legend_style, {'Desired Path';'ORB Actual';'GF Actual';}, 'Location', 'best');
  %
  %     %     xlim([0 15])
  %     %     ylim([-10 2])
  %     xlim(figure_track_xylim{sn}(1:2));
  %     ylim(figure_track_xylim{sn}(3:4));
  %     zlim([-1 1])
  %     xlabel('X (m)')
  %     ylabel('Y (m)')
  %
  %     pause(0.001)
  %   end
  
  %   close all
  
end

if plot_planTrack
  h = figure(4);
  fname = ['Planned Tracks; ' imu_type];
  suptitle(fname);
  %   set(h, 'Position', [338 190 800 283])
  set(h, 'Position', track_figure_size)
  
  export_fig(h, [save_path '/' fname '.fig']);
  export_fig(h, [save_path '/' fname '.png']);
end

if plot_actTrack_summ
  h = figure(5);
  fname = ['Actual_Tracks_' imu_type '_' num2str(Fwd_Vel_List(vn_summ)) 'mps'];
  suptitle(fname);
  %   set(h, 'Position', [338 190 800 283])
  set(h, 'Position', track_figure_size)
  
  export_fig(h, [save_path '/' fname '.fig']);
  export_fig(h, [save_path '/' fname '.png']);
end

%%
if save_to_matlab
  save(['simu_closednav_' imu_type '_imu_v8'], ...
    'err_nav_msc', 'err_est_msc', ...
    'err_nav_vif', 'err_est_vif', ...
    'err_nav_svo', 'err_est_svo', ...
    'err_nav_orb', 'err_est_orb', ...
    'err_nav_lazy', 'err_est_lazy', ...
    'err_nav_gf', 'err_est_gf', ...
    'err_nav_gg', 'err_est_gg', ...
    'err_nav_truth', 'err_est_truth', ...
    'arr_plan', 'End_Point_List');
end

% if save_to_matlab
%   save(['simu_closednav_' imu_type '_imu_v4'], ...
%     'err_nav_orb', 'err_est_orb', ...
%     'err_nav_gf', 'err_est_gf', ...
%     'arr_plan', 'End_Point_List');
% end
