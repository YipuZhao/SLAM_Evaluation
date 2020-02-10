clear all
close all

%%
addpath('/home/yipuzhao/SDK/aboxplot');
addpath('/home/yipuzhao/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark = 'EuRoC_ECCV18'
setParam

err_type = 'rel_drift' % 'track_loss_rate' %  'abs_orient' % 'abs_drift' % 'rel_orient' %

doViz = true; % false; %
gn = 1;
%
num_above_med = zeros(3, 1)';
num_below_med = zeros(3, 1)';
err_avg = zeros(3, 1)';
base_weight = zeros(3, 1)';
%
for sn = [6:11] % 1:length(seq_list) %
  
  disp(['Sequence --------------------- ' seq_list{sn} ' ---------------------'])
  %   figure(1)
  %   clf
  %   %
  %   figure(2)
  %   clf
  
  % load the ground truth track
  %   track_ref = loadTrackTUM([ref_path '/' seq_list{sn} '_tum.txt'], 0, inf);
  track_ref = loadTrackTUM([ref_path '/' seq_list{sn} '_cam0.txt'], 1, maxNormTrans);
  
  %%
  seq_idx = [seq_list{sn} ]
  %   seq_idx = [seq_list{sn} '_blur_5']
  %   seq_idx = [seq_list{sn} '_blur_9']
  
  if doViz
    figure(3);
    clf
    %
    plot3(track_ref(:, 2), ...
      track_ref(:, 3), ...
      track_ref(:, 4), '-o', 'MarkerSize', 3)
    hold on
  end
  
  for rn = 1:round_num
    %% Load Trajectory Files
    for tn = 1:length(slam_path_list)
      %% load each result track
      if tn <= 7 % 11 % 4 %
        %         track{tn} = loadTrackTUM([slam_path_list{tn} '/Round' num2str(rn) '/' ...
        %           seq_idx '_blur_9_' 'KeyFrameTrajectory.txt'], 1, maxNormTrans);
        track{tn} = loadTrackTUM([slam_path_list{tn} '/Round' num2str(rn) '/' ...
          seq_idx '_blur_5_' 'KeyFrameTrajectory.txt'], 1, maxNormTrans);
      else
        %         track{tn} = loadTrackTUM([slam_path_list{tn} '/Round' num2str(rn) '/' ...
        %           seq_idx '_blur_9_' track_type{1} 'Trajectory.txt'], 1, maxNormTrans);
        track{tn} = loadTrackTUM([slam_path_list{tn} '/Round' num2str(rn) '/' ...
          seq_idx '_blur_5_' track_type{1} 'Trajectory.txt'], 1, maxNormTrans);
      end
      
      %% associate the data to the model quat with timestamp
      asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
      
      
      %% Compute evaluation metrics
      if isempty(track{tn}) || isempty(track_ref)
          err_struct{tn}.abs_drift{rn} = [];
          err_struct{tn}.abs_orient{rn} = [];
          err_struct{tn}.term_drift{rn} = [];
          err_struct{tn}.term_orient{rn} = [];
          err_struct{tn}.rel_drift{rn} = [];
          err_struct{tn}.rel_orient{rn} = [];
          err_struct{tn}.track_loss_rate(rn) = 1.0;
          err_struct{tn}.track_fit{rn} = [];
        else
      %       [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
      %         err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
      %         err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
      %         err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}] = ...
      %         getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
      %         1, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
      %         0, seq_duration(sn), 0);
      [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
        err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
        err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
        err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}] = ...
        getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
        asso_idx, min_match_num, step_length, fps, rel_interval_list(1), ...
        benchmark_type, rm_iso_track, seq_duration(sn), 0);
      end
      
      %%  viz the track
      %
      if doViz
        if isempty(err_struct{tn}.track_fit{rn})
          disp(['no valid track for ' legend_arr{tn}])
        else
          plot3(err_struct{tn}.track_fit{rn}(1, :), ...
            err_struct{tn}.track_fit{rn}(2, :), ...
            err_struct{tn}.track_fit{rn}(3, :), '-o', 'MarkerSize', 3)
        end
      end
    end
  end
  
  if doViz
    legend( ['ground\_truth'; legend_arr] )
    axis equal
    hold off
  end
  
  %% Plot Comparison Illustration
  err_summ = [];
  for j=1:length(slam_path_list)
    err_all_rounds = [];
    failed_runs = 0;
    for i=1:round_num
      %
      switch err_type
        case 'abs_drift'
          err_raw = err_struct{j}.abs_drift{i};
        case 'abs_orient'
          err_raw = err_struct{j}.abs_orient{i};
        case 'rel_drift'
          err_raw = err_struct{j}.rel_drift{i};
        case 'rel_orient'
          err_raw = err_struct{j}.rel_orient{i};
      end
      %
      if strcmp(err_type, 'track_loss_rate')
        err_metric = err_struct{j}.track_loss_rate(i);
      else
        err_metric = summarizeMetricFromSeq(err_raw, ...
          err_struct{j}.track_loss_rate(i), ...
          track_loss_ratio(1), 'rms');
      end
      %
      if ~isempty(err_metric) && abs(err_metric) < 20 % && ( sn~=9 || ( j~=1 && j~=2 ) )
        err_all_rounds = [err_all_rounds; err_metric];
      else
        err_all_rounds = [err_all_rounds; NaN];
        failed_runs = failed_runs + 1;
      end
    end
    %     err_summ = [err_summ err_all_rounds];
    err_summ = [ err_summ nanmean(err_all_rounds) ];
    disp(['runs failed = ' num2str(failed_runs)])
  end
  
  % solve the median of each row
  err_med = median( err_summ, 'omitnan' );
  
  for i=1:length(err_summ)
    
    %     if err_summ(i) > err_med
    %       num_above_med(i) = num_above_med(i) + 1;
    %     end
    %     if err_summ(i) < err_med
    %       num_below_med(i) = num_below_med(i) + 1;
    %     end
    
    if i == length(err_summ)
      fprintf(' %.3f\n', round( err_summ(i), 3) )
    else
      if i > 1 && i <= 4
        bn = 1;
        fprintf(' %.3f &', round( err_summ(i), 3) )
      elseif i > 5 && i <= 8
        bn = 5;
        fprintf(' %.3f &', round( err_summ(i), 3) )
      else
        fprintf(' %.3f &', round( err_summ(i), 3) )
      end
    end
  end
  
  valid_idx = ~isnan(err_summ);
  %     err_avg(valid_idx) = err_avg(valid_idx) + err_summ(valid_idx) .* seq_duration(sn);
  %     base_weight = base_weight + valid_idx .* seq_duration(sn);
  err_avg(valid_idx) = err_avg(valid_idx) + err_summ(valid_idx) .* 1;
  base_weight = base_weight + valid_idx .* 1;
  
end

disp 'average error'
err_avg ./ base_weight

disp 'above median number'
num_above_med

disp 'below median number'
num_below_med


