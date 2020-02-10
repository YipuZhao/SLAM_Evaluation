clear all;
close all

addpath('~/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark = 'EuRoC' % 'TUM' % 'KITTI' %
setParam
round_num = 1;
do_viz = 1;
%
lmk_ratio_list = [0.1 0.2 0.3 0.4];

% mat_path = '/home/yipuzhao/Codes/VSLAM/SLAM_Evaluation/output/TimeCost'

for sn=1:length(seq_list)
  
  %% Seq 0X
seq_idx = seq_list{sn};
  disp(['Sequence =============== ' seq_idx ' ==============='])

  
  
  load([save_path '/' seq_idx '/' 'Ref_' seq_idx]);
  load([save_path '/' seq_idx '/' 'GF_' seq_idx]);
  load([save_path '/' seq_idx '/' 'MV_' seq_idx]);
  
  %
  for rn = 1:round_num
    for ln = 1:length(lmk_ratio_list)
      
      disp(['Lmk Ratio = ' num2str(lmk_ratio_list(ln)) ':'])
      
      % Ref
      disp 'Ref'
      mean(timeOpt_ref{rn})
      std(timeOpt_ref{rn})
      
      % GF
      disp 'GF'
      mean(timeObs_gf{ln, rn}+timeOpt_gf{ln, rn})
      std(timeObs_gf{ln, rn}+timeOpt_gf{ln, rn})
      
      % MV
      disp 'Max-Vol'
      mean(timeObs_mv{ln, rn}+timeOpt_mv{ln, rn})
      std(timeObs_mv{ln, rn}+timeOpt_mv{ln, rn})
      
      %% plot
      if do_viz
        
        h=figure(1);
        clf
        subplot(2,2,1)
        plot(lmkUsed_ref{rn}, '-r')
        hold on
        plot(lmkInlier_ref{rn}, '-.r')
        plot(lmkUsed_gf{ln, rn}, '-g')
        plot(lmkInlier_gf{ln, rn}, '-.g')
        plot(lmkUsed_mv{ln, rn}, '-b')
        plot(lmkInlier_mv{ln, rn}, '-.b')
        xlim([0 length(lmkUsed_ref{rn})])
        xlabel('frame num')
        ylabel('lmk num')
        legend({
          'ORB - lmk per frame';
          'ORB - inlier per frame';
          'GF - lmk per frame';
          'GF - inlier per frame';
          'MV - lmk per frame';
          'MV - inlier per frame';
          })
        %
        subplot(2,2,2)
        plot(timeOpt_ref{rn})
        hold on
        plot(timeOpt_gf{ln, rn})
        plot(timeObs_gf{ln, rn}+timeOpt_gf{ln, rn})
        plot(timeOpt_mv{ln, rn})
        plot(timeObs_mv{ln, rn}+timeOpt_mv{ln, rn})
        xlim([0 length(timeOpt_ref{rn})])
        xlabel('frame num')
        ylabel('ms')
        hold off
        legend({
          'ORB - pose opt time';
          'GF - pose opt time';
          'GF - obs compute & pose opt time';
          'MV - pose opt time';
          'MV - obs compute & pose opt time';
          })
        %
        subplot(2,2,3)
        g = vertcat(repmat({'ORB Opt'}, length(lmkUsed_ref{rn}), 1), ...
          repmat({'GF Opt'}, length(lmkUsed_gf{ln, rn}), 1), ...
          repmat({'MV Opt'}, length(lmkUsed_mv{ln, rn}), 1));
        boxplot([lmkUsed_ref{rn}, lmkUsed_gf{ln, rn}, lmkUsed_mv{ln, rn}], g, 'Whisker', 999);
        grid on
        ylabel('lmk num')
        %
        subplot(2,2,4)
        g = vertcat(repmat({'ORB Opt'}, length(timeOpt_ref{rn}), 1), ...
          repmat({'GF Opt'}, length(timeObs_gf{ln, rn}), 1), ...
          repmat({'GF Obs + Opt'}, length(timeObs_gf{ln, rn}), 1), ...
          repmat({'MV Opt'}, length(timeObs_mv{ln, rn}), 1), ...
          repmat({'MV Obs + Opt'}, length(timeObs_mv{ln, rn}), 1));
        boxplot([timeOpt_ref{rn}, timeOpt_gf{ln, rn}, timeObs_gf{ln, rn}+timeOpt_gf{ln, rn}, timeOpt_mv{ln, rn}, timeObs_mv{ln, rn}+timeOpt_mv{ln, rn}], g, 'Whisker', 999);
        grid on
        ylabel('ms')
        
        % save
        set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
        export_fig(h, [save_path '/' seq_idx '/Time_' seq_idx '_ratio_' ...
          num2str(lmk_ratio_list(ln)) '.png'], '-r 200');
        close(h)
        
      end
      
    end
  end
end
