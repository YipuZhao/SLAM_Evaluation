clear all
close all

%%
addpath('/home/yipuzhao/SDK/altmany-export_fig');
addpath('/home/yipuzhao/Codes/EuRoC_DatasetTools/matlab/quaternion');

step_length = 0; % 10; %1 %
min_match_num = 10; % 200
seg_length = 1000000; % 150 % 800 %
fps = 20;
max_asso_val = 0.03;
rel_interval = 3;
legend_arr = {'kf-BA'; 'Track'; 'Track+Corr';};

% Test2
seq_list = {
    'MH_01_easy';
    'MH_03_medium';
    'MH_04_difficult';
    'MH_02_easy';
    'V1_01_easy';
    'V2_01_easy';
    };
% % Test3
% seq_list = {
%     'MH_05_difficult';
%     'V1_02_medium';
%     'V2_02_medium';
%     'V2_03_difficult';
%     };
% seq_list = {'V1_03_difficult';};

do_viz = 1;
round_num = 10; % 5; %
% time_delay_BA = 0;

slam_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/EuRoC_POSE_REF_SLAM/Test2']
ref_path = ['/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT']

%%
for time_delay_BA = 1:3
    for sn = 1:length(seq_list)
        seq_idx = seq_list{sn}
        for rn=1:round_num
            
            %% load the key-frame orb slam track
            fid = fopen([slam_path '_Round' num2str(rn) '/' seq_idx '_KeyFrameTrajectory.txt'], 'rt');
            if fid == -1
                continue ;
            end
            % NOTICE the additional column at the end to save lmk number per
            % frame
            track_BA = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f'));
            fclose(fid);
            
            %% load the real-time tracking orb slam track
            fid = fopen([slam_path '_Round' num2str(rn) '/' seq_idx '_AllFrameTrajectory.txt'], 'rt');
            if fid == -1
                continue ;
            end
            % NOTICE the additional column at the end to save lmk number per
            % frame
            track_OL = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
            fclose(fid);
            
            %% load the ground truth track
            fid = fopen([ref_path '/' seq_idx '_tum.txt'], 'rt');
            track_ref = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
            fclose(fid);
            
            %% associate the data to the model quat with timestamp
            asso_BA_2_ref = associate_track(track_BA, track_ref, 1, max_asso_val);
            asso_OL_2_ref = associate_track(track_OL, track_ref, 1, max_asso_val);
            
            %% add the difference between OL & BA track to OL track
            track_OLP = track_OL;
            for kf_idx=1:length(track_BA)-1
                kf_time = track_BA(kf_idx, 1);
                next_kf_time = track_BA(kf_idx + 1, 1);
                %
                af_idx_set = find(track_OL(:, 1) >= kf_time & track_OL(:, 1) < next_kf_time);
                if isempty(af_idx_set) || abs( track_OL(af_idx_set(1), 1) - kf_time ) > 0.1
                    continue ;
                end
                %
                pose_diff = ominus( ...
                    transform44( track_OL(af_idx_set(1), 2:8) ), ...
                    transform44( track_BA(kf_idx, 2:8) ) );
                for fn=1:length(af_idx_set)
                    af_idx = af_idx_set(fn) + time_delay_BA * fps;
                    if af_idx > length(track_OL)
                        break ;
                    end
                    pose_added = transform44( track_OL(af_idx, 2:8) ) * pose_diff;
                    % convert from homo matrix to track pose
                    track_OLP(af_idx, 2:8) = homm2pqform(pose_added);
                end
            end
            
            %% segment the associated track-pairs into several part
            %% and perform evaluation per part
            %% BA
            [err_BA.seq{sn}.abs_drift{rn}, err_BA.seq{sn}.abs_orient{rn}, ...
                err_BA.seq{sn}.rel_drift{rn}, err_BA.seq{sn}.rel_orient{rn}, ...
                err_BA.seq{sn}.track_loss_rate(rn), err_BA.seq{sn}.track_fit{rn}] ...
                = getErrorMetrixPart(track_BA, track_ref, asso_BA_2_ref, ...
                1, min_match_num, step_length, fps, rel_interval, 0);
            
            %% OL
            [err_OL.seq{sn}.abs_drift{rn}, err_OL.seq{sn}.abs_orient{rn}, ...
                err_OL.seq{sn}.rel_drift{rn}, err_OL.seq{sn}.rel_orient{rn}, ...
                err_OL.seq{sn}.track_loss_rate(rn), err_OL.seq{sn}.track_fit{rn}] ...
                = getErrorMetrixPart(track_OL, track_ref, asso_OL_2_ref, ...
                1, min_match_num, step_length, fps, rel_interval, 0);
            
            %%OLP
            [err_OLP.seq{sn}.abs_drift{rn}, err_OLP.seq{sn}.abs_orient{rn}, ...
                err_OLP.seq{sn}.rel_drift{rn}, err_OLP.seq{sn}.rel_orient{rn}, ...
                err_OLP.seq{sn}.track_loss_rate(rn), err_OLP.seq{sn}.track_fit{rn}] ...
                = getErrorMetrixPart(track_OLP, track_ref, asso_OL_2_ref, ...
                1, min_match_num, step_length, fps, rel_interval, 0);
            
            %%
            %                     rn
            if do_viz && rn == round_num
                %                         if sum(isnan(err_orig{tn}.seq{sn}.part{pn}.abs_drift{:})) == 0 && ...
                %                                 sum(isnan(err_gf{tn}.seq{sn}.part{pn}.abs_drift{:})) == 0
                dn_max = -1;
                tlen_max = -1;
                for dn=1:round_num
                    if ~isempty(err_BA.seq{sn}.track_fit{dn}) && ...
                            ~isempty(err_OL.seq{sn}.track_fit{dn}) && ...
                            ~isempty(err_OLP.seq{sn}.track_fit{dn})
                        if length(err_OL.seq{sn}.abs_drift{dn}) > tlen_max
                            dn_max = dn;
                            tlen_max = length(err_OL.seq{sn}.abs_drift{dn});
                        end
                    end
                end
                if dn == -1
                    disp 'no valid track generated!'
                else
                    h=figure('Visible','Off');
                    %                     h=figure();
                    %                     plotDriftSummary(1, sn, tn, track_type, dn_max, round_num, ...
                    %                         err_type_list{en}, track_ref, err_orig, err_gf, max_asso_val, legend_arr);
                    plotErrorPropagation(sn, dn_max, round_num, ...
                        track_ref, err_BA, err_OL, err_OLP, legend_arr);
                    %
                    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
                    mkdir(['./newtest/EuRoC_' seq_idx '/']);
                    export_fig(h, ['./newtest/EuRoC_' seq_idx '/' ...
                        seq_idx '_delay_' num2str(time_delay_BA) ...
                        '_integral_' num2str(rel_interval) '.png'], '-r 200');
                    
                    close(h)
                end
            end
        end
    end
    %
    save(['./newtest/EuRoC_Eval' '_delay_' num2str(time_delay_BA) ...
        '_integral_' num2str(rel_interval) '.mat'], 'err_BA', 'err_OL', 'err_OLP');
end