clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark =  'EuRoC_RAL18_Debug' % 'KITTI_RAL18_Debug' %
setParam
do_viz = 1;
%
ref_reload = 1;

% round_num = 1;

for sn = [1, 5, 10] % [1:6, 9:10]  % 1:length(seq_list) % [1:6, 9:10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  for tn=1
    
    for gn=1:length(baseline_slam_list)
      %
      log_{gn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        
        %% Load Log Files
        disp(['Loading ORB-SLAM log...'])
%         if tn == 1
%           [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} baseline_slam_list{gn}], ...
%             rn, seq_idx, log_{gn, tn}, 1);
%         else
          [log_{gn, tn}] = loadLogTUM_new([slam_path_list{tn} baseline_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn}, 1);
%         end
        
      end
    end
    
  end
  
  
  % plot trend of time cost
  metric_type = {'Feature Extraction'; 'Init Pose Tracking'; 'Map-to-frame Matching'; 'Refine Pose Optimization'; 'Tracking in Total'; };
  h = figure;
  hold on
  for mn = 1:length(metric_type)
    %     h = figure(100 + mn);
    %     clf
    %
    for tn=1
      err_summ{tn} = [];
      %
      for gn=5
        err_all_rounds = [];
        %
        for rn=1
          %
          switch mn
            case 1
              err_raw = log_{gn, tn}.timeOrbExtr{rn};
            case 2
              err_raw = log_{gn, tn}.timeInitTrack{rn};
            case 3
              err_raw = log_{gn, tn}.timeRefTrack{rn} - log_{gn, tn}.timeOpt{rn}; % log_{gn, tn}.timeMatch{rn};
            case 4
              err_raw = log_{gn, tn}.timeOpt{rn};
            case 5
              err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeInitTrack{rn} + log_{gn, tn}.timeRefTrack{rn};
          end
          %
          err_metric = mean(err_raw);
          %
          if ~isempty(err_metric) && ~isnan(err_metric)
            err_all_rounds = [err_all_rounds; err_metric];
          else
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
          end
          
          if rn == 1
            if mn == 5
              plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-');
              %             elseif tn <= 3
              %               plot(log_{gn, tn}.timeStamp{rn}, err_raw, ':');
            else
              plot(log_{gn, tn}.timeStamp{rn}, err_raw, '-.');
            end
          end
        end
      end
    end
  end
  legend(metric_type);
  xlabel('time stamp')
  ylabel(['ms'])
  % ylim([0 45])
  
  %   set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  export_fig(h, [save_path '/Trend_TimeCost_' seq_idx '.png']); % , '-r 200');
  
  
  
  %% boxplot of time cost
  metric_type = {'Feature Extraction'; 'Init Pose Tracking'; 'Map-to-frame Matching'; 'Refine Pose Optimization'; 'Tracking in Total'; };
  %   h = figure;
  %   suptitle(strrep(seq_idx, '_', '\_'))
  for gn=1:length(baseline_slam_list)
    %     h = figure(100 + mn);
    %     clf
    %
    for tn=1
      err_summ{gn} = [];
      for mn = 1:length(metric_type)
        err_all_rounds = [];
        %
        for rn=1:round_num
          %
          switch mn
            case 1
              err_raw = log_{gn, tn}.timeOrbExtr{rn};
            case 2
              err_raw = log_{gn, tn}.timeInitTrack{rn};
            case 3
              err_raw = log_{gn, tn}.timeRefTrack{rn} - log_{gn, tn}.timeOpt{rn}; % log_{gn, tn}.timeMatch{rn};
            case 4
              err_raw = log_{gn, tn}.timeOpt{rn};
            case 5
              err_raw = log_{gn, tn}.timeOrbExtr{rn} + log_{gn, tn}.timeInitTrack{rn} + log_{gn, tn}.timeRefTrack{rn};
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
        %         err_summ{tn} = cat(2, err_summ{tn}, err_all_rounds);
        
        %
        err_summ{gn} = cat(2, err_summ{gn}, err_all_rounds);
      end
    end
    
    %     %% Plot Comparison Illustration
    %     %     assert(size(err_summ, 2) == length(gf_slam_list))
    %     err_boxplot = [];
    %     for tn = 1
    %       err_boxplot = cat(1, err_boxplot, reshape(err_summ{tn}, [1 size(err_summ{tn})]));
    %     end
    %     % plot absolute error
    %     subplot(2, 3, mn)
    %     %     clf
    %     %     h = figure('Visible','Off');
    %     %     hold on
    %     %     plot(baseline_number_list, err_boxplot(tn, 1, :));
    %     aboxplot(err_boxplot, 'labels', baseline_number_list, 'OutlierMarker', 'x');
    %     if mn == 1
    %       legend(legend_arr,'Location','northwest');
    %     end
    %     % boxplot(err_summ{tn}, 'labels', baseline_number_list, 'Positions', baseline_number_list);
    %     xlabel('lmk tracked per frame')
    %     ylabel(['ms'])
    %     ylim([0 45])
    %     title(metric_type{mn})
    %
    % save the figure
    %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
    %     close(h)
  end
  
  err_sequence{sn} = err_summ;
  
  %   set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
  %   export_fig(h, [save_path '/Box_TimeProfiling_' seq_idx '.png']); % , '-r 200');
  
  %   close all
end

%% TODO
err_all = [];
for gn=1:length(baseline_slam_list)
  
  %   err_average{gn} = zeros(size(err_sequence{1}{1}));
  err_average{gn} = [];
  for sn=[1:6, 9:10]
    %     err_average{gn} = err_average{gn} + err_sequence{sn}{gn};
    err_average{gn} = [err_average{gn}; err_sequence{sn}{gn}];
  end
  
  %
  err_all = cat(3, err_all, err_average{gn}');
  
end

% % plot the average time profile over all sequences
% h = figure;
% title('Averaged on EuRoC')
%
% aboxplot(err_all, 'labels', baseline_number_list)
%
% metric_type = {'Feature Extraction'; 'Init Pose Tracking'; 'Map-to-frame Matching'; 'Refine Pose Optimization'; 'Tracking in Total'; };
% legend(metric_type,'Location','northwest');
% % boxplot(err_summ{tn}, 'labels', baseline_number_list, 'Positions', baseline_number_list);
% xlabel('lmk tracked per frame')
% ylabel(['ms'])
% ylim([0 45])

legend_syl = {'b-o'; 'b--.'; 'g-o'; 'g--.'; 'r-o'; 'r--.'; 'm-o'; 'm--.'; 'k-o'; 'k--.'; };
figure; hold on
for i=1:5
  tmp(:,:)=err_all(i, :, :);plot(baseline_number_list, mean(tmp, 1), legend_syl{2*i-1})
  hold on;plot(baseline_number_list, prctile(tmp, 95), legend_syl{2*i})
end
legend({'Feature Extraction: average'; 'Feature Extraction: max';
  'Init Pose Tracking: average'; 'Init Pose Tracking: max';
  'Map-to-frame Matching: average'; 'Map-to-frame Matching: max';
  'Refine Pose Optimization: average'; 'Refine Pose Optimization: max';
  'Tracking in Total: average'; 'Tracking in Total: max'; })
xlabel('lmk tracked per frame')
ylabel(['ms'])
ylim([0 45])

% set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
export_fig(h, [save_path '/Box_TimeProfiling_Average.png']); % , '-r 200');

