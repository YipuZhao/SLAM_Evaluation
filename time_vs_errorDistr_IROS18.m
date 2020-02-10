clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark =  'EuRoC_IROS_18' % 'KITTI_IROS_18' % 'KITTI_Baseline' % 'EuRoC_Baseline' %
setParam

metric_type = {
  'track\_loss\_rate';
  'abs\_drift';
  'abs\_orient';
  'rel\_drift';
  'rel\_orient';
  }

do_fair_comparison = false;
do_perc_plot = false; % true; %

lower_prc = 25;
upper_prc = 75;

for sn = 1:length(seq_list) %
  
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
        seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
      
      % associate the data to the model quat with timestamp
      asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
      
      % Compute evaluation metrics
      [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
        err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
        err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
        err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
        getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
        1, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
        0, seq_duration(sn));
      
      % Load Log Files
      disp(['Loading ORB-SLAM log...'])
      [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} baseline_slam_list{gn}], ...
        rn, seq_idx, log_{gn, tn});
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
          seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
        
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        
        % Compute evaluation metrics
        [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
          err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
          err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
          err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
          getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          1, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          0, seq_duration(sn));
        
        % Load Log Files
        disp(['Loading ORB-SLAM log...'])
        [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} gf_slam_list{gn}], ...
          rn, seq_idx, log_{gn, tn});
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
    tn = 1
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
        else
          err_metric = summarizeMetricFromSeq(err_raw, ...
            err_struct{gn, tn}.track_loss_rate(rn), ...
            track_loss_ratio(1), 'rms');
        end
        
        if ~isempty(err_metric)
          err_all_rounds = [err_all_rounds; err_metric];
          
          % grab the mean time cost
          time_raw = log_{gn, tn}.timeTrack{rn};
          time_all_rounds = [time_all_rounds; time_raw];
          
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
        %         time_all_rounds = mink(time_all_rounds,  K_fair(gn));
        %         time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
      end
      
      % grab the mean error across all valid runs
      base_mean = [base_mean nanmean(err_all_rounds)];
      time_mean = [time_mean nanmean(time_all_rounds)];
      %
      base_lower = [base_lower prctile(err_all_rounds, lower_prc)];
      time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
      %
      base_upper = [base_upper prctile(err_all_rounds, upper_prc)];
      time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
      
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
      errorbar(time_mean, base_mean, base_lower, base_upper, marker_styl{tn})
      title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
    else
      plot(time_mean, base_mean, marker_styl{tn})
      title('average')
    end
    
    %% plot the subset points
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
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
          end
          
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
            
            % grab the mean time cost
            time_raw = log_{gn, tn}.timeTrack{rn};
            time_all_rounds = [time_all_rounds; time_raw];
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
          %          time_all_rounds = mink(time_all_rounds,  ...
          %            K_fair( baseline_taken_index( mod(tn, mod_base)+1 ) ));
          %          time_all_rounds = [time_all_rounds; NaN(round_num - ...
          %            K_fair( baseline_taken_index( mod(tn, mod_base)+1 )), 1)];
          %           time_all_rounds = mink(time_all_rounds,  K_fair(gn));
          %           time_all_rounds = [time_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        end
        
        % grab the mean error across all valid runs
        subset_mean = [subset_mean nanmean(err_all_rounds)];
        time_mean = [time_mean nanmean(time_all_rounds)];
        %
        subset_lower = [subset_lower prctile(err_all_rounds, lower_prc)];
        time_lower = [time_lower prctile(time_all_rounds, lower_prc)];
        %
        subset_upper = [subset_upper prctile(err_all_rounds, upper_prc)];
        time_upper = [time_upper prctile(time_all_rounds, upper_prc)];
        
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
        errorbar(time_mean, subset_mean, subset_lower, subset_upper, marker_styl{floor((tn-2)/(mod_base)) + 2})
        title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(time_mean, subset_mean, marker_styl{floor((tn-2)/(mod_base)) + 2})
        title('average')
      end
      
    end
    
    legend_style = gobjects(length(legend_arr),1);
    for i=1:length(legend_arr)
      legend_style(i) = plot(nan, nan, marker_styl{i});
    end
    
    legend(legend_style, legend_arr)
    xlabel('time')
    ylabel(metric_type{mn})
    %     set(gca, 'YScale', 'log')
    
    set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h(mn), [save_path '/Time_vs_' metric_type{mn} '_' seq_idx '.png']);
    
  end
  
  close all
  
  clear err_struct
  
end
