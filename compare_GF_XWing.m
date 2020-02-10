clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');
% addpath('/mnt/DATA/SDK/DataDensity');

% set up parameters for each benchmark
benchMark = 'XWing_RAL19_Desktop'
%

setParam

rel_interval_list = [30]; % [10]; % [3]; %
% round_num = 2;

% do_fair_comparison = false; % true; %
do_perc_plot = true; % false; %
plot_summary = true; % false; %
scatter_buf = cell(length(metric_type), length(slam_path_list));
table_buf = cell(length(metric_type), length(slam_path_list));

% simply ignore any config with failure runs
track_fail_thres = 1; % 2; %

opt_time_only = false; % true;

for sn = 1:length(seq_list) % [1, 4, 10] %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref = loadTrackTUM_with_Twist([ref_path '/' seq_idx '_cam0_with_twist.txt'], ...
    1, maxNormTrans);
  
  %% grab the baseline results
  for tn = 1:baseline_num
    %     if strcmp(pipeline_type{tn}, 'vins')
    %       track_ref = track_ref_imu0;
    %     else
    %       track_ref = track_ref_cam0;
    %     end
    for gn=1:length(baseline_slam_list)
      %%
      log_{gn, tn} = [];
      for rn = 1:round_num
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} baseline_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        
        % Compute evaluation metrics
        if isempty(track{tn}) || isempty(track_ref)
          err_struct{gn, tn}.scale_fac(rn) = 1.0;
          err_struct{gn, tn}.abs_drift{rn} = [];
          err_struct{gn, tn}.abs_orient{rn} = [];
          err_struct{gn, tn}.term_drift{rn} = [];
          err_struct{gn, tn}.term_orient{rn} = [];
          err_struct{gn, tn}.rel_drift{rn} = [];
          err_struct{gn, tn}.rel_orient{rn} = [];
          err_struct{gn, tn}.track_loss_rate(rn) = 1.0;
          err_struct{gn, tn}.track_fit{rn} = [];
        else
          if strcmp(sensor_type, 'stereo')
            % stereo config, no scale correction
            [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
              err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
              err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
              err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
              err_struct{gn, tn}.scale_fac(rn)] = ...
              getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          else
            % mono config, with scale correction
            [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
              err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
              err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
              err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
              err_struct{gn, tn}.scale_fac(rn)] = ...
              getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          end
        end
        
        % Load Log Files
        if tn <= baseline_orb
          %           disp(['Loading ORB-SLAM log...'])
          if strcmp(sensor_type, 'stereo')
            [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} baseline_slam_list{gn}], ...
              rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
          else
            [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn} baseline_slam_list{gn}], ...
              rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
          end
        elseif strcmp(sensor_type, 'mono') && tn == 4
          %           disp(['Loading DSO log...'])
          [log_{gn, tn}] = loadLogDSO([slam_path_list{tn} baseline_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        else
          %           disp(['Loading SVO log...'])
          [log_{gn, tn}] = loadLogSVO([slam_path_list{tn} baseline_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        end
      end
    end
  end
  
  %% plot the track at an example run
  viz_indx = [1, 2, 3];
  
  h(1)=figure;
  hold on
  plot3(track_ref(:,2), track_ref(:,3), track_ref(:,4), '-')
  hold on
  for tn=1:baseline_num
    plot3(err_struct{1, tn}.track_fit{viz_indx(tn)}(1, :), ...
      err_struct{1, tn}.track_fit{viz_indx(tn)}(2, :), ...
      err_struct{1, tn}.track_fit{viz_indx(tn)}(3, :), '--.')
    %   plot3(err_struct{1}.track_fit{2}(1, :), err_struct{1}.track_fit{2}(2, :), err_struct{1}.track_fit{2}(3, :), '--*c')
  end
  axis equal
  xlabel('E')
  ylabel('N')
  legend({'Ground Truth'; 'ORB-SLAM'; 'Hash-SLAM'; 'HashX-SLAM'})
  
  %%
  h(2)=figure;
  subplot(2,1,1)
  speed_linear_vec = vecnorm(track_ref(:, [9:11])');
  plot(track_ref(:, 1), speed_linear_vec', '-');
  hold on
  for tn=1:baseline_num
    plot(err_struct{1, tn}.rel_drift{viz_indx(tn)}(:,1), err_struct{1, tn}.rel_drift{viz_indx(tn)}(:,2), '--.');
  end
  xlim([err_struct{1}.rel_drift{viz_indx(1)}(1, 1) err_struct{1}.rel_drift{viz_indx(1)}(end, 1)])
  xlabel('sec')
  ylabel('m/s')
  legend({'Linear Velocity';
    'Relative Pose Error of ORB-SLAM';
    'Relative Pose Error of Hash-SLAM';
    'Relative Pose Error of HashX-SLAM'})
  %
  subplot(2,1,2)
  hold on
  for tn=1:baseline_num
    asso_err_2_ref  = associate_track(err_struct{1, tn}.rel_drift{viz_indx(tn)}, ...
      track_ref, 1, max_asso_val);
    plot(err_struct{1, tn}.rel_drift{viz_indx(tn)}(:,1), ...
      err_struct{1, tn}.rel_drift{viz_indx(tn)}(:,2) ./ ...
      speed_linear_vec(asso_err_2_ref)' * 100, '--.');
  end
  xlim([err_struct{1}.rel_drift{viz_indx(1)}(1, 1) err_struct{1}.rel_drift{viz_indx(1)}(end, 1)])
  ylim([0 150])
  xlabel('sec')
  ylabel('%')
  legend({'Relative Pose Error of ORB-SLAM / Linear Velocity (%)';
    'Relative Pose Error of Hash-SLAM / Linear Velocity (%)';
    'Relative Pose Error of HashX-SLAM / Linear Velocity (%)'})
  
  %%
  h(3)=figure;
  subplot(2,1,1)
  speed_angular_vec = vecnorm(track_ref(:, [12:14])');
  plot(track_ref(:, 1), speed_angular_vec', '-');
  hold on
  for tn=1:baseline_num
    plot(err_struct{1, tn}.rel_orient{viz_indx(tn)}(:,1), err_struct{1, tn}.rel_orient{viz_indx(tn)}(:,2), '--.');
  end
  xlim([err_struct{1}.rel_orient{viz_indx(1)}(1, 1) err_struct{1}.rel_orient{viz_indx(1)}(end, 1)])
  xlabel('sec')
  ylabel('deg/s')
  legend({'Angular Velocity';
    'Relative Orientation Error of ORB-SLAM';
    'Relative Orientation Error of Hash-SLAM';
    'Relative Orientation Error of HashX-SLAM'})
  %
  subplot(2,1,2)
  hold on
  for tn=1:baseline_num
    asso_err_2_ref  = associate_track(err_struct{1, tn}.rel_drift{viz_indx(tn)}, ...
      track_ref, 1, max_asso_val);
    plot(err_struct{1, tn}.rel_orient{viz_indx(tn)}(:,1), ...
      err_struct{1, tn}.rel_orient{viz_indx(tn)}(:,2) ./ ...
      speed_angular_vec(asso_err_2_ref)' * 100, '--.');
  end
  xlim([err_struct{1}.rel_orient{viz_indx(1)}(1, 1) err_struct{1}.rel_orient{viz_indx(1)}(end, 1)])
  ylim([0 300])
  xlabel('sec')
  ylabel('%')
  legend({'Relative Orientation Error of ORB-SLAM / Angular Velocity (%)';
    'Relative Orientation Error of Hash-SLAM / Angular Velocity (%)';
    'Relative Orientation Error of HashX-SLAM / Angular Velocity (%)'})
  
  %%
%   export_fig(h(1), [save_path '/Track_ORB_site_1.png']);
%   export_fig(h(1), [save_path '/Track_ORB_site_1.fig']);
%   %
%   export_fig(h(2), [save_path '/RPE_ORB_site_1.png']);
%   export_fig(h(2), [save_path '/RPE_ORB_site_1.fig']);
%   %
%   export_fig(h(3), [save_path '/ROE_ORB_site_1.png']);
%   export_fig(h(3), [save_path '/ROE_ORB_site_1.fig']);
  
  export_fig(h(1), [save_path '/Track_ORB_site_2.png']);
  export_fig(h(1), [save_path '/Track_ORB_site_2.fig']);
  %
  export_fig(h(2), [save_path '/RPE_ORB_site_2.png']);
  export_fig(h(2), [save_path '/RPE_ORB_site_2.fig']);
  %
  export_fig(h(3), [save_path '/ROE_ORB_site_2.png']);
  export_fig(h(3), [save_path '/ROE_ORB_site_2.fig']);
  
  close all
  
  clear err_struct log_
  
end