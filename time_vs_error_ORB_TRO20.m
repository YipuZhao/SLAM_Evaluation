clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'EuRoC_RAL18_ActiveMatch' % 'EuRoC_RAL18_Debug' % 'KITTI_RAL18_Debug' %
% 'KITTI_Baseline' % 'EuRoC_Baseline' %
setParam

metric_type = {
  'track\_loss\_rate';
  'abs\_drift';
  %   'abs\_orient';
  %   'rel\_drift';
  %   'rel\_orient';
  }

do_fair_comparison = false; % true; %
do_perc_plot = true; % false; %

opt_time_only = false; % true;

lower_prc = 25;
upper_prc = 75;

%%
method_VINS = {
  'svo-msf';
  'msckf';
  'okvis';
  'rovio';
  'vins-mono';
  'vins-mono-lc';
  'svo-gtsam';
  };

RMSE_VINS = [
  0.14 0.42 0.16 0.21 0.27 0.07 0.05;
  0.20 0.45 0.22 0.25 0.12 0.05 0.03;
  0.48 0.23 0.24 0.25 0.13 0.08 0.12;
  1.38 0.37 0.34 0.49 0.23 0.12 0.13;
  0.51 0.48 0.47 0.52 0.35 0.09 0.16;
  0.40 0.34 0.09 0.10 0.07 0.04 0.07 ;
  0.63 0.20 0.20 0.10 0.10 0.06 0.11;
  nan 0.67 0.24 0.14 0.13 0.11 nan;
  0.20 0.10 0.13 0.12 0.08 0.06 0.07;
  0.37 0.16 0.16 0.14 0.08 0.06 nan;
  nan 1.13 0.29 0.14 0.21 0.09 nan;
  ]';

timeCost_VINS = repmat([
  18;
  25;
  30;
  25;
  55;
  55;
  10;
  ], 1, 11);

%%
for sn = [1, 3, 5, 10] % [1, 5, 10] % [1:6, 9:10]  % 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0, maxNormTrans);
  
  %% grab the baseline results
  tn = 1
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
        err_struct{gn, tn}.abs_drift{rn} = [];
        err_struct{gn, tn}.abs_orient{rn} = [];
        err_struct{gn, tn}.term_drift{rn} = [];
        err_struct{gn, tn}.term_orient{rn} = [];
        err_struct{gn, tn}.rel_drift{rn} = [];
        err_struct{gn, tn}.rel_orient{rn} = [];
        err_struct{gn, tn}.track_loss_rate(rn) = 1.0;
        err_struct{gn, tn}.track_fit{rn} = [];
      else
        [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
          err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
          err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
          err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
          getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          rm_iso_track, seq_duration(sn), seq_start_time(sn));
      end
      
      
      % Load Log Files
      disp(['Loading ORB-SLAM log...'])
      %       [log_{gn, tn}] = loadLogTUM_old([slam_path_list{tn} baseline_slam_list{gn}], ...
      %         rn, seq_idx, log_{gn, tn});
      [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} baseline_slam_list{gn}], ...
        rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
    end
  end
  
  %% grab the subset results
  for tn=2:length(slam_path_list)
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
          err_struct{gn, tn}.abs_drift{rn} = [];
          err_struct{gn, tn}.abs_orient{rn} = [];
          err_struct{gn, tn}.term_drift{rn} = [];
          err_struct{gn, tn}.term_orient{rn} = [];
          err_struct{gn, tn}.rel_drift{rn} = [];
          err_struct{gn, tn}.rel_orient{rn} = [];
          err_struct{gn, tn}.track_loss_rate(rn) = 1.0;
          err_struct{gn, tn}.track_fit{rn} = [];
        else
          [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
            err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
            err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
            err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
            getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            rm_iso_track, seq_duration(sn), seq_start_time(sn));
        end
        
        % Load Log Files
        disp(['Loading ORB-SLAM log...'])
        [log_{gn, tn}] = loadLogTUM_new([slam_path_list{tn} gf_slam_list{gn}], ...
          rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
      end
    end
  end
  
  %% plot the baseline results
  for mn=1:length(metric_type)
    
    %% Plot mean error only for better viz
    h(mn) = figure(mn);
    clf
    hold on
    
    %% plot the baseline point
    for tn = 1
      base_mean = [];
      base_lower = [];
      base_upper = [];
      time_mean = [];
      time_lower = [];
      time_upper = [];
      %
      for gn=1:length(baseline_slam_list)
        if isempty(err_struct{gn, tn})
          continue
        end
        
        if do_fair_comparison
          K_fair(gn) = sum(err_struct{gn, tn}.track_loss_rate < track_loss_ratio(1));
        end
        
        err_all_rounds = [];
        time_all_rounds = [];
        drop_plot = false;
        for rn=1:round_num
          switch metric_type{mn}
            case 'abs\_drift'
              err_raw = err_struct{gn, tn}.abs_drift{rn};
            case 'abs\_orient'
              err_raw = err_struct{gn, tn}.abs_orient{rn};
            case 'rel\_drift'
              err_raw = err_struct{gn, tn}.rel_drift{rn};
            case 'rel\_orient'
              err_raw = err_struct{gn, tn}.rel_orient{rn};
          end
          
          if strcmp(metric_type{mn}, 'track\_loss\_rate')
                      err_metric = err_struct{gn, tn}.track_loss_rate(rn) * 100.0;
%             if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
%               err_metric = 1;
%             else
%               err_metric = 0;
%             end
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
            
            % grab the mean time cost
            if opt_time_only
              time_raw = log_{gn, tn}.timeSelect{rn} + log_{gn, tn}.timeOpt{rn};
            else
              time_raw = log_{gn, tn}.timeOrbExtr{rn} + ...
                log_{gn, tn}.timeInitTrack{rn} + log_{gn, tn}.timeRefTrack{rn};
            end
            %           time_raw = log_{gn, tn}.timeRefTrack{rn};
            %           time_all_rounds = [time_all_rounds; mean(time_raw)];
            time_all_rounds = [time_all_rounds; prctile(time_raw, 80)];
            %           time_all_rounds = [time_all_rounds; time_raw];
            
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            %           err_all_rounds = [err_all_rounds; NaN];
            %           time_all_rounds = [time_all_rounds; NaN];
          end
          
        end
        
        if do_fair_comparison
          % for fair comparison, only take the top-k results, where k is the
          % number of runs successed with baseline method
          err_all_rounds = mink(err_all_rounds,  K_fair(gn));
          err_all_rounds = [err_all_rounds; NaN(round_num -  K_fair(gn), 1)];
          %
          time_all_rounds = mink(time_all_rounds,  K_fair(gn));
          time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        end
        
        if drop_plot == false
          % grab the mean error across all valid runs
          base_mean = [base_mean nanmean(err_all_rounds)];
          time_mean = [time_mean nanmean(time_all_rounds)];
          %
          base_lower = [base_lower prctile(err_all_rounds, lower_prc)];
          time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
          %
          base_upper = [base_upper prctile(err_all_rounds, upper_prc)];
          time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
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
        errorbar(time_mean, base_mean, ...
          base_mean - base_lower, base_upper - base_mean, ...
          marker_styl{tn})
        %       title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean, base_mean, marker_styl{tn})
        %       title('average')
      end
      
    end
    
    %% plot the active subset
    mod_base = length(baseline_taken_index);
    for tn=2:length(slam_path_list)
      %
      subset_mean = [];
      subset_lower = [];
      subset_upper = [];
      time_mean = [];
      time_lower = [];
      time_upper = [];
      
      for gn=1:length(gf_slam_list)
        if isempty(err_struct{gn, tn})
          continue
        end
        
        err_all_rounds = [];
        time_all_rounds = [];
        drop_plot = false;
        for rn=1:round_num
          switch metric_type{mn}
            case 'abs\_drift'
              err_raw = err_struct{gn, tn}.abs_drift{rn};
            case 'abs\_orient'
              err_raw = err_struct{gn, tn}.abs_orient{rn};
            case 'rel\_drift'
              err_raw = err_struct{gn, tn}.rel_drift{rn};
            case 'rel\_orient'
              err_raw = err_struct{gn, tn}.rel_orient{rn};
          end
          
          if strcmp(metric_type{mn}, 'track\_loss\_rate')
                        err_metric = err_struct{gn, tn}.track_loss_rate(rn) * 100.0;
%             if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
%               err_metric = 1;
%             else
%               err_metric = 0;
%             end
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
          end
          
          if err_struct{gn, tn}.track_loss_rate(rn) > track_loss_ratio(1)
            drop_plot = true;
          end
          
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
            
            if opt_time_only
              time_raw = log_{gn, tn}.timeSelect{rn} + log_{gn, tn}.timeOpt{rn};
            else
              time_raw = log_{gn, tn}.timeOrbExtr{rn} + ...
                log_{gn, tn}.timeInitTrack{rn} + log_{gn, tn}.timeRefTrack{rn};
            end
            %             time_raw = log_{gn, tn}.timeRefTrack{rn};
            %             time_all_rounds = [time_all_rounds; mean(time_raw)];
            time_all_rounds = [time_all_rounds; prctile(time_raw, 80)];
            %             time_all_rounds = [time_all_rounds; time_raw];
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            % err_all_rounds = [err_all_rounds; NaN];
          end
          
        end
        
        if do_fair_comparison
          % for fair comparison, only take the top-k results, where k is the
          % number of runs successed with baseline method
          err_all_rounds = mink(err_all_rounds,  ...
            K_fair( baseline_taken_index( mod(tn, mod_base)+1 ) ));
          err_all_rounds = [err_all_rounds; NaN(round_num - ...
            K_fair( baseline_taken_index( mod(tn, mod_base)+1 )), 1)];
          %           err_all_rounds = mink(err_all_rounds,  K_fair(gn));
          %           err_all_rounds = [err_all_rounds; NaN(round_num -  K_fair(gn), 1)];
          %
          time_all_rounds = mink(time_all_rounds,  ...
            K_fair( baseline_taken_index( mod(tn, mod_base)+1 ) ));
          time_all_rounds = [time_all_rounds; NaN(round_num - ...
            K_fair( baseline_taken_index( mod(tn, mod_base)+1 )), 1)];
          %           time_all_rounds = mink(time_all_rounds,  K_fair(gn));
          %           time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        end
        
        if drop_plot == false
          % grab the mean error across all valid runs
          subset_mean = [subset_mean nanmean(err_all_rounds)];
          time_mean = [time_mean nanmean(time_all_rounds)];
          %
          subset_lower = [subset_lower prctile(err_all_rounds, lower_prc)];
          time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
          %
          subset_upper = [subset_upper prctile(err_all_rounds, upper_prc)];
          time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
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
        errorbar(time_mean, subset_mean, ...
          subset_mean - subset_lower, subset_upper - subset_mean, ...
          marker_styl{floor((tn-2)/(mod_base)) + 2})
        title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean, subset_mean, marker_styl{floor((tn-2)/(mod_base)) + 2})
        title('average')
      end
      
    end
    
    
    title(strrep(seq_idx, '_', '\_'))
    %     legend_style = gobjects(length(legend_arr),1);
    %     for i=1:length(legend_arr)
    %       legend_style(i) = plot(nan, nan, marker_styl{i});
    %     end
    
    xlabel('time')
    ylabel(metric_type{mn})
    switch metric_type{mn}
      case 'track\_loss\_rate'
        ylim([0 100])
      case 'abs\_drift'
        
        hold on
        for i=1:length(method_VINS)
          scatter(timeCost_VINS(i, sn), RMSE_VINS(i, sn), 'x');
        end
        legend([legend_arr; method_VINS])
        
        %             ylim([0.02 0.24])
        %         set(gca, 'YScale', 'log')
        xlabel('Tracking Time per Frame (ms)')
        ylabel('RMSE (m)')
        
      case 'abs\_orient'
        %
      case 'rel\_drift'
        ylim([0.005 0.05])
        %         set(gca, 'YScale', 'log')
      case 'rel\_orient'
        ylim([0.05 0.5])
        %         set(gca, 'YScale', 'log')
    end
    
    
    %     set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    if opt_time_only
      export_fig(h(mn), [save_path '/Debug_OptTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    else
      %       export_fig(h(mn), [save_path '/ORB_FullTime_vs_' metric_type{mn} '_' seq_idx '.png']);
      export_fig(h(mn), [save_path '/ORBActive_FullTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    end
    
  end
  
  close all
  
  clear err_struct log_
  
end
