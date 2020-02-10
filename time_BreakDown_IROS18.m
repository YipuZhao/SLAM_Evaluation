clear all
close all

%%
addpath('/home/yipuzhao/SDK/aboxplot');
addpath('/home/yipuzhao/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark = 'EuRoC_TimeCost' % 'EuRoC_ICRA_18' %  
setParam

for gn = 1:length(gf_slam_list)
  
  for tn=1:length(slam_path_list)
    time_Match{tn} = [];
    time_Selec{tn} = [];
    time_Optim{tn} = [];
    time_Total{tn} = [];
  end
  
  for sn = 1:length(seq_list) %
    
    seq_idx = seq_list{sn};
    disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
    
    %%
    for tn=1:length(slam_path_list)
      log_{gn, tn} = [];
    end
    %
    for rn = 1:round_num
      for tn=1:length(slam_path_list)
        
        % Load Log Files
        %       disp(['Loading ORB-SLAM log...'])
        if tn <= 2
          [log_{gn, tn}] = loadLogTUM([slam_path_list{tn}], ...
            rn, seq_idx, log_{gn, tn});
        else
          [log_{gn, tn}] = loadLogTUM([slam_path_list{tn} gf_slam_list{gn}], ...
            rn, seq_idx, log_{gn, tn});
        end
        
      end
      
    end
    
    %%
    selected_idx = [3:length(slam_path_list), 2, 1];
    
    % matching time
    for j=selected_idx
      for rn=1:round_num
        time_Match{j} = [time_Match{j} mean( log_{1, j}.timeMatch{rn} )];
      end
    end
    
    % selection time
    for j=selected_idx
      for rn=1:round_num
        time_Selec{j} = [time_Selec{j} mean( log_{1, j}.timeSelect{rn} )];
      end
    end
    
    % optimization time
    for j=selected_idx
      %       time_arr = [];
      for rn=1:round_num
        time_Optim{j} = [time_Optim{j} mean( log_{1, j}.timeOpt{rn} )];
      end
    end
    
    % total tracking time
    for j=selected_idx
      %       time_arr = [];
      for rn=1:round_num
        time_Total{j} = [time_Total{j} mean( log_{1, j}.timeTrack{rn} )];
% time_Total{j} = [time_Total{j}; log_{1, j}.timeTrack{rn}];
      end
    end
    
  end
  
  selected_idx = [3:length(slam_path_list), 2, 1];
  legend_arr(selected_idx)'
  
  for j=selected_idx
    disp '--------------------------------'
    disp(['matching time of ' legend_arr{j} ': ' num2str(nanmean(time_Match{j}))])
    disp(['selection time of ' legend_arr{j} ': ' num2str(nanmean(time_Selec{j}))])
    disp(['optimization time of ' legend_arr{j} ': ' num2str(nanmean(time_Optim{j}))])
    disp(['total track time of ' legend_arr{j} ': ' num2str(nanmean(time_Total{j}))])
  end
  
end