clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'EuRoC_Debug' % 'KITTI_IROS_18' %
setParam

metric_type = {
  'track\_loss\_rate';
  %   'abs\_drift';
  %   'abs\_orient';
  'rel\_drift';
  'rel\_orient';
  }

do_fair_comparison = false;

for sn = [1, 5] %  10 % [6,9,10] % 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0);
  
  %% load Trajectory Files
  for gn=1:length(gf_slam_list)
    %
    for tn=1:length(slam_path_list)
      
      log_{gn, tn} = [];
      for rn = 1:round_num
        %% load each result track
        if tn <= 2
          
          track{tn} = loadTrackTUM([slam_path_list{tn} 'ObsNumber_1500' '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
          %           track{tn} = loadTrackTUM([slam_path_list{tn} 'ObsNumber_1500' '_Round' num2str(rn) '/' ...
          %             seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
          %           track{tn} = loadTrackTUM([slam_path_list{tn} 'ObsNumber_800' '_Round' num2str(rn) '/' ...
          %             seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
          % Load Log Files
          %           disp(['Loading ORB-SLAM log...'])
          [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} 'ObsNumber_1500'], ...
            rn, seq_idx, log_{gn, tn});
          
        else
          
          track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{1} 'Trajectory.txt'], ln_head, maxNormTrans);
          % Load Log Files
          %           disp(['Loading ORB-SLAM log...'])
          [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn});
          
        end
        
        %% associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        
        %% Compute evaluation metrics
        [err_struct{gn, tn}.abs_drift{rn}, err_struct{gn, tn}.abs_orient{rn}, ...
          err_struct{gn, tn}.term_drift{rn}, err_struct{gn, tn}.term_orient{rn}, ...
          err_struct{gn, tn}.rel_drift{rn}, err_struct{gn, tn}.rel_orient{rn}, ...
          err_struct{gn, tn}.track_loss_rate(rn), err_struct{gn, tn}.track_fit{rn}] = ...
          getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          1, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          0, seq_duration(sn), seq_start_time(sn));
      end
      
    end
  end
  
  
  %% plot an example trend
  %   for gn=1:length(gf_slam_list)
  %     for rn=1:round_num
  %       h = figure
  %       for mn=2:length(metric_type)
  %         for tn=1:length(slam_path_list)
  %
  %           if isempty(err_struct{gn, tn})
  %             continue
  %           end
  %
  %           switch metric_type{mn}
  %             case 'term\_drift'
  %               err_raw = err_struct{gn, tn}.abs_drift{rn};
  %             case 'term\_orient'
  %               err_raw = err_struct{gn, tn}.abs_orient{rn};
  %             case 'rel\_drift'
  %               err_raw = err_struct{gn, tn}.rel_drift{rn};
  %             case 'rel\_orient'
  %               err_raw = err_struct{gn, tn}.rel_orient{rn};
  %           end
  %
  %           subplot(2, 2, mn-1)
  %           hold on
  %           if tn == 1
  %             plot(err_raw(:, 1), err_raw(:, 2), '-');
  %           else
  %             plot(err_raw(:, 1), err_raw(:, 2), ':');
  %           end
  %         end
  %
  %         xlabel('time')
  %         ylabel(metric_type{mn})
  %         legend(legend_arr);
  %
  %       end
  %       %
  %       set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  %       export_fig(h, [save_path '/ErrTrend_MaxVol_' seq_idx '_lmkNum_' ...
  %         num2str(lmk_number_list(gn)) '_round_' num2str(rn) '.png']); % , '-r 200');
  %
  %       close(h)
  %     end
  %   end
  
  %% Summarize into mean/rms
  h = figure;
  K_fair = sum(err_struct{1, 1}.track_loss_rate < track_loss_ratio(1));
  %
  for mn=1:length(metric_type)
    %     h = figure(100 + mn);
    %     clf
    %
    for tn=1:length(slam_path_list)
      err_summ{tn} = [];
      %
      for gn=1:length(gf_slam_list)
        err_all_rounds = [];
        %
        for rn=1:round_num
          %
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
          %
          if strcmp(metric_type{mn}, 'track\_loss\_rate')
            err_metric = err_struct{gn, tn}.track_loss_rate(rn) * 100.0;
          else
            err_metric = summarizeMetricFromSeq(err_raw, ...
              err_struct{gn, tn}.track_loss_rate(rn), ...
              track_loss_ratio(1), 'rms');
            %             %             whisk_val = ;
          end
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            %             gn
            %             rn
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
          end
        end
        %
        %         err_summ{tn} = [err_summ err_all_rounds];
        %         err_summ = [err_summ median(err_all_rounds)];
        
        if do_fair_comparison
          % for fair comparison, only take the top-k results, where k is the
          % number of runs successed with baseline method
          err_all_rounds = mink(err_all_rounds, K_fair);
          err_all_rounds = [err_all_rounds; NaN(round_num - K_fair, 1)];
        end
        
        err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
      end
      
    end
    
    %% Plot Comparison Illustration
    %     assert(size(err_summ, 2) == length(gf_slam_list))
    err_boxplot = [];
    for tn = 1:length(legend_arr)
      err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
    end
    
    metric_type{mn}
    nanmean(err_boxplot, 2)'
    
    subplot(1, length(metric_type), mn)
    errorbar(1:size(err_boxplot, 1), nanmean(err_boxplot, 2), ...
      nanmean(err_boxplot, 2) - prctile(err_boxplot, 25, 2), ...
      nanmean(err_boxplot, 2) - prctile(err_boxplot, 75, 2) )
    title([metric_type{mn}])
    xlim([0, size(err_boxplot, 1)+1])
    
    %     % plot absolute error
    %     h = figure(mn);
    %     clf
    %     %     h = figure('Visible','Off');
    %     %     hold on
    %     aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x', 'whisker', 999); % Advanced box plot
    %     %         boxplot(err_boxplot', 'labels', [100 100]);
    %     hold on
    %     % plot the canonical ORB-SLAM
    %     err_avg = nanmean( err_summ{1}(:, 1) );
    %     err_prc_25 = prctile(err_summ{1}(:, 1), 25);
    %     err_prc_75 = prctile(err_summ{1}(:, 1), 75);
    %     line([0.5, length(lmk_number_list)+0.5], [err_avg, err_avg], 'LineStyle', '--', 'LineWidth', 0.75);
    %     line([0.5, length(lmk_number_list)+0.5], [err_prc_25, err_prc_25], 'LineStyle', ':', 'LineWidth', 0.75);
    %     line([0.5, length(lmk_number_list)+0.5], [err_prc_75, err_prc_75], 'LineStyle', ':', 'LineWidth', 0.75);
    %
    %     % boxplot(err_summ{tn}, 'labels', lmk_number_list);
    %     legend(legend_arr{2:end});
    %     if strcmp(metric_type{mn}, 'track\_loss\_rate')
    %       ylim([0 110]);
    %     end
    %     xlabel('lmk tracked per frame')
    %     ylabel(metric_type{mn})
    
  end
  %
  % save the figure
  set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  %     export_fig(h, [save_path '/Baseline_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
  export_fig(h, [save_path '/MaxVol_' seq_idx '.png']); % , '-r 200');
  %     export_fig(h, [save_path '/Variant_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
  close(h)
  
  %   close all
  
  clear err_struct
  
  %   err_summ = [];
  %   for j=[3:10, 2, 1]
  %     err_all_rounds = [];
  %     for i=1:round_num
  %       %
  %       switch err_type
  %         case 'term_drift'
  %           err_raw = err_struct{j}.term_drift{i};
  %         case 'term_orient'
  %           err_raw = err_struct{j}.term_orient{i};
  %         case 'rel_drift'
  %           err_raw = err_struct{j}.rel_drift{i};
  %         case 'rel_orient'
  %           err_raw = err_struct{j}.rel_orient{i};
  %       end
  %       %
  %       if strcmp(err_type, 'track_loss_rate')
  %         err_metric = err_struct{j}.track_loss_rate(i);
  %       else
  %         err_metric = summarizeMetricFromSeq(err_raw, ...
  %           err_struct{j}.track_loss_rate(i), ...
  %           track_loss_ratio(1), 'rms');
  %       end
  %       %
  %       if ~isempty(err_metric)
  %         err_all_rounds = [err_all_rounds; err_metric];
  %       else
  %         %         err_all_rounds = [err_all_rounds; NaN];
  %       end
  %     end
  %     err_summ = [err_summ mean(err_all_rounds)];
  %     %         err_summ = [err_summ median(err_all_rounds)];
  %   end
  %
  %   for i=1:length(err_summ)
  %     if i == length(err_summ)
  %       fprintf(' %.4f\n', round( err_summ(i), 4) )
  %     else
  %       %       if i > 1 && i <= 4
  %       %         bn = 1;
  %       %         fprintf(' %.3f(%+.1f\\%%) &', round( err_summ(i), 3), ...
  %       %           round( ( err_summ(i) - err_summ(bn) ) / err_summ(bn) * 100, 1) )
  %       %       elseif i > 5 && i <= 8
  %       %         bn = 5;
  %       %         fprintf(' %.3f(%+.1f\\%%) &', round( err_summ(i), 3), ...
  %       %           round( ( err_summ(i) - err_summ(bn) ) / err_summ(bn) * 100, 1) )
  %       %       else
  %       fprintf(' %.4f &', round( err_summ(i), 4) )
  %       %       end
  %     end
  %   end
  %
  %   %   if do_viz
  %   %     warning('off','all')
  %   %
  %   %     %     h=figure();
  %   %     h=figure('Visible','Off');
  %   %     boxFigure_5_Methods(sn, gf_slam_list, track_loss_ratio(1), round_num, ...
  %   %       err_type_list{1}, err_line, err_lineCut_1, err_pointline, ...
  %   %       err_pointlineCut_1, err_point, legend_arr, style);
  %   %
  %   %     warning('on','all')
  %   %     %
  %   %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  %   %     %     mkdir([save_path '/' seq_idx '/']);
  %   %     export_fig(h, [save_path '/BoxFig_' seq_idx '_' track_type{1} '.png'], '-r 200');
  %   %     close(h)
  %   %   end
  
end
