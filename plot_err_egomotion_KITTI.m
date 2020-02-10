clear all
close all

%%
addpath('/home/yipuzhao/SDK/altmany-export_fig');
addpath('/home/yipuzhao/Codes/ObsThreshRegressor');

err_type = 'rms'
step_length = 10; % 0; %
thres_blow_up = 50;
min_match_num = 30 % 200
seg_length = 150 % 300 % 600

% gf_slam_list = {'AllFrame_20percent'; 'AllFrame_40percent'; 'AllFrame_60percent'; 'AllFrame_80percent';}
% gf_slam_list = {'Test4_20percent'; 'Test4_40percent'; 'Test4_60percent';}
gf_slam_list = {'Test2_100percent';}
track_type = {'KeyFrame';};
% track_type = {'AllFrame'; 'KeyFrame';};
seq_list = {'02'; '06'; '07'; '08'; '09';}; % {'06'; '07'; '08'; '09';}; % {'09';}; % 
do_viz = 1;
round_num_list = {10, 10, 10, 10, 10};

% color_list = linspace(1,255,255);

for gn = 1 : length(gf_slam_list)
    
    gf_slam_prefix = gf_slam_list{gn}
    
    orig_slam_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_REF_SLAM/Test4']
%     gf_slam_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM/Thres_Sweep_Test/' gf_slam_prefix]    
    gf_slam_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM/' gf_slam_prefix]
    %     gf_slam_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM/half_frame_rate /' gf_slam_prefix]
    ref_path = ['/home/yipuzhao/ros_workspace/package_dir/ORB_Data/KITTI_POSE_GT']
    
    %%
    for tn = 1:length(track_type)
        
        figure;
        hold on;
        for sn = 1:length(seq_list)
            seq_idx = seq_list{sn};
            
            for rn=1:round_num_list{sn}
                
                %% load the original orb slam track
                fid = fopen([orig_slam_path '_Round' num2str(rn) '/Seq' seq_idx '_10_' track_type{tn} 'Trajectory.txt'], 'rt');
                if fid == -1
                    continue ;
                end
                % NOTICE the additional column at the end to save lmk number per
                % frame
                track_orig = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f', 'HeaderLines', 1));
                fclose(fid);
                
                %% load the good feature orb slam track
                fid = fopen([gf_slam_path '_Round' num2str(rn) '/Seq' seq_idx '_10_' track_type{tn} 'Trajectory.txt'], 'rt');
                if fid == -1
                    continue ;
                end
                track_gf = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
                fclose(fid);
                
                %% load the ground truth track
                fid = fopen([ref_path '/' seq_idx '_tum.txt'], 'rt');
                track_ref = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
                fclose(fid);
                
                %% associate the data to the model quat with timestamp
                asso_orig_2_ref = associate_track(track_orig, track_ref, 1, 0.2);
                asso_gf_2_ref = associate_track(track_gf, track_ref, 1, 0.2);
                
                %% segment the associated track-pairs into several part
                %% and perform evaluation per part
                fr_st = 1;
                pn = 1;
                while fr_st < size(track_ref, 1)
                    
                    fr_st
                    % fr_st : fr_st + seg_length
                    valid_viz = true;
                    fr_ed = min(fr_st + seg_length, size(track_ref, 1));
                    
                    %% GF
                    [err_gf{sn}.part{pn}(rn), track_fit_gf] = ...
                        getErrorMetrixPart(track_gf, track_ref, fr_st, fr_ed, ...
                        asso_gf_2_ref, 1, min_match_num, step_length, err_type);
                    if isnan(err_gf{sn}.part{pn}(rn))
                        valid_viz = false;
                    end
                    
                    %% Orig
                    [err_orig{sn}.part{pn}(rn), track_fit_orig] = ...
                        getErrorMetrixPart(track_orig, track_ref, fr_st, fr_ed, ...
                        asso_orig_2_ref, 1, min_match_num, step_length, err_type);
                    if isnan(err_orig{sn}.part{pn}(rn))
                        valid_viz = false;
                    end
                    
                    %%
                    %                     rn
                    if do_viz && valid_viz && rn == round_num_list{sn}
                        
                        %                         figure;
                        %                         hold on
                        %                         plot(track_ref(fr_st:fr_ed, 2), track_ref(fr_st:fr_ed, 4), '-o')
                        %                         plot(track_fit_orig(1, :), track_fit_orig(3, :), '-x')
                        %                         plot(track_fit_gf(1, :), track_fit_gf(3, :), '-*')
                        %                         axis equal
                        
                        %% compare the average error metric over all rounds between org-slam and gf-slam
                        mean_err_gf = mean(err_gf{sn}.part{pn});
                        mean_err_orig = mean(err_orig{sn}.part{pn});
%                         mean_err_gf = median(err_gf{sn}.part{pn});
%                         mean_err_orig = median(err_orig{sn}.part{pn});
                        
                        if mean_err_gf < thres_blow_up && mean_err_orig < thres_blow_up
                            %% get the average ego-motion of the part
                            % quantize ego-motion pattern into transition-only and rotation-only variables
                            [motion_t, motion_r] = quantizeMotion(track_ref(fr_st:fr_ed, :));
                            
                            %
                            if mean_err_gf-mean_err_orig >= 0
                                scatter(motion_t, motion_r, 200*abs(mean_err_gf-mean_err_orig), 'r');
                            else
                                scatter(motion_t, motion_r, 200*abs(mean_err_gf-mean_err_orig), 'g');
                            end
                        end
                    end
                    
                    pn = pn + 1;
                    fr_st = fr_ed + 1 - int16(seg_length / 2);
                    if fr_ed == size(track_ref, 1)
                        break ;
                    end
                    
                end
            end
        end
        
        %     save(['./output/' gf_slam_prefix '_KeyFrameEval.mat'], 'err_rms_orig', 'err_rms_gf');
        xlim([0 18])
        ylim([0 18])
        xlabel('translation speed (m/sec)');
        ylabel('rotation speed (deg/sec)')
        title([gf_slam_prefix ' ' track_type{tn} ' ' err_type])
        set(gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
        export_fig(gcf, ['./output/' err_type '/' gf_slam_prefix '_' track_type{tn} '_' err_type '.png'])
        
        close all
    end
end