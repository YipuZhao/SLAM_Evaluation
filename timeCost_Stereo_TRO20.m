clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'TUM_VI_TRO19_Stereo' % 'EuRoC_TRO19_Stereo' % 'KITTI_TRO19_Stereo' % 
% 

setParam

do_viz = 1;
%
ref_reload = 1;

% round_num = 1;

plot_total_time_stat = true;
plot_lmk_num = true; % false; %
plot_gf_time_trend = false; % true; %
plot_gf_time_stat = false; % true; %

plot_subset = [1,2,6]; % [1,6,7]; % [1,2,5]; %

total_time_summ = cell(length(slam_path_list), 7);
lmk_summ = cell(length(slam_path_list), 4);

for sn = 1:length(seq_list) % [1, 10] % [1,5,10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref_cam0 = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 1, maxNormTrans);
  track_ref_imu0 = loadTrackTUM([ref_path '/' seq_idx '_imu0.txt'], 1, maxNormTrans);
  
  for tn=1:baseline_num
    if strcmp(pipeline_type{tn}, 'vins')
      track_ref = track_ref_imu0;
    else
      track_ref = track_ref_cam0;
    end
    for gn=1:length(gf_slam_list)
      log_{gn, tn} = [];
      track_loss_rate_{gn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        % Load Log Files
        if tn <= baseline_orb
          disp(['Loading ORB-SLAM log...'])
          [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        else
          disp(['Loading SVO log...'])
          [log_{gn, tn}] = loadLogSVO([slam_path_list{tn} ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        end
        
        %
        %         track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
        %           max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
        %           (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
        
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} baseline_slam_list{table_index(tn)} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        %
        if isempty(asso_track_2_ref{tn})
          track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; 1.0];
        else
          if valid_by_duration
            valid_dat_idx = find(asso_track_2_ref{tn}(:) > 0);
            %
            track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
              max(0, min(1, 1 - ( track{tn}(valid_dat_idx(end), 1) - ...
              track{tn}(valid_dat_idx(1), 1) ) / (seq_duration(sn) - seq_start_time(sn)) ))];
          else
            track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
              max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
              (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
          end
        end
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
        disp(['Loading ORB-SLAM log...'])
        [log_{gn, tn}] = loadLogTUM_stereo([slam_path_list{tn} gf_slam_list{gn}], ...
          rn, seq_idx, log_{gn, tn}, seq_start_time(sn) * fps);
        
        %
        %         track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
        %           max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
        %           (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
        
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        %
        if isempty(asso_track_2_ref{tn})
          track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; 1.0];
        else
          if valid_by_duration
            valid_dat_idx = find(asso_track_2_ref{tn}(:) > 0);
            %
            track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
              max(0, min(1, 1 - ( track{tn}(valid_dat_idx(end), 1) - ...
              track{tn}(valid_dat_idx(1), 1) ) / (seq_duration(sn) - seq_start_time(sn)) ))];
          else
            track_loss_rate_{gn, tn} = [track_loss_rate_{gn, tn}; ...
              max(0, min(1, 1 - size(log_{gn, tn}.timeTotal{rn}, 1) / ...
              (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
          end
        end
      end
    end
  end
  
  %% plot hist of total tracking time
  if plot_total_time_stat
    gn = table_index(end) % 4;
    for tn=[1:length(slam_path_list)] % 1:length(slam_path_list)
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
              err_raw = log_{gn, tn}.timeMapOpt{rn};
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
  
  %% plot trend of lmk number
  if plot_lmk_num
    metric_type = {'lmkTrackMotion'; 'lmkTrackFrame'; 'lmkTrackMap'; 'lmkBA';};
    h = figure(2);
    hold on
    for mn = 1:length(metric_type)
      %         subplot(2, 2, mn)
      %     clf
      for tn = [1:baseline_orb, baseline_num+1:length(slam_path_list)]
        err_summ{tn} = [];
        %
        for gn=table_index(tn) % 4%1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1:round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.lmkTrackMotion{rn};
              case 2
                err_raw = log_{gn, tn}.lmkTrackFrame{rn};
              case 3
                err_raw = log_{gn, tn}.lmkTrackMap{rn};
              case 4
                err_raw = log_{gn, tn}.lmkBA{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_metric) && track_loss_rate_{gn, tn}(rn) < track_loss_ratio(1)
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
          
          %           if mn == 1
          lmk_summ{tn, mn} = [lmk_summ{tn, mn}; err_all_rounds];
          %           end
          
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
      legend(legend_arr{[1, baseline_num+1 : length(slam_path_list)]});
      % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
      xlabel('lmk tracked per frame')
      ylabel([metric_type{mn}])
      %
    end
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/LmkNum_' seq_idx '.png']); % , '-r 200');
  end
  
  %% plot trend of time cost
  if plot_gf_time_trend
    metric_type = {'timeTrackMotion'; 'timeStereoMotion'; ...
      'timeTrackFrame'; 'timeStereoFrame'; 'timeTrackMap'; 'timeStereoMap'; };
    h = figure(3);
    hold on
    for mn = 1:length(metric_type)
      for tn=plot_subset % [1:length(slam_path_list)] %1:length(slam_path_list)
        err_summ{tn} = [];
        %
        for gn=table_index(end) % 4 %1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1 % :round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.timeTrackMotion{rn};
              case 2
                err_raw = log_{gn, tn}.timeStereoMotion{rn};
              case 3
                err_raw = log_{gn, tn}.timeTrackFrame{rn};
              case 4
                err_raw = log_{gn, tn}.timeStereoFrame{rn};
              case 5
                err_raw = log_{gn, tn}.timeTrackMap{rn};
              case 6
                err_raw = log_{gn, tn}.timeStereoMap{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_metric)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
            
            if rn == 1 % 2
              subplot(3, 2, mn)
              hold on
              if tn <= 1
                plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-');
              else
                plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-.');
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
      subplot(3, 2, mn)
      %     clf
      %     h = figure('Visible','Off');
      %     hold on
      %     plot(lmk_number_list, err_boxplot(tn, 1, :));
      %     aboxplot(err_boxplot, 'labels', lmk_number_list, 'OutlierMarker', 'x');
      if mn == 3
        legend(legend_arr{plot_subset},'Location','northwest');
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
    export_fig(h, [save_path '/TrackingTimeCost_' seq_idx '.png']); % , '-r 200');
    
    %% plot trend of time cost per module
    metric_type = {'timeTrackMap'; 'timeMapMatch'; 'timeMapOpt'; 'timeMatPredict'; 'timeMatOnline'; };
    h = figure(4);
    hold on
    for mn = 1:length(metric_type)
      %     h = figure(100 + mn);
      %     clf
      %
      for tn=plot_subset % [1:length(slam_path_list)] % 1:length(slam_path_list)
        err_summ{tn} = [];
        %
        for gn=table_index(end) % 4%1:length(gf_slam_list)
          err_all_rounds = [];
          %
          for rn=1 % :round_num
            %
            switch mn
              case 1
                err_raw = log_{gn, tn}.timeTrackMap{rn};
              case 2
                err_raw = log_{gn, tn}.timeMapMatch{rn};
              case 3
                err_raw = log_{gn, tn}.timeMapOpt{rn};
              case 4
                err_raw = log_{gn, tn}.timeMatPredict{rn};
              case 5
                err_raw = log_{gn, tn}.timeMatOnline{rn};
            end
            %
            err_metric = mean(err_raw);
            %
            if ~isempty(err_metric)
              err_all_rounds = [err_all_rounds; err_metric];
            else
              disp 'error! no valid data for plot!'
              err_all_rounds = [err_all_rounds; NaN];
            end
            
            if rn == 1 % 2
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
    export_fig(h, [save_path '/ModuleTimeCost_' seq_idx '.png']); % , '-r 200');
    
    
    h = figure(5);
    hold on
    for tn=plot_subset % [1:length(slam_path_list)] % 1:length(slam_path_list)
      err_summ{tn} = [];
      %
      %         gn = table_index(tn);
      for gn=table_index(end) % 4%1:length(gf_slam_list)
        err_all_rounds = [];
        %
        for rn=1 % :round_num
          %
          err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeTrackMotion{rn} ...
            + log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
          %           err_raw = log_{gn, tn}.timeTrackMotion{rn} ...
          %             + log_{gn, tn}.timeTrackFrame{rn} + log_{gn, tn}.timeTrackMap{rn};
          %
          err_metric = mean(err_raw);
          %
          if ~isempty(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
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
        err_summ{tn} = cat(2, err_summ{tn}, mean(err_all_rounds));
      end
    end
    
    %% Plot Comparison Illustration
    legend(legend_arr{[plot_subset]},'Location','northwest');
    % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
    xlabel('TimeStamp (sec)')
    %     ylabel('Time Cost of timeTrackMap (ms)')
    ylabel('Tracking Time per Frame (ms)')
    
  end
  
  %% boxplot of time cost
  if plot_gf_time_stat
    metric_type = {'timeOrbExtr'; 'timeTrackMotion'; 'timeTrackFrame'; 'timeTrackMap'; };
    h = figure(6);
    hold on
    for mn = 1:length(metric_type)
      %     h = figure(100 + mn);
      %     clf
      %
      for tn=plot_subset%[1:length(slam_path_list)] % 1:length(slam_path_list)
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
            err_metric = mean(err_raw);
            %
            if ~isempty(err_metric)
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
      for tn = plot_subset%[1:length(slam_path_list)] % 1:length(legend_arr)
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
    tn = 6
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
    tn = 2
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
    xtick{length(lmk_number_list) + 2} = 'Post-ORB';
    xtick{length(lmk_number_list) + 3} = 'ORB';
    boxplot(err_boxplot, 'Symbol', '', 'Labels', xtick);
    %     legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
    %     xlabel('Feature Subset Tracked Per Frame')
    ylabel('Tracking Time per Frame (ms)')
    %     ylabel('Time Cost of timeTrackMap (ms)')
    
  end
  
  %% clean up
  close all
end

if plot_total_time_stat
  
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
  
  
  % Plot Comparison Illustration
  if strcmp(benchMark, 'KITTI_TRO19_Stereo')
    x = categorical({
      'ORB';
      'Lazy-ORB';
      'SVO';
      'DSO';
      'GF';
      'Rnd';
      'Long';
      }');
    x = reordercats(x, {'SVO' 'DSO' 'ORB' 'Lazy-ORB' 'GF' 'Rnd' 'Long'});
  else
    x = categorical({
      'ORB';
      'Lazy-ORB';
      'SVO';
      'OKVIS';
      'MSCKF';
      'GF';
      'Rnd';
      'Long';
      }');
    x = reordercats(x, {'SVO' 'ORB' 'Lazy-ORB' 'GF' 'Rnd' 'Long' 'OKVIS' 'MSCKF'});
  end
  %
  y = cellfun(@nanmean, total_time_summ);
  y(:, 2) = y(:, 1) - y(6, 1);
  y(:, 1) = y(:, 1) - y(:, 2);
  %
  h = figure(1);
  clf
  b = barh(x, y([1:length(slam_path_list)], 1:end-1), 'stacked')
  xlabel(['Tracking Time per Frame (ms)'])
  
  b(1).FaceColor = [0 0.447 0.741];
  b(2).FaceColor = 'c';
  b(3).FaceColor = [0.85 0.325 0.098];
  b(4).FaceColor = [0.929 0.694 0.125];
  b(5).FaceColor = [0.494 0.184 0.556];
  b(6).FaceColor = [0.466 0.674 0.188];
  
  %   xlim([0 30])
  legend({'Feature Extr.'; 'Stereo Matching'; 'Init Tracking'; 'Feature Matching'; 'Geom. Optim.'; 'Direct Optim.'})
  
  %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  export_fig(h, [save_path '/Bar_TotalTimeCost_Stereo.png']); % , '-r 200');
  
end



if plot_lmk_num
  
  % print the mean
  mean_buf = cellfun(@nanmean, lmk_summ);
  disp(['mean feat. tracked:'])
  mean_buf(:, 3)
  
  % print the std
  std_buf = cellfun(@nanstd, lmk_summ);
  disp(['std of feat. tracked:'])
  std_buf(:, 3)
  
  % print the quatile
  perc25_buf = cellfun(@quantile, lmk_summ, num2cell(ones(size(lmk_summ)) * 0.25));
  disp(['25% of feat. tracked:'])
  perc25_buf(:, 3)
  %
  perc75_buf = cellfun(@quantile, lmk_summ, num2cell(ones(size(lmk_summ)) * 0.75));
  disp(['75% of feat. tracked:'])
  perc75_buf(:, 3)
  
end


disp 'done!'