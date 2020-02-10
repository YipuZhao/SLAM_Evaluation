clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark =  'EuRoC_IROS18_Accuracy'
setParam

err_type = 'RPE3' % 'RMSE' % 'ROE3' % 

step_length = int32(0);
lower_prc = 25;
upper_prc = 75;
boxplot_wisk_val = 50;

for gn = 1:length(gf_slam_list)
  err_summ = [];
  err_table = [];
  for sn = 1:length(seq_list) %
    
    seq_idx = seq_list{sn};
    disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
    
    %%
    for tn=1:length(slam_path_list)
      log_{gn, tn} = [];
    end
    %
    for rn = 1:round_num
      %% Load Trajectory Files
      % load the ground truth track
      track_ref = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 0);
      
      for tn=1:length(slam_path_list)
        %% load each result track
        if tn <= 2
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
          err_struct{tn}.scale_fac(rn) = 1.0;
          err_struct{tn}.abs_drift{rn} = [];
          err_struct{tn}.abs_orient{rn} = [];
          err_struct{tn}.term_drift{rn} = [];
          err_struct{tn}.term_orient{rn} = [];
          err_struct{tn}.rel_drift{rn} = [];
          err_struct{tn}.rel_orient{rn} = [];
          err_struct{tn}.track_loss_rate(rn) = 1.0;
          err_struct{tn}.track_fit{rn} = [];
        else
          %         [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
          %           err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
          %           err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
          %           err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}] = ...
          %           getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          %           1, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          %           0, seq_duration(sn), seq_start_time(sn));
          [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
            err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
            err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
            err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}, ...
            err_struct{tn}.scale_fac(rn)] = ...
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
    
    %   %%
    %   time_arr = [];
    %   for rn=1:10
    %     time_arr = [time_arr mean( log_{1, 8}.timeTrack{rn} )];
    %   end
    %   disp 'track time of comb cond:'
    %   mean(time_arr)
    %
    %   time_arr = [];
    %   for rn=1:10
    %     time_arr = [time_arr mean( log_{1, 2}.timeTrack{rn} )];
    %   end
    %   disp 'track time of inlier orb:'
    %   mean(time_arr)
    %
    %   time_arr = [];
    %   for rn=1:10
    %     time_arr = [time_arr mean( log_{1, 1}.timeTrack{rn} )];
    %   end
    %   disp 'track time of canonical orb:'
    %   mean(time_arr)
    
    %% Print Out Comparison Table
    err_mean_seq = [];
    err_lower_seq = [];
    err_upper_seq = [];
    err_summ_seq = [];
    selected_idx = [3:length(slam_path_list), 2, 1];
    for j=selected_idx
      err_all_rounds = [];
      for i=1:round_num
        %
        switch err_type
          case 'RMSE'
            err_raw = err_struct{j}.abs_drift{i};
          case 'RPE3'
            err_raw = err_struct{j}.rel_drift{i};
          case 'ROE3'
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
      err_mean_seq = [err_mean_seq nanmean(err_all_rounds)];
      %       err_lower_seq = [err_lower_seq prctile(err_all_rounds, lower_prc)];
      %       err_upper_seq = [err_upper_seq prctile(err_all_rounds, upper_prc)];
      err_summ_seq = [err_summ_seq err_all_rounds];
    end
    
    legend_arr(selected_idx)'
    
    for i=1:length(err_mean_seq)
      if i == length(err_mean_seq)
        fprintf(' %.4f\n', round( err_mean_seq(i), 4) )
      else
        %       if i > 1 && i <= 4
        %         bn = 1;
        %         fprintf(' %.3f(%+.1f\\%%) &', round( err_summ(i), 3), ...
        %           round( ( err_summ(i) - err_summ(bn) ) / err_summ(bn) * 100, 1) )
        %       elseif i > 5 && i <= 8
        %         bn = 5;
        %         fprintf(' %.3f(%+.1f\\%%) &', round( err_summ(i), 3), ...
        %           round( ( err_summ(i) - err_summ(bn) ) / err_summ(bn) * 100, 1) )
        %       else
        fprintf(' %.4f &', round( err_mean_seq(i), 4) )
        %       end
      end
    end
    
    err_table = [err_table; err_mean_seq];
    err_summ = [err_summ; err_summ_seq];
    
    %% Plot Comparison Illustration
    %
    
    h1=figure(1);
    clf
    %     errorbar(1:length(err_mean_seq), err_mean_seq, ...
    %       err_mean_seq - err_lower_seq, err_upper_seq - err_mean_seq )
    %     title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
    boxplot(err_summ_seq, legend_arr(selected_idx)','Whisker',boxplot_wisk_val);
    ylabel(err_type)
    title(seq_idx)
    %
    export_fig(h1, [save_path '/BoxPlot_' err_type '_' seq_idx '.png']);
    export_fig(h1, [save_path '/BoxPlot_' err_type '_' seq_idx '.fig']);
    
  end
  
  disp 'Average:'
  %   nanmean(err_table([1:6, 9:10], :), 1)
  nanmean(err_table(:, :), 1)
  
  h2=figure(2);
  clf
  subplot(2,1,1)
  boxplot(err_summ, legend_arr(selected_idx)','Whisker',boxplot_wisk_val)
  set(gca, 'YScale', 'log')
  ylabel(err_type)
  subplot(2,1,2)
  boxplot(err_summ([31:50,71:80],:), legend_arr(selected_idx)','Whisker',boxplot_wisk_val)
  set(gca, 'YScale', 'log')
  ylabel(err_type)
  %
  export_fig(h2, [save_path '/BoxPlot_' err_type '.png']);
  export_fig(h2, [save_path '/BoxPlot_' err_type '.fig']);
  
end