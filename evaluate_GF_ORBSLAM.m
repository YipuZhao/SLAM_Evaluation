clear all
close all

%%
addpath('/home/yipuzhao/SDK/altmany-export_fig');
% addpath('/home/yipuzhao/Codes/EuRoC_DatasetTools/matlab/quaternion');

% set up parameters for each benchmark
benchMark = 'EuRoC' % 'TUM' % 'KITTI' %
setParam
legend_arr = {'ORB-SLAM'; 'GF-ORB-SLAM';}; %

for in = 1:length(rel_interval_list)
  for gn = 1:length(gf_slam_list)
    
    gf_slam_prefix = gf_slam_list{gn}
    
    %%
    for sn = [2:4, 7] % 1:length(seq_list)
      
      seq_idx = seq_list{sn};
      disp(['Sequence =============== ' seq_idx ' ==============='])
      
      for tn = 1:length(track_type)
        for rn=1:round_num
          %% Load Trajectory Files
          % load the original orb slam track
          fid = fopen([orig_slam_path '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{tn} 'Trajectory.txt'], 'rt');
          if fid ~= -1
            % NOTICE the additional column at the end to save lmk number per
            % frame
            track_orig = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
            fclose(fid);
            % cut-off the first 100 frames
            %                     track_orig = track_orig(301:end, :);
          else
            track_orig = [];
          end
          
          % load the good feature orb slam track
          fid = fopen([gf_slam_path gf_slam_prefix '_Round' num2str(rn) '/' ...
            seq_idx '_' track_type{tn} 'Trajectory.txt'], 'rt');
          if fid ~= -1
            track_gf = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
            fclose(fid);
            % cut-off the first 100 frames
            %                     track_gf = track_gf(301:end, :);
          else
            track_gf = [];
          end
          
          % load the ground truth track
          fid = fopen([ref_path '/' seq_idx '_tum.txt'], 'rt');
          if fid ~= -1
            track_ref = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
            fclose(fid);
          else
            track_ref = [];
          end
          
          %% associate the data to the model quat with timestamp
          asso_orig_2_ref = associate_track(track_orig, track_ref, 1, max_asso_val);
          asso_gf_2_ref = associate_track(track_gf, track_ref, 1, max_asso_val);
          
          %% segment the associated track-pairs into several part
          %% and perform evaluation per part
          % Orig
          [err_orig{tn}.seq{sn}.abs_drift{rn}, err_orig{tn}.seq{sn}.abs_orient{rn}, ...
            err_orig{tn}.seq{sn}.rel_drift{rn}, err_orig{tn}.seq{sn}.rel_orient{rn}, ...
            err_orig{tn}.seq{sn}.track_loss_rate(rn), err_orig{tn}.seq{sn}.track_fit{rn}] = ...
            getErrorMetric_align(track_orig, track_ref, asso_orig_2_ref, ...
            1, min_match_num, step_length, fps, rel_interval_list(in), ...
            rm_iso_track, seq_duration(sn));
          
          % GF
          [err_gf{tn}.seq{sn}.abs_drift{rn}, err_gf{tn}.seq{sn}.abs_orient{rn}, ...
            err_gf{tn}.seq{sn}.rel_drift{rn}, err_gf{tn}.seq{sn}.rel_orient{rn}, ...
            err_gf{tn}.seq{sn}.track_loss_rate(rn), err_gf{tn}.seq{sn}.track_fit{rn}] = ...
            getErrorMetric_align(track_gf, track_ref, asso_gf_2_ref, ...
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
            if ~isempty(err_orig{tn}.seq{sn}.track_fit{dn}) && ...
                ~isempty(err_gf{tn}.seq{sn}.track_fit{dn}) && ...
                ~isempty(err_orig{tn}.seq{sn}.abs_drift{dn}) && ...
                ~isempty(err_gf{tn}.seq{sn}.abs_drift{dn})
              if length(err_gf{tn}.seq{sn}.abs_drift{dn}) > tlen_max
                dn_max = dn;
                tlen_max = length(err_gf{tn}.seq{sn}.abs_drift{dn});
              end
            end
          end
          if dn_max == -1
            disp 'no valid track generated!'
          else
            for en = 1:length(err_type_list)
              %                 h=figure('Visible','Off');
              h=figure();
              plotDriftSummary(1, sn, tn, track_type, track_loss_ratio, dn_max, round_num, fps, ...
                err_type_list{en}, track_ref, err_orig, err_gf, max_asso_val, legend_arr);
              %
              set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
              mkdir([save_path '/' seq_idx '/']);
              mkdir([save_path '/' seq_idx '/' err_type_list{en} '/']);
              %                         export_fig(gcf, ['./output/Seq' seq_idx '/' gf_slam_prefix '_Seq_' seq_idx '_Part' num2str(pn) '_' err_type '.png'])
              export_fig(h, [save_path '/' seq_idx '/' err_type_list{en} '/' ...
                gf_slam_prefix '_' seq_idx '_' track_type{tn} '_GF.png'], '-r 200');
              
              close(h)
            end
          end
        end
      end
    end
    
    %     save([save_path '/' gf_slam_prefix '_Eval_MaxVol.mat'], 'err_orig', 'err_gf');
    
  end
end