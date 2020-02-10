clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');
% addpath('/mnt/DATA/SDK/DataDensity');

% set up parameters for each benchmark
benchMark = 'NewCollege_ICRA19_Desktop' % 'EuRoC_ICRA19_Desktop' %  

setParam

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
  track_ref_cam = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 1, maxNormTrans);
  track_ref_imu = loadTrackTUM([ref_path '/' seq_idx '_imu0.txt'], 1, maxNormTrans);
  
  %% grab the baseline results
  for tn = 1:baseline_num
    if strcmp(pipeline_type{tn}, 'vins')
      track_ref = track_ref_imu;
    else
      track_ref = track_ref_cam;
    end
    for gn=1:length(baseline_slam_list)
      %%
      log_{gn, tn} = [];
      for rn = 1:round_num
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} baseline_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val, step_def);
        
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
              getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
            
            % for slow mo only
            %             [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
            %               err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
            %               err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
            %               err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
            %               err_struct{gn, tn}.scale_fac(rn)] = ...
            %               getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            %               asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            %               rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
            
          else
            % mono config, with scale correction
            [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
              err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
              err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
              err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
              err_struct{gn, tn}.scale_fac(rn)] = ...
              getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          end
        end
        
        % Load Log Files
        if tn <= baseline_orb
          disp(['Loading ORB-SLAM log...'])
          if strcmp(sensor_type, 'stereo')
            [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} baseline_slam_list{gn}], ...
              rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
          else
            [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn} baseline_slam_list{gn}], ...
              rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
            %             [log_{gn, tn}] = loadLogTUM_hash([slam_path_list{tn} baseline_slam_list{gn}], ...
            %               rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
          end
        elseif strcmp(sensor_type, 'mono') && tn == 2
          disp(['Loading DSO log...'])
          [log_{gn, tn}] = loadLogDSO([slam_path_list{tn} baseline_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        else
          disp(['Loading SVO log...'])
          [log_{gn, tn}] = loadLogSVO([slam_path_list{tn} baseline_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        end
      end
    end
  end
  
  %% grab the subset results
  for tn=baseline_num+1:length(slam_path_list)
    if strcmp(pipeline_type{tn}, 'vins')
      track_ref = track_ref_imu;
    else
      track_ref = track_ref_cam;
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
          if strcmp(sensor_type, 'stereo')
            % stereo config, no scale correction
            [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
              err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
              err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
              err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
              err_struct{gn, tn}.scale_fac(rn)] = ...
              getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          else
            % mono config, with scale correction
            [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
              err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
              err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
              err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}, ...
              err_struct{gn, tn}.scale_fac(rn)] = ...
              getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
              asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
              rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
          end
        end
        
        % Load Log Files
        %         if tn <= 1
        disp(['Loading Proposed Method log...'])
        if strcmp(sensor_type, 'stereo')
          [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        else
          %           [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn} gf_slam_list{gn}], ...
          %             rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
          [log_{gn, tn}] = loadLogTUM_hash_mono([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        end
        
      end
    end
  end
  
  %% plot the curve per sequence
  for mn=1:length(metric_type)
    
    %% Plot mean error only for better viz
    h(mn) = figure(mn);
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
        
        %         errorbar(time_mean(base_plot_idx), base_mean(base_plot_idx), ...
        %           base_mean(base_plot_idx) - base_lower(base_plot_idx), ...
        %           base_upper(base_plot_idx) - base_mean(base_plot_idx), ...
        %           marker_styl{tn}, 'color', marker_color{tn})
        
        
        errorbar(time_upper(base_plot_idx), base_mean(base_plot_idx), ...
          base_mean(base_plot_idx) - base_lower(base_plot_idx), ...
          base_upper(base_plot_idx) - base_mean(base_plot_idx), ...
          marker_styl{tn}, 'color', marker_color{tn})
        
        
        %         text(time_mean(base_plot_idx) + 2, base_mean(base_plot_idx), baseline_slam_list(base_plot_idx))
        
        title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean(base_plot_idx), base_mean(base_plot_idx), ...
          marker_styl{tn}, 'color', marker_color{tn})
        title('average')
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
        
        %         errorbar(time_mean(subset_plot_idx), subset_mean(subset_plot_idx), ...
        %           subset_mean(subset_plot_idx) - subset_lower(subset_plot_idx), ...
        %           subset_upper(subset_plot_idx) - subset_mean(subset_plot_idx), ...
        %           marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1}, ...
        %           'color', marker_color{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1})
        
        errorbar(time_upper(subset_plot_idx), subset_mean(subset_plot_idx), ...
          subset_mean(subset_plot_idx) - subset_lower(subset_plot_idx), ...
          subset_upper(subset_plot_idx) - subset_mean(subset_plot_idx), ...
          marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1}, ...
          'color', marker_color{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1})
        
        %         text(time_mean(subset_plot_idx) + 2, subset_mean(subset_plot_idx), gf_slam_list(subset_plot_idx))
        
        title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean(subset_plot_idx), subset_mean(subset_plot_idx), ...
          marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1}, ...
          'color', marker_color{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1})
        title('average')
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
          marker_styl{4 + vn});
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
      legend(legend_style([2:3,1,4:end]), tmp_arr{[2:3,1,4:end]}, 'Location', 'best')
    else
      %
      legend_style = gobjects(length(legend_arr),1);
      for i=1:length(legend_arr)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', marker_color{i});
      end
      %
      legend(legend_style, legend_arr, 'Location', 'best')
      %       if strcmp(sensor_type, 'stereo')
      %         legend(legend_style([3:5,1:2,6:end]), legend_arr{[3:5,1:2,6:end]}, 'Location', 'best')
      %       else
      %         %         legend(legend_style([2:5,1,6:end]), legend_arr{[2:5,1,6:end]}, 'Location', 'best')
      %         legend(legend_style([2:3,1,4:end]), legend_arr{[2:3,1,4:end]}, 'Location', 'best')
      %       end
    end
    
    legend boxoff
    xlabel('Tracking Time per Frame (ms)')
    %     ylabel(metric_type{mn})
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
        ylabel('RPE (m/s)')
      case 'ROE3'
        %         ylim([0.05 0.5])
        set(gca, 'YScale', 'log')
        ylabel('ROE (deg/s)')
      case 'ScaleError'
        ylabel('Scale Error (%)')
    end
    
    %     set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    if opt_time_only
      export_fig(h(mn), [save_path '/Debug_OptTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    else
      export_fig(h(mn), [save_path '/Mono_FullTime_vs_' metric_type{mn} '_' seq_idx '.png']);
      export_fig(h(mn), [save_path '/Mono_FullTime_vs_' metric_type{mn} '_' seq_idx '.fig']);
      %       export_fig(h(mn), [save_path '/Stereo_FullTime_vs_' metric_type{mn} '_' seq_idx '.fig']);
      %       export_fig(h(mn), [save_path '/Stereo_FullTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    end
  end
  
  %% plot the track at an example run
  figure;
  hold on
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
  axis equal
  legend([{'GT'}; legend_arr(valid_idx)])
%   export_fig(gcf, [save_path '/Track3D_' seq_idx '.fig']);
%   export_fig(gcf, [save_path '/Track3D_' seq_idx '.png']);  close all
  
  clear err_struct log_
  
end

%%
if plot_summary
  close all
  for mn=1:length(metric_type)
    figure;
    hold on
    for tn=1:baseline_num
      scatter_syl = marker_styl{tn};
      scatter_syl = scatter_syl(length(scatter_syl):end);
      %
      if ~isempty(scatter_buf{mn,tn})
        scatter(scatter_buf{mn,tn}(1,:), scatter_buf{mn,tn}(2,:), ...
          scatter_syl, 'MarkerEdgeColor', marker_color{tn});
        j = boundary(scatter_buf{mn,tn}(1,:)', scatter_buf{mn,tn}(2,:)', 0.5);
        plot(scatter_buf{mn,tn}(1,j), scatter_buf{mn,tn}(2,j), [':' scatter_syl], ...
          'color', marker_color{tn});
      end
    end
    %
    for tn=baseline_num+1:length(slam_path_list)
      scatter_syl = marker_styl{floor((tn-baseline_num-1)/(mod_base)) + baseline_num + 1};
      scatter_syl = scatter_syl(length(scatter_syl):end);
      %
      if ~isempty(scatter_buf{mn,tn})
        scatter(scatter_buf{mn,tn}(1,:), scatter_buf{mn,tn}(2,:), ...
          scatter_syl, 'MarkerEdgeColor', marker_color{tn});
        j = boundary(scatter_buf{mn,tn}(1,:)', scatter_buf{mn,tn}(2,:)', 0.5);
        plot(scatter_buf{mn,tn}(1,j), scatter_buf{mn,tn}(2,j), [':' scatter_syl], ...
          'color', marker_color{tn});
      end
    end
    %
    legend_style = gobjects(length(legend_arr),1);
    for i=1:length(legend_arr)
      scatter_syl = marker_styl{i};
      scatter_syl = scatter_syl(length(scatter_syl):end);
      legend_style(i) = plot(nan, nan, scatter_syl, 'color', marker_color{i});
    end
    legend(legend_style, legend_arr, 'Location', 'best')
    %     legend(legend_style([3:6,1:2,7:8]), legend_arr{[3:6,1:2,7:8]}, 'Location', 'best')
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
        ylabel('RPE (m/s)')
      case 'ROE3'
        %         ylim([0.05 0.5])
        set(gca, 'YScale', 'log')
        ylabel('ROE (deg/s)')
    end
  end
end

%%
for i=1:length(metric_type)
  disp(['==================' metric_type{i} '=================='])
  for k=1:length(seq_list)
    for j=1:length(slam_path_list)
      %     [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
      %       time_std(table_index(tn)); subset_std(table_index(tn))]];
      if j == length(slam_path_list)
        fprintf(' %.3f \\\\ \n', round( table_buf{i, j}(2, k), 4) )
      else
        fprintf(' %.3f &', round( table_buf{i, j}(2, k), 4) )
      end
    end
  end
end

disp(['==================Time Cost=================='])
for k=1:length(seq_list)
  for j=1:length(slam_path_list)
    %     [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
    %       time_std(table_index(tn)); subset_std(table_index(tn))]];
    if j == length(slam_path_list)
      fprintf(' %.1f \\\\ \n', round( table_buf{1, j}(1, k), 4) )
    else
      fprintf(' %.1f &', round( table_buf{1, j}(1, k), 4) )
    end
  end
end

disp 'finish!'
