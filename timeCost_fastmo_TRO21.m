clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark = 'EuRoC_RAL19_FastMo' % 'EuRoC_RAL19_FastMo_MinSet'

setParam

do_viz = 1;
%
ref_reload = 1;

% round_num = 1;

% plot_total_time_stat = true;
% plot_lmk_num = false; % true; %
% plot_gf_time_trend = false; % true; %
% plot_gf_time_stat = true; % false; %

total_time_summ = cell(length(slam_path_list), 6);

for sn = 1:length(seq_list) % [1,5,10] %  %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  for tn=1:baseline_num
    for fn=1:length(fast_mo_list)
      log_{fn, tn} = [];
      track_loss_rate_{fn, tn} = [];
      for rn = 1:round_num
        disp(['Round ' num2str(rn)])
        % Load Log Files
        if tn == 1
          % msckf
          disp(['Loading MSCKF log...'])
          [log_{fn, tn}] = loadLog_MSCKF([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
        elseif tn <= 4
          % ICE-BA / VINS-Fusion
          disp(['Loading ICA-BA & VINS-Fusion log...'])
          [log_{fn, tn}] = loadLog_VINS([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
        elseif tn == 5
          % SVO
          disp(['Loading SVO log...'])
          [log_{fn, tn}] = loadLog_SVO_v2([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
        elseif tn <= baseline_num
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
          [log_{fn, tn}] = loadLogTUM_BA([slam_path_list{tn} ...
            num2str(fast_mo_list(fn), '%.01f') '/' ...
            baseline_slam_list{table_index(tn)}], ...
            rn, seq_idx, log_{fn, tn}, 2);
          
        end
        
        %
        track_loss_rate_{fn, tn} = [track_loss_rate_{fn, tn}; ...
          max(0, min(1, 1 - size(log_{fn, tn}.timeStamp{rn}, 1) / ...
          (fps * (seq_duration(sn) - seq_start_time(sn))) ) )];
        
      end
    end
  end
  
  %%
  metric_type = {'timeFrontEnd'; 'numMeasur'; 'timeBackEnd'; 'numPoseState'; };
  for mn=1:4
    h = figure;
    clf
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
              err_raw = log_{fn, tn}.timeFrontEnd{rn};
            case 2
              err_raw = log_{fn, tn}.numMeasur{rn};
            case 3
              err_raw = log_{fn, tn}.timeBackEnd{rn};
            case 4
%               if isempty(log_{fn, tn}.numLmkState{rn})
%                 err_raw = log_{fn, tn}.numPoseState{rn};
%               else
%                 err_raw = log_{fn, tn}.numPoseState{rn} + log_{fn, tn}.numLmkState{rn};
%               end
err_raw = log_{fn, tn}.numPoseState{rn};
          end
          %
          if ~isempty(err_raw) % && track_loss_rate_{fn, tn}(rn) < 0.5
            %             err_all_rounds = [err_all_rounds; mean(err_raw)];
            err_all_rounds = [err_all_rounds; err_raw(err_raw >= 0)];
          else
            disp 'error! no valid data for plot!'
            err_all_rounds = [err_all_rounds; NaN];
          end
        end
        %
        %         err_summ{fn} = cat(2, err_summ{fn}, err_all_rounds);
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
    %     for fn=1:length(fast_mo_list)
    %       err_boxplot = cat(2, err_boxplot, err_summ{fn});
    %     end
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
        ['FastMo Speed: ' num2str(fast_mo_list(fn), '%.01f')], ...
        'HorizontalAlignment', 'center')
    end
    text(length(fast_mo_list)*baseline_num+0.5-baseline_num*0.5, y_top, ...
      ['FastMo Speed: ' num2str(fast_mo_list(end), '%.01f')], ...
      'HorizontalAlignment', 'center')
    %     if mn == 1
    %     legend(legend_arr{[1:length(slam_path_list)]},'Location','northwest');
    %     end
    % boxplot(err_summ{tn}, 'labels', lmk_number_list, 'Positions', lmk_number_list);
    ylim([0 y_top * 1.01])
    xlabel('config')
    ylabel([metric_type{mn}])
    %
    % save the figure
    %     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     export_fig(h, [save_path '/MaxVol_' seq_idx '_' metric_type{mn} '.png']); % , '-r 200');
    %     close(h)
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/Box_Config_' metric_type{mn} '_' seq_idx '.png']); % , '-r 200');
    
  end
  
  close all
  
end