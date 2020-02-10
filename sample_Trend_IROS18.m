clear all
close all

%%
addpath('/home/yipuzhao/SDK/aboxplot');
addpath('/home/yipuzhao/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark =  'EuRoC_IROS18_Ushape'
setParam

% plot_slam_idx = [2, 7];
err_table = [];
for sn = 1 % 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  % load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 0);
  
  for gn = 1:length(gf_slam_list)
    
    %%
    for tn=1:length(slam_path_list)
      log_{gn, tn} = [];
    end
    %
    for rn = 1:round_num
      %% Load Trajectory Files
      for tn=1:length(slam_path_list)
        %% load each result track
        if tn == 1
          track{tn} = loadTrackTUM([slam_path_list{tn} '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        else
          track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        end
        
        %% associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        
        %% Compute evaluation metrics
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
          % mono config, with scale correction
          [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
            err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
            err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
            err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
            getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
        end
        
        % Load Log Files
        %       disp(['Loading ORB-SLAM log...'])
        if tn <= 2
          [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn}], ...
            rn, seq_idx, log_{gn, tn});
        else
          [log_{gn, tn}] = loadLogTUM_mono([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn});
        end
        
      end
    end
  end
  
  %% Print Out Comparison Table
  lower_prc = 25;
  upper_prc = 75;
  err_type = 'rel_orient' % 'abs_orient' % 'abs_drift' % 'track_loss_rate' % 'rel_drift' %  
  
  %
  %   figure;
  %   hold on
  for tn=1:length(slam_path_list)
    %
    err_mean = [];
    err_lower = [];
    err_upper = [];
    err_summ{tn} = [];
    %
    for gn = 1:length(gf_slam_list)
      %
      err_all_rounds = [];
      for i=1:round_num
        %
        switch err_type
          case 'term_drift'
            err_raw = err_struct{gn, tn}.term_drift{i};
          case 'term_orient'
            err_raw = err_struct{gn, tn}.term_orient{i};
          case 'abs_drift'
            err_raw = err_struct{gn, tn}.abs_drift{i};
          case 'abs_orient'
            err_raw = err_struct{gn, tn}.abs_orient{i};
          case 'rel_drift'
            err_raw = err_struct{gn, tn}.rel_drift{i};
          case 'rel_orient'
            err_raw = err_struct{gn, tn}.rel_orient{i};
        end
        %
        if strcmp(err_type, 'track_loss_rate')
          err_metric = err_struct{gn, tn}.track_loss_rate(i);
        else
          err_metric = summarizeMetricFromSeq(err_raw, ...
            err_struct{gn, tn}.track_loss_rate(i), ...
            track_loss_ratio(1), 'rms');
        end
        %
        if ~isempty(err_metric)
          err_all_rounds = [err_all_rounds; err_metric];
        else
          %         err_all_rounds = [err_all_rounds; NaN];
        end
      end
      err_mean = [err_mean mean(err_all_rounds)];
      err_lower = [err_lower prctile(err_all_rounds, lower_prc)];
      err_upper = [err_upper prctile(err_all_rounds, upper_prc)];
      %         err_summ = [err_summ median(err_all_rounds)];
      err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds)
      
    end
    
    % plot
    %     errorbar([80 100 120 140 160 180 200], err_mean, ...
    %       err_mean - err_lower, err_upper - err_mean )
  end
  
  
  %% Plot Comparison Illustration
  %     assert(size(err_summ, 2) == length(gf_slam_list))
  %   err_boxplot = [];
  %   for tn = 2:length(slam_path_list)
  %     err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
  %   end
  % plot absolute error
  h = figure;
  clf
  %     h = figure('Visible','Off');
  %     hold on
  aboxplot(err_summ{tn}(:, 2:end), 'labels', [80 100 120 140 160 180 200], ...
    'OutlierMarker', 'x', 'colorgrad','orange_down'); % Advanced box plot
  %   boxplot(err_summ{tn}, 'labels', [60 80 100 120 140 160 180 200], 'Colors', []);
  hold on
  % plot the canonical ORB-SLAM
  err_avg = nanmean( err_summ{2}(:, 1) );
  err_prc_25 = prctile(err_summ{2}(:, 1), 25);
  err_prc_75 = prctile(err_summ{2}(:, 1), 75);
  line([0.5, 8.5], [err_avg, err_avg], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'r');
  line([0.5, 8.5], [err_prc_25, err_prc_25], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
  line([0.5, 8.5], [err_prc_75, err_prc_75], 'LineStyle', ':', 'LineWidth', 1.5, 'Color', 'r');
  
  % boxplot(err_summ{tn}, 'labels', lmk_number_list);
  %   legend(legend_arr{2:end});
  if strcmp(err_type, 'track_loss_rate')
    ylim([0 110]);
  end
  xlabel('lmk tracked per frame')
%     ylabel('RPE (m/s)')
    ylabel('ROE (deg/s)')
%   ylabel('ATE (m)')
  %   set(gca, 'YScale', 'log')
  
end