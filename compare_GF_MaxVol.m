clear all
close all

%%
addpath('/mnt/DATA/SDK/aboxplot');
addpath('/mnt/DATA/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark = 'EuRoC' % 'TUM' % 'KITTI' %
setParam
% legend_arr = {'ORB-SLAM'; 'MV-SLAM'; 'MV-SLAM-Full';};
% legend_arr = {'ORB-SLAM'; 'GF-SLAM'; 'Combined-SLAM';};

err_type = 'rel_drift' % 'rel_orient' % 'track_loss_rate' % 'term_drift' % 'term_orient' %

for sn = 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0);
  
  %% According to the VIN-ORB paper, the timestamp of EuRoC ground truth shall be added with
  % an offset term:
  % MH01~05 + 0.2 sec
  % V02     - 0.2 sec
  %
  %   if sn <= 5
  %     track_ref(:, 1) = track_ref(:, 1) + 0.5;
  %   elseif sn >= 9
  %     track_ref(:, 1) = track_ref(:, 1) - 0.5;
  %   end
  
  %   for gn = 1:length(lmk_ratio_list)
  for gn = 1:length(gf_slam_list)
    for rn = 1:round_num
      
      for tn=1:length(slam_path_list)
        %% Load each result track
        track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
        
        % for fair comparison, VIN output during the initial period (first 15 sec) is neglected;
        % while that of Visual ORB SLAM is kept
        if tn == 2
          timeAfterInit = track{tn}(1, 1) + 20.0;
          validIdx = find( track{tn}(:, 1) > timeAfterInit );
          track{tn} = track{tn}(validIdx, :);
        end
        
        %% Associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        
        %% Compute evaluation metrics
        [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
          err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
          err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
          err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}] = ...
          getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
      end
      
    end
  end
  
  if do_viz
    % Boxplot Illustration
    h=figure();
    boxFigure_2_Methods(gf_slam_list, track_loss_ratio(1), round_num, ...
      err_type_list{1}, err_struct{1}, err_struct{2}, legend_arr);
    %
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     mkdir([save_path '/' seq_idx '/']);
    export_fig(h, [save_path '/BoxTrend_' seq_idx '_' track_type{1} '.png'], '-r 200');
    close(h)
    
    % Trajectory Illustration
    h=figure();
    plotDriftSummary(1, track_type{1}, 1, round_num, ...
      track_ref, err_struct{1}, err_struct{2}, legend_arr);
    %
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %   mkdir([save_path '/' seq_idx '/']);
    export_fig(h, [save_path '/Traj_' seq_idx '_' track_type{1} '.png'], '-r 200');
    close(h)
  end
  
  %% Print latex table
  err_summ = [];
  for j=1:length(slam_path_list)
    err_all_rounds = [];
    for i=1:round_num
      %
      switch err_type
        case 'term_drift'
          err_raw = err_struct{j}.term_drift{i};
        case 'term_orient'
          err_raw = err_struct{j}.term_orient{i};
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
      if ~isempty(err_metric)
        err_all_rounds = [err_all_rounds; err_metric];
      else
        err_all_rounds = [err_all_rounds; NaN];
      end
    end
    err_summ = [ err_summ nanmean(err_all_rounds) ];
  end
  
  
  for i=1:length(err_summ)
    if i == length(err_summ)
      fprintf(' %.4f\n', round( err_summ(i), 4) )
    else
      fprintf(' %.4f &', round( err_summ(i), 4) )
    end
  end
  
end
