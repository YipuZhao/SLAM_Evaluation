clear all
close all

addpath('~/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark = 'EuRoC' % 'TUM' % 'KITTI' %
setParam
round_num = 10; %
do_viz = 1;
%
% lmk_ratio_list = [0.4, 0.6, 0.8]; %[0.1 0.2 0.3 0.4]; %
ref_reload = 1;

for sn = 1:length(seq_list) % [2:4, 7] %
  
  % Seq 0X
  seq_idx = seq_list{sn};
  disp(['Sequence =============== ' seq_idx ' ==============='])
  
  %
  %   for ln = 1:length(lmk_ratio_list)
  for gn = 1:length(gf_slam_list)
    %
    for rn = 1:round_num
      disp(['Round ' num2str(rn)])
      
      %% Load .m Record Files
      % ref
      disp(['Loading reference log...'])
      dir_Ref = [orig_slam_path '_Round' num2str(rn)]
      
      %         run([dir_Ref '/' seq_idx '_Log']);
      fid = fopen([dir_Ref '/' seq_idx '_Log.txt'], 'rt');
      if fid ~= -1
        log_ref = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
        fclose(fid);
      else
        log_ref = [];
      end
      %         lmkUsed_ref{rn} = lmkNum;
      %         lmkInlier_ref{rn} = inlierNum;
      %         timeOpt_ref{rn} = optTime * 1000;
      %         clear lmkNum inlierNum updTime srhTime optTime
      lmkUsed_ref{rn} = log_ref(:, 11);
      timeTrack_ref{rn} = (log_ref(:, 4) + log_ref(:, 5) + log_ref(:, 8) + log_ref(:, 9)) * 1000;
      timeObs_ref{rn} = log_ref(:, 5) * 1000;
      timeOpt_ref{rn} = (log_ref(:, 8) + log_ref(:, 9)) * 1000;
      %
      clear log_ref
      
      mkdir([save_path '/' seq_idx '/']);
      save([save_path '/' seq_idx '/Ref_' seq_idx], ...
        'lmkUsed_ref', 'timeTrack_ref', 'timeObs_ref', 'timeOpt_ref');
      
      
      %%
      disp(['Loading GF log...'])
      % GF
      dir_GF = [gf_slam_path gf_slam_list{gn} '_Round' num2str(rn)]
      %       run([dir_GF '/' seq_idx '_Log']);
      fid = fopen([dir_GF '/' seq_idx '_Log.txt'], 'rt');
      if fid ~= -1
        log_gf = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
        fclose(fid);
      else
        log_gf = [];
      end
      
      lmkUsed_gf{rn} = log_gf(:, 12);
      timeTrack_gf{rn} = (log_gf(:, 4) + log_gf(:, 5) + log_gf(:, 8) + log_gf(:, 9)) * 1000;
      timeObs_gf{rn} = log_gf(:, 5) * 1000;
      timeOpt_gf{rn} = (log_gf(:, 8) + log_gf(:, 9)) * 1000;
      %
      clear log_gf
      
      %       disp 'GF lmk number - mean = '
      %       mean(lmkUsed_gf{ln, rn})
      %
      %       disp 'GF lmk number - std = '
      %       std(lmkUsed_gf{ln, rn})
      
      % save mat file
      save([save_path '/' seq_idx '/GF_' seq_idx], ...
        'lmkUsed_gf', 'timeTrack_gf', 'timeObs_gf', 'timeOpt_gf');
      
      %%
      disp(['Loading Max-Vol log...'])
      % Max-Vol
      dir_MV = [mv_slam_path gf_slam_list{gn} '_Round' num2str(rn)]
      %       run([dir_MV '/' seq_idx '_Log']);
      fid = fopen([dir_MV '/' seq_idx '_Log.txt'], 'rt');
      if fid ~= -1
        log_mv = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
        fclose(fid);
      else
        log_mv = [];
      end
      
      lmkUsed_mv{rn} = log_mv(:, 12);
      timeTrack_mv{rn} = (log_mv(:, 4) + log_mv(:, 5) + log_mv(:, 8) + log_mv(:, 9)) * 1000;
      timeObs_mv{rn} = log_mv(:, 5) * 1000;
      timeOpt_mv{rn} = (log_mv(:, 8) + log_mv(:, 9)) * 1000;
      %
      clear log_mv
      
      %       disp 'Max-Vol lmk number - mean = '
      %       mean(lmkUsed_mv{ln, rn})
      %
      %       disp 'Max-Vol lmk number - std = '
      %       std(lmkUsed_mv{ln, rn})
      
      % save mat file
      save([save_path '/' seq_idx '/MV_' seq_idx], ...
        'lmkUsed_mv', 'timeTrack_mv', 'timeObs_mv', 'timeOpt_mv');
      
      %       %% Plot Time Cost Figures
      %       if do_viz
      %         %   h=figure('Visible','Off');
      %         h=figure(1);
      %         clf
      %         subplot(2,2,1)
      %         plot(lmkUsed_ref{rn}, '-r')
      %         hold on
      %         plot(lmkUsed_gf{ln, rn}, '-g')
      %         plot(lmkUsed_mv{ln, rn}, '-b')
      %         xlim([0 length(lmkUsed_ref{rn})])
      %         xlabel('frame num')
      %         ylabel('lmk num')
      %         legend({
      %           'ORB - lmk per frame';
      %           'GF - lmk per frame';
      %           'MV - lmk per frame';
      %           })
      %         %
      %         subplot(2,2,2)
      %         plot(timeOpt_ref{rn}, '-r')
      %         hold on
      %         %         plot(timeOpt_gf{ln, rn})
      %         %         plot(timeObs_gf{ln, rn}+timeOpt_gf{ln, rn})
      %         plot(timeObs_mv{ln, rn}+timeOpt_mv{ln, rn}, '-b')
      %         plot(timeSVD_mv{ln, rn}, '-.')
      %         plot(timeSubset_mv{ln, rn}, '-.')
      %         plot(timeOpt_mv{ln, rn}, '-.')
      %         xlim([0 length(timeOpt_ref{rn})])
      %         xlabel('frame num')
      %         ylabel('ms')
      %         hold off
      %         legend({
      %           'ORB - pose opt time';
      %           %           'GF - pose opt time';
      %           %           'GF - obs compute & pose opt time';
      %           'MV - obs compute & pose opt time';
      %           'MV - SVD time';
      %           'MV - subset selection time';
      %           'MV - pose opt time';
      %           })
      %         %
      %         subplot(2,2,3)
      %         %         g = vertcat(repmat({'ORB Opt'}, length(lmkUsed_ref{rn}), 1), ...
      %         %           repmat({'GF Opt'}, length(lmkUsed_gf{ln, rn}), 1), ...
      %         %           repmat({'MV Opt'}, length(lmkUsed_mv{ln, rn}), 1));
      %         %         boxplot([lmkUsed_ref{rn}, lmkUsed_gf{ln, rn}, lmkUsed_mv{ln, rn}], ...
      %         %           g, 'Whisker', 999);
      %         g = vertcat(...
      %           repmat({'ORB Inlier'}, length(lmkInlier_ref{rn}),   1),   ...
      %           repmat({'MV Inlier'}, length(lmkInlier_mv{ln, rn}), 1)    ...
      %           );
      %         boxplot([lmkInlier_ref{rn}, lmkInlier_mv{ln, rn}], ...
      %           g, 'Whisker', 999);
      %
      %         grid on
      %         ylabel('lmk num')
      %         %
      %         subplot(2,2,4)
      %         %         g = vertcat(repmat({'ORB Opt'}, length(timeOpt_ref{rn}), 1), ...
      %         %           repmat({'GF Opt'}, length(timeObs_gf{ln, rn}), 1), ...
      %         %           repmat({'GF Obs + Opt'}, length(timeObs_gf{ln, rn}), 1), ...
      %         %           repmat({'MV Opt'}, length(timeObs_mv{ln, rn}), 1), ...
      %         %           repmat({'MV Obs + Opt'}, length(timeObs_mv{ln, rn}), 1));
      %         %         boxplot([timeOpt_ref{rn}, timeOpt_gf{ln, rn}, timeObs_gf{ln, rn}+timeOpt_gf{ln, rn}, ...
      %         %           timeOpt_mv{ln, rn}, timeObs_mv{ln, rn}+timeOpt_mv{ln, rn}], g, 'Whisker', 999);
      %
      %         %         g = vertcat(repmat({'ORB Track'}, length(timeTrackLocalMap_mv{rn}), 1), ...
      %         %           repmat({'GF Track'}, length(timeTrackLocalMap_gf{ln, rn}), 1), ...
      %         %           repmat({'MV Track'}, length(timeTrackLocalMap_mv{ln, rn}), 1));
      %         %         boxplot([timeTrackLocalMap_mv{rn}, timeTrackLocalMap_gf{ln, rn}, ...
      %         %           timeTrackLocalMap_mv{rn}], g, 'Whisker', 999);
      %
      %         g = vertcat(...
      %           repmat({'ORB Track'}, length(timeTrack_ref{rn}), 1),      ...
      %           repmat({'ORB Opt'}, length(timeOpt_ref{rn}), 1),          ...
      %           repmat({'MV Track'},  length(timeTrack_mv{ln, rn}), 1),   ...
      %           repmat({'MV Opt'},  length(timeOpt_mv{ln, rn}), 1),       ...
      %           repmat({'MV Obs'},  length(timeObs_mv{ln, rn}), 1),       ...
      %           repmat({'MV SVD'},  length(timeSVD_mv{ln, rn}), 1),       ...
      %           repmat({'MV Subset'},  length(timeSubset_mv{ln, rn}), 1)     ...
      %           );
      %         boxplot([
      %           timeTrack_ref{rn}, ...
      %           timeOpt_ref{rn}, ...
      %           timeTrack_mv{ln, rn}, ...
      %           timeOpt_mv{ln, rn}, ...
      %           timeObs_mv{ln, rn}, ...
      %           timeSVD_mv{ln, rn}, ...
      %           timeSubset_mv{ln, rn} ...
      %           ], g, 'Whisker', 999);
      %
      %         grid on
      %         ylabel('ms')
      %
      %         % save
      %         set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
      %         export_fig(h, [save_path '/' seq_idx '/Time_' seq_idx '_ratio_' ...
      %           num2str(lmk_ratio_list(ln)) '.png'], '-r 200');
      %         close(h)
      %
      %       end
    end
    
    %% print stat
    %       disp 'num of lmk used:'
    %       nanmean(lmkUsed_ref{rn})
    %       nanstd(lmkUsed_ref{rn})
    %       nanmean(lmkUsed_gf{rn})
    %       nanstd(lmkUsed_gf{rn})
    %       nanmean(lmkUsed_mv{rn})
    %       nanstd(lmkUsed_mv{rn})
    
    disp 'time used in pose tracking:'
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeTrack_ref{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    %
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeTrack_gf{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    %
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeTrack_mv{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    
    
    disp 'time used in pose optimization:'
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeOpt_ref{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    %
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeOpt_gf{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    %
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeOpt_mv{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    
    disp 'time used in feature selection:'
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeObs_gf{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    %
    arr_tmp  = [];
    for ii=1:rn
      arr_tmp = [arr_tmp; timeObs_mv{ii}];
    end
    fprintf('%.01f\\ %.01f^2\n', nanmean(arr_tmp), nanstd(arr_tmp))
    
  end
end
