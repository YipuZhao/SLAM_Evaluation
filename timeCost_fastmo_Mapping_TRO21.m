clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');
addpath('/mnt/DATA/SDK/TORSCHE2017')
addpath('/mnt/DATA/SDK/TORSCHE2017/+torsche')

% set up parameters for each benchmark
benchMark = 'EuRoC_RAL19_FastMo_Demo' % 'FPV_RAL19_FastMo_Demo' %
%
% 'Hololens_RAL19_FastMo_Demo' % 'EuRoC_Mono_RAL19_FastMo_Demo'
% 'EuRoC_RAL19_FastMo_OnlFAST' % 'EuRoC_RAL19_FastMo_PreFAST' % 'EuRoC_RAL19_FastMo' %

setParam

do_viz = 1;
%
ref_reload = 1;

% round_num = 1;

plot_time_breakdown = false; % true; %
plot_time_schedule  = false; % true; %
plot_time_bar       = true; % false; %

total_time_summ = cell(length(fast_mo_list), baseline_num, 4);

bar_color = [
  0.93,0.69,0.13;
  0.49,0.18,0.56;
  0.47,0.67,0.19;
  0.30,0.75,0.93;
  ];

for sn = 1:length(seq_list) % [1,5,10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  % load the ground truth track
  track_ref_cam = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 1, maxNormTrans);
  track_ref_imu = loadTrackTUM([ref_path '/' seq_idx '_imu0.txt'], 1, maxNormTrans);
  
  for tn=1:baseline_num
    for fn=1:length(fast_mo_list)
      log_{fn, tn} = [];
      track_loss_rate_{fn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        % Load Log Files
        %         if tn == 1
        %           % msckf
        %           disp(['Loading MSCKF log...'])
        %           [log_{fn, tn}] = loadLog_MSCKF([slam_path_list{tn} ...
        %             num2str(fast_mo_list(fn), '%.01f') '/' ...
        %             baseline_slam_list{table_index(tn)}], ...
        %             rn, seq_idx, log_{fn, tn}, 2);
        %         elseif tn <= 3
        %           % ICE-BA / VINS-Fusion
        %           disp(['Loading ICA-BA & VINS-Fusion log...'])
        %           [log_{fn, tn}] = loadLog_VINS([slam_path_list{tn} ...
        %             num2str(fast_mo_list(fn), '%.01f') '/' ...
        %             baseline_slam_list{table_index(tn)}], ...
        %             rn, seq_idx, log_{fn, tn}, 2);
        %         elseif tn == 4
        %           % SVO
        %           disp(['Loading SVO log...'])
        %           [log_{fn, tn}] = loadLog_SVO_v2([slam_path_list{tn} ...
        %             num2str(fast_mo_list(fn), '%.01f') '/' ...
        %             baseline_slam_list{table_index(tn)}], ...
        %             rn, seq_idx, log_{fn, tn}, 2);
        %         else
        % ORB & GF
        disp(['Loading ORB & GF log...'])
        % load front end logging
        [log_{fn, tn}] = loadLogTUM_hash_stereo([slam_path_list{tn} ...
          num2str(fast_mo_list(fn), '%.01f') '/' ...
          baseline_slam_list{table_index(tn)}], ...
          rn, seq_idx, log_{fn, tn}, 2);
        log_{fn, tn}.timeFrontEnd{rn} = log_{fn, tn}.timeTotal{rn};
        log_{fn, tn}.numMeasur{rn}    = log_{fn, tn}.lmkLocalMap{rn};
        % load back end logging
        if tn == baseline_num
          [log_{fn, tn}] = loadLogTUM_GoodBA_v2([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
        else
          [log_{fn, tn}] = loadLogTUM_GoodBA([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
        end
        %         end
        
        % % Load Track Files
        track_dat = loadTrackTUM([slam_path_list{tn} num2str(fast_mo_list(fn), '%.01f') '/' ...
          baseline_slam_list{table_index(tn)} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], 1, maxNormTrans);
        
        if strcmp(pipeline_type{tn}, 'vins')
          track_ref = track_ref_imu;
        else
          track_ref = track_ref_cam;
        end
        
        % associate the data to the model quat with timestamp
        asso_track_2_ref  = associate_track(track_dat, track_ref, 1, max_asso_val, step_def);
        
        % Compute evaluation metrics
        % stereo config, no scale correction
        [err_struct{fn, tn}.abs_drift{rn}, ...
          err_struct{fn, tn}.abs_orient{rn}, ...
          err_struct{fn, tn}.term_drift{rn}, ...
          err_struct{fn, tn}.term_orient{rn}, ...
          err_struct{fn, tn}.rel_drift{rn}, ...
          err_struct{fn, tn}.rel_orient{rn}, ...
          err_struct{fn, tn}.track_loss_rate(rn), ...
          err_struct{fn, tn}.track_fit{rn}, ...
          err_struct{fn, tn}.scale_fac(rn)] = ...
          getErrorMetric_align_mex(track_dat, track_ref, asso_track_2_ref, ...
          asso_idx, min_match_num, int32(-1), fps, rel_interval_list(1), benchmark_type, ...
          rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
        
        %
        track_loss_rate_{fn, tn} = [track_loss_rate_{fn, tn}; ...
          max(0, min(1, 1 - size(log_{fn, tn}.timeStamp{rn}, 1) / ...
          (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
        
      end
    end
  end
  
  %% Time cost breakdown
  if plot_time_breakdown
    %
    metric_type = {'timeBackEnd'; 'timeNewKeyFrame'; 'timeMapCulling'; 'timeMapTriangulate';
      'timeSrhNeighbor'; 'timeLocalBA'; %'numPoseState'; 'numLmkState';
      'timePredict'; 'timeInsertVertex'; 'timeJacobian'; 'timeQuery'; 'timeSchur';
      'timePermute'; 'timeCholesky'; 'timePostProc'; 'timeOptimization'; };
    h = figure;
    clf
    for mn=1:length(metric_type)
      subplot(4,4,mn)
      %
      max_length = 0;
      for fn=1:length(fast_mo_list)
        %       err_summ{fn} = [];
        %
        for tn=1:baseline_num
          err_all_rounds = [];
          %
          for rn=1:round_num
            %
            switch mn
              case 1
                err_raw = log_{fn, tn}.timeBackEnd{rn};
              case 2
                err_raw = log_{fn, tn}.timeNewKeyFrame{rn};
              case 3
                err_raw = log_{fn, tn}.timeMapCulling{rn};
              case 4
                err_raw = log_{fn, tn}.timeMapTriangulate{rn};
              case 5
                err_raw = log_{fn, tn}.timeSrhNeighbor{rn};
              case 6
                err_raw = log_{fn, tn}.timeLocalBA{rn};
                %             case 7
                %               err_raw = log_{fn, tn}.numPoseState{rn};
                %             case 8
                %               err_raw = log_{fn, tn}.numLmkState{rn};
              case 7
                err_raw = log_{fn, tn}.timePrediction{rn};
              case 8
                err_raw = log_{fn, tn}.timeInsertVertex{rn};
              case 9
                err_raw = log_{fn, tn}.timeJacobian{rn};
              case 10
                err_raw = log_{fn, tn}.timeQuery{rn};
              case 11
                err_raw = log_{fn, tn}.timeSchur{rn};
              case 12
                err_raw = log_{fn, tn}.timePermute{rn};
              case 13
                err_raw = log_{fn, tn}.timeCholesky{rn};
              case 14
                err_raw = log_{fn, tn}.timePostProc{rn};
              case 15
                err_raw = log_{fn, tn}.timeOptimization{rn};
            end
            %
            if ~isempty(err_raw)
              %             err_all_rounds = [err_all_rounds; mean(err_raw(err_raw >= 0))];
              err_all_rounds = [err_all_rounds; err_raw(err_raw >= 0)];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
          end
          %
          %           err_summ{fn} = cat(2, err_summ{fn}, ...
          %             [err_all_rounds nan(max_length-length(err_all_rounds), 1)]);
          err_summ{fn, tn} = err_all_rounds;
          if length(err_all_rounds) > max_length
            max_length = length(err_all_rounds);
          end
        end
      end
      
      %% Plot Comparison Illustration
      %     assert(size(err_summ, 2) == length(gf_slam_list))
      err_boxplot = [];
      for fn=1:length(fast_mo_list)
        for tn=1:baseline_num
          err_boxplot = cat(2, err_boxplot, [err_summ{fn, tn}; nan(max_length-length(err_summ{fn, tn}), 1)]);
        end
      end
      % plot absolute error
      %     subplot(2, 2, mn)
      boxplot(err_boxplot, 'labels', repmat(legend_arr, length(fast_mo_list), 1), 'whisker', 10);
      set(gca, 'XTickLabelRotation', 45);
      hold on
      y_top = max(max(err_boxplot));
      for fn=1:length(fast_mo_list)-1
        plot([fn*baseline_num+0.5, fn*baseline_num+0.5], [0, y_top], ...
          '--r', 'LineWidth', 1.5)
        %
        text(fn*baseline_num+0.5-baseline_num*0.5, y_top, ...
          ['FastMo x' num2str(fast_mo_list(fn), '%.01f')], ...
          'HorizontalAlignment', 'center')
      end
      text(length(fast_mo_list)*baseline_num+0.5-baseline_num*0.5, y_top, ...
        ['FastMo x' num2str(fast_mo_list(end), '%.01f')], ...
        'HorizontalAlignment', 'center')
      %     if mn == 1
      %     legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
      %     end
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      ylim([0 y_top * 1.01])
      xlabel('config')
      ylabel([metric_type{mn}])
    end
    %
    % save the figure
    %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
    %     close(h)
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/GoodGraph_breakdown_' seq_idx '.png']); % , '-r 200');
    
  end
  
  %% Profile example
  if plot_time_schedule
    %
    h = figure;
    clf
    for fn=1:length(fast_mo_list)
      subplot(length(fast_mo_list), 4, [(fn-1)*4+1, (fn-1)*4+2])
      hold on
      %
      rn = 1;
      for tn = 1:baseline_num
        %
        x = log_{fn, tn}.timeStampBack{rn};
        x = x - repmat(log_{fn, tn}.timeStampBack{rn}(1), length(x), 1);
        y = log_{fn, tn}.timeBackEnd{rn};
        % y = log_{fn, tn}.timeLocalBA{rn};
        vld_idx = find(y>=0);
        for i=1:length(vld_idx)
          line([x(vld_idx(i)) x(vld_idx(i))+y(vld_idx(i))/1000], ...
            [tn tn], 'Color', marker_color{tn}, ...
            'LineWidth', 2, 'MarkerSize', 10);
        end
        %       set(gca, 'XScale', 'log')
        
        % set proc time
        % T = torsche.taskset(y(vld_idx)');
        % start = x(vld_idx)';
        % processor = ones(size(vld_idx'));
        % description = 'a handmade schedule';
        % add_schedule(T,description,start,T.ProcTime,processor);
        % get_schedule(T);
        % plot(T);
        
        % compute overlap / gap
        gap_arr{tn} = [];
        coll_arr{tn} = [];
        for i=2:length(vld_idx)
          gap = x(vld_idx(i)) - x(vld_idx(i-1))+y(vld_idx(i-1))/1000;
          if gap > 0
            gap_arr{tn} = [gap_arr{tn}; gap];
          else
            coll_arr{tn} = [coll_arr{tn}; -gap];
          end
        end
        gap_arr{tn} = gap_arr{tn} / x(end);
        coll_arr{tn} = coll_arr{tn} / x(end);
      end
      
      % add legend and other stuff
      %
      legend_style = gobjects(length(legend_arr),1);
      for i=1:length(legend_arr)
        legend_style(i) = plot(nan, nan, marker_styl{i}, ...
          'color', marker_color{i});
      end
      %
      legend(legend_style, legend_arr, 'Location', 'best')
      
      legend boxoff
      xlabel('Duration (sec)')
      ylabel('Local BA Slots')
      ylim([0 baseline_num + 1])
      
      subplot(length(fast_mo_list), 4, (fn-1)*4+3)
      %     max_length = 0;
      %     %     group_idx = {};
      %     for tn=4:6 % 1:baseline_num
      %       if max_length < length(gap_arr{tn})
      %         max_length = length(gap_arr{tn});
      %       end
      %       %       group_idx = {group_idx, legend_arr{tn}};
      %     end
      %     summ_arr = [];
      %     for tn=4:6 % 1:baseline_num
      %       summ_arr = [summ_arr [gap_arr{tn}; nan(max_length - length(gap_arr{tn}), 1)]];
      %     end
      %     boxplot(summ_arr);
      hold on
      for tn = 1:baseline_num
        scatter(tn, sum(gap_arr{tn}));
      end
      
      subplot(length(fast_mo_list), 4, (fn-1)*4+4)
      %     max_length = 0;
      %     %     group_idx = {};
      %     for tn=4:6 % 1:baseline_num
      %       if max_length < length(coll_arr{tn})
      %         max_length = length(coll_arr{tn});
      %       end
      %       %       group_idx = {group_idx, legend_arr{tn}};
      %     end
      %     summ_arr = [];
      %     for tn=4:6 % 1:baseline_num
      %       summ_arr = [summ_arr [coll_arr{tn}; nan(max_length - length(coll_arr{tn}), 1)]];
      %     end
      %     boxplot(summ_arr);
      hold on
      for tn = 1:baseline_num
        scatter(tn, sum(coll_arr{tn}));
      end
      
    end
    
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/GoodGraph_profile_' seq_idx '.png']); % , '-r 200');
    
  end
  
  
  %% Bar example
  if plot_time_bar
    %
    for fn=1:length(fast_mo_list)
      h = figure;
      clf
      %
      rn = 1;
      for tn = 1:baseline_num
        subplot(baseline_num, 1, tn)
        hold on
        %
        x = log_{fn, tn}.timeStampBack{rn};
        if isempty(x)
          continue ;
        end
        x = x - repmat(log_{fn, tn}.timeStampBack{rn}(1), length(x), 1);
        
        %         y1 = log_{fn, tn}.timeNewKeyFrame{rn};
        %         y2 = log_{fn, tn}.timeMapCulling{rn};
        %         y3 = log_{fn, tn}.timeMapTriangulate{rn};
        %         y4 = log_{fn, tn}.timeSrhNeighbor{rn};
        %         %         y5 = log_{fn, tn}.timePrediction{rn} + log_{fn, tn}.timeInsertVertex{rn} + ...
        %         %           log_{fn, tn}.timeJacobian{rn} + log_{fn, tn}.timeQuery{rn} + ...
        %         %           log_{fn, tn}.timeSchur{rn} + log_{fn, tn}.timePermute{rn} + ...
        %         %           log_{fn, tn}.timeCholesky{rn} + log_{fn, tn}.timePostProc{rn};
        %         %         y6 = log_{fn, tn}.timeLocalBA{rn} - y5;
        %         if tn >= 2
        %           y6 = log_{fn, tn}.timeOptimization{rn};
        %           y5 = log_{fn, tn}.timeLocalBA{rn} - y6;
        %         else
        %           y6 = log_{fn, tn}.timeLocalBA{rn};
        %           y5 = zeros(size(log_{fn, tn}.timeLocalBA{rn}));
        %         end
        %         vld_idx = find(log_{fn, tn}.timeBackEnd{rn}>=0);
        %
        %         y = [y1 y2 y3 y4 y5 y6];
        %
        y1 = log_{fn, tn}.timeNewKeyFrame{rn} + log_{fn, tn}.timeMapCulling{rn} + log_{fn, tn}.timeMapTriangulate{rn};
        y2 = log_{fn, tn}.timeSrhNeighbor{rn};
        if tn >= 2
          y4 = log_{fn, tn}.timeOptimization{rn};
          y3 = log_{fn, tn}.timeLocalBA{rn} - y4;
        else
          y4 = log_{fn, tn}.timeLocalBA{rn};
          y3 = zeros(size(log_{fn, tn}.timeLocalBA{rn}));
        end
        vld_idx = find(log_{fn, tn}.timeBackEnd{rn}>=0);
        
        y = [y1 y2 y3 y4];
        % y = [y2 y3 y4 y1];
        yyaxis left;
        b = bar(x(vld_idx), y(vld_idx, :), 'stacked', 'BarWidth', 3.0);
        for i = 1:4
          b(i).FaceColor = 'flat';
          b(i).CData = bar_color(i, :);
        end
        
        total_time_summ{fn, tn, 1} = [total_time_summ{fn, tn, 1}; y1];
        total_time_summ{fn, tn, 2} = [total_time_summ{fn, tn, 2}; y2];
        total_time_summ{fn, tn, 3} = [total_time_summ{fn, tn, 3}; y3];
        total_time_summ{fn, tn, 4} = [total_time_summ{fn, tn, 4}; y4];
        
        %         if tn == baseline_num
        %           hold on
        %           tmp_budget = log_{fn, tn}.timeBudget{rn};
        %           tmp_budget( log_{fn, tn}.timeBudget{rn} > 800 ) = 800;
        %           plot(x, tmp_budget, '--g')
        %         end
        
        ylabel('Time Cost (ms)')
        %         ylim([0 1000])
        ylim([0 max_y_lim])
        
        %         if tn == baseline_num
        %           plot(x(vld_idx), log_{fn, tn}.timeBudget{rn}(vld_idx, :), 'r--')
        %
        %           x = log_{fn, tn}.timeBudget{rn}(vld_idx, :);
        %           y = sum(y(vld_idx, :), 2);
        %           inl_idx = x < 3000;
        %           x = x(inl_idx);
        %           y = y(inl_idx);
        %
        %           figure
        %           hold on
        %           scatter(x,y,'x')
        %           %           A=[x .* x .* x x .* x x repmat(1, length(x), 1)]
        %           A=[x repmat(1, length(x), 1)]
        %           coe = A\y
        %           u=[0:10:1000];
        %           %           v=coe(1) * (u .* u .* u) + coe(2) * (u .* u) + coe(3) * u + coe(4);
        %           v=coe(1) * u + coe(2);
        %           plot(u, v, 'r--')
        %           xlim([0 250]); xlabel('free KF num');
        %           ylim([0 1500]); ylabel('BA time cost (ms)');
        %
        %         end
        
        %         set(gca, 'YScale', 'log')
        hold on
        yyaxis right;
        %         plot(err_struct{fn, tn}.abs_drift{rn}(:,1) - repmat(log_{fn, tn}.timeStampBack{rn}(1), ...
        %           length(err_struct{fn, tn}.abs_drift{rn}), 1), err_struct{fn, tn}.abs_drift{rn}(:,2), '--r')
        %         plot(err_struct{fn, tn}.rel_drift{rn}(:,1) - repmat(log_{fn, tn}.timeStampBack{rn}(1), ...
        %           length(err_struct{fn, tn}.rel_drift{rn}), 1), err_struct{fn, tn}.rel_drift{rn}(:,2), '--r')
        %         plot(log_{fn, tn}.timeStamp{rn} - repmat(log_{fn, tn}.timeStamp{rn}(1), ...
        %           length(log_{fn, tn}.timeStamp{rn}), 1), log_{fn, tn}.lmkTrackMap{rn}, '--r');
        plot(x, log_{fn, tn}.numPoseState{rn} ./ 6, '--r');
        % plot(x, log_{fn, tn}.numPoseState{rn} + log_{fn, tn}.numLmkState{rn}, '--b');
        
        % add legend and other stuff
        %
        %         legend_style = gobjects(length(legend_arr),1);
        %         for i= 1:length(legend_arr)
        %           legend_style(i) = plot(nan, nan, marker_styl{i}, ...
        %             'color', marker_color{i});
        %         end
        %         %
        %         legend(legend_style, legend_arr, 'Location', 'best')
        if tn == 1
          %           legend({'Init New KF'; 'Map Culling'; 'Triangulate'; 'Add. Search'; 'Good Graph'; 'Optim.'; }, ...
          %             'Location', 'best')
          legend({'Insertion'; 'Additional Search'; 'Graph Selection (Covisibility/Good Graph)'; 'BA Solving'; }, ...
            'Location', 'best')
          % legend({'Additional Search'; 'Good Graph'; 'Local Optimization'; 'Misc.'; }, ...
          %             'Location', 'best')
          legend boxoff
        end
        
        xlabel('Duration (sec)')
        ylabel('Local BA Scale (KFs)')
        ylim([0 140])
        % ylim([0 17000])
        %         ylim([0 1.0])
        grid on
      end
      
      set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
      export_fig(h, [save_path '/GoodGraph_bar_' seq_idx '_x' num2str(fast_mo_list(fn)) '.fig']);
      export_fig(h, [save_path '/GoodGraph_bar_' seq_idx '_x' num2str(fast_mo_list(fn)) '.png']);
      
    end
  end
  
  close all
  
end

% total_time_summ = cell(length(fast_mo_list), baseline_num, 4);
y = cellfun(@nanmean, total_time_summ);
% y = cellfun(@quantile, total_time_summ, num2cell(ones(size(total_time_summ)) * 0.75));

%
h = figure;
clf
for fn = 1 : length(fast_mo_list)
  subplot(length(fast_mo_list), 1, fn);
  %
  x = categorical({'GF'; 'GF+GG'; }');
  b = barh(x, reshape(y(fn, :, :),2,[]), 'stacked')
  xlabel(['Tracking Time per Frame (ms)'])
  
  b(1).FaceColor = bar_color(1, :);
  b(2).FaceColor = bar_color(2, :);
  b(3).FaceColor = bar_color(3, :);
  b(4).FaceColor = bar_color(4, :);
  
  %   xlim([0 30])
  legend({'Init'; 'Additional Search'; 'Good Graph'; 'Local Optimization';})
end

%     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
export_fig(h, [save_path '/Bar_TotalTimeCost_Stereo.png']); % , '-r 200');
