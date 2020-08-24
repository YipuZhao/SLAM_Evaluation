clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');
% addpath('/mnt/DATA/SDK/DataDensity');

% set up parameters for each benchmark
benchMark = 'EuRoC_TRO21_Jetson_OnlFAST' % 'EuRoC_TRO21_Jetson_PreFAST' % 
% 'EuRoC_TRO21_FastMo_OnlFAST' % 'EuRoC_TRO21_FastMo_PreFAST' %
%
% 'EuRoC_TRO21_FastMo_MinSet' % 'EuRoC_TRO21_FastMo' % 'FPV_TRO21_FastMo_OnlFAST' %
% 'EuRoC_Mono_TRO21_FastMo_OnlFAST' % 'Hololens_TRO21_FastMo_OnlFAST'

setParam

% track_type = {'KeyFrame';};
% param of evaluation
metric_type = {
  'TrackLossRate';
  'RMSE';
  %   'ScaleError';
  %   'RPE3';
  %   'ROE3';
  %   %
  %   'KF';
  %   'MP';
  %   'KF+MP';
  };

% do_fair_comparison = false; % true; %
do_perc_plot = true; % false; %
do_box_plot = true; % false; %
plot_summary = false; % true; %
scatter_buf = cell(length(metric_type), length(slam_path_list));
table_buf = cell(length(metric_type), length(slam_path_list)*length(fast_mo_list));

opt_time_only = false; % true;

for sn = 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref_cam = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 1, maxNormTrans);
  track_ref_imu = loadTrackTUM([ref_path '/' seq_idx '_imu0.txt'], 1, maxNormTrans);
  
  %% go through each fast mo speed
  for fn = 1:length(fast_mo_list)
    %% grab the baseline results
    for tn = 1:baseline_num
      if strcmp(pipeline_type{tn}, 'vins')
        track_ref = track_ref_imu;
      else
        track_ref = track_ref_cam;
      end
      for gn=1:length(baseline_slam_list)
        %%
        %         log_{gn, tn} = [];
        for rn = 1:round_num
          % Load Track Files
          track_dat = loadTrackTUM([slam_path_list{tn} num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{gn} '_Round' num2str(rn) '/' seq_idx '_' track_type{1} 'Trajectory.txt'], ...
            1, maxNormTrans);
          
          % associate the data to the model quat with timestamp
          asso_track_2_ref  = associate_track(track_dat, track_ref, 1, max_asso_val, step_def);
          
          % Compute evaluation metrics
          if isempty(track_dat) || isempty(track_ref)
            err_struct{fn, (gn-1)*baseline_num+tn}.scale_fac(rn) = 1.0;
            err_struct{fn, (gn-1)*baseline_num+tn}.abs_drift{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.abs_orient{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.term_drift{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.term_orient{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.rel_drift{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.rel_orient{rn} = [];
            err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn) = 1.0;
            err_struct{fn, (gn-1)*baseline_num+tn}.track_fit{rn} = [];
          else
            if strcmp(sensor_type, 'stereo')
              % stereo config, no scale correction
              [err_struct{fn, (gn-1)*baseline_num+tn}.abs_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.abs_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.term_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.term_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.rel_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.rel_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn), ...
                err_struct{fn, (gn-1)*baseline_num+tn}.track_fit{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.scale_fac(rn)] = ...
                getErrorMetric_align_mex(track_dat, track_ref, asso_track_2_ref, ...
                asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
                rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
            else
              % mono config, with scale correction
              [err_struct{fn, (gn-1)*baseline_num+tn}.abs_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.abs_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.term_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.term_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.rel_drift{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.rel_orient{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn), ...
                err_struct{fn, (gn-1)*baseline_num+tn}.track_fit{rn}, ...
                err_struct{fn, (gn-1)*baseline_num+tn}.scale_fac(rn)] = ...
                getErrorMetric_align_mex(track_dat, track_ref, asso_track_2_ref, ...
                asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
                rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
            end
          end
          
          %         % Load Log Files
          %         if tn <= baseline_orb
          %           disp(['Loading ORB-SLAM log...'])
          %           [log_{gn, tn}] = loadLogTUM_BA([slam_path_list{tn} baseline_slam_list{gn}], ...
          %             rn, seq_idx, log_{gn, tn}, 1); % seq_start_time(sn) * fps);
          %         else
          %           disp(['Loading VINS-Fusion log...'])
          %           [log_{gn, tn}] = loadLogVINSFusion([slam_path_list{tn} baseline_slam_list{gn}], ...
          %             rn, seq_idx, log_{gn, tn}, 1); % seq_start_time(sn) * fps);
          %         end
          
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
    
    %% plot the curve per method & config
    for tn = 1:baseline_num
      for gn=1:length(baseline_slam_list)
        base_mean = [];
        base_std = [];
        base_lower = [];
        base_upper = [];
        base_plot_idx = [];
        base_fastmo_summ{mn, tn, gn} = [];
        %
        for fn = 1:length(fast_mo_list)
          if isempty(err_struct{fn, (gn-1)*baseline_num+tn})
            continue
          end
          
          if tn == vins_idx
            K_fair(fn) = sum(err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate < 0.6);
          else
            K_fair(fn) = sum(err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate < track_loss_ratio(1));
          end
          
          err_all_rounds = [];
          time_all_rounds = [];
          drop_plot = false;
          for rn=1:round_num
            switch metric_type{mn}
              case 'RMSE'
                err_raw = err_struct{fn, (gn-1)*baseline_num+tn}.abs_drift{rn};
              case 'RPE3'
                err_raw = err_struct{fn, (gn-1)*baseline_num+tn}.rel_drift{rn};
              case 'ROE3'
                err_raw = err_struct{fn, (gn-1)*baseline_num+tn}.rel_orient{rn};
                %
              case 'KF'
                err_raw = 6 * ( log_{fn, (gn-1)*baseline_num+tn}.numKF{rn} );
              case 'MP'
                err_raw = 3 * ( log_{fn, (gn-1)*baseline_num+tn}.numPoint{rn} );
              case 'KF+MP'
                err_raw = 6 * ( log_{fn, (gn-1)*baseline_num+tn}.numKF{rn} ) + ...
                  3 * ( log_{fn, (gn-1)*baseline_num+tn}.numPoint{rn} );
            end
            
            if strcmp(metric_type{mn}, 'TrackLossRate')
              err_metric = err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn) * 100.0;
            elseif strcmp(metric_type{mn}, 'ScaleError')
              err_metric = abs(1 - err_struct{fn, (gn-1)*baseline_num+tn}.scale_fac(rn)) * 100.0;
            elseif strcmp(metric_type{mn}, 'KF') || strcmp(metric_type{mn}, 'MP') || strcmp(metric_type{mn}, 'KF+MP')
              err_metric = mean(err_raw);
            else
              if tn == vins_idx
                err_metric = summarizeMetricFromSeq(err_raw, ...
                  err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn), ...
                  0.6, 'rms');
              else
                err_metric = summarizeMetricFromSeq(err_raw, ...
                  err_struct{fn, (gn-1)*baseline_num+tn}.track_loss_rate(rn), ...
                  track_loss_ratio(1), 'rms');
              end
            end
            
            if ~isempty(err_metric)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              %             gn
              %             rn
              disp 'error! no valid data for plot!'
              %           err_all_rounds = [err_all_rounds; NaN];
              %           time_all_rounds = [time_all_rounds; NaN];
            end
          end
          %       if drop_plot == false
          % grab the mean error across all valid runs
          base_mean = [base_mean nanmean(err_all_rounds)];
          %
          base_std = [base_std nanstd(err_all_rounds)];
          %
          base_lower = [base_lower prctile(err_all_rounds, lower_prc)];
          %
          base_upper = [base_upper prctile(err_all_rounds, upper_prc)];
          %       end
          if round_num - K_fair(fn) < track_fail_thres
            base_plot_idx = [base_plot_idx fn];
          end
          % draw a point to the graph
          %       scatter(time_avg, err_avg, marker_styl{tn})
          
          if round_num - K_fair(fn) < track_fail_thres
            base_fastmo_summ{mn, tn, gn} = [base_fastmo_summ{mn, tn, gn}; err_all_rounds'];
          else
            base_fastmo_summ{mn, tn, gn} = [base_fastmo_summ{mn, tn, gn}; nan([1 round_num])];
          end
          
          if exist('table_index')
            if table_index(tn) == gn
              if round_num - K_fair(fn) < track_fail_thres
                table_buf{mn, (fn-1)*baseline_num+tn} = [
                  table_buf{mn, (fn-1)*baseline_num+tn} ...
                  [nanmean(err_all_rounds); nanstd(err_all_rounds)]
                  ];
              else
                table_buf{mn, (fn-1)*baseline_num+tn} = [
                  table_buf{mn, (fn-1)*baseline_num+tn} ...
                  [nan; nan]
                  ];
              end
            end
            
            %           if ismember(table_index(tn), base_plot_idx)
            %             table_buf{mn, (fn-1)*baseline_num+tn} = [
            %               table_buf{mn, (fn-1)*baseline_num+tn} ...
            %               [base_mean(table_index(tn)); base_std(table_index(tn))]
            %               ];
            %           else
            %             table_buf{mn, (fn-1)*baseline_num+tn} = [
            %               table_buf{mn, (fn-1)*baseline_num+tn} ...
            %               [nan; nan]
            %               ];
            %           end
          end
        end
        
        if do_perc_plot
          errorbar(fast_mo_list(base_plot_idx), base_mean(base_plot_idx), ...
            base_mean(base_plot_idx) - base_lower(base_plot_idx), ...
            base_upper(base_plot_idx) - base_mean(base_plot_idx), ...
            marker_styl{tn}, 'color', marker_color{tn},...
            'ButtonDownFcn', {@errBarCallback, baseline_number_list(gn)})
          title(['mean - ' num2str(lower_prc) '% - ' num2str(upper_prc) '%'])
        else
          plot(fast_mo_list(base_plot_idx), base_mean(base_plot_idx), ...
            marker_styl{tn}, 'color', marker_color{tn})
          title('average')
        end
        
        scatter_buf{mn, tn} = [scatter_buf{mn, tn} ...
          [fast_mo_list(base_plot_idx); base_mean(base_plot_idx); ...
          fast_mo_list(base_plot_idx); base_std(base_plot_idx)]];
        
      end
      
      xlim([fast_mo_list(1)-1, fast_mo_list(end)+1]);
      
      %% add legend and other stuff
      %
      legend_style = gobjects(length(legend_arr),1);
      for i=1:length(legend_arr)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', marker_color{i});
      end
      %
      legend(legend_style, legend_arr, 'Location', 'best')
      
      legend boxoff
      xlabel('Fast-Mo Speed (times)')
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
          %
        case 'KF'
          ylabel('KF (x6)')
        case 'MP'
          ylabel('MP (x3)')
        case 'KF+MP'
          ylabel('KF+MP (x1)')
      end
    end
    
    %     set(h(mn), 'Units', 'normalized', 'Position', [0,0,1,1]);
    if opt_time_only
      export_fig(h(mn), [save_path '/Debug_OptTime_vs_' metric_type{mn} '_' seq_idx '.png']);
    else
      if strcmp(sensor_type, 'stereo')
        export_fig(h(mn), [save_path '/Stereo_FastMo_vs_' metric_type{mn} '_' seq_idx '.fig']);
        export_fig(h(mn), [save_path '/Stereo_FastMo_vs_' metric_type{mn} '_' seq_idx '.png']);
      else
        export_fig(h(mn), [save_path '/Mono_FullTime_vs_' metric_type{mn} '_' seq_idx '.png']);
        export_fig(h(mn), [save_path '/Mono_FullTime_vs_' metric_type{mn} '_' seq_idx '.fig']);
      end
    end
    
  end
  
  %% plot the boxplot per sequence
  for mn=1:length(metric_type)
    boxplot_data_summ = [];
    for tn = 1:4
      gn = table_index(tn);
      boxplot_data_summ = cat(3, boxplot_data_summ, reshape(base_fastmo_summ{mn, tn, gn}, [size(base_fastmo_summ{mn, tn, gn}) 1]));
    end
    
    h(mn) = figure(mn);
    clf
    aboxplot(boxplot_data_summ, 'labels', legend_arr(1:4));
    legend({'1x fast-mo';'2x fast-mo';'3x fast-mo';'4x fast-mo';'5x fast-mo';});
    legend boxoff
    xlabel('VSLAM Methods');
    switch metric_type{mn}
      case 'TrackLossRate'
        ylabel('Un-Tracked Frame (%)')
      case 'RMSE'
        set(gca, 'YScale', 'log')
        ylabel('RMSE (m)')
        ylim([0.01 0.5])
    end
    
    if strcmp(sensor_type, 'stereo')
      export_fig(h(mn), [save_path '/Stereo_GFVar_Boxplot_' metric_type{mn} '_' seq_idx '.fig']);
      export_fig(h(mn), [save_path '/Stereo_GFVar_Boxplot_' metric_type{mn} '_' seq_idx '.png']);
    else
      export_fig(h(mn), [save_path '/Mono_GFVar_Boxplots_' metric_type{mn} '_' seq_idx '.png']);
      export_fig(h(mn), [save_path '/Mono_GFVar_Boxplot_' metric_type{mn} '_' seq_idx '.fig']);
    end
    
    %
    
    boxplot_data_summ = [];
    for tn = 4:baseline_num
      gn = table_index(tn);
      boxplot_data_summ = cat(3, boxplot_data_summ, reshape(base_fastmo_summ{mn, tn, gn}, [size(base_fastmo_summ{mn, tn, gn}) 1]));
    end
    
%     if size(boxplot_data_summ, 1) > 1
      h(mn) = figure(mn);
      clf
      aboxplot(boxplot_data_summ, 'labels', legend_arr(4:baseline_num));
      legend({'1x fast-mo';'2x fast-mo';'3x fast-mo';'4x fast-mo';'5x fast-mo';});
      legend boxoff
      xlabel('VSLAM Methods');
      switch metric_type{mn}
        case 'TrackLossRate'
          ylabel('Un-Tracked Frame (%)')
        case 'RMSE'
          set(gca, 'YScale', 'log')
          ylabel('RMSE (m)')
          ylim([0.01 1.5])
      end
      
      if strcmp(sensor_type, 'stereo')
        export_fig(h(mn), [save_path '/Stereo_Baselines_Boxplot_' metric_type{mn} '_' seq_idx '.fig']);
        export_fig(h(mn), [save_path '/Stereo_Baselines_Boxplot_' metric_type{mn} '_' seq_idx '.png']);
      else
        export_fig(h(mn), [save_path '/Mono_Baselines_Boxplots_' metric_type{mn} '_' seq_idx '.png']);
        export_fig(h(mn), [save_path '/Mono_Baselines_Boxplot_' metric_type{mn} '_' seq_idx '.fig']);
      end
    end
%   end
  
  %% plot the track at an example run
  figure;
  hold on
  plot3(track_ref(:,2), track_ref(:,3), track_ref(:,4), '-y')
  %   plot(track_ref(:,2), track_ref(:,4), '-b')
  hold on
  %   gn = 2;
  valid_idx = [];
  for i=1:length(slam_path_list)
    if ~isempty(err_struct{fn, (table_index(i)-1)*baseline_num+i}.track_fit{1})
      plot3(err_struct{fn, (table_index(i)-1)*baseline_num+i}.track_fit{1}(1, :), ...
        err_struct{fn, (table_index(i)-1)*baseline_num+i}.track_fit{1}(2, :), ...
        err_struct{fn, (table_index(i)-1)*baseline_num+i}.track_fit{1}(3, :), ...
        '--.', 'Color', marker_color{i})
      %     plot(err_struct{1,i}.track_fit{1}(1, :), err_struct{1,i}.track_fit{1}(3, :), '--.')
      valid_idx = [valid_idx, i];
    end
  end
  axis equal
  legend([{'GT'}; legend_arr(valid_idx)])
  export_fig(gcf, [save_path '/Track3D_' seq_idx '.fig']);
  export_fig(gcf, [save_path '/Track3D_' seq_idx '.png']);
  
  close all
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
    xlabel('Fast-Mo Speed (times)')
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
        %
      case 'KF'
        ylabel('KF (x6)')
      case 'MP'
        ylabel('MP (x3)')
      case 'KF+MP'
        ylabel('KF+MP (x1)')
    end
  end
end


%%
for i=1:length(metric_type)
  fprintf('\n==================%s==================\n', metric_type{i});
  for l=1:length(fast_mo_list)
    for j=1:length(slam_path_list)
      avg_buf = [];
      fprintf('& %s & ', legend_arr{j});
      for k=1:length(seq_list)
        %     [time_mean(table_index(tn)); subset_mean(table_index(tn)); ...
        %       time_std(table_index(tn)); subset_std(table_index(tn))]];
        % (fn-1)*baseline_num+tn
        %         if k == length(seq_list)
        %           fprintf(' %.3f \\\\ \n', round( table_buf{i, (l-1)*baseline_num+j}(1, k), 4) )
        %         else
        %           fprintf(' %.3f &', round( table_buf{i, (l-1)*baseline_num+j}(1, k), 4) )
        %         end
        fprintf(' %.3f &', round( table_buf{i, (l-1)*baseline_num+j}(1, k), 4) )
        avg_buf = [avg_buf table_buf{i, (l-1)*baseline_num+j}(1, k)];
      end
      %
      fprintf(' %.3f \\\\ \n', round( nanmean(avg_buf), 4) )
    end
  end
end

disp 'finish!'
