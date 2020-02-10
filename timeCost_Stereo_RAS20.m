clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'TSRB_Stereo_RAS19_Desktop' % 'TSRB_RGBD_RAS19_Desktop' %
% 'RobotCar_RAL19_Desktop' % 'NewCollege_RAL19_Desktop'

setParam

mkdir(save_path)

do_viz = 1;
%
ref_reload = 1;

% round_num = 1;

plot_total_time_stat    = true;
plot_lmk_num            = false; % true; %
plot_gf_time_trend      = true; % false; %
plot_gf_time_stat       = false; % true; %

total_time_summ = cell(length(slam_path_list), 7);

for sn = 1:length(seq_list) % [1, 4, 10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  for tn=1:baseline_num
    for gn=1:length(gf_slam_list) % 1:length(baseline_slam_list)
      log_{gn, tn} = [];
      track_loss_rate_{gn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        % Load Log Files
        disp(['Loading ORB-SLAM log...'])
        [log_{gn, tn}] = loadLogTUM_hash_stereo([slam_path_list{tn} baseline_slam_list{tn}], ...
          rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        %
        track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
          max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
          (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
      end
    end
  end
  
  for tn=baseline_num+1:length(slam_path_list)
    for gn=1:length(gf_slam_list)
      log_{gn, tn} = [];
      track_loss_rate_{gn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        % Load Log Files
        disp(['Loading GF log...'])
        [log_{gn, tn}] = loadLogTUM_hash_stereo([slam_path_list{tn} gf_slam_list{gn}], ...
          rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        %
        track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
          max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
          (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
      end
    end
  end
  
  %% plot hist of total tracking time
  if plot_total_time_stat
    for tn=[1:length(slam_path_list)] % 1:length(slam_path_list)
      gn = table_index(tn) % table_index(end) % 3;
      %
      for mn = 1:7
        err_all_rounds = [];
        %
        for rn=1:round_num
          %
          switch mn
            case 1
              err_raw = log_{gn, tn}.timeOrbExtr{rn};
              % case 2 reserved for stereo matching time
            case 3
              err_raw = log_{gn, tn}.timeTrackMotion{rn} + log_{gn, tn}.timeTrackFrame{rn};
            case 4
              err_raw = log_{gn, tn}.timeMapMatch{rn};
            case 5
              %               if tn == 1
              err_raw = log_{gn, tn}.timeMapOpt{rn};
              %               else
              %                 err_raw = log_{gn, tn}.timeOptim{rn};
              %               end
            case 6
              err_raw = log_{gn, tn}.timeDirect{rn};
            case 7
              err_raw = log_{gn, tn}.timeTotal{rn};
          end
          
          %           err_metric = mean(err_raw);
          %
          if ~isempty(err_raw) && track_loss_rate_{gn, tn}(rn) < track_loss_ratio(1)
            err_all_rounds = [err_all_rounds; err_raw];
          else
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
          end
        end
        %
        total_time_summ{tn, mn} = [total_time_summ{tn, mn}; err_all_rounds];
      end
    end
    
    %     % Plot Comparison Illustration
    %     x = categorical({'ORB'; 'svo2'; 'DSO'; 'GF-ORB';}');
    %     x = reordercats(x, {'GF-ORB' 'ORB' 'DSO' 'svo2' });
    %     %
    %     h = figure(1);
    %     clf
    %     barh(x, total_time_summ, 'stacked')
    %     xlabel(['Tracking Time per Frame (ms)'])
    %     xlim([0 30])
    %     legend({'Feature Extr.'; 'Init Tracking'; 'Feature Matching'; 'Geom. Optim.'; 'Direct Optim.'})
    %
    % %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     export_fig(h, [save_path '/Bar_TotalTimeCost_' seq_idx '.png']); % , '-r 200');
  end
  
  %
  %   min_box_size = inf;
  %   figure(1)
  %   clf
  %   subplot(1,4,[1,2,3])
  %   hold on
  %   for i=1:length(slam_path_list)
  %     plot(log_{1, i}.timeStamp{1, 1} - repmat(log_{1, i}.timeStamp{1, 1}(1), ...
  %       length(log_{1, i}.timeStamp{1, 1}), 1), log_{1, i}.timeTrackMap{1, 1}, ...
  %       'color', marker_color{i})
  %     if min_box_size > length(log_{1, i}.timeTrackMap{1, 1})
  %       min_box_size = length(log_{1, i}.timeTrackMap{1, 1});
  %     end
  %   end
  %   max_time = log_{1, i}.timeStamp{1, 1}(end) - log_{1, i}.timeStamp{1, 1}(1);
  %   plot([0 max_time], [15 15], 'r--', 'LineWidth', 2);
  %   legend(legend_arr);
  %   xlim([0 max_time]);
  %   %
  %   subplot(1,4,4)
  %   box_arr = [];
  %   for i=1:length(slam_path_list)
  %     box_arr = [box_arr log_{1, i}.timeTrackMap{1, 1}(1:min_box_size)];
  %   end
  %   %   boxplot(legend_arr, box_arr)
  %   aboxplot(box_arr, 'labels', legend_arr, 'OutlierMarker', '.');
  %   hold on
  %   plot([0 length(slam_path_list) + 0.5], [15 15], 'r--', 'LineWidth', 2);
  
  %   figure
  %   subplot(1,4,[1,2,3])
  %   plot(log_{1, 1}.timeStamp{1, 1} - repmat(log_{1, 1}.timeStamp{1, 1}(1), length(log_{1, 1}.timeStamp{1, 1}), 1), log_{1, 1}.timeTotal{1, 1})
  %   hold on
  %   plot(log_{1, 2}.timeStamp{1, 1} - repmat(log_{1, 2}.timeStamp{1, 1}(1), length(log_{1, 2}.timeStamp{1, 1}), 1), log_{1, 2}.timeTotal{1, 1})
  %   plot(log_{1, 3}.timeStamp{1, 1} - repmat(log_{1, 3}.timeStamp{1, 1}(1), length(log_{1, 3}.timeStamp{1, 1}), 1), log_{1, 3}.timeTotal{1, 1})
  %   plot(log_{1, 4}.timeStamp{1, 1} - repmat(log_{1, 4}.timeStamp{1, 1}(1), length(log_{1, 4}.timeStamp{1, 1}), 1), log_{1, 4}.timeTotal{1, 1})
  %   legend(legend_arr);
  %   subplot(1,4,4)
  %   boxplot([log_{1, 1}.timeTotal{1, 1}(1:51266), log_{1, 2}.timeTotal{1, 1}(1:51266), log_{1, 3}.timeTotal{1, 1}(1:51266), log_{1, 4}.timeTotal{1, 1}(1:51266) ])
  %
  
  
  %% plot trend of lmk number
  if plot_lmk_num
    metric_type = {'lmkRefTrack'; 'lmkRefInlier'; 'lmkInitTrack'; 'lmkBA';};
    h = figure(2);
    hold on
    for mn = 1:4
      %         subplot(2, 2, mn)
      %     clf
      for tn=[1:length(slam_path_list)]
        err_summ{tn} = [];
        %
        for gn=table_index(end) % 3%1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.lmkRefTrack{rn};
              case 2
                err_raw = log_{gn, tn}.lmkRefInlier{rn};
              case 3
                err_raw = log_{gn, tn}.lmkInitTrack{rn};
              case 4
                err_raw = log_{gn, tn}.lmkBA{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_raw)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
            if rn == 1
              subplot(2, 2, mn)
              hold on
              if tn == 1
                plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-');
              else
                plot(log_{gn, tn}.timeStamp{rn}, err_raw, ':');
              end
            end
            
          end
          %
          %         err_summ{tn} = [err_summ err_all_rounds];
          %         err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
          err_summ{tn} = cat(2, err_summ{tn}, mean(err_all_rounds));
        end
        
        % print out
        err_summ{tn}
        
      end
      
      %% Plot Comparison Illustration
      %     assert(size(err_summ, 2) == length(gf_slam_list))
      %     err_boxplot = [];
      %     for tn = 1:length(legend_arr)
      %       err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
      %     end
      % plot absolute error
      subplot(2, 2, mn)
      %     clf
      %     aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x');
      legend(legend_arr{[1:length(slam_path_list)]});
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      xlabel('lmk tracked per frame')
      ylabel([metric_type{mn}])
      %
    end
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/LmkNum_' seq_idx '.png']); % , '-r 200');
  end
  
  %% plot trend of time cost for tracking thread
  if plot_gf_time_trend
    metric_type = {'timeOrbExtr'; 'timeTrackMotion'; 'timeTrackFrame'; 'timeTrackMap'; };
    h = figure(3);
    hold on
    for mn = 1:length(metric_type)
      for tn=[1:length(slam_path_list)] % 1:length(slam_path_list)
        err_summ{tn} = [];
        %
        %         gn = table_index(tn);
        for gn = table_index(tn) %table_index(end) % 3%1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1 % :round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.timeOrbExtr{rn};
              case 2
                err_raw = log_{gn, tn}.timeTrackMotion{rn};
              case 3
                err_raw = log_{gn, tn}.timeTrackFrame{rn};
              case 4
                err_raw = log_{gn, tn}.timeTrackMap{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_raw)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
            
            if rn == 1 % 2
              if ~isempty(err_raw)
                subplot(2, 2, mn)
                hold on
                if tn <= 1
                  plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-');
                else
                  plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-.');
                end
              end
            end
            
          end
          %
          err_summ{tn} = cat(2, err_summ{tn}, mean(err_all_rounds));
        end
        
        % print out
        err_summ{tn}
        
      end
      
      %% Plot Comparison Illustration
      %     assert(size(err_summ, 2) == length(gf_slam_list))
      %     err_boxplot = [];
      %     for tn = 1:length(legend_arr)
      %       err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
      %     end
      % plot absolute error
      subplot(2, 2, mn)
      %     clf
      %     h = figure('Visible','Off');
      %     hold on
      %     plot(lmk_number_list, err_boxplot(tn, 1, :));
      %     aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x');
      if mn == 3
        legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
      end
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      xlabel('lmk tracked per frame')
      ylabel([metric_type{mn} ' (ms)'])
      %
      % save the figure
      %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
      %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
      %     close(h)
    end
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/TimeCost_Tracking_' seq_idx '.png']); % , '-r 200');
    
    % plot trend of time cost per module
    metric_type = {'timeTrackMap'; 'timeMapMatch'; 'timeMapSelect'; 'timeHashQuery'; 'timeOptim'; 'timeHashInsert'; };
    h = figure(4);
    hold on
    for mn = 1:length(metric_type)
      %     h = figure(100 + mn);
      %     clf
      %
      for tn=[1:length(slam_path_list)] % [1:length(slam_path_list)]
        err_summ{tn} = [];
        %
        %         gn = table_index(tn);
        for gn = table_index(tn) %table_index(end) % 3%1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1:round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.timeTrackMap{rn};
              case 2
                err_raw = log_{gn, tn}.timeMapMatch{rn};
              case 3
                err_raw = log_{gn, tn}.timeMapSelect{rn};
              case 4
                err_raw = log_{gn, tn}.timeHashQuery{rn};
              case 5
                %                 if tn == 1
                err_raw = log_{gn, tn}.timeMapOpt{rn};
                %                 else
                %                   err_raw = log_{gn, tn}.timeOptim{rn};
                %                 end
              case 6
                err_raw = log_{gn, tn}.timeHashInsert{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_raw)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
            
            if rn == 1 % 2
              if ~isempty(err_raw)
                subplot(3, 2, mn)
                hold on
                if tn <= 1
                  plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-');
                  %             elseif tn <= 3
                  %               plot(log_{gn, tn}.timeStamp{rn}, err_raw, ':');
                else
                  plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-.');
                end
              end
            end
            
          end
          %
          %         err_summ{tn} = [err_summ err_all_rounds];
          %         err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
          err_summ{tn} = cat(2, err_summ{tn}, mean(err_all_rounds));
        end
        
        % print out
        err_summ{tn}
        
      end
      
      %% Plot Comparison Illustration
      %     assert(size(err_summ, 2) == length(gf_slam_list))
      %     err_boxplot = [];
      %     for tn = 1:length(legend_arr)
      %       err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
      %     end
      % plot absolute error
      subplot(3, 2, mn)
      %     clf
      %     h = figure('Visible','Off');
      %     hold on
      %     plot(lmk_number_list, err_boxplot(tn, 1, :));
      %     aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x');
      if mn == 3
        legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
      end
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      xlabel('lmk tracked per frame')
      ylabel([metric_type{mn} ' (ms)'])
      %
      % save the figure
      %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
      %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
      %     close(h)
    end
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/TimeCost_Detail_' seq_idx '.png']); % , '-r 200');
    
    h = figure(5);
    subplot(1,3,[1,2])
    hold on
    for tn=[1:length(slam_path_list)] % 1:length(slam_path_list)
      err_summ{tn} = [];
      %
      %         gn = table_index(tn);
      for gn = table_index(tn) %table_index(end) % 3%1:length(gf_slam_list)
        err_all_rounds = [];
        %
        for rn=1:round_num
          %
          err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeTrackMotion{rn} ...
            + log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
          %           err_raw = log_{gn, tn}.timeTrackMotion{rn} ...
          %             + log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
          %
          %           err_metric = mean(err_raw);
          err_metric = err_raw;
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            disp 'error! no valid data for plot!'
            %             err_all_rounds = [err_all_rounds; NaN];
          end
          
          if rn == 1 % 2
            hold on
            if tn <= 1
              plot(log_{gn, tn}.timeStamp{rn} - log_{gn, tn}.timeStamp{rn}(1), err_raw, '-');
            else
              plot(log_{gn, tn}.timeStamp{rn} - log_{gn, tn}.timeStamp{rn}(1), err_raw, '-.');
            end
          end
          
        end
        %
        %         err_summ{tn} = cat(2, err_summ{tn}, mean(err_all_rounds));
        err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
      end
    end
    
    %% Plot Comparison Illustration
    legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
    % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
    xlabel('TimeStamp (sec)')
    %     ylabel('Time Cost of timeTrackMap (ms)')
    ylabel('Tracking Time per Frame (ms)')
    
    subplot(1,3,3)
    aboxplot(err_summ, 'labels', legend_arr);
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/TimeCost_Total_' seq_idx '.fig']); % , '-r 200');
    export_fig(h, [save_path '/TimeCost_Total_' seq_idx '.png']); % , '-r 200');
    
  end
  
  %% boxplot of time cost
  if plot_gf_time_stat
    metric_type = {'timeOrbExtr'; 'timeTrackMotion'; 'timeTrackFrame'; 'timeTrackMap'; };
    h = figure(7);
    hold on
    for mn = 1:length(metric_type)
      %     h = figure(100 + mn);
      %     clf
      %
      for tn=[1:length(slam_path_list)] % 1:length(slam_path_list)
        err_summ{tn} = [];
        %
        for gn=1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1:round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.timeOrbExtr{rn};
              case 2
                err_raw = log_{gn, tn}.timeTrackMotion{rn};
              case 3
                err_raw = log_{gn, tn}.timeTrackFrame{rn};
              case 4
                err_raw = log_{gn, tn}.timeTrackMap{rn};
            end
            %
            err_metric = nanmean(err_raw);
            %
            if ~isempty(err_raw) % && track_loss_rate_{gn, tn}(rn) < track_loss_ratio(1)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
          end
          %
          %         err_summ{tn} = [err_summ err_all_rounds];
          %         err_summ = [err_summ median(err_all_rounds)];
          err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
        end
      end
      
      %% Plot Comparison Illustration
      %     assert(size(err_summ, 2) == length(gf_slam_list))
      err_boxplot = [];
      for tn = [1:length(slam_path_list)] % 1:length(legend_arr)
        err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
      end
      % plot absolute error
      subplot(2, 2, mn)
      %     clf
      %     h = figure('Visible','Off');
      %     hold on
      %     plot(lmk_number_list, err_boxplot(tn, 1, :));
      aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x');
      if mn == 1
        legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
      end
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      xlabel('lmk tracked per frame')
      ylabel([metric_type{mn} ' (ms)'])
      %
      % save the figure
      %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
      %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
      %     close(h)
    end
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/Box_TotalTimeCost_' seq_idx '.png']); % , '-r 200');
    
    h = figure(8);
    hold on
    %     h = figure(100 + mn);
    %     clf
    %
    err_boxplot = [];
    %
    tn = 4
    for gn=1:length(gf_slam_list)
      err_all_rounds = [];
      %
      for rn=1:round_num
        %
        err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeTrackMotion{rn} + ...
          log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
        %           err_raw = log_{gn, tn}.timeTrackMotion{rn} ...
        %             + log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
        %
        err_metric = err_raw;
        %           err_metric = mean(err_raw);
        %
        %           if ~isempty(err_metric)
        %             err_all_rounds = [err_all_rounds; err_metric];
        %           else
        %             disp 'error! no valid data for plot!'
        %             err_all_rounds = [err_all_rounds; NaN];
        %           end
        if fps*seq_duration(sn) > length(err_metric)
          err_metric = [err_metric; nan(fps*seq_duration(sn)-length(err_metric), 1)];
        end
        err_all_rounds = [err_all_rounds; err_metric];
      end
      %
      %         err_summ{tn} = [err_summ err_all_rounds];
      %         err_summ = [err_summ median(err_all_rounds)];
      err_boxplot = cat(2, err_boxplot, err_all_rounds);
    end
    err_boxplot = cat(2, err_boxplot, nan(fps*seq_duration(sn)*round_num, 1));
    %
    tn = 1
    gn = 1
    err_all_rounds = [];
    %
    for rn=1:round_num
      %
      err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeTrackMotion{rn} + ...
        log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
      err_metric = err_raw;
      if fps*seq_duration(sn) > length(err_metric)
        err_metric = [err_metric; nan(fps*seq_duration(sn)-length(err_metric), 1)];
      end
      err_all_rounds = [err_all_rounds; err_metric];
    end
    %
    err_boxplot = cat(2, err_boxplot, err_all_rounds);
    
    %% Plot Comparison Illustration
    %     assert(size(err_summ, 2) == length(gf_slam_list))
    % plot absolute error
    xtick = cell(1, length(lmk_number_list) + 2);
    for xi=1:length(lmk_number_list)
      xtick{xi} = num2str(lmk_number_list(xi));
    end
    xtick{length(lmk_number_list) + 1} = ' ';
    xtick{length(lmk_number_list) + 2} = 'ORB';
    boxplot(err_boxplot, 'Symbol', '', 'Labels', xtick);
    %     legend(legend_arr{[1,2,6]},'Location','northwest');
    %     xlabel('Feature Subset Tracked Per Frame')
    ylabel('Tracking Time per Frame (ms)')
    %     ylabel('Time Cost of timeTrackMap (ms)')
    
  end
  
  %% clean up
  close all
end

if plot_total_time_stat
  % Plot Comparison Illustration
  %   x = categorical({'ORB'; 'MHash'; 'GF'; 'GF-gpu'; 'Comb'; 'Comb-gpu'; }');
  x = categorical({'ORB'; 'MHash'; 'GF'; 'Comb'; }');
  %   x = categorical({'ORB'; 'MHash'; 'Comb'; }');
  %   x = categorical({'ORB'}');
  y = cellfun(@nanmean, total_time_summ);
  
  y(:, 2) = y(:, 1) - y(3, 1);
  y(:, 1) = y(:, 1) - y(:, 2);
  
  %
  h = figure(1);
  clf
  b=barh(x, y(:, 1:end-1), 'stacked');
  for i=1:size(b,2)
    b(i).BarWidth = 0.5;
  end
  xlabel(['Tracking Time per Frame (ms)'])
  
  b(1).FaceColor = [0 0.447 0.741];
  b(2).FaceColor = 'c';
  b(3).FaceColor = [0.85 0.325 0.098];
  b(4).FaceColor = [0.929 0.694 0.125];
  b(5).FaceColor = [0.494 0.184 0.556];
  b(6).FaceColor = [0.466 0.674 0.188];
  
  %   xlim([0 20])
  legend({'Feature Extr.'; 'Stereo Matching'; 'Init Tracking'; 'Feature Matching'; 'Geom. Optim.'; 'Direct Optim.'})
  %   legend boxoff
  set(gca,'FontSize',12)
  %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  export_fig(h, [save_path '/Bar_TotalTimeCost_Stereo.fig']); % , '-r 200');
  export_fig(h, [save_path '/Bar_TotalTimeCost_Stereo.png']); % , '-r 200');
  
  % print the mean
  mean_buf = cellfun(@nanmean, total_time_summ);
  disp(['mean time cost:'])
  mean_buf(:, end)
  
  % print the std
  std_buf = cellfun(@nanstd, total_time_summ);
  disp(['std of time cost:'])
  std_buf(:, end)
  
  % print the quatile
  perc25_buf = cellfun(@quantile, total_time_summ, num2cell(ones(size(total_time_summ)) * 0.25));
  disp(['25% of time cost:'])
  perc25_buf(:, end)
  %
  perc75_buf = cellfun(@quantile, total_time_summ, num2cell(ones(size(total_time_summ)) * 0.75));
  disp(['75% of time cost:'])
  perc75_buf(:, end)
  
end

disp 'done!'
%
% close all
% clear all
% load('/home/yipuzhao/Codes/VSLAM/SLAM_Evaluation/output/TRO18/bar_x200ca.mat')
% y_1 = y;
% load('/home/yipuzhao/Codes/VSLAM/SLAM_Evaluation/output/TRO18/bar_jetson.mat')
% y_2 = y;
% load('/home/yipuzhao/Codes/VSLAM/SLAM_Evaluation/output/TRO18/bar_euclid.mat')
% y_3 = y;
%
% x_all = categorical({'X200:ORB'; 'X200:svo2'; 'X200:DSO'; 'X200:GF-ORB'; 'Jetson:ORB'; 'Jetson:svo2'; 'Jetson:DSO'; 'Jetson:GF-ORB'; 'Euclid:ORB'; 'Euclid:svo2'; 'Euclid:DSO'; 'Euclid:GF-ORB';}');
% x_all = reordercats(x_all, {'X200:GF-ORB' 'X200:ORB' 'X200:DSO' 'X200:svo2' 'Jetson:GF-ORB' 'Jetson:ORB' 'Jetson:DSO' 'Jetson:svo2' 'Euclid:GF-ORB' 'Euclid:ORB' 'Euclid:DSO' 'Euclid:svo2'});
% h = figure(1);
% clf
% b=barh(x_all, [y_1; y_2; y_3], 'stacked');
% for i=1:size(b,2)
% b(i).BarWidth = 0.5;
% end
% xlabel(['Tracking Time per Frame (ms)'])
% %   xlim([0 20])
% line([33, 33], [x_all(4), x_all(10)]);
% legend({'Feature Extr.'; 'Init Tracking'; 'Feature Matching'; 'Geom. Optim.'; 'Direct Optim.'})

