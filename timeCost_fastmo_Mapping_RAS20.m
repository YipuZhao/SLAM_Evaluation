close all
clear all

addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

data_dir = '/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/laptop_onboard/';
% data_dir = '/media/yipuzhao/1399F8643500EDCD/ClosedLoop_Exp/Simulation/laptop_onboard';

% Batch Config
seq_list = {
  'loop';
  'long';
  'zigzag';
  'square';
  'two_circle';
  'infinite';
  };

imu_type = 'ADIS16448'; % 'mpu6000'; %
mtd_fname = {
  'GF_gpu_skf_log';
  'GF_GG_skf_gpu_log';
  };%
num_feat = 100;
fwd_vel = '1.5'; % '1.0'; % '0.5'; %

do_viz = 1;
%
ref_reload = 1;

round_num = 1 % 5;

max_y_lim = 250 % 800 % 400

plot_time_bar       = true; % false; %
plot_budget_aware   = false; % true; %

save_path = './output/RAS19/lowpower/'

% total_time_summ = cell(1, 6);
total_time_summ = cell(1, 2, 4);

bar_color = [
  0.93,0.69,0.13;
  0.49,0.18,0.56;
  0.47,0.67,0.19;
  0.30,0.75,0.93;
  ];

for sn = 6 % 1:length(seq_list) % [1,5,10] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %   tn=6; % 1 %
  fn=1;
  
  %% Load Log Files for ORB & GF
  for tn = 1:2
    log_{fn, tn} = [];
    for rn = 1:round_num
      disp(['Round ' num2str(rn)])
      disp(['Loading ORB & GF log...'])
      
      % load front end logging
      log_fname = [data_dir '/' seq_idx ...
        '/' imu_type '/' mtd_fname{tn} '/ObsNumber_' num2str(num_feat) ...
        '_Vel' num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_Log.txt'];
      %
      fid = fopen(log_fname, 'rt');
      if fid ~= -1
        
        log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', ...
          'HeaderLines', 2));
        
        log_{fn, tn}.timeStamp{rn}         = log_orb_slam(:, 1);
        %
        log_{fn, tn}.timeOrbExtr{rn}       = log_orb_slam(:, 2) * 1000;
        log_{fn, tn}.timeTrackMotion{rn}   = log_orb_slam(:, 3) * 1000;
        log_{fn, tn}.timeTrackFrame{rn}    = log_orb_slam(:, 4) * 1000;
        log_{fn, tn}.timeTrackMap{rn}      = log_orb_slam(:, 5) * 1000;
        log_{fn, tn}.timeMapMatch{rn}      = log_orb_slam(:, 6) * 1000;
        log_{fn, tn}.timeMapSelect{rn}     = log_orb_slam(:, 7) * 1000;
        log_{fn, tn}.timeMapOpt{rn}        = log_orb_slam(:, 8) * 1000;
        %
        log_{fn, tn}.timeStereoMotion{rn}  = log_orb_slam(:, 9) * 1000;
        log_{fn, tn}.timeStereoFrame{rn}   = log_orb_slam(:, 10) * 1000;
        log_{fn, tn}.timeStereoMap{rn}     = log_orb_slam(:, 11) * 1000;
        log_{fn, tn}.timeStereoPost{rn}    = log_orb_slam(:, 12) * 1000;
        
        log_{fn, tn}.timeStereo{rn}         = log_{fn, tn}.timeStereoMotion{rn} + ...
          log_{fn, tn}.timeStereoFrame{rn} + log_{fn, tn}.timeStereoMap{rn};
        %
        log_{fn, tn}.timeMatPredict{rn}    = log_orb_slam(:, 13) * 1000;
        log_{fn, tn}.timeMatOnline{rn}     = log_orb_slam(:, 14) * 1000;
        
        %
        log_{fn, tn}.timeHashInsert{rn}    = log_orb_slam(:, 15) * 1000;
        log_{fn, tn}.timeHashQuery{rn}     = log_orb_slam(:, 16) * 1000;
        
        log_{fn, tn}.timeTotal{rn}         = log_{fn, tn}.timeOrbExtr{rn} + ...
          log_{fn, tn}.timeTrackMotion{rn} + log_{fn, tn}.timeTrackFrame{rn} + log_{fn, tn}.timeTrackMap{rn};
        log_{fn, tn}.timeDirect{rn} = [];
        %
        log_{fn, tn}.lmkTrackMotion{rn}    = log_orb_slam(:, 17);
        log_{fn, tn}.lmkTrackFrame{rn}     = log_orb_slam(:, 18);
        log_{fn, tn}.lmkTrackMap{rn}       = log_orb_slam(:, 19);
        log_{fn, tn}.lmkLocalMap{rn}       = log_orb_slam(:, 20);
        log_{fn, tn}.lmkBA{rn}             = log_orb_slam(:, 21);
        log_{fn, tn}.lmkHashDynm{rn}       = log_orb_slam(:, 22);
        
      end
      fclose(fid);
      
      % load back end logging
      %     [log_tmp] = loadLogTUM_GoodBA_old([slam_path_list{tn} ...
      %       num2str(fast_mo_list(fn), '%.01f') '/' ...
      %       baseline_slam_list{table_index(tn)}], ...
      %       rn, seq_idx, log_tmp, 2);
      %         end
      log_fname = [data_dir '/' seq_idx ...
        '/' imu_type '/' mtd_fname{tn} '/ObsNumber_' num2str(num_feat) ...
        '_Vel' num2str(fwd_vel, '%.01f') '/round' num2str(rn) '_Log_Mapping.txt'];
      %
      fid = fopen(log_fname, 'rt');
      if fid ~= -1
        %       log_ = cell2mat(textscan(fid, ...
        %         '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
        log_dat = cell2mat(textscan(fid, ...
          '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
        %
        log_{fn, tn}.timeStampBack{rn}     = log_dat(:, 1);
        %
        log_{fn, tn}.timeNewKeyFrame{rn}   = log_dat(:, 2) * 1000;
        log_{fn, tn}.timeMapCulling{rn}    = log_dat(:, 3) * 1000;
        log_{fn, tn}.timeMapTriangulate{rn}= log_dat(:, 4) * 1000;
        log_{fn, tn}.timeSrhNeighbor{rn}   = log_dat(:, 5) * 1000;
        log_{fn, tn}.timeLocalBA{rn}       = log_dat(:, 6) * 1000;
        
        log_{fn, tn}.timeBackEnd{rn}         = log_{fn, tn}.timeNewKeyFrame{rn} + ...
          log_{fn, tn}.timeMapCulling{rn} + log_{fn, tn}.timeMapTriangulate{rn} + ...
          log_{fn, tn}.timeSrhNeighbor{rn} + log_{fn, tn}.timeLocalBA{rn};
        
        log_{fn, tn}.timePrediction{rn}    = log_dat(:, 7) * 1000;
        log_{fn, tn}.timeInsertVertex{rn}  = log_dat(:, 8) * 1000;
        log_{fn, tn}.timeJacobian{rn}      = log_dat(:, 9) * 1000;
        log_{fn, tn}.timeQuery{rn}         = log_dat(:, 10) * 1000;
        log_{fn, tn}.timeSchur{rn}         = log_dat(:, 11) * 1000;
        log_{fn, tn}.timePermute{rn}       = log_dat(:, 12) * 1000;
        log_{fn, tn}.timeCholesky{rn}      = log_dat(:, 13) * 1000;
        log_{fn, tn}.timePostProc{rn}      = log_dat(:, 14) * 1000;
        log_{fn, tn}.timeOptimization{rn}  = log_dat(:, 15) * 1000;
        log_{fn, tn}.timeBudget{rn}        = log_dat(:, 16) * 1000;
        
        % NOTE
        % only free KF contributes to the state space;
        % fixed ones serves as diagonal priors only
        %
        log_{fn, tn}.numPoseState{rn}      = log_dat(:, 18) * 6;
        log_{fn, tn}.numLmkState{rn}       = log_dat(:, 19) * 3;
      end
      fclose(fid);
      
    end
  end
  
  %%
  if plot_time_bar
    
    h = figure(1);
    clf
    %
    rn = 1;
    for tn = 1:2
      subplot(2, 1, tn)
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
      %       if tn == 2
      %         yyaxis left;
      %       end
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
      grid on
      
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
      
      %       if tn == 2
      %         %         set(gca, 'YScale', 'log')
      %         hold on
      %         yyaxis right;
      %         %         plot(err_struct{fn, tn}.abs_drift{rn}(:,1) - repmat(log_{fn, tn}.timeStampBack{rn}(1), ...
      %         %           length(err_struct{fn, tn}.abs_drift{rn}), 1), err_struct{fn, tn}.abs_drift{rn}(:,2), '--r')
      %         %         plot(err_struct{fn, tn}.rel_drift{rn}(:,1) - repmat(log_{fn, tn}.timeStampBack{rn}(1), ...
      %         %           length(err_struct{fn, tn}.rel_drift{rn}), 1), err_struct{fn, tn}.rel_drift{rn}(:,2), '--r')
      %         plot(x, log_{fn, tn}.timeBudget{rn}, '--r');
      %         ylim([0 max_y_lim])
      %       end
      hold on
      yyaxis right;
      plot(x, log_{fn, tn}.numPoseState{rn} ./ 6, '--r');
      
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
        ylim([0 30])
      %         ylabel('RPE (m/s)')
      %         ylim([0 1.0])
      %         ylim([0 1.0])
    end
    
%     set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/GoodGraph_bar_' seq_idx '_fwd_' fwd_vel '.fig']);
    export_fig(h, [save_path '/GoodGraph_bar_' seq_idx '_fwd_' fwd_vel '.png']);
  end
  
  %%
  if plot_budget_aware
    
    h = figure(2);
    clf
    %
    rn = 1;
    for tn = 1:2
      subplot(2, 1, tn)
      hold on
      %
      x = log_{fn, tn}.timeStamp{rn};
      x = x - repmat(log_{fn, tn}.timeStamp{rn}(1), length(x), 1);
      if isempty(x)
        continue ;
      end
      
      y = log_{fn, tn}.lmkLocalMap{rn};
      
      if tn == 2
        yyaxis left;
      end
      plot(x, y, '--g');
      
      if tn == 2
        hold on
        yyaxis right;
        
        x = log_{fn, tn}.timeStampBack{rn};
        x = x - repmat(log_{fn, tn}.timeStamp{rn}(1), length(x), 1);
        y = log_{fn, tn}.timeBudget{rn};
        
        plot(x, y, '--r');
        ylim([0 max_y_lim])
      end
      
      xlabel('Duration (sec)')
      
    end
    
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    export_fig(h, [save_path '/GoodGraph_budget_' seq_idx '_fwd_' fwd_vel '.fig']);
    export_fig(h, [save_path '/GoodGraph_budget_' seq_idx '_fwd_' fwd_vel '.png']);
    
  end
  
end
