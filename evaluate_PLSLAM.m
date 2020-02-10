clear all
close all

%%
addpath('/home/yipuzhao/SDK/altmany-export_fig');
% addpath('/home/yipuzhao/Codes/EuRoC_DatasetTools/matlab/quaternion');

% set up parameters for each benchmark
benchMark = 'Gazebo_PL' % 'EuRoC_PL' % 
setParam
legend_arr = {'PL-SLAM'; 'LC-PL-SLAM';}; % {'ORB-SLAM'; 'Bucket-ORB-SLAM';}; % {'ORB-SLAM'; 'GF-ORB-SLAM';}; %

for in = 1:length(rel_interval_list)
  %%
  for sn = 1 % 1:length(seq_list) % [2:4, 7] %
    
    seq_idx = seq_list{sn};
    disp(['Sequence =============== ' seq_idx ' ==============='])
    
    for tn = 1:length(track_type)
      for rn= 1:round_num
        %           disp(['round num' num2str(rn)])
        
        %% Load Trajectory Files
        % load the original orb slam track
        track_orig = loadTrackTUM([orig_slam_path '/Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], 1, 1.0);
        
        % load the pl slam track
        track_pl = loadTrackTUM([pl_slam_path '/Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], 1, 1.0);
        
        % load the ground truth track
        track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0, 1.0);
        
        %% associate the data to the model quat with timestamp
        asso_orig_2_ref = associate_track(track_orig, track_ref, 1, max_asso_val);
        asso_pl_2_ref = associate_track(track_pl, track_ref, 1, max_asso_val);
        
        %% segment the associated track-pairs into several part
        %% and perform evaluation per part
        % Orig
        [err_orig{tn}.seq{sn}.abs_drift{rn}, err_orig{tn}.seq{sn}.abs_orient{rn}, ...
          err_orig{tn}.seq{sn}.term_drift{rn}, err_orig{tn}.seq{sn}.term_orient{rn}, ...
          err_orig{tn}.seq{sn}.rel_drift{rn}, err_orig{tn}.seq{sn}.rel_orient{rn}, ...
          err_orig{tn}.seq{sn}.track_loss_rate(rn), err_orig{tn}.seq{sn}.track_fit{rn}] = ...
          getErrorMetric_align(track_orig, track_ref, asso_orig_2_ref, ...
          1, min_match_num, step_length, fps, rel_interval_list(in), ...
          rm_iso_track, seq_duration(sn));
        
        % PL-SLAM
        [err_pl{tn}.seq{sn}.abs_drift{rn}, err_pl{tn}.seq{sn}.abs_orient{rn}, ...
          err_pl{tn}.seq{sn}.term_drift{rn}, err_pl{tn}.seq{sn}.term_orient{rn}, ...
          err_pl{tn}.seq{sn}.rel_drift{rn}, err_pl{tn}.seq{sn}.rel_orient{rn}, ...
          err_pl{tn}.seq{sn}.track_loss_rate(rn), err_pl{tn}.seq{sn}.track_fit{rn}] = ...
          getErrorMetric_align(track_pl, track_ref, asso_pl_2_ref, ...
          1, min_match_num, step_length, fps, rel_interval_list(in), ...
          rm_iso_track, seq_duration(sn));
        
      end
      
      %% Plot Evaluation Illustration
      if do_viz
        %           if sum(isnan(err_orig{tn}.seq{sn}.part{pn}.abs_drift{:})) == 0 && ...
        %               sum(isnan(err_gf{tn}.seq{sn}.part{pn}.abs_drift{:})) == 0
        dn_max = -1;
        tlen_max = -1;
        for dn=1:round_num
          if (~isempty(err_orig{tn}.seq{sn}.track_fit{dn}) || ...
              ~isempty(err_pl{tn}.seq{sn}.track_fit{dn})) && ...
              (~isempty(err_orig{tn}.seq{sn}.abs_drift{dn}) || ...
              ~isempty(err_pl{tn}.seq{sn}.abs_drift{dn}))
            if length(err_orig{tn}.seq{sn}.abs_drift{dn}) + ...
                length(err_pl{tn}.seq{sn}.abs_drift{dn}) > tlen_max
              dn_max = dn;
              tlen_max = length(err_pl{tn}.seq{sn}.abs_drift{dn});
            end
          end
        end
        % dn_max = 1;
        if dn_max == -1
          disp 'no valid track generated!'
        else
          for en = 1:length(err_type_list)
            %               h=figure('Visible','Off');
            h=figure();
            compFigure_2_Methods(plot3DTrack, sn, tn, track_type, track_loss_ratio, ...
              dn_max, round_num, fps, err_type_list{en}, track_ref, ...
              err_orig, err_pl, max_asso_val, legend_arr);
            set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
            %
            if ~exist([save_path '/' seq_idx '/'], 'dir')
              mkdir([save_path '/' seq_idx '/']);
            end
            detail_save_path = [save_path '/' seq_idx '/' err_type_list{en} '/'];
            if ~exist(detail_save_path, 'dir')
              mkdir(detail_save_path);
            end
            %                         export_fig(gcf, ['./output/Seq' seq_idx '/' gf_slam_prefix '_Seq_' seq_idx '_Part' num2str(pn) '_' err_type '.png'])
            export_fig(h, [detail_save_path seq_idx '_' track_type{tn} ...
              '_PL.png'], '-r 200');
            
            close(h)
          end
        end
      end
    end
  end
  
  %     save([save_path '/' gf_slam_prefix '_Eval_MaxVol.mat'], 'err_orig', 'err_gf');
  
end