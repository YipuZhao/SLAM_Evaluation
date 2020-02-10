close all
clear all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%% Close Loop Simu Config
benchMark = 'whatever'
setParam
data_dir = '/mnt/DATA/tmp/ClosedNav/demo_v3';

%% Demo Config
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
  1.0;
  ];

Latency_List = [
  0;
  0.01;
  0.03;
  0.06;
  0.1;
%   0.15;
%   0.2;
%   0.3;
  ];

round_num = 5; % 10;
step_length = int32(-inf);
min_match_num = int32(100);

track_loss_ratio = [0.9 0.98];

fps = 30;
imu_type = 'ADIS16448'; % 'mpu6000'; % 

%
plot_errBox     = true; % false; %
plot_actTrack   = true; % false; %

legend_arr = {...
  '0ms'; '10ms'; '30ms'; '60ms'; '100ms'; % '200ms'; '300ms';
  };
figure_size = [1 1 1700 356];

figure_track_xylim = {
  [-1 15 -10 2]; % loop
  [-1 20 -20 1]; % long
  [-2 16 -16 2]; % zigzag
  [-2 16 -16 2]; % square
  [-2 16 -16 2]; % two_circle
  [-2 16 -16 2]; % infinite
  };

marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [0 1 0];
      [0 0 0];
      [0.3 0.1 0.5];
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

save_path       = './output/RAS19/'

%% Load data from text
Prefix = 'Latency_';
for sn=1:length(Seq_Name_List)
  for vn = 1:length(Fwd_Vel_List)
    for fn = 1:length(Latency_List)
      
      err_nav_delay{sn, vn, fn} = [];
      err_est_delay{sn, vn, fn} = [];
      
      for rn = 1 : round_num
        %% load results
        %         [err_nav_delay{sn, vn, fn}, err_est_delay{sn, vn, fn}, ~] = ...
        %           processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'Demo', ...
        %           Prefix, Latency_List(fn), Fwd_Vel_List(vn), rn, ...
        %           err_nav_delay{sn, vn, fn}, err_est_delay{sn, vn, fn});
        [err_nav_delay{sn, vn, fn}, err_est_delay{sn, vn, fn}, arr_plan{sn, vn, fn}] = ...
          processClosedLoopText(data_dir, '', imu_type, '', ...
          Prefix, Latency_List(fn), Fwd_Vel_List(vn), rn, ...
          err_nav_delay{sn, vn, fn}, err_est_delay{sn, vn, fn});
      end
    end
  end
end

%% Plot the results
for sn=1:length(Seq_Name_List)
  
  %% label invalid results
  for vn=1:length(Fwd_Vel_List)
    for fn = 1:length(Latency_List)
%       duration_plan = arr_plan{sn, vn, fn}(end,1)-arr_plan{sn, vn, fn}(1,1);
      for rn = 1 : round_num
        err_est_delay{sn, vn, fn}.valid_flg{rn} = true;
      end
    end
  end
  
  if plot_errBox
    %% viz err distribution
    h = figure(1);
    clf
    ii=1
    createBoxPlot_closedLoop_demo
    
    fname = ['Navigation Error: ' Seq_Name_List{sn} ' scene; ' imu_type];
    suptitle(fname);
    set(h, 'Position', figure_size)
    
    export_fig(h, [save_path '/' fname '.fig']);
    export_fig(h, [save_path '/' fname '.png']);
  end
  
  if plot_actTrack
    %% viz traj distribution
    h = figure(3);
    clf
    ii=1
    createTrackPlot_closedLoop_demo
    
    fname = ['Actual Track: ' Seq_Name_List{sn} ' scene; ' imu_type];
    suptitle(fname);
    set(h, 'Position', [338 190 800 283])
    
    export_fig(h, [save_path '/' fname '.fig']);
    export_fig(h, [save_path '/' fname '.png']);
  end
  
end
