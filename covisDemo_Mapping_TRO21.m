clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');

data_path = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_Stereo_BA_logging_Speedx0.3/ObsNumber_800_Round1/';
% data_path = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB2_Baseline_BALogging/ObsNumber_800_Round1/';

% method_list = { 'ORB'; 'Rnd'; 'Long'; 'GF_c50'; };
% marker_styl = { '-bo'; '-ro'; '-go'; '-ko'; };

seq_list = {
  'MH_01_easy';
  'MH_02_easy';
  'MH_03_medium';
  'MH_04_difficult';
  'MH_05_difficult';
  'V1_01_easy';
  'V1_02_medium';
  'V1_03_difficult';
  'V2_01_easy';
  'V2_02_medium';
  'V2_03_difficult';
  };

% BA_list = dir([data_path '/*_Log_BA.txt']);
% BA_log = 'MH_01_easy_Log_BA.txt';

font_size = 12;
mark_size = 5;
figure_size = [1 1 1000 1000];
save_path = './output/RAL19'

for j= 1:length(seq_list)
  
  disp(['-------------- Working on Sequence ' seq_list{j} ' --------------'])
  
  %%
  index_Set = [];
  log_BA = {};
  %   log_path = [data_path '/' BA_list(j).name];
  %   log_path = [data_path '/' BA_log];
  disp(['Loading BA log...'])
  fid = fopen([data_path '/' seq_list{j} '_Log_BA.txt'], 'rt');
  if fid ~= -1
    
    i = 1;
    tx = [];
    tline = fgetl(fid);
    while ischar(tline) %&& length(tline) > 1
      % get time stamp
      tline = fgetl(fid);
      if isnan(str2double(tline))
        break ;
      end
      log_BA{i}.timeStamp = str2double(tline);
      tx = [tx, log_BA{i}.timeStamp];
      %       disp(tline)
      % get KF index
      tline = fgetl(fid);
      arr_1 = str2num(tline);
      if arr_1(1) > 0
        log_BA{i}.index_KF = arr_1(2:end);
      else
        log_BA{i}.index_KF = [];
      end
      % get fixF index
      tline = fgetl(fid);
      arr_2 = str2num(tline);
      if arr_2(1) > 0
        log_BA{i}.index_fixF = arr_2(2:end);
      else
        log_BA{i}.index_fixF = [];
      end
      %
      index_Set = unique([index_Set log_BA{i}.index_KF log_BA{i}.index_fixF]);
      i = i + 1;
    end
    
    fclose(fid);
    
    if length(index_Set) == 0 || length(log_BA) == 0
      continue ;
    end
    
    %
    tx_start = tx(1);
    tx = tx - tx_start;
    
    %%
    disp(['Loading ORB-SLAM log...'])
    log_time{j} = {};
    [log_time{j}] = loadLogTUM_BA(data_path(1:end-8), ...
      1, seq_list{j}, log_time{j}, 1);
    
    %
    vld_idx = find(log_time{j}.timeLocalBA{1} > 0);
    
    assert(length(tx) == length(vld_idx))
    
    %% Visualization
    index_Map = ones(length(index_Set), length(log_BA));
    for i=1:length(log_BA)
      index_Map(i+1:end, i) = 0;
    end
    
    for i=1:length(log_BA)
      index_Map(log_BA{i}.index_KF + 1, i) = 2;
      index_Map(log_BA{i}.index_fixF + 1, i) = 3;
    end
    
    %   figure(1);
    %   imagesc(index_Map)
    %   % legend({'non-fixed KF'; 'fixed KF'});
    %   xlabel('KeyFrame');
    %   ylabel('Subset used in Local BA');
    %   % Put up "legend"
    %   str = sprintf('unused KF');
    %   text(10, 190, str, 'Color', [0.15, 0.588, 0.92], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    %   str = sprintf('non-fixed KF');
    %   text(10, 200, str, 'Color', [0.5, 0.8, 0.345], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    %   str = sprintf('fixed KF');
    %   text(10, 210, str, 'Color', [0.977, 0.98, 0.078], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    
    h = figure(2);
    clf
    subplot(6,1,[1,2,3]);
    surf(tx, index_Set, index_Map, 'EdgeAlpha', 0.5)
    xlim([tx(1), tx(end)])
    ylim([index_Set(1), index_Set(end)])
    %     surf([1:length(log_BA)], index_Set, index_Map, 'EdgeAlpha', 0.5)
    %     xlim([index_Set(1)+1, index_Set(end)+1])
    %     ylim([index_Set(1), index_Set(end)])
    % legend({'non-fixed KF'; 'fixed KF'});
    %     xlabel('KeyFrame');
    xlabel('KeyFrame TimeStamp');
    ylabel('Subset used in Local BA');
    view(0.5, -90)
    % Put up "legend"
    str = sprintf('unused KF');
    text(tx(1) + 10, length(index_Set) - 60, str, 'Color', [0.15, 0.588, 0.92], ...
      'FontSize', font_size, 'FontWeight', 'Bold', 'Interpreter', 'None');
    str = sprintf('non-fixed KF');
    text(tx(1) + 10, length(index_Set) - 40, str, 'Color', [0.5, 0.8, 0.345], ...
      'FontSize', font_size, 'FontWeight', 'Bold', 'Interpreter', 'None');
    str = sprintf('fixed KF');
    text(tx(1) + 10, length(index_Set) - 20, str, 'Color', [0.977, 0.98, 0.078], ...
      'FontSize', font_size, 'FontWeight', 'Bold', 'Interpreter', 'None');
    
    num_nf_KF = sum(index_Map == 2, 1);
    num_fx_KF = sum(index_Map == 3, 1);
    disp([ 'average KF num = ' num2str(mean(num_nf_KF+num_fx_KF)) ...
      '; non-fix KF = ' num2str(mean(num_nf_KF)) ...
      '; fixed KF = ' num2str(mean(num_fx_KF)) ])
    
    %
    subplot(6,1,4)
    hold on
    scatter(log_time{j}.timeStamp{1}(vld_idx) - tx_start, ...
      log_time{j}.timeBackEnd{1}(vld_idx), ones(size(vld_idx))*mark_size, 'ob');
    scatter(log_time{j}.timeStamp{1}(vld_idx) - tx_start, ...
      log_time{j}.timeLocalBA{1}(vld_idx), ones(size(vld_idx))*mark_size, 'sr');
    legend({'timeBackEnd'; 'timeLocalBA';}, 'Location', 'northwest');
    %
    %     xlim([index_Set(1)+1, index_Set(end)+1])
    xlim([tx(1), tx(end)])
    xlabel('KeyFrame TimeStamp');
    ylabel('Time cost in Local BA (ms)');
    
    %
    subplot(6,1,5)
    hold on
    %     plot(tx, num_nf_KF, '--', 'Color', [0.5, 0.8, 0.345]);
    %     plot(tx, num_fx_KF, '--', 'Color', [0.777, 0.78, 0.078]);
    scatter(tx, num_nf_KF, ones(size(vld_idx))*mark_size, 'o', 'MarkerEdgeColor', [0.5, 0.8, 0.345]);
    scatter(tx, num_fx_KF, ones(size(vld_idx))*mark_size, 's', 'MarkerEdgeColor', [0.88, 0.88, 0.18]);
    %     plot(num_nf_KF+num_fx_KF, '--k');
    %     legend({'non-fixed KF'; 'fixed KF'; 'all-used KF';}, 'Location', 'northwest');
    legend({'non-fixed KF'; 'fixed KF';}, 'Location', 'northwest');
    %
    %     xlim([index_Set(1)+1, index_Set(end)+1])
    xlim([tx(1), tx(end)])
    xlabel('KeyFrame TimeStamp');
    ylabel('KF used in Local BA');
    
    %
    subplot(6,1,6)
    hold on
    %     plot(log_time{j}.numLmkState{1}/3, '--', 'Color', 'b');
    scatter(log_time{j}.timeStamp{1}(vld_idx) - tx_start, ...
      log_time{j}.numLmkState{1}(vld_idx)/3, ones(size(vld_idx))*mark_size, 'ob');
    legend({'lmk';}, 'Location', 'northwest');
    %
    %     xlim([index_Set(1)+1, index_Set(end)+1])
    %     xlabel('KeyFrame');
    xlim([tx(1), tx(end)])
    xlabel('KeyFrame TimeStamp');
    ylabel('Lmk used in Local BA');
    disp([ 'average Lmk num = ' num2str(mean(log_time{j}.numLmkState{1}(vld_idx)/3)) ])
    
    set(h, 'Position', figure_size)
    export_fig(h, [save_path '/BA_scale_' seq_list{j} '.png']);
    
    %     figure(3);
    %     index_Map = ones(length(index_Set), length(log_BA));
    %     for i=1:length(log_BA)
    %       index_Map(i+1:end, i) = 0;
    %     end
    %     for i=1:length(log_BA)
    %       index_Map(max(i+1-50, 1):i, i) = 2;
    %       index_Map(max(i-50, 1), i) = 3;
    %     end
    %     surf([1:length(log_BA)], index_Set, index_Map, 'EdgeAlpha', 0.5)
    %     xlim([index_Set(1)+1, index_Set(end)+1])
    %     ylim([index_Set(1), index_Set(end)])
    %     % legend({'non-fixed KF'; 'fixed KF'});
    %     xlabel('KeyFrame');
    %     ylabel('Subset used in Local BA');
    %     view(0.5, -90)
    %     % Put up "legend"
    %     str = sprintf('unused KF');
    %     text(10, length(index_Set) - 30, str, 'Color', [0.15, 0.588, 0.92], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    %     str = sprintf('non-fixed KF');
    %     text(10, length(index_Set) - 20, str, 'Color', [0.5, 0.8, 0.345], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    %     str = sprintf('fixed KF');
    %     text(10, length(index_Set) - 10, str, 'Color', [0.977, 0.98, 0.078], 'FontSize', 14, 'FontWeight', 'Bold', 'Interpreter', 'None');
    
    %% Estimate cross correlation between LBA time and state vector
    R_nf = corrcoef(log_time{j}.timeLocalBA{1}(vld_idx), num_nf_KF);
    R_fx = corrcoef(log_time{j}.timeLocalBA{1}(vld_idx), num_fx_KF);
    R_lmk = corrcoef(log_time{j}.timeLocalBA{1}(vld_idx), log_time{j}.numLmkState{1}(vld_idx));
    
    disp([ 'Correlation coef. of non-fixed KF number & BA time cost = ' num2str(R_nf(1,2)) ])
    disp([ 'Correlation coef. of fixed KF number & BA time cost = ' num2str(R_fx(1,2)) ])
    disp([ 'Correlation coef. of Lmk number & BA time cost = ' num2str(R_lmk(1,2)) ])
    
  end
end