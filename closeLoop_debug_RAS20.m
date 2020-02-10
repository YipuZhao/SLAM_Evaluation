close all
clear all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

%% Close Loop Simu Config
benchMark = 'whatever'
setParam

data_dir = '/mnt/DATA/tmp/ClosedNav/';

Seq_Name_List = {
  'line';
  'turn';
  'loop';
  'long';
  };

End_Point_List = {
  [14 0];
  [2 -4];
  [0 0];
  [18 -14.5];
  };

Fwd_Vel_List = [
  0.5;
  1.0
  ];

Number_AF_List = [
  600;
  1200;
  ];

Number_GF_List = [
  80;
  120;
  160;
  ];

round_num = 10;
step_length = int32(-inf);
min_match_num = int32(100);

track_loss_ratio = [0.9 0.98];
term_dist_thres = 5.0; % 10.0; %

fps = 30;
imu_type = 'high_imu'; % 'low_imu'; % 

legend_arr = {...
  'ORB_{600}^l'; 'ORB_{1200}^l'; 'GF_{80}^l'; 'GF_{120}^l'; 'GF_{160}^l'; ...
  'ORB_{600}^h'; 'ORB_{1200}^h'; 'GF_{80}^h'; 'GF_{120}^h'; 'GF_{160}^h';
  };
% legend_arr = {'ORB_{600}'; 'ORB_{1200}'; 'GF_{80}'; 'GF_{120}'; 'ORB_{600}'; 'ORB_{1200}'; 'GF_{80}'; 'GF_{120}'};
figure_size_1 = [1 1 1700 356];
figure_size_2 = [1 1 1700 1000];

y_range = {[0, 1.2]; [0, 1]; [0, 0.3]};

%
metric_type = {
  %   'track\_loss\_rate';
  'abs\_drift';
  'term\_drift';
  %   'scale\_fac';
  'rel\_drift';
  %   'rel\_orient';
  %   'latency';
  }

save_path       = './output/RAS19/'


load(['simu_closednav_' imu_type]);

%%
for sn= 1:length(Seq_Name_List)
  
  %% label invalid results
  for vn=1:length(Fwd_Vel_List)
    for fn = 1:length(Number_AF_List)
      for rn = 1 : round_num
        odom_end = err_odom_baseline{sn, vn, fn}.track_fit{rn}(1:3, end);
        if norm(odom_end(1:2) - End_Point_List{sn}') < term_dist_thres
          err_odom_baseline{sn, vn, fn}.valid_flg{rn} = true;
        else
          err_odom_baseline{sn, vn, fn}.valid_flg{rn} = false;
        end
% err_odom_baseline{sn, vn, fn}.valid_flg{rn} = true;
      end
    end
    %
    for fn = 1:length(Number_GF_List)
      for rn = 1 : round_num
        odom_end = err_odom_gf{sn, vn, fn}.track_fit{rn}(1:3, end);
        if norm(odom_end(1:2) - End_Point_List{sn}') < term_dist_thres
          err_odom_gf{sn, vn, fn}.valid_flg{rn} = true;
        else
          err_odom_gf{sn, vn, fn}.valid_flg{rn} = false;
        end
% err_odom_gf{sn, vn, fn}.valid_flg{rn} = true;
      end
    end
  end
  
  %% viz err distribution
  h = figure(1);
  clf
  for ii=1:2
    for mn=1:length(metric_type)
      %
      err_summ = [];
      for vn=1:length(Fwd_Vel_List)
        % plot baseline
        for fn = 1:length(Number_AF_List)
          switch metric_type{mn}
            case 'abs\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_baseline{sn, vn, fn}.abs_drift{rn};
                else
                  track_raw = err_odom_baseline{sn, vn, fn}.abs_drift{rn};
                end
                err_metric = summarizeMetricFromSeq(track_raw, ...
                  0, 1.0, 'rms');
                if err_odom_baseline{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'term\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_baseline{sn, vn, fn}.term_drift{rn};
                else
                  track_raw = err_odom_baseline{sn, vn, fn}.term_drift{rn};
                end
                err_metric = track_raw(1, 2);
                if err_odom_baseline{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'rel\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_baseline{sn, vn, fn}.rel_drift{rn};
                else
                  track_raw = err_odom_baseline{sn, vn, fn}.rel_drift{rn};
                end
                err_metric = summarizeMetricFromSeq(track_raw, ...
                  0, 1.0, 'rms');
                if err_odom_baseline{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'latency'
              err_all_rounds = [];
              for rn = 1 : round_num
                track_raw = log_orb_baseline{sn, vn, fn}.timeTotal{rn};
                %               err_metric = summarizeMetricFromSeq(err_raw, ...
                %                 0, 1.0, 'mean');
                err_all_rounds = [err_all_rounds; track_raw];
              end
          end
          %
          err_summ = [err_summ err_all_rounds];
        end
        
        % plot the gf
        for fn = 1:length(Number_GF_List)
          switch metric_type{mn}
            case 'abs\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_gf{sn, vn, fn}.abs_drift{rn};
                else
                  track_raw = err_odom_gf{sn, vn, fn}.abs_drift{rn};
                end
                err_metric = summarizeMetricFromSeq(track_raw, ...
                  0, 1.0, 'rms');
                if err_odom_gf{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'term\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_gf{sn, vn, fn}.term_drift{rn};
                else
                  track_raw = err_odom_gf{sn, vn, fn}.term_drift{rn};
                end
                err_metric = track_raw(1, 2);
                if err_odom_gf{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'rel\_drift'
              err_all_rounds = [];
              for rn = 1 : round_num
                if ii==1
                  track_raw = err_msf_gf{sn, vn, fn}.rel_drift{rn};
                else
                  track_raw = err_odom_gf{sn, vn, fn}.rel_drift{rn};
                end
                err_metric = summarizeMetricFromSeq(track_raw, ...
                  0, 1.0, 'rms');
                if err_odom_gf{sn, vn, fn}.valid_flg{rn} == true
                  err_all_rounds = [err_all_rounds; err_metric];
                else
                  err_all_rounds = [err_all_rounds; nan];
                end
              end
            case 'latency'
              err_all_rounds = [];
              for rn = 1 : round_num
                track_raw = log_orb_gf{sn, vn, fn}.timeTotal{rn};
                %               err_metric = summarizeMetricFromSeq(err_raw, ...
                %                 0, 1.0, 'mean');
                err_all_rounds = [err_all_rounds; track_raw];
              end
          end
          %
          err_summ = [err_summ err_all_rounds];
        end
      end
      
      %
      hs = subplot(2, length(metric_type), (ii-1)*length(metric_type) + mn);
%       boxplot(err_summ, legend_arr, 'Symbol', '')
      boxplot(err_summ, legend_arr)
      set(hs, 'TickLabelInterpreter', 'tex');
      %       set(gca,'TickLabelInterpreter', 'tex');
      title(metric_type{mn})
      ylim(y_range{mn})
      
      err_summ
      
    end
  end
  
  fname = ['Debug-BoxPlot-Scene-' Seq_Name_List{sn} '-IMU-' imu_type];
  suptitle(fname);
  set(h, 'Position', figure_size_1)
  
  export_fig(h, [save_path '/' fname '.fig']);
  export_fig(h, [save_path '/' fname '.png']);
   
   %% viz traj distribution
  h = figure(2);
  clf
  for ii=1:2
    for vn=1:length(Fwd_Vel_List)
      %
      subplot(2, length(Fwd_Vel_List), (ii-1)*length(Fwd_Vel_List) + vn)
      hold on
      % plot baseline
      for fn = 1:length(Number_AF_List)
        for rn = 1 : round_num
          if ii==1
            track_raw = err_msf_baseline{sn, vn, fn}.track_fit{rn};
          else
            track_raw = err_odom_baseline{sn, vn, fn}.track_fit{rn};
          end
          %
          if err_odom_baseline{sn, vn, fn}.valid_flg{rn} == true
            plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--.r');
          end
        end
        %
      end
      
      % plot the gf
      for fn = 1:length(Number_GF_List)
        for rn = 1 : round_num
          if ii==1
            track_raw = err_msf_gf{sn, vn, fn}.track_fit{rn};
          else
            track_raw = err_odom_gf{sn, vn, fn}.track_fit{rn};
          end
          %
          if err_odom_gf{sn, vn, fn}.valid_flg{rn} == true
            plot3(track_raw(1, :), track_raw(2, :), track_raw(3, :), '--g');
          end
        end
        %
      end
      
      %
      title(['Vel_{' num2str(Fwd_Vel_List(vn), '%.01f') '}'])
    end
  end
  
  fname = ['Debug-TrackPlot-Scene-' Seq_Name_List{sn} '-IMU-' imu_type];
  suptitle(fname);
  set(h, 'Position', figure_size_2)
  
  export_fig(h, [save_path '/' fname '.fig']);
  export_fig(h, [save_path '/' fname '.png']);
  
  close all
  
end

%%

