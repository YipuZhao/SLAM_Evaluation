clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark =  'EuRoC_RAL18_Debug' % 'TUM_RAL18_Debug' % 'KITTI_RAL18_Debug' % 'EuRoC_RAL18_TradeOff' % 
% 'EuRoC_Baseline' % 'KITTI_Baseline' %
setParam

metric_type = {
  'track\_loss\_rate';
  'abs\_drift';
  %   'abs\_orient';
  'rel\_drift';
  'rel\_orient';
  'time\_cost';
  }

do_fair_comparison = false; % true;
do_perc_plot = true; % false; %

lower_prc = 25;
upper_prc = 75;

for sn = [1, 5, 6:8] %  1:length(seq_list) % 
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0, maxNormTrans);
  
  %% grab the baseline results
  baseline_number_list = [];
  for tn=1:3
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
%         [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} baseline_slam_list{gn}], ...
%           rn, seq_idx, log_{gn, tn});
      [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} baseline_slam_list{gn}], ...
        rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
      
      end
    end
    
    %% collect the baseline budget
    for gn=1:length(baseline_slam_list)
      number_tmp = [];
      for rn=1:round_num
        if err_struct{gn, tn}.track_loss_rate(rn) < track_loss_ratio(1)
          number_tmp = [number_tmp nanmean( log_{gn, tn}.lmkBA{rn} )];
        end
      end
      %
      baseline_number_list(gn, tn) = nanmean(number_tmp);
    end
  end
  
  %% plot the baseline results
  for mn=1:length(metric_type)
    
    %% Plot mean error only for better viz
    h(mn) = figure(mn);
    clf
    hold on
    
    %% plot the baseline point
    for tn = 1:3
      base_avg = [];
      base_lower = [];
      base_upper = [];
      %
      for gn=1:length(baseline_slam_list)
        if isempty(err_struct{gn, tn})
          continue
        end
        
        if do_fair_comparison
          K_fair(gn) = sum(err_struct{gn, tn}.track_loss_rate < track_loss_ratio(1));
        end
        
        err_all_rounds = [];
        for rn=1:round_num
          switch metric_type{mn}
            case 'time\_cost'
              %             err_raw = log_{gn, tn}.timeTrack{rn};
              err_raw = log_{gn, tn}.timeOrbExtr{rn} + ...
                log_{gn, tn}.timeInitTrack{rn} + log_{gn, tn}.timeRefTrack{rn};
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
          elseif strcmp(metric_type{mn}, 'time\_cost')
            err_metric = mean(err_raw);
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
          end
          
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
          end
        end
        
        if do_fair_comparison
          % for fair comparison, only take the top-k results, where k is the
          % number of runs successed with baseline method
          err_all_rounds = mink(err_all_rounds,  K_fair(gn));
          err_all_rounds = [err_all_rounds; NaN(round_num -  K_fair(gn), 1)];
        end
        
        % grab the mean error across all valid runs
        base_avg = [base_avg nanmean(err_all_rounds)];
        base_lower = [base_lower prctile(err_all_rounds, lower_prc)];
        base_upper = [base_upper prctile(err_all_rounds, upper_prc)];
        %
        % draw a point to the graph
        %       scatter(time_avg, err_avg, marker_styl{tn})
      end
      
      if do_perc_plot
        %       subplot(1,3,1)
        %       plot(baseline_number_list, base_avg, marker_styl{tn})
        %       title('average')
        %       subplot(1,3,2)
        %       plot(baseline_number_list, base_lower, marker_styl{tn})
        %       title('25%')
        %       subplot(1,3,3)
        %       plot(baseline_number_list, base_upper, marker_styl{tn})
        %       title('75%')
        errorbar(baseline_number_list(:, tn)', base_avg, ...
          base_avg - base_lower, base_upper - base_avg, ...
          marker_styl{tn})
        title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
      else
        plot(baseline_number_list(:, tn)', base_avg, marker_styl{tn})
        title('average')
      end
      
    end
    
    
    legend_style = gobjects(length(legend_arr),1);
    for i=1:length(legend_arr)
      legend_style(i) = plot(nan, nan, marker_styl{i});
    end
    
    legend(legend_style, legend_arr)
    xlabel('lmk tracked per frame')
    ylabel(metric_type{mn})
    
    set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     export_fig(h(mn), [save_path '/Baseline_LmkNum_vs_' metric_type{mn} '_' seq_idx '.png']);
    %     export_fig(h(mn), [save_path '/SubsetNoBoost_LmkNum_vs_' metric_type{mn} '_' seq_idx '.png']);
    %     export_fig(h(mn), [save_path '/SubsetBoundOnly_LmkNum_vs_' metric_type{mn} '_' seq_idx '.png']);
    export_fig(h(mn), [save_path '/Baseline_LmkNum_vs_' metric_type{mn} '_' seq_idx '.png']);
    
  end
  
  close all
  
  clear err_struct
  
end
