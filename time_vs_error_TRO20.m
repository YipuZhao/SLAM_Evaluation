clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');
% addpath('/mnt/DATA/SDK/DataDensity');

% set up parameters for each benchmark
benchMark = 'EuRoC_TRO20_Stereo' % 
% 'TUM_VI_TRO20_Stereo' % 'KITTI_TRO20_Stereo' % 
% 'EuRoC_TRO20_OnDevice_X200CA' % 'EuRoC_TRO20_OnDevice_Jetson' % 'EuRoC_TRO20_OnDevice_Euclid' % 
% 'EuRoC_TRO20_Mono' % 'TUM_RGBD_TRO20_Mono' % 'NUIM_TRO20_Mono' %
%
% 'EuRoC_TRO20_OnDevice_Odroid' % 'TUM_VI_TRO20_Mono' %
% 'EuRoC_MapHash_Mono'  'EuRoC_Propo_OnDevice_Euclid' %

setParam

% do_fair_comparison = false; % true; %
do_perc_plot = true; % false; %
plot_summary = true; % false; % 
scatter_buf = cell(length(metric_type), length(slam_path_list));
table_buf = cell(length(metric_type), length(slam_path_list));

opt_time_only = false; % true;

% round_num = 1;

for sn = 1:length(seq_list) % [1,5,10] %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref_cam0 = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 1, maxNormTrans);
  track_ref_imu0 = loadTrackTUM([ref_path '/' seq_idx '_imu0.txt'], 1, maxNormTrans);
  
  %% grab the baseline results
  for tn = 1:baseline_num
    if strcmp(pipeline_type{tn}, 'vins')
      track_ref = track_ref_imu0;
    else
      track_ref = track_ref_cam0;
    end
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
          %           if strcmp(sensor_type, 'stereo')
          %             % stereo config, no scale correction
          %             [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
          %               err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
          %               err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
          %               err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
          %               err_struct{gn, tn}.scale_fac(rn)] = ...
          %               getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          %               asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
          %               rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          %           else
          % mono config, with scale correction
          [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
            err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
            err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
            err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
            err_struct{gn, tn}.scale_fac(rn)] = ...
            getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          %           end
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
          %         elseif tn == 1
          %           [log_{gn, tn}] = loadLogTUM_old([slam_path_list{tn} baseline_slam_list{gn}], ...
          %             rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        elseif strcmp(sensor_type, 'mono') && tn == 3
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
  
  %% grab the subset results
  for tn=baseline_num+1:length(slam_path_list)
    if strcmp(pipeline_type{tn}, 'vins')
      track_ref = track_ref_imu0;
    else
      track_ref = track_ref_cam0;
    end
    for gn=1:length(gf_slam_list)
      %%
      log_{gn, tn} = [];
      for rn = 1:round_num
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
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
          %           if strcmp(sensor_type, 'stereo')
          %             % stereo config, no scale correction
          %             [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
          %               err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
          %               err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
          %               err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
          %               err_struct{gn, tn}.scale_fac(rn)] = ...
          %               getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          %               asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
          %               rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          %           else
          % mono config, with scale correction
          [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
            err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
            err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
            err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
            err_struct{gn, tn}.scale_fac(rn)] = ...
            getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          %           end
        end
        
        % Load Log Files
        %         if tn <= 1
        %         disp(['Loading ORB-SLAM log...'])
        if strcmp(sensor_type, 'stereo')
          [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        else
          [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        end
        
      end
    end
  end
  
  %% plot the curve per sequence
  for mn=1:length(metric_type)
    
    %% Plot mean error only for better viz
    if ~show_figure
      h(mn) = figure('visible', 'off');
    else
      h(mn) = figure();
    end
    clf
    hold on
    
    %% plot the baseline point
    for tn = 1:baseline_num
      base_mean = [];
      base_std = [];
      base_lower = [];
      base_upper = [];
      base_plot_idx = [];
      %
      time_mean = [];
      time_std = [];
      time_lower = [];
      time_upper = [];
      %
      for gn=1:length(baseline_slam_list)
        if isempty(err_struct{gn, tn})
          continue
        end
        
        %       if do_fair_comparison
        K_fair(gn) = sum(err_struct{gn, tn}.track_loss_rate < track_loss_ratio(1));
        %       end
        
        err_all_rounds = [];
        time_all_rounds = [];
        drop_plot = false;
        for rn=1:round_num
          switch metric_type{mn}
            case 'RMSE'
              err_raw = err_struct{gn, tn}.abs_drift{rn};
            case 'abs\_orient'
              err_raw = err_struct{gn, tn}.abs_orient{rn};
            case 'RPE3'
              err_raw = err_struct{gn, tn}.rel_drift{rn};
            case 'ROE3'
              err_raw = err_struct{gn, tn}.rel_orient{rn};
          end
          
          if strcmp(metric_type{mn}, 'TrackLossRate')
            err_metric = err_struct{gn, tn}.track_loss_rate(rn) * 100.0;
            %           if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
            %             err_metric = 1;
            %           else
            %             err_metric = 0;
            %           end
          elseif strcmp(metric_type{mn}, 'ScaleError')
            err_metric = abs(1 - err_struct{gn, tn}.scale_fac(rn)) * 100.0;
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
          end
          
          %         if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
          %           drop_plot = true;
          %         end
          
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            %           err_all_rounds = [err_all_rounds; NaN];
            %           time_all_rounds = [time_all_rounds; NaN];
          end
          
          if err_struct{gn, tn}.track_loss_rate(rn) < track_loss_ratio(1)
            % grab the mean time cost
            if opt_time_only
              time_raw = log_{gn, tn}.timeSelect{rn} + log_{gn, tn}.timeOpt{rn};
            else
              time_raw = log_{gn, tn}.timeTotal{rn};
            end
            %             time_all_rounds = [time_all_rounds; mean(time_raw)];
            % time_all_rounds = [time_all_rounds; prctile(time_raw, 80)];
            time_all_rounds = [time_all_rounds; time_raw];
          end
          
        end
        
        %       if do_fair_comparison
        %         % for fair comparison, only take the top-k results, where k is the
        %         % number of runs successed with baseline method
        %         err_all_rounds = mink(err_all_rounds,  K_fair(gn));
        %         err_all_rounds = [err_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        %         %
        %         time_all_rounds = mink(time_all_rounds,  K_fair(gn));
        %         time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        %       end
        
        %       if drop_plot == false
        % grab the mean error across all valid runs
        base_mean = [base_mean nanmean(err_all_rounds)];
        time_mean = [time_mean nanmean(time_all_rounds)];
        %
        base_std = [base_std nanstd(err_all_rounds)];
        time_std = [time_std nanstd(time_all_rounds)];
        %
        base_lower = [base_lower prctile(err_all_rounds, lower_prc)];
        time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
        %
        base_upper = [base_upper prctile(err_all_rounds, upper_prc)];
        time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
        %       end
        if round_num - K_fair(gn) < track_fail_thres
          base_plot_idx = [base_plot_idx gn];
        end
        % draw a point to the graph
        %       scatter(time_avg, err_avg, marker_styl{tn})
      end
      
      if do_perc_plot
        %       subplot(1,3,1)
        %       plot(time_avg, base_avg, marker_styl{tn})
        %       title('average')
        %       subplot(1,3,2)
        %       plot(time_avg, base_prc_5, marker_styl{tn})
        %       title('5%')
        %       subplot(1,3,3)
        %       plot(time_avg, base_prc_95, marker_styl{tn})
        %       title('95%')
        errorbar(time_mean(base_plot_idx), base_mean(base_plot_idx), ...
          base_mean(base_plot_idx) - base_lower(base_plot_idx), ...
          base_upper(base_plot_idx) - base_mean(base_plot_idx), ...
          marker_styl{tn}, 'color', marker_color{tn})
        
        if show_text
          for bi=1:length(base_plot_idx)
            text(time_mean(base_plot_idx(bi)), base_mean(base_plot_idx(bi)), ...
              num2str(baseline_number_list(base_plot_idx(bi))))
          end
        end
        
        %         title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean(base_plot_idx), base_mean(base_plot_idx), ...
          marker_styl{tn}, 'color', marker_color{tn})
        %         title('average')
      end
      
      scatter_buf{mn, tn} = [scatter_buf{mn, tn} ...
        [time_mean(base_plot_idx); base_mean(base_plot_idx); ...
        time_std(base_plot_idx); base_std(base_plot_idx)]];
      
      if exist('table_index')
        if ismember(table_index(tn), base_plot_idx)
          table_buf{mn, tn} = [table_buf{mn, tn} ...
            [time_mean(table_index(tn)); base_mean(table_index(tn)); ...
            time_std(table_index(tn)); base_std(table_index(tn))]];
        else
          table_buf{mn, tn} = [table_buf{mn, tn} ...
            [nan; nan; nan; nan]];
        end
      end
      
    end
    
    %% plot the subset points
    mod_base = length(baseline_taken_index);
    for tn=baseline_num+1:length(slam_path_list)
      %
      subset_mean = [];
      subset_std = [];
      subset_lower = [];
      subset_upper = [];
      subset_plot_idx = [];
      %
      time_mean = [];
      time_std = [];
      time_lower = [];
      time_upper = [];
      
      for gn=1:length(gf_slam_list)
        if isempty(err_struct{gn, tn})
          continue
        end
        
        K_fair(gn) = sum(err_struct{gn, tn}.track_loss_rate < track_loss_ratio(1));
        
        err_all_rounds = [];
        time_all_rounds = [];
        drop_plot = false;
        for rn=1:round_num
          switch metric_type{mn}
            case 'RMSE'
              err_raw = err_struct{gn, tn}.abs_drift{rn};
            case 'abs\_orient'
              err_raw = err_struct{gn, tn}.abs_orient{rn};
            case 'RPE3'
              err_raw = err_struct{gn, tn}.rel_drift{rn};
            case 'ROE3'
              err_raw = err_struct{gn, tn}.rel_orient{rn};
          end
          
          if strcmp(metric_type{mn}, 'TrackLossRate')
            err_metric = err_struct{gn, tn}.track_loss_rate(rn) * 100.0;
            %             if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
            %               err_metric = 1;
            %             else
            %               err_metric = 0;
            %             end
          elseif strcmp(metric_type{mn}, 'ScaleError')
            err_metric = abs(1 - err_struct{gn, tn}.scale_fac(rn)) * 100.0;
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
          end
          
          %           if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
          %             drop_plot = true;
          %           end
          
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            % err_all_rounds = [err_all_rounds; NaN];
          end
          
          if err_struct{gn, tn}.track_loss_rate(rn) < track_loss_ratio(1)
            % grab the mean time cost
            if opt_time_only
              time_raw = log_{gn, tn}.timeSelect{rn} + log_{gn, tn}.timeOpt{rn};
            else
              time_raw = log_{gn, tn}.timeTotal{rn};
            end
            %             time_all_rounds = [time_all_rounds; mean(time_raw)];
            % time_all_rounds = [time_all_rounds; prctile(time_raw, 80)];
            time_all_rounds = [time_all_rounds; time_raw];
          end
          
        end
        
        %         if do_fair_comparison
        %           % for fair comparison, only take the top-k results, where k is the
        %           % number of runs successed with baseline method
        %           err_all_rounds = mink(err_all_rounds,  ...
        %             K_fair( baseline_taken_index( mod(tn, mod_base)+1 ) ));
        %           err_all_rounds = [err_all_rounds; NaN(round_num - ...
        %             K_fair( baseline_taken_index( mod(tn, mod_base)+1 )), 1)];
        %           %           err_all_rounds = mink(err_all_rounds,  K_fair(gn));
        %           %           err_all_rounds = [err_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        %           %
        %           time_all_rounds = mink(time_all_rounds,  ...
        %             K_fair( baseline_taken_index( mod(tn, mod_base)+1 ) ));
        %           time_all_rounds = [time_all_rounds; NaN(round_num - ...
        %             K_fair( baseline_taken_index( mod(tn, mod_base)+1 )), 1)];
        %           %           time_all_rounds = mink(time_all_rounds,  K_fair(gn));
        %           %           time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        %         end
        
        %         if drop_plot == false
        % grab the mean error across all valid runs
        subset_mean = [subset_mean nanmean(err_all_rounds)];
        time_mean = [time_mean nanmean(time_all_rounds)];
        %
        subset_std = [subset_std nanstd(err_all_rounds)];
        time_std = [time_std nanstd(time_all_rounds)];
        %
        subset_lower = [subset_lower prctile(err_all_rounds, lower_prc)];
        time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
        %
        subset_upper = [subset_upper prctile(err_all_rounds, upper_prc)];
        time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
        %         end
        if round_num - K_fair(gn) < track_fail_thres
          subset_plot_idx = [subset_plot_idx gn];
        end
        % draw a point to the graph
        %       scatter(time_avg, err_avg, marker_styl{tn})
      end
      
      if do_perc_plot
        %         subplot(1,3,1)
        %         hold on
        %         %       plot(time_avg, err_avg, marker_styl{tn})
        %         plot(time_avg, subset_avg, marker_styl{floor((tn-2)/(mod_base)) + 2})
        %         title('average')
        %         subplot(1,3,2)
        %         hold on
        %         %       plot(time_prc_25, err_prc_25, marker_styl{tn})
        %         plot(time_avg, subset_prc_5, marker_styl{floor((tn-2)/(mod_base)) + 2})
        %         title('5%')
        %         subplot(1,3,3)
        %         hold on
        %         %       plot(time_prc_75, err_prc_75, marker_styl{tn})
        %         plot(time_avg, subset_prc_95, marker_styl{floor((tn-2)/(mod_base)) + 2})
        %         title('95%')
        errorbar(time_mean(subset_plot_idx), subset_mean(subset_plot_idx), ...
          subset_mean(subset_plot_idx) - subset_lower(subset_plot_idx), ...
          subset_upper(subset_plot_idx) - subset_mean(subset_plot_idx), ...
          marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1}, ...
          'color', marker_color{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1})
        
        if show_text
          for bi=1:length(subset_plot_idx)
            text(time_mean(subset_plot_idx(bi)), subset_mean(subset_plot_idx(bi)), ...
              num2str(lmk_number_list(subset_plot_idx(bi))))
          end
        end
        
        %         title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean(subset_plot_idx), subset_mean(subset_plot_idx), ...
          marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1}, ...
          'color', marker_color{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1})
        %         title('average')
      end
      
      scatter_buf{mn, tn} = [scatter_buf{mn, tn} ...
        [time_mean(subset_plot_idx); subset_mean(subset_plot_idx); ...
        time_std(subset_plot_idx); subset_std(subset_plot_idx)]];
      
      if exist('table_index')
        if ismember(table_index(tn), subset_plot_idx)
          table_buf{mn, tn} = [table_buf{mn, tn} ...
            [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
            time_std(table_index(tn)); subset_std(table_index(tn))]];
        else
          table_buf{mn, tn} = [table_buf{mn, tn} ...
            [nan; nan; nan; nan]];
        end
      end
      
    end
    
    
    %% plot additional markers for VINS results
    if exist('method_VINS') && strcmp(metric_type{mn}, 'RMSE')
      %
      %       scatter_syl = marker_styl{tn};
      %       scatter_syl = scatter_syl(length(scatter_syl)-1:end);
      %       hold on
      for vn=1:length(method_VINS)
        s = scatter(time_VINS(sn, vn), RMSE_VINS(sn, vn), ...
          marker_styl{baseline_num + 1 + vn});
        colorSc(vn, :) = get(s, 'CData');
      end
    end
    
    
    %% add legend and other stuff
    if exist('method_VINS') && strcmp(metric_type{mn}, 'RMSE')
      %
      legend_style = gobjects(length(legend_arr) + length(method_VINS),1);
      for i=1:length(legend_arr)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', marker_color{i});
      end
      for i=length(legend_arr)+1:length(legend_arr)+length(method_VINS)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', colorSc(i-length(legend_arr), :));
      end
      tmp_arr = [legend_arr; method_VINS];
      lgd = legend(legend_style([2:3,1,4:end]), tmp_arr{[2:3,1,4:end]}, ...
        'Location', 'best');
      lgd.FontSize = font_size;
    else
      %
      legend_style = gobjects(length(legend_arr),1);
      for i=1:length(legend_arr)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', marker_color{i});
      end
      %
      %     legend(legend_style, legend_arr, 'Location', 'best')
      if strcmp(sensor_type, 'stereo')
        lgd = legend(legend_style([3:5,1:2,6:end]), legend_arr{[3:5,1:2,6:end]}, ...
          'Location', 'best');
        lgd.FontSize = font_size;
      else
        %         legend(legend_style([2:5,1,6:end]), legend_arr{[2:5,1,6:end]}, 'Location', 'best')
        %         lgd = legend(legend_style([2:3,1,4:end]), legend_arr{[2:3,1,4:end]}, ...
        %           'Location', 'best');
        
        lgd = legend(legend_style, legend_arr, ...
          'Location', 'best');
        
        lgd.FontSize = font_size;
      end
    end
    
    legend boxoff
    xlabel('Average Tracking Latency (ms)', 'FontSize', font_size)
    %     xlabel('Tracking Time per Frame (ms)', 'FontSize', font_size)
    %     ylabel(metric_type{mn})
    switch metric_type{mn}
      case 'TrackLossRate'
        %       ylim([0 100])
        %         set(gca, 'YScale', 'log')
        ylabel('Un-Tracked Frame (%)', 'FontSize', font_size)
      case 'RMSE'
        %             ylim([0.02 0.24])
        set(gca, 'YScale', 'log')
        ylabel('RMSE (m)', 'FontSize', font_size)
      case 'abs\_orient'
        %
      case 'RPE3'
        %         ylim([0.005 0.05])
        set(gca, 'YScale', 'log')
        ylabel('RPE (m/s)', 'FontSize', font_size)
      case 'ROE3'
        %         ylim([0.05 0.5])
        set(gca, 'YScale', 'log')
        ylabel('ROE (deg/s)', 'FontSize', font_size)
      case 'ScaleError'
        ylabel('Scale Error (%)', 'FontSize', font_size)
    end
    
    set(h(mn), 'Position', figure_size)
    %     set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    if opt_time_only
      export_fig(h(mn), [save_path '/Debug_OptTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    else
      %       export_fig(h(mn), [save_path '/Mono_Latency_' metric_type{mn} '_' seq_idx '.png']);
      %       export_fig(h(mn), [save_path '/Mono_Latency_' metric_type{mn} '_' seq_idx '.fig']);
      %       export_fig(h(mn), [save_path '/Device_Euclid_Latency_' metric_type{mn} '_' seq_idx '.png']);
      %       export_fig(h(mn), [save_path '/Device_Euclid_Latency_' metric_type{mn} '_' seq_idx '.fig']);
      % export_fig(h(mn), [save_path '/Device_Jetson_Latency_' metric_type{mn} '_' seq_idx '.png']);
      % export_fig(h(mn), [save_path '/Device_Jetson_Latency_' metric_type{mn} '_' seq_idx '.fig']);
      %       export_fig(h(mn), [save_path '/Device_X200CA_Latency_' metric_type{mn} '_' seq_idx '.png']);
      %       export_fig(h(mn), [save_path '/Device_X200CA_Latency_' metric_type{mn} '_' seq_idx '.fig']);
      %       export_fig(h(mn), [save_path '/Device_Odroid_Latency_' metric_type{mn} '_' seq_idx '.png']);
      export_fig(h(mn), [save_path '/Stereo_Latency_' metric_type{mn} '_' seq_idx '.fig']);
      export_fig(h(mn), [save_path '/Stereo_Latency_' metric_type{mn} '_' seq_idx '.png']);
    end
  end
  
  %% plot the track at an example run
  figure;
  clf
  plot3(track_ref(:,2), track_ref(:,3), track_ref(:,4), '-y')
  %   plot(track_ref(:,2), track_ref(:,4), '-b')
  hold on
  %   gn = 2;
  valid_idx = [];
  for i=1:length(slam_path_list)
    if ~isempty(err_struct{table_index(i),i}.track_fit{1})
      plot3(err_struct{table_index(i),i}.track_fit{1}(1, :), ...
        err_struct{table_index(i),i}.track_fit{1}(2, :), ...
        err_struct{table_index(i),i}.track_fit{1}(3, :), ...
        '--.', 'Color', marker_color{i})
      %     plot(err_struct{1,i}.track_fit{1}(1, :), err_struct{1,i}.track_fit{1}(3, :), '--.')
      valid_idx = [valid_idx, i];
    end
  end
  view(0,0)
  %   axis equal
  legend([{'GT'}; legend_arr(valid_idx)])
  %   export_fig(gcf, [save_path '/Track3D_' seq_idx '.fig']);
  %   export_fig(gcf, [save_path '/Track3D_' seq_idx '.png']);  close all
  
  close all
  clear err_struct log_
  
end

%% order to print out summary 
% for stereo
slam_mtd_order = [3, 1:2, 6:8, 4:5];
% for mono
% slam_mtd_order = [2, 3, 1, 4:6];

if plot_summary
    close all
    for mn=1:length(metric_type)
      figure;
      hold on
      for tn=slam_mtd_order
        scatter_syl = marker_styl{tn};
        scatter_syl = scatter_syl(length(scatter_syl):end);
        scatter(scatter_buf{mn,tn}(1,:), scatter_buf{mn,tn}(2,:), ...
          scatter_syl, 'MarkerEdgeColor', marker_color{tn});
        j = boundary(scatter_buf{mn,tn}(1,:)', scatter_buf{mn,tn}(2,:)', 0.5);
        plot(scatter_buf{mn,tn}(1,j), scatter_buf{mn,tn}(2,j), [':' scatter_syl], ...
          'color', marker_color{tn});
      end
      %
%       for tn=4
%         scatter_syl = marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1};
%         scatter_syl = scatter_syl(length(scatter_syl):end);
%         scatter(scatter_buf{mn,tn}(1,:), scatter_buf{mn,tn}(2,:), ...
%           scatter_syl, 'MarkerEdgeColor', marker_color{tn});
%         j = boundary(scatter_buf{mn,tn}(1,:)', scatter_buf{mn,tn}(2,:)', 0.5);
%         plot(scatter_buf{mn,tn}(1,j), scatter_buf{mn,tn}(2,j), [':' scatter_syl], ...
%           'color', marker_color{tn});
%       end
      %
      legend_style = gobjects(length(legend_arr),1);
      for i=1:length(legend_arr)
        scatter_syl = marker_styl{i};
        scatter_syl = scatter_syl(length(scatter_syl):end);
        legend_style(i) = plot(nan, nan, scatter_syl, 'color', marker_color{i});
      end
      %     legend(legend_style([3:4, 1:2, 5:6]), legend_arr{[3:4, 1:2, 5:6]}, 'Location', 'best')
      legend(legend_style(slam_mtd_order), legend_arr{slam_mtd_order}, 'Location', 'best')
      %     legend(legend_style([2,3,1,6]), legend_arr{[2,3,1,6]}, 'Location', 'best')
      %     legend(legend_style([3,1,2,6]), legend_arr{[3,1,2,6]}, 'Location', 'best')
      %
      xlabel('Tracking Time per Frame (ms)')
      %   ylabel(metric_type{mn})
      switch metric_type{mn}
        case 'TrackLossRate'
          %       ylim([0 100])
          %         set(gca, 'YScale', 'log')
          ylabel('Un-Tracked Frame (%)')
        case 'RMSE'
          %             ylim([0.02 0.24])
          set(gca, 'YScale', 'log')
          ylabel('RMSE (m)')
        case 'abs\_orient'
          %
        case 'RPE3'
          %         ylim([0.005 0.05])
          set(gca, 'YScale', 'log')
          ylabel('RPE3 (m/s)')
        case 'ROE3'
          %         ylim([0.05 0.5])
          set(gca, 'YScale', 'log')
          ylabel('ROE (deg/s)')
      end
    end
  
%   mtd_VINS = {'svomsf'; 'msckf'; 'okvis'; 'rovio'; 'vinsmono'; 'svogtsam'};
%   
%   RMSE_VINS = [
%     0.14 0.42 0.16 0.21 0.27 0.05
%     0.20 0.45 0.22 0.25 0.12 0.03
%     0.48 0.23 0.24 0.25 0.13 0.12
%     1.38 0.37 0.34 0.49 0.23 0.13
%     0.51 0.48 0.47 0.52 0.35 0.16
%     0.40 0.34 0.09 0.10 0.07 0.07
%     0.63 0.20 0.20 0.10 0.10 0.11
%     nan 0.67 0.24 0.14 0.13 nan
%     0.20 0.10 0.13 0.12 0.08 0.07
%     0.37 0.16 0.16 0.14 0.08 nan
%     nan 1.13 0.29 0.14 0.21 nan
%     ];
%   
%   time_VINS = [
%     10.12 23.286343474729243 34.45716357557306 23.161929366972476 63.54280540054348 31.66453847816673;
%     9.920849166891589 22.658193540204355 34.19164716923077 23.13870004197531 61.07770836537196 32.193929095513106;
%     10.538878176812892 11.728531555213374 32.49234006077587 22.80714456904541 71.325129869533 62.919931751544574
%     9.748879009964414 22.02041862405063 26.94485186793612 22.790130780653115 63.11419262795276 25.552754641366224
%     9.58671661646926 22.157435284468665 29.633627712292004 22.702577067217632 60.13781228634362 17.015873227668845
%     8.793656197074954 23.247456882651214 25.772469131934564 20.864116554600173 64.48724021374571 43.09663759905831
%     8.954884050290136 21.973954 19.82569783580247 21.652605348717948 56.21554189344263 76.32892773809525
%     nan 21.243677938609846 17.265912877166915 20.56323701805475 44.3186230689013 nan
%     8.456355065132223 23.957648742042753 24.185243483826877 21.027745728869373 57.70985057243197 23.028449354226023
%     8.736827900592795 23.52646850516854 22.99945402058695 21.825285956313266 51.80080331031544 nan
%     nan 21.485682449552236 13.26667232305999 21.415750553970224 44.33911163067695 nan
%     ];
%   
%   VINS_color = {
%     [1 0.84 0];
%     [0.184 0.078 0.635];
%     [0 0 0];
%     [1 0 0];
%     [0 1 0];
%     [0.9 0.7 0.3];
%     };
%   
%   close all
%   for mn=1:length(metric_type)
%     figure;
%     hold on
%     for tn=1:3
%       scatter_syl = marker_styl{tn};
%       scatter_syl = scatter_syl(length(scatter_syl):end);
%       scatter(scatter_buf{mn,tn}(1,:), scatter_buf{mn,tn}(2,:), ...
%         scatter_syl, 'MarkerEdgeColor', marker_color{tn});
%       j = boundary(scatter_buf{mn,tn}(1,:)', scatter_buf{mn,tn}(2,:)', 0.5);
%       plot(scatter_buf{mn,tn}(1,j), scatter_buf{mn,tn}(2,j), [':' scatter_syl], ...
%         'color', marker_color{tn});
%     end
%     for tn=1:length(mtd_VINS)
%       vld_x = time_VINS(~isnan(time_VINS(:,tn)), tn);
%       vld_y = RMSE_VINS(~isnan(RMSE_VINS(:,tn)), tn);
%       scatter(vld_x, vld_y, ...
%         'x', 'MarkerEdgeColor', VINS_color{tn});
%       j = boundary(vld_x, vld_y, 0.5);
%       plot(vld_x(j), vld_y(j), ':', 'color', VINS_color{tn});
%     end
%     %
%     legend_style = gobjects(3+length(mtd_VINS),1);
%     for i=1:3
%       scatter_syl = marker_styl{i};
%       scatter_syl = scatter_syl(length(scatter_syl):end);
%       legend_style(i) = plot(nan, nan, scatter_syl, 'color', marker_color{i});
%     end
%     for i=1:length(mtd_VINS)
%       scatter_syl = 'x';
%       legend_style(3+i) = plot(nan, nan, scatter_syl, 'color', VINS_color{i});
%     end
%     %     legend(legend_style([3:4, 1:2, 5:6]), legend_arr{[3:4, 1:2, 5:6]}, 'Location', 'best')
%     %     legend(legend_style([2,3,1]), legend_arr{[2,3,1]}, 'Location', 'best')
%     %     legend(legend_style([2,3,1,6]), legend_arr{[2,3,1,6]}, 'Location', 'best')
%     %     legend(legend_style([3,1,2,6]), legend_arr{[3,1,2,6]}, 'Location', 'best')
%     legend(legend_style, {'ORB'; 'SVO2'; 'DSO'; 'svomsf'; 'msckf'; 'okvis'; 'rovio'; 'vinsmono'; 'svogtsam'}, 'Location', 'best')
%     %
%     xlabel('Average Tracking Latency (ms)')
%     %     xlabel('Tracking Time per Frame (ms)')
%     %   ylabel(metric_type{mn})
%     switch metric_type{mn}
%       case 'TrackLossRate'
%         %       ylim([0 100])
%         %         set(gca, 'YScale', 'log')
%         ylabel('Un-Tracked Frame (%)')
%       case 'RMSE'
%         %             ylim([0.02 0.24])
%         set(gca, 'YScale', 'log')
%         ylabel('RMSE (m)')
%       case 'abs\_orient'
%         %
%       case 'RPE3'
%         %         ylim([0.005 0.05])
%         set(gca, 'YScale', 'log')
%         ylabel('RPE (m/s)')
%       case 'ROE3'
%         %         ylim([0.05 0.5])
%         set(gca, 'YScale', 'log')
%         ylabel('ROE (deg/s)')
%     end
%   end
  
end

%% print out latex table
for i=1:length(metric_type)
  disp(['==================' metric_type{i} '=================='])
  avg_buf = cell(length(slam_path_list), 1);
  for k=1:length(seq_list)
    for j=1:length(slam_mtd_order)
      %     [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
      %       time_std(table_index(tn)); subset_std(table_index(tn))]];
      if j == length(slam_mtd_order)
        fprintf(' %.3f \\\\ \n', round( table_buf{i, slam_mtd_order(j)}(2, k), 4) )
      else
        fprintf(' %.3f &', round( table_buf{i, slam_mtd_order(j)}(2, k), 4) )
      end
      %       if j == length(slam_mtd_order)
      %         fprintf(' %.3f, %.3f \\\\ \n', round( table_buf{i, slam_mtd_order(j)}(2, k), 4), ...
      %           round( table_buf{i, slam_mtd_order(j)}(4, k), 4) )
      %       else
      %         fprintf(' %.3f, %.3f &', round( table_buf{i, slam_mtd_order(j)}(2, k), 4), ...
      %           round( table_buf{i, slam_mtd_order(j)}(4, k), 4) )
      %       end
      %
      avg_buf{j} = [avg_buf{j} table_buf{i, slam_mtd_order(j)}(2, k)];
    end
  end
  % average
  disp(['average:'])
  for j=1:length(slam_path_list)
    if j == length(slam_path_list)
      fprintf(' %.3f \\\\ \n', round( nanmean( avg_buf{j}), 4) )
    else
      fprintf(' %.3f &', round( nanmean( avg_buf{j}), 4) )
    end
  end
  %   % std
  %   disp(['std:'])
  %   for j=1:length(slam_path_list)
  %     if j == length(slam_path_list)
  %       fprintf(' %.3f \\\\ \n', round( nanstd( avg_buf{j}), 4) )
  %     else
  %       fprintf(' %.3f &', round( nanstd( avg_buf{j}), 4) )
  %     end
  %   end
  %   % min
  %   disp(['min:'])
  %   for j=1:length(slam_path_list)
  %     if j == length(slam_path_list)
  %       fprintf(' %.3f \\\\ \n', round( nanmin( avg_buf{j}), 4) )
  %     else
  %       fprintf(' %.3f &', round( nanmin( avg_buf{j}), 4) )
  %     end
  %   end
  %   % max
  %   disp(['max:'])
  %   for j=1:length(slam_path_list)
  %     if j == length(slam_path_list)
  %       fprintf(' %.3f \\\\ \n', round( nanmax( avg_buf{j}), 4) )
  %     else
  %       fprintf(' %.3f &', round( nanmax( avg_buf{j}), 4) )
  %     end
  %   end
end

% disp(['==================Time Cost=================='])
% avg_buf = cell(length(slam_path_list), 1);
% for k=1:length(seq_list)
%   for j=1:length(slam_mtd_order)
%     %     [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
%     %       time_std(table_index(tn)); subset_std(table_index(tn))]];
%     if j == length(slam_mtd_order)
%       fprintf(' %.1f \\\\ \n', round( table_buf{1, slam_mtd_order(j)}(1, k), 4) )
%     else
%       fprintf(' %.1f &', round( table_buf{1, slam_mtd_order(j)}(1, k), 4) )
%     end
%     %
%     avg_buf{j} = [avg_buf{j} table_buf{1, slam_mtd_order(j)}(1, k)];
%   end
% end
% % average
% disp(['average:'])
% for j=1:length(slam_path_list)
%   if j == length(slam_path_list)
%     fprintf(' %.3f \\\\ \n', round( nanmean( avg_buf{j}), 4) )
%   else
%     fprintf(' %.3f &', round( nanmean( avg_buf{j}), 4) )
%   end
% end
% % std
% disp(['std:'])
% for j=1:length(slam_path_list)
%   if j == length(slam_path_list)
%     fprintf(' %.3f \\\\ \n', round( nanstd( avg_buf{j}), 4) )
%   else
%     fprintf(' %.3f &', round( nanstd( avg_buf{j}), 4) )
%   end
% end
% % min
% disp(['min:'])
% for j=1:length(slam_path_list)
%   if j == length(slam_path_list)
%     fprintf(' %.3f \\\\ \n', round( nanmin( avg_buf{j}), 4) )
%   else
%     fprintf(' %.3f &', round( nanmin( avg_buf{j}), 4) )
%   end
% end
% % max
% disp(['max:'])
% for j=1:length(slam_path_list)
%   if j == length(slam_path_list)
%     fprintf(' %.3f \\\\ \n', round( nanmax( avg_buf{j}), 4) )
%   else
%     fprintf(' %.3f &', round( nanmax( avg_buf{j}), 4) )
%   end
% end

disp 'finish!'
