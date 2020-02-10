clear all
close all

%%
addpath('/mnt/DATA/SDK/altmany-export_fig');
addpath('/mnt/DATA/SDK/aboxplot');

% set up parameters for each benchmark
benchMark =  'EuRoC_IROS18_Accuracy'
setParam

gn = 1;
for sn = 4 % 8 % 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %
  for rn = 1:round_num
    %% Load Trajectory Files
    % load the ground truth track
    track_ref = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 0);
    
    for tn=1:length(slam_path_list)
      %% load each result track
      if tn <= 2
        track{tn} = loadTrackTUM([slam_path_list{tn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
      else
        track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
      end
      
      %% associate the data to the model quat with timestamp
      asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
      
      %% Compute evaluation metrics
      if isempty(track{tn}) || isempty(track_ref)
        err_struct{tn}.scale_fac(rn) = 1.0;
        err_struct{tn}.abs_drift{rn} = [];
        err_struct{tn}.abs_orient{rn} = [];
        err_struct{tn}.term_drift{rn} = [];
        err_struct{tn}.term_orient{rn} = [];
        err_struct{tn}.rel_drift{rn} = [];
        err_struct{tn}.rel_orient{rn} = [];
        err_struct{tn}.track_loss_rate(rn) = 1.0;
        err_struct{tn}.track_fit{rn} = [];
      else
        [err_struct{tn}.abs_drift{rn}, err_struct{tn}.abs_orient{rn}, ...
          err_struct{tn}.term_drift{rn}, err_struct{tn}.term_orient{rn}, ...
          err_struct{tn}.rel_drift{rn}, err_struct{tn}.rel_orient{rn}, ...
          err_struct{tn}.track_loss_rate(rn), err_struct{tn}.track_fit{rn}, ...
          err_struct{tn}.scale_fac(rn)] = ...
          getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          rm_iso_track, seq_duration(sn), seq_start_time(sn), valid_by_duration);
      end
    end
  end
  
  %% plot example tracks
  h=figure(1);
  axis equal
  %
  rn=1;%5;
  tail_length = 60;
  offset = 0;%15;
  for ii=1:size(err_struct{7}.track_fit{rn},2)
    clf
    hold on
    plot3(track_ref(:,2), track_ref(:,3), track_ref(:,4), '-b')
    idx_viz = [max(1,ii-tail_length):ii];
    plot3(err_struct{7}.track_fit{rn}(1, idx_viz), err_struct{7}.track_fit{rn}(2, idx_viz), err_struct{7}.track_fit{rn}(3, idx_viz), '--og')
    plot3(err_struct{2}.track_fit{rn}(1, idx_viz + offset), err_struct{2}.track_fit{rn}(2, idx_viz + offset), err_struct{2}.track_fit{rn}(3, idx_viz + offset), '--*c')
    plot3(err_struct{1}.track_fit{rn}(1, idx_viz + offset), err_struct{1}.track_fit{rn}(2, idx_viz + offset), err_struct{1}.track_fit{rn}(3, idx_viz + offset), '--xr')
    legend({'Ground Truth'; 'Quality+MD';'INL-ORB';'ALL-ORB'})
    view([-35.6 66.8])
    pause(0.001)
    %     export_fig(h, [save_path '/tmp/' seq_idx '-' num2str(ii, '%05d') '.png']);
  end
  
end