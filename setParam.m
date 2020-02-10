%% set up default param shared by each benchmark

% param of trajectory alignment
step_length = int32(10); % 0; %
min_match_num = int32(200); % 10
seg_length = 1000000; % 150 % 800 %
asso_idx = int32(1);
max_asso_val = 0.02; % 0.03; % 0.01; %
rel_interval_list = [3]; % [1, 3, 5, 10];
rm_iso_track = false;
valid_by_duration = false;

% simply ignore any config with failure runs
track_fail_thres = 1;

% param of evaluation
metric_type = {
  'TrackLossRate';
  'RMSE';
  'ScaleError';
  %   'abs\_orient';
  'RPE3';
  'ROE3';
  };

% param of plotting
lower_prc = 25;
upper_prc = 75;
% lower_prc = 10;
% upper_prc = 90;
show_text = false; % true; %
show_figure = true; % false; %
font_size = 12;
mark_size = 5;
figure_size = [1 1 871 356];

% misc
step_def = 8000; % 800; % 600;
track_type = {'AllFrame';}; % {'AllFrame'; 'KeyFrame';}; %
err_type_list = {'rms';}; % {'rms'; 'max'; 'all';}; %
do_viz = 1;
round_num = 10; %3; % 5; % 20; %

ln_head = 1;
maxNormTrans = 999; % 5.0; % 1.0;
benchmark_type = 'TUM';
sensor_type = 'mono';

baseline_num = 3;
baseline_orb = 1;

%% set up default param for each specific benchmark
switch benchMark
  
  %% IROS 2018 related
  
  case 'EuRoC_IROS18_Accuracy'
    %
    plot3DTrack = 1;
    fps = 20;
    %     gf_slam_list = {
    %       'ObsNumber_80';
    %       'ObsNumber_100';
    %       'ObsNumber_120';
    %       'ObsNumber_140';
    %       'ObsNumber_160';
    %       'ObsNumber_180';
    %       'ObsNumber_200';
    %       };
    gf_slam_list = {
      %   'ObsNumber_60';
      'ObsNumber_100';
      %   'ObsNumber_140';
      %   'ObsNumber_180';
      };
    
    %
    seq_list = {
      'MH_01_easy';
      'MH_02_easy';
      'MH_03_medium';
      'MH_04_difficult';
      'MH_05_difficult';
      'V1_01_easy';
      %       'V1_02_medium';
      %       'V1_03_difficult';
      'V2_01_easy';
      'V2_02_medium';
      %       'V2_03_difficult';
      };
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      30;
      30;
      15;
      15;
      15;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    %     step_length = int32(0);
    track_loss_ratio = [0.5 0.98];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Ref_all/Refer';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Ref_inlierOnly/Refer';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Quality/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Bucket/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Obs_minSV/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Efficiency/Obs_maxVol/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_topSV_U_shape/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_proj/';
      %             '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_lazier/';
      %             '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_proj_lazier/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Comb_Obs_minSV/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Efficiency/Comb_Obs_maxVol/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Comb_Cond_approx/';
      };
    
    %     legend_arr = {
    %       'ORB'; 'ORB-INL'; 'Quality'; 'Bucket';
    %       'Obs-GF'; %'Obs-MV';
    %       'Cond-MV';
    %       %       'Cond-MV-redo';
    %       %       'Cond-MV-v2';
    %       %       'Cond-MV-proj';
    %       %             'Cond-MV-lazier';
    %       %             'Cond-MV-proj-lazier';
    %       %       'Cond-MV-v2';
    %       %       'Cond-MV-v2-np';
    %       'Comb-Obs-GF'; %'Comb-Obs-MV';
    %       'Comb-Cond-MV';
    %       };
    legend_arr = {
      'ALL-ORB'; 'INL-ORB'; 'Quality'; 'Bucket';
      'Obs'; %'Obs-MV';
      'MD';
      %       'Cond-MV-redo';
      %       'Cond-MV-v2';
      %       'Cond-MV-proj';
      %             'Cond-MV-lazier';
      %             'Cond-MV-proj-lazier';
      %       'Cond-MV-v2';
      %       'Cond-MV-v2-np';
      %       'Quality+Obs'; %'Comb-Obs-MV';
      'Quality+MD';
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT';
    save_path           = './output/IROS18/';
    %
    
  case 'EuRoC_IROS18_TimeCost'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      %       'ObsNumber_80';
      'ObsNumber_100';
      %       'ObsNumber_120';
      %       'ObsNumber_140';
      %       'ObsNumber_160';
      %       'ObsNumber_180';
      %       'ObsNumber_200';
      %       'ObsNumber_220';
      %       'ObsNumber_260';
      };
    %
    seq_list = {
      'MH_01_easy';
      'MH_02_easy';
      'MH_03_medium';
      'MH_04_difficult';
      'MH_05_difficult';
      'V1_01_easy';
      %       'V1_02_medium';
      %       'V1_03_difficult';
      'V2_01_easy';
      'V2_02_medium';
      %       'V2_03_difficult';
      };
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      %       84;
      %       105;
      112;
      115;
      %       115;
      ];
    seq_start_time = [
      30;
      30;
      15;
      15;
      15;
      5;
      %       5;
      %       5;
      5;
      5;
      %       5;
      ];
    
    round_num = 1;
    
    step_length = int32(0);
    track_loss_ratio = [0.5 0.98];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/TimeCost/Ref_All/Refer';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/TimeCost/Ref_inlierOnly/Refer';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Quality/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Bucket/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Obs_minSV/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Efficiency/Obs_maxVol/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_proj/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_lazier/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_proj_lazier/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Comb_Obs_minSV/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Efficiency/Comb_Obs_maxVol/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Comb_Cond_approx/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/TimeCost/Comb_approx_timeCost/';
      };
    
    legend_arr = {
      'ORB'; 'ORB-INL'; 'Quality'; 'Bucket';
      'Obs-GF'; %'Obs-MV';
      'Cond-MV';
      %       'Cond-MV-v2';
      %       'Cond-MV-proj';
      'Comb-Obs-GF'; %'Comb-Obs-MV';
      'Comb-Cond-MV';
      %       'Comb-Cond-MV-Time';
      };
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT';
    save_path           = './output/ICRA18/';
    %
    
  case 'EuRoC_IROS18_Ushape'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_120';
      'ObsNumber_140';
      'ObsNumber_160';
      'ObsNumber_180';
      'ObsNumber_200';
      %       'ObsNumber_220';
      %       'ObsNumber_260';
      };
    %
    seq_list = {
      'MH_05_difficult';
      };
    seq_duration = [
      111;
      ];
    seq_start_time = [
      15;
      ];
    
    lmk_number_list = [60 100 140 180];
    
    step_length = int32(0);
    track_loss_ratio = [0.5 0.98];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Ref_inlierOnly/Refer';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_approx_U_shape/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/EuRoC/Lmk_2000/Cond_topSV_U_shape/';
      };
    
    legend_arr = {
      'ORB-INL';
      'Cond-MV';
      };
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT';
    save_path           = './output/IROS18/';
    %
    
    
    
  case 'KITTI_IROS18_TradeOff'
    %
    % Note that the param for traj alignment in KITTI are different from
    % the other 2 benchmarks, mostly due to the significant scaling drift
    % in ORB-SLAM results.  Here we align the track according to starting
    % point, rather than over the entire track.
    %
    plot3DTrack = 0;
    %     step_length = 16; % 8; % 0; % 10
    %     min_match_num = 30; % 200
    max_asso_val = 0.05;
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    %
    fps = 10;
    gf_slam_list = {
      'ObsNumber_40';
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_120';
      'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_250';
      }
    baseline_slam_list = {
      %       'ObsNumber_600';
      %       'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1200';
      'ObsNumber_1500';
      'ObsNumber_2000';
      'ObsNumber_2500';
      'ObsNumber_3000';
      }
    
    %
    seq_list = {
      '02';
      '07';
      '08';
      %       '09';
      };
    seq_duration = [
      431.42;
      101.86;
      422.94;
      %       157.73;
      ];
    
    
    lmk_number_list = [40 60 80 120 160];
    %     lmk_number_list = [40 60 80 120 160 200 250];
    baseline_number_list = [1000 1200 1500 2000 2500 3000];
    baseline_taken_index = [3 ]; % [1 2 3 4 ];
    
    maxNormTrans = 1000.0;
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    ln_head = 5*fps;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/KITTI/ORB_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/KITTI/IROS18_Jac/Lmk_1500/Random_baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/KITTI/IROS18_Jac/Lmk_2000/Random_baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/KITTI/IROS18_Jac/Lmk_1500/Quality_baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_IROS18/KITTI/IROS18_Jac/Lmk_2000/Quality_baseline/';
      %
      '/mnt/DATA/tmp/KITTI/IROS18_Jac/Lmk_1500/MaxVol_lazier_pool1.25_auto/';
      %       '/mnt/DATA/tmp/KITTI/IROS18_Jac/Lmk_2000/MaxVol_lazier_pool1.25_auto/';
      %       '/mnt/DATA/tmp/KITTI/IROS18_Jac/Lmk_1500/MaxVol_lazier_ransac_auto/';
      '/mnt/DATA/tmp/KITTI/IROS18_Jac/Lmk_1500/MaxVol_lazier_pool1.25_auto_bound/';
      '/mnt/DATA/tmp/KITTI/IROS18_Jac/Lmk_1500/MaxVol_lazier_noPool_auto/';
      };
    
    legend_arr = {
      'ORB-Baseline';
      'Random-Baseline';
      'Quality-Baseline';
      'MaxVol-lazier';
      'MaxVol-lazier-boundMap';
      'MaxVol-lazier-noPool';
      };
    
    marker_styl = {
      'b--o';
      'g--+';
      'r--x';
      'c:s';
      'm:d';
      'k:^';
      'g:o';
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/KITTI_POSE_GT'
    save_path           = './output/IROS18/KITTI/'
    %
    
    
    
    
    %% TRO 2019 related
    
  case 'EuRoC_TRO19_Mono'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      %       'ObsNumber_240';
      }
    baseline_slam_list = {
      'ObsNumber_25';
      'ObsNumber_100';
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60, 80, 100, 130, 160, 200]; % [60 80 100 130 160 200 240]; %
    baseline_number_list = [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [8]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    %     ln_head = 5*fps;
    %     seq_start_time = [
    %       30;
    %       30;
    %       15;
    %       15;
    %       15;
    %       5;
    %       %       5;
    %       %       5;
    %       5;
    %       5;
    %       %       5;
    %       ];
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 3; % 5;
    
    slam_path_list  = {
      %       '/mnt/DATA/tmp/EuRoC/Lmk_1500/ORB_Debug/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/ORBv1_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/EuRoC/ORBv2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/DSO_Mono_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/EuRoC/Inlier_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/vins_Mono_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/rovio_Mono_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_600/ORBv1_info_measErr_incSample/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv1_info_measErr_incSample/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_600/ORBv1_random/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv1_random/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_600/ORBv1_longlife/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv1_longlife/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      %       'vins';
      %       'vins';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'SVO';
      'DSO';
      %       'VIMono';
      %       'ROVIO';
      'GF';
      %       'GF-fullPrior';
      %       'GF-noPrior';
      'Rnd';
      'Long';
      };
    
    %     marker_styl = {
    %       '--bo';
    %       '--m+';
    %       '--c*';
    %       '--rd';
    %       '--gd';
    %       %
    %       '--ks';
    %       %       '--ms';
    %       %       '--cs';
    %       '--rx';
    %       '--gx';
    %       };
    marker_styl = {
      '--o';
      '--+';
      '--*';
      %       '--d';
      %       '--d';
      ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [1 0 1];
      [0 1 1];
      %       [1 0.84 0];
      %       [0.49 0.18 0.56];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    %     table_index = [11 11 11 3 1 3 3 3];
    %     table_index = [8 8 8 3 1 3 3 3];
    %     table_index = [8 8 8 3 3 3];
    table_index = [8 8 8 1 1 1];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/EuRoC/'
    %
    
  case 'EuRoC_TRO19_OnDevice_Euclid'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60, 80, 100, 130]; % [60, 80, 100, 130, 160, 200]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    baseline_number_list = [150 200 300 400 600 800 1000 1500 2000]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [4]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    baseline_num = 3;
    baseline_orb = 1;
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    track_fail_thres = 2;
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/ORBv1_Baseline_lvl3_fac1.6/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/ORBv1_Baseline_lvl3_fac2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/DSO_Mono_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_400/ORBv1_info_measErr_incSample_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_600/ORBv1_info_measErr_incSample_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_400/ORBv1_info_measErr_noPrior_25ms/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_400/ORBv1_info_measErr_fac2_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_600/ORBv1_info_measErr_noPrior_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_800/ORBv1_info_measErr_incSample/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_600/ORBv1_random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/Lmk_600/ORBv1_longlife/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'ORB-l3';
      'SVO';
      'DSO';
      'GF';
      %       'GF-ORB-l3';
      %       'GF-noPrior-ORB';
      %       'Random';
      %       'Longlive';
      };
    
    marker_styl = {
      '--o';
      %       '--o';
      '--+';
      '--*';
      ':s';
      %       ':s';
      %
      'd';
      'd';
      'd';
      };
    marker_color = {
      [0 0 1];
      %       [1 1 0];
      [1 0 1];
      [0 1 1];
      [0 0 0];
      %       [0 0.5 0];
      %
      [1 0.3 0.78];
      [0.85 0.33 0.1];
      [1 0.84 0];
      };
    
    %     table_index = [4 4 4 1]; % [5 5 5 3]; %
    table_index = [4 4 4 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/Euclid/'
    %
    
    %     % additional results grabbed from Jeff's VINS benchmarking paper
    %     method_VINS = {
    %       'svo-msf';
    %       'msckf';
    % %       'okvis';
    %       'vins-mono';
    % %       'svo-gtsam';
    %       };
    
    RMSE_VINS = [
      0.29 0.48 0.20 ;
      0.31 0.40 0.18 ;
      0.66 0.45 0.17 ;
      2.02 0.67 0.12 ;
      0.87 0.48 0.35 ;
      0.36 0.25 0.05 ;
      0.78 0.22 0.12 ;
      nan 0.63 0.10 ;
      0.33 0.17 0.08 ;
      0.59 0.18 0.08 ;
      nan 1.86 0.17 ;
      ];
    
    time_VINS = [
      40.31129245304476, 53.006312863744085, 152.39906024738463;
      44.71015399010792, 51.76893363124561, 143.90504992948289;
      38.61439816222534, 51.71760303479471, 180.090119249208;
      41.5672627406639, 49.22274453141832, 168.85724263600525;
      38.45534664913262, 50.36748714239482, 153.8327836374322;
      31.11650502786033, 51.97679441316372, 188.55670100164204;
      32.03208114444445, 46.512963840722506, 170.89565506382976;
      nan, 40.48963765896981, 115.2418642188082;
      34.53929937227723, 50.79091160689655, 167.15673794011977;
      36.57105348473636, 48.00802083240224, 156.80929511680142;
      nan, 37.98306740369231, 109.9514429991251;
      ];
    
    %     RMSE_VINS = [
    %       0.29 0.48 0.20 0.20 0.12;
    %       0.31 0.40 0.22 0.18 0.05;
    %       0.66 0.45 0.37 0.17 0.10;
    %       2.02 0.67 0.44 0.12 0.24;
    %       0.87 0.48 nan 0.35 0.13;
    %       0.36 0.25 0.13 0.05 0.08;
    %       0.78 0.22 0.22 0.12 0.10;
    %       nan 0.63 0.30 0.10 nan;
    %       0.33 0.17 0.18 0.08 0.13;
    %       0.59 0.18 0.30 0.08 nan;
    %       nan 1.86 0.38 0.17 nan;
    %       ];
    %
    %     time_VINS = [
    %       40.31129245304476, 53.006312863744085, 202.17195872841793, 152.39906024738463, 252.11295676130652;
    %       44.71015399010792, 51.76893363124561, 203.35690308845096, 143.90504992948289, 103.26798785139319;
    %       38.61439816222534, 51.71760303479471, 151.9343041656415, 180.090119249208, 449.28615950132394;
    %       41.5672627406639, 49.22274453141832, 127.53531034704051, 168.85724263600525, 268.43018996774197;
    %       38.45534664913262, 50.36748714239482, nan, 153.8327836374322, 119.50113575850891;
    %       31.11650502786033, 51.97679441316372, 88.75017311416342, 188.55670100164204, 215.76427212567913;
    %       32.03208114444445, 46.512963840722506, 69.8214942646877, 170.89565506382976, 1534.0587507418547;
    %       nan, 40.48963765896981, 73.76871886167577, 115.2418642188082, nan;
    %       34.53929937227723, 50.79091160689655, 91.99335132071168, 167.15673794011977, 180.7722507193732;
    %       36.57105348473636, 48.00802083240224, 82.44410717061403, 156.80929511680142, nan;
    %       nan, 37.98306740369231, 75.63585353057852, 109.9514429991251, nan;
    %       ];
    
  case 'EuRoC_TRO19_OnDevice_X200CA'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60, 80, 100, 130, 160, 200]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    baseline_number_list = [150 200 300 400 600 800 1000 1500 2000]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [4]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    baseline_num = 3;
    baseline_orb = 1;
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    track_fail_thres = 2;
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/ORBv1_Baseline_lvl8/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/ORBv1_Baseline_lvl3_fac1.6/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/ORBv2_Baseline_lvl3_fac2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/SVO2_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/DSO_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_400/ORBv1_info_measErr_incSample_25ms/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_400/ORBv1_info_measErr_fac2_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_600/ORBv1_info_measErr_incSample_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_400/ORBv1_info_measErr_noPrior_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_600/ORBv1_info_measErr_noPrior_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_800/ORBv1_info_measErr_incSample/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_600/ORBv1_random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/X200CA/Lmk_600/ORBv1_longlife/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      %       'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'ORB-l3';
      'SVO';
      'DSO';
      'GF';
      %       'GF-ORB-l3';
      %       'GF-noPrior-ORB';
      %       'Random';
      %       'Longlive';
      };
    
    marker_styl = {
      '--o';
      %       '--o';
      '--+';
      '--*';
      ':s';
      %       ':s';
      };
    marker_color = {
      [0 0 1];
      %       [1 1 0];
      [1 0 1];
      [0 1 1];
      [0 0 0];
      %       [0 0.8 0];
      };
    
    %     table_index = [4 4 4 1];
    table_index = [4 4 4 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/X200CA/'
    %
    
  case 'EuRoC_TRO19_OnDevice_Jetson'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_100';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60, 80, 100, 150, 200]; %
    baseline_number_list = [100 200 300 400 600 800 1000 1500 2000];
    baseline_taken_index = [4]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    track_fail_thres = 2;
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 3; % 2;
    baseline_orb = 1;
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/ORBv1_Baseline_lvl3_fac1.6/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/ORBv1_Baseline_lvl3_fac2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/DSO_Mono_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_400/ORBv1_info_measErr_incSample_25ms/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_400/ORBv1_info_measErr_fac2_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_600/ORBv1_info_measErr_incSample_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_400/ORBv1_info_measErr_noPrior_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_600/ORBv1_info_measErr_noPrior_25ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_800/ORBv1_info_measErr_incSample/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_800/ORBv1_random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Jetson/Lmk_800/ORBv1_longlife/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo'
      %       'vo'
      %       'vo';
      %       'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'ORB-l3';
      'SVO';
      'DSO';
      'GF';
      %       'GF-ORB-l3';
      %       'GF-noPrior-ORB';
      %       'Random';
      %       'Longlive';
      };
    
    marker_styl = {
      '--o';
      %       '--o';
      '--+';
      '--*';
      ':s';
      %       ':s';
      };
    marker_color = {
      [0 0 1];
      %       [1 1 0];
      [1 0 1];
      [0 1 1];
      [0 0 0];
      %       [0 0.5 0];
      };
    
    %     table_index = [4 4 4 1];
    table_index = [4 4 4 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/Jetson/'
    %
    
  case 'EuRoC_TRO19_OnDevice_Odroid'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_150';
      'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_400';
      'ObsNumber_500';
      'ObsNumber_600';
      'ObsNumber_700';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60, 80, 100, 150, 200]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    %     baseline_number_list = [300 400 600 800 1000 1500 2000];
    baseline_number_list = [400 500 600 700 800 1000 1500 2000];
    baseline_taken_index = [3]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Odroid/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Odroid/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Odroid/DSO_Mono_Baseline/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'SVO';
      'DSO';
      %       'GF';
      %       'Random';
      %       'Longlive';
      };
    
    marker_styl = {
      'b--o';
      'm--o';
      'c--o';
      %       'k--s';
      %       'r:*';
      %       'g:*';
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/Odroid/'
    %
    
  case 'EuRoC_TRO19_Stereo'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      %       'ObsNumber_60';
      'ObsNumber_80';
      %       'ObsNumber_100';
      %       'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_240';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      'ObsNumber_300';
      'ObsNumber_360';
      %       'ObsNumber_420';
      %       'ObsNumber_480';
      }
    baseline_slam_list = {
      'ObsNumber_80';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [80, 100, 130, 160, 200, 240, 300, 360]; % [60, 80, 100, 130, 160, 200, 240]; % [60, 80, 100, 150, 200];
    baseline_number_list = [80 200 300 400 600 800 1000 1500 2000]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [6]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    sensor_type = 'stereo';
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    %     ln_head = 5*fps;
    %     seq_start_time = [
    %       30;
    %       30;
    %       15;
    %       15;
    %       15;
    %       5;
    %       %       5;
    %       %       5;
    %       5;
    %       5;
    %       %       5;
    %       ];
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 5;
    baseline_orb = 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/vanilla_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/delayed_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/SVO2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/okvis_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/OKVIS_Stereo_Baseline_redo/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/msckf_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/msckf_Stereo_Baseline_v2/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_incSample_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_info_dispErr_v4/';
      %       '/mnt/DATA/tmp/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_v5/';
      %       '/mnt/DATA/tmp/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_v6/';
      %             '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_info_dispErr_robust_v4/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Random_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Random_v4/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Longlife_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Longlife_v4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_v10/';
      %             '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_fin/'
      % '/mnt/DATA/tmp/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_v10_1/';
      % '/mnt/DATA/tmp/EuRoC/Lmk_800/ORBv2_Stereo_info_dispErr_v11/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Random_v10/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/Lmk_800/ORBv2_Stereo_Longlive_v10/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vins';
      'vins';
      %       'vo';
      'vo';
      %       'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'Lz-ORB';
      'SVO';
      'OKVIS';
      'MSCKF';
      'GF';
      %       'GF-prior';
      %       'GF-fix';
      %       'GF-st-15ms';
      %       'GF-st';
      %       'GF-st-more';
      %       'GF-15ms';
      %       'GF-more-15ms';
      'Rnd';
      'Long';
      };
    
    %     marker_styl = {
    %       '--bo';
    %       '-.b*';
    %       '--m+';
    %       '--rd';
    %       '--gd';
    %       '--ks';
    %       %       'm--s';
    %       %             'c--s';
    %       %             'r--s';
    %       '--rx';
    %       '--gx';
    % %       ':r*';
    % %       ':g*';
    %       };
    marker_styl = {
      '--o';
      '-.*';
      '--+';
      '--d';
      '--d';
      ':s';
      %             ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [0 0.2 0.8];
      [1 0 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 0 0];
      %             [0 0.8 0.5];
      [1 0 0];
      [0 1 0];
      };
    
    %     % param of evaluation
    %     metric_type = {
    %       'TrackLossRate';
    %         'RMSE';
    %       %   'ScaleError';
    %       %   'abs\_orient';
    % %       'RPE3';
    % %       'ROE3';
    %       };
    
    table_index = [6 6 6 4 1 4 4 4]; % [6 6 6 4 1 4 4 4 4]; % [6 6 6 4 1 3 3 3]; %
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/TRO19/EuRoC/'
    %
    
  case 'TUM_VI_TRO19_Stereo'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      %       'ObsNumber_150';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      %       'ObsNumber_280';
      %       'ObsNumber_320';
      %       'ObsNumber_360';
      %       'ObsNumber_400';
      %       'ObsNumber_440';
      }
    baseline_slam_list = {
      'ObsNumber_80';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      'room1_512_16';
      'room2_512_16';
      'room3_512_16';
      'room4_512_16';
      'room5_512_16';
      'room6_512_16';
      };
    seq_duration = [
      141.0;
      144.1;
      141.0;
      111.4;
      142.3;
      131.8;
      ];
    
    lmk_number_list = [60, 80, 100, 130, 160, 200, 240]; %
    % [60, 80, 100, 130, 160, 200, 240, 280, 320, 360, 400, 440]; % [100, 150, 200, 250, 300]; % [1500];
    baseline_number_list = [80 200 300 400 600 800 1000 1500 2000]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [5]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    sensor_type = 'stereo';
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 5;
    baseline_orb = 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/vanilla_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/delayed_ORBv2_Stereo_Baseline/';
      %             '/mnt/DATA/tmp/TUM_VI/ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/SVO2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/OKVIS_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/OKVIS_Stereo_Baseline_old/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/msckf_Stereo_Baseline_v2/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_incSample_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_lowSample_15ms_v3/';
      % '/mnt/DATA/tmp/TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_15ms_v2/';%
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_15ms_fullPrior/';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_15ms_noPrior/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_random_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_random_15ms_v3/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_longlive_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/Lmk_600/ORBv2_Stereo_longlive_15ms_v3/'
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop//TUM_VI/Lmk_600/ORBv2_Stereo_info_dispErr_v10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop//TUM_VI/Lmk_600/ORBv2_Stereo_random_v10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop//TUM_VI/Lmk_600/ORBv2_Stereo_longlive_v10/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vins';
      'vins';
      'vo';
      'vo';%
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'Lz-ORB';
      'SVO';
      'OKVIS';
      'MSCKF';
      'GF';
      % 'GF-fullPrior';
      % 'GF-noPrior';
      %       'GF-15ms';
      %       'GF-more-15ms';
      'Rnd';
      'Long';
      };
    
    %     marker_styl = {
    %       '--bo';
    %       '-.b+';
    %       '--mo';
    %       '--rd';
    %       '--cd';
    %       '--ks';
    %       %       'c--s';
    %       %       'm--s';
    %       ':r*';
    %       ':g*';
    %       };
    marker_styl = {
      '--o';
      '-.*';
      '--+';
      '--d';
      '--d';
      ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [0 0.2 0.8];
      [1 0 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    %     table_index = [5 5 5 4 1 6 6 6];
    table_index = [5 5 5 4 1 5 5 5];
    %     table_index = [5 5 5 4 1 4 4 4];
    %     table_index = [5 5 5 4 1 2 2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/TUM_VI_POSE_GT'
    save_path           = './output/TRO19/TUM_VI/'
    %
    
    
    
  case 'KITTI_TRO19_Stereo'
    %
    plot3DTrack = 0;
    fps = 10;
    gf_slam_list = {
      %       'ObsNumber_60';
      %       'ObsNumber_80';
      %       'ObsNumber_100';
      %       'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_240';
      %       'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      'ObsNumber_300';
      %       'ObsNumber_360';
      %       'ObsNumber_420';
      %       'ObsNumber_480';
      }
    baseline_slam_list = {
      %       'ObsNumber_80';
      %       'ObsNumber_200';
      %       'ObsNumber_300';
      %       'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      'Seq00_stereo';
      'Seq01_stereo';
      'Seq02_stereo';
      'Seq03_stereo';
      'Seq04_stereo';
      'Seq05_stereo';
      'Seq06_stereo';
      'Seq07_stereo';
      'Seq08_stereo';
      'Seq09_stereo';
      'Seq10_stereo';
      };
    seq_duration = [
      450;
      114;
      483;
      82.7;
      28.1;
      287.5;
      114.3;
      114.3;
      423;
      165;
      124.5;
      ];
    
    lmk_number_list = [130, 160, 200, 240, 300]; % [60, 80, 100, 130, 160, 200, 240]; % [60, 80, 100, 150, 200];
    baseline_number_list = [600 800 1000 1500 2000];
    baseline_taken_index = [4];
    
    sensor_type = 'stereo';
    rel_interval_list = [8];  % approx. 100m (8s * 13m/s ~ 100m)
    benchmark_type = 'KITTI';
    valid_by_duration = true;
    maxNormTrans = inf;
    
    step_length = int32(0); %
    %     step_length = int32(-1);
    
    track_loss_ratio = [0.1 0.98]; % [0.5 0.98];
    
    seq_start_time = [
      1;
      1;
      1;
      1;
      1;
      1;
      1;
      1;
      1;
      1;
      1;
      ];
    
    baseline_num = 4;
    baseline_orb = 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/vanilla_ORBv2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/vanilla_ORBv2_Stereo_Baseline_v2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/delayed_ORBv2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/delayed_ORBv2_Stereo_Baseline_v2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/SVO2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/DSO_Stereo_Baseline/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1500/ORBv2_Stereo_GF/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1000/ORBv2_Stereo_GF_v2/';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1000/ORBv2_GF_Stereo_Prior/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1500/ORBv2_Stereo_Random/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1500/ORBv2_Stereo_Longlive/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1000/ORBv2_Stereo_GF/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1000/ORBv2_Stereo_Random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1000/ORBv2_Stereo_Long/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vins';
      %       'vins';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'Lz-ORB';
      'SVO';
      'DSO';
      %       'OKVIS';
      %       'MSCKF';
      'GF';
      'Rnd';
      'Long';
      };
    
    marker_styl = {
      '--o';
      '-.*';
      '--+';
      '--*';
      %       '--d';
      %       '--d';
      ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [0 0.2 0.8];
      [1 0 1];
      [0 1 1];
      %       [1 0.84 0];
      %       [0.49 0.18 0.56];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    % param of evaluation
    metric_type = {
      'TrackLossRate';
      'RMSE';
      'ScaleError';
      %   'abs\_orient';
      'RPE3';
      'ROE3';
      };
    
    %     table_index = [4 4 4 4 3 3 3]; % [7 7 7 7 2 2 2]; % [6 6 5 5 3 3 3];
    table_index = [4 4 4 4 2 2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/KITTI_POSE_GT'
    save_path           = './output/TRO19/KITTI/'
    %
    
    
    
  case 'RobotCar_TRO19_Stereo'
    %
    plot3DTrack = 1;
    fps = 5;
    gf_slam_list = {
      %       'ObsNumber_60';
      'ObsNumber_80';
      %       'ObsNumber_100';
      %       'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_240';
      %       'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      'ObsNumber_300';
      'ObsNumber_360';
      %       'ObsNumber_420';
      %       'ObsNumber_480';
      }
    baseline_slam_list = {
      'ObsNumber_80';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      '2014-07-14-15-16-36';
      '2014-11-18-13-20-12';
      %       '2014-12-05-11-09-10';
      };
    seq_duration = [
      967;
      1200;
      %       2100;
      ];
    
    lmk_number_list = [80, 100, 130, 160, 200, 240, 300, 360]; % [60, 80, 100, 130, 160, 200, 240]; % [60, 80, 100, 150, 200];
    baseline_number_list = [80 200 300 400 600 800 1000 1500 2000]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [7];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    %     round_num = 5;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    seq_start_time = [
      1;
      1;
      1;
      ];
    
    baseline_num = 5;
    baseline_orb = 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/vanilla_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/delayed_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/SVO2_Stereo_Baseline/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/OKVIS_Stereo_Baseline_redo/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/msckf_Stereo_Baseline_v2/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/lmk1000/ORBv2_Stereo_GF/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/lmk1000/ORBv2_Stereo_Random_v10/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/RobotCar/lmk1000/ORBv2_Stereo_Longlive_v10/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vins';
      'vins';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'Lz-ORB';
      'SVO';
      'OKVIS';
      'MSCKF';
      'GF';
      'Rnd';
      'Long';
      };
    
    marker_styl = {
      '--o';
      '-.*';
      '--+';
      '--d';
      '--d';
      ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [0 0.2 0.8];
      [1 0 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    table_index = [7 7 7 4 1 2 2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/TRO19/RobotCar/'
    %
    
    
    
  case 'TUM_VI_TRO19_Mono'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      }
    baseline_slam_list = {
      %       'ObsNumber_200';
      %       'ObsNumber_300';
      %       'ObsNumber_400';
      %       'ObsNumber_600';
      'ObsNumber_800';
      %       'ObsNumber_1000';
      %       'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    
    %
    seq_list = {
      'room1_512_16';
      'room2_512_16';
      'room3_512_16';
      'room4_512_16';
      'room5_512_16';
      'room6_512_16';
      };
    seq_duration = [
      141.0;
      144.1;
      141.0;
      111.4;
      142.3;
      131.8;
      ];
    
    lmk_number_list = [60, 80, 100, 130, 160, 200, 240]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    baseline_number_list = [800]; %[200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    sensor_type = 'mono';
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 3;
    baseline_orb = 1;
    
    round_num = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/ORBv1_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/svo2_Mono_Baseline/';
      '/mnt/DATA/tmp/TUM_VI/DSO_Mono_Baseline/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'svo2';
      'DSO';
      };
    
    marker_styl = {
      'b--o';
      'm--o';
      'c--o';
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/TUM_VI_POSE_GT'
    save_path           = './output/TRO19/TUM_VI/'
    %
    
  case 'TUM_RGBD_TRO19_Mono'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_120';
      %       'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      %       'rgbd_dataset_freiburg2_pioneer_360';
      %       'rgbd_dataset_freiburg2_pioneer_slam';
      %       'rgbd_dataset_freiburg2_pioneer_slam2';
      %       'rgbd_dataset_freiburg2_pioneer_slam3';
      'rgbd_dataset_freiburg2_360_hemisphere';
      'rgbd_dataset_freiburg2_desk';
      'rgbd_dataset_freiburg2_desk_with_person';
      'rgbd_dataset_freiburg3_long_office_household';
      %       'rgbd_dataset_freiburg2_large_with_loop';
      %       'rgbd_dataset_freiburg2_large_no_loop';
      };
    seq_duration = [
      %       72.75;
      %       155.72;
      %       115.63;
      %       111.91;
      91.48;
      99.36;
      142.08;
      87.09;
      %       173.19;
      %       112.37;
      ];
    
    lmk_number_list = [60, 80, 100, 120];
    baseline_number_list = [200 300 400 600 800 1000 1500 2000];
    baseline_taken_index = [3]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/DSO_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_300/ORBv1_info_measErr_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_400/ORBv1_info_measErr_15ms/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_400/ORBv1_info_measErr_15ms_fullPrior/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_600/ORBv1_info_measErr_15ms/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_400/ORBv1_random_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_600/ORBv1_random_15ms/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_400/ORBv1_longlife_15ms/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_RGBD/Lmk_600/ORBv1_longlife_15ms/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    
    legend_arr = {
      'ORB';
      'SVO';
      'DSO';
      'GF';
      'Rnd';
      'Long';
      };
    
    marker_styl = {
      '--o';
      '--o';
      '--o';
      '--s';
      %       'c--s';
      ':*';
      ':*';
      };
    
    marker_color = {
      [0 0 1];
      [1 0 1];
      [0 1 1];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    table_index = [4 4 4 3 3 3];
    %     table_index = [4 4 4 2 2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/TUM_RGBD_POSE_GT'
    save_path           = './output/TRO19/TUM_RGBD/'
    %
    
  case 'NUIM_TRO19_Mono'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      'living_room_traj0';
      'living_room_traj1';
      'living_room_traj2';
      'living_room_traj3';
      %
      'office_room_traj0';
      'office_room_traj1';
      'office_room_traj2';
      'office_room_traj3';
      };
    seq_duration = [
      51;
      33;
      30;
      42;
      %
      51;
      33;
      30;
      42;
      ];
    
    lmk_number_list = [60, 80, 100, 130, 160]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    baseline_number_list = [200 300 400 600 800 1000 1500 2000];
    baseline_taken_index = [4]; % [3]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 3; % 4;
    baseline_orb = 1; % 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/ORBv1_Baseline_redo/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/ORB2_RGBD_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/DSO_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_400/ORBv1_info_measErr/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv1_info_measErr/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv2_info_dispErr/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_400/ORBv1_random/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv1_random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv2_random/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_400/ORBv1_longlife/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv1_longlife/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/NUIM/Lmk_600/ORBv2_longlife/';
      };
    
    
    pipeline_type = {
      'vo';
      %       'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      'vo';
      %       'vo';
      'vo';
      %       'vo';
      };
    
    
    legend_arr = {
      'ORB';
      %       'ORB-RGBD';
      'SVO';
      'DSO';
      'GF';
      %       'GF-ORB-RGBD';
      'Rnd';
      %       'Random-ORB-RGBD';
      'Long';
      %       'Longlive-ORB-RGBD';
      };
    
    marker_styl = {
      '--o';
      %       '--.';
      '--o';
      '--o';
      '--s';
      %       '--d';
      ':*';
      %       ':^';
      ':*';
      %       ':^';
      };
    
    marker_color = {
      [0 0 1];
      %       [0 0 1];
      [1 0 1];
      [0 1 1];
      [0 0 0];
      %       [0 0 0];
      [1 0 0];
      %       [1 0 0];
      [0 1 0];
      %       [0 1 0];
      };
    
    %     table_index = [4 4 4 2 2 2]; %
    table_index = [4 4 4 3 3 3]; %
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/NUIM_POSE_GT'
    save_path           = './output/TRO19/NUIM/'
    %
    
    
    
    %% ECCV 2018 related
    
  case 'EuRoC_PL'
    %
    plot3DTrack = 1;
    fps = 20;
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    round_num = 1; % 5; % 10
    track_loss_ratio = [1.0 1.0];
    
    %     step_length = 0; %
    min_match_num = 250;
    %     track_type = {'KeyFrame';};
    
    orig_slam_path  = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/LineOnly/'
    pl_slam_path    = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/Cut_LineOnly_0.1/'
    ref_path        = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path       = './output/PL_SLAM/Cut_PointLine_0.1/'
    %
    
  case 'EuRoC_Point_Line_Cut'
    %
    plot3DTrack = 1;
    fps = 20;
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    round_num = 1; % 5; % 10
    track_loss_ratio = [1.0 1.0];
    
    %     step_length = 0; %
    min_match_num = 250;
    %     track_type = {'KeyFrame';};
    gf_slam_list = {'whatever'};
    
    style = 'latex';
    
    point_slam_path         = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/PointOnly/'
    line_slam_path          = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/old/LineOnly/'
    lineCut_slam_path       = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/old/Cut_LineOnly_0.1/'
    pointline_slam_path     = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/PointLine_200/'
    pointlineCut_slam_path  = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/EuRoC/Cut_PointLine_0.1/'
    ref_path = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path               = './output/PL_SLAM/Full_0.1/'
    %
    
  case 'EuRoC_ECCV18'
    %
    plot3DTrack = 1;
    fps = 20;
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    benchmark_type = 'EuRoC';
    
    round_num = 10; % 5; % 3; % 1; %
    maxNormTrans = 10.0; % 50.0; % 20.0;
    % no scale fitting for stereo evaluation
    step_length = int32(-1); % 0; %
    %         track_loss_ratio = [0.8 1.0];
    track_loss_ratio = [0.3 1.0];
    
    valid_by_duration = true;
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    ln_head = 0; % 5*fps;
    
    %     step_length = 0; %
    %     min_match_num = 250;
    %     track_type = {'KeyFrame';};
    gf_slam_list = {'whatever'};
    
    style = 'latex';
    
    blur_postfix = '' %
    
    slam_path_list = {
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/LineOnly/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.15/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.15_ext/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/PointLine_P50_L100_final/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.15_final/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.15_ext_final/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/PointOnly_final/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/ORBSLAM_lvl4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/ORBSLAM_lvl8/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/SVO2/';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/SVO2_Stereo_Baseline/';
      };
    
    legend_arr = {
      'Line';
      %       'Line/_L100';
      'Line/_L50';
      'MaxVol/_L50';
      'MaxVol/_L50/_v2';
      %       'Line/_L30';
      %       'L150';
      %       'L150+cut';
      %       'P50+L100';
      %       'PL/_brute';
      'P50+L100';
      'P50+L100/_MaxVol/_0.15';
      'P50+L100/_MaxVol/_0.15-v2';
      %       'P50+L100/_MaxVol/_0.30';
      %       'P50+L100/_proj';
      %       'PL/_proj';
      %       'P50+L100/_maxVol';
      %       'P50+L100/_reprod';
      %       'P50+L100/_maxVol';
      %       'P50+L100/_minEig';
      %       'Pinf+Linf/_reprod';
      %       'P50+L100+cut';
      %       'P100+L50';
      %       'P100+L50+cut';
      %       'P150';
      %       'Point-l4';
      % %       'Point-l8';
      'ORB-SLAM2-l4';
      'ORB-SLAM2-l8';
      %       'ORB-SLAM2-l8-lowblur';
      %       'ORB-SLAM2-l8-highblur';
      'SVO2';
      %       'ORB-SLAM150';
      };
    
    %
    ref_path = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path            = './output/PL_SLAM/'
    %
    
  case 'EuRoC_Blur_ECCV18'
    %
    plot3DTrack = 1;
    fps = 20;
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    benchmark_type = 'EuRoC';
    
    round_num = 10; % 5; % 3; % 1; %
    maxNormTrans = 10.0; % 50.0; % 20.0;
    % no scale fitting for stereo evaluation
    step_length = int32(0); % int32(-1); %
    %         track_loss_ratio = [0.8 1.0];
    track_loss_ratio = [0.3 1.0];
    
    valid_by_duration = true;
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    ln_head = 0; % 5*fps;
    
    %     step_length = 0; %
    %     min_match_num = 250;
    %     track_type = {'KeyFrame';};
    gf_slam_list = {'whatever'};
    
    style = 'latex';
    
    blur_postfix = '_blur_5' %
    
    slam_path_list = {
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/LineOnly/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/LineOnly_L100/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/LineOnly_L50/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/LineOnly_L30/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.30/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.30_new/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.30_ext/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_LineOnly_ratio0.30_ext_new/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/MaxVol_L50_ratio0.15/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/MaxVol_L50_ratio0.15_ext/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/PointLine_P50_L100_final/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.30_final/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.30_final_new/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.30_ext_final/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/MaxVol_P50_L100_ratio0.30_ext_final_new/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/MaxVol_P50_L100_ratio0.15/';
      %       '/mnt/DATA/tmp/EuRoC/PL_SLAM/MaxVol_P50_L100_ratio0.15_ext/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/PointOnly_final/';
      %     '/mnt/DATA/tmp/EuRoC/PL_SLAM/PointOnly_lvl4/';
      %     '/mnt/DATA/tmp/EuRoC/PL_SLAM/PointOnly_lvl8/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/ORBSLAM_lvl4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/ORBSLAM_lvl8/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/EuRoC/SVO2/';
      %       '/mnt/DATA/tmp/EuRoC/SVO2_Stereo/';
      };
    
    legend_arr = {
      'Line/_L50';
      'MaxVol/_L50';
      'MaxVol/_L50/_v2';
      'MaxVol/_L50/_ext';
      'MaxVol/_L50/_v2/_ext';
      'P50+L100';
      'P50+L100/_MaxVol/_0.30';
      'P50+L100/_MaxVol/_0.30/_v2';
      'P50+L100/_MaxVol/_0.30/_ext';
      'P50+L100/_MaxVol/_0.30/_v2/_ext';
      'P150';
      'ORB-SLAM2-l4';
      'ORB-SLAM2-l8';
      'SVO2';
      };
    
    %
    ref_path = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path            = './output/PL_SLAM/'
    %
    
  case 'KITTI_CVPR_18'
    %
    plot3DTrack = 1;
    fps = 10;
    seq_list = {'00'; '01'; '02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10';}; %
    seq_duration = [
      450;
      114;
      483;
      82.7;
      28.1;
      287.5;
      114.3;
      114.3;
      423;
      165;
      124.5;
      ];
    
    round_num = 1; % 10; % 5; %
    %     track_loss_ratio = [1.0 1.0];
    track_loss_ratio = [0.85 1.0];
    benchmark_type = 'KITTI';
    
    maxNormTrans = 1000.0; % 5.0;
    
    %     step_length = 0; %
    min_match_num = 250;
    %     track_type = {'KeyFrame';};
    gf_slam_list = {'whatever'};
    
    style = 'latex';
    
    point_slam_path      = '/mnt/DATA/tmp/KITTI/PL_SLAM/PointLine/'
    line_slam_path       = '/mnt/DATA/tmp/KITTI/PL_SLAM/PointLine/'
    lineCut_1_path       = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    lineCut_2_path       = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    lineCut_3_path       = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    %
    pointline_slam_path  = '/mnt/DATA/tmp/KITTI/PL_SLAM/PointLine/'
    pointlineCut_1_path  = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    pointlineCut_2_path  = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    pointlineCut_3_path  = '/mnt/DATA/tmp/KITTI/PL_SLAM/Cut_PointLine_0.1/'
    %
    ref_path             = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/KITTI_POSE_GT'
    save_path            = './output/PL_SLAM/Full_0.1/'
    %
    
  case 'Gazebo_PL'
    %
    plot3DTrack = 1;
    fps = 30;
    seq_list = {
      'brick_wall';
      'wood_wall';
      };
    seq_duration = [
      146;
      182;
      ];
    
    round_num = 1; % 10; %  5; %
    track_loss_ratio = [1.0 1.0];
    
    %     step_length = 0; %
    min_match_num = 250;
    %     track_type = {'KeyFrame';};
    
    orig_slam_path  = '/mnt/DATA/tmp/Gazebo/PointLine/'
    pl_slam_path    = '/mnt/DATA/tmp/Gazebo/Cut_PointLine_0.1/'
    ref_path        = '/mnt/DATA/Datasets/GazeboMaze/Pose_GT'
    save_path       = './output/PL_SLAM/Cut_PointLine_0.1/'
    %
    
  case 'Gazebo_ECCV18'
    %
    plot3DTrack = 1;
    fps = 30;
    seq_list = {
      %       'brick_wall_0.01';
      %       'brick_wall_0.025';
      %       'brick_wall_0.05';
      %
      'hard_wood_0.01';
      %       'hard_wood_0.025';
      %       'hard_wood_0.05';
      %
      'wood_wall_0.01';
      %       'wood_wall_0.025';
      %       'wood_wall_0.05';
      };
    seq_duration = [
      %       100;
      %       99;
      %       98;
      104;
      %       98;
      %       107;
      99;
      %       96;
      %       98;
      ];
    
    benchmark_type = 'EuRoC';
    
    round_num = 10; % 5; % 3; %  1; %
    maxNormTrans = 50.0; % 20.0;
    % no scale fitting for stereo evaluation
    step_length = int32(-1); % 0; %
    %         track_loss_ratio = [0.8 1.0];
    track_loss_ratio = [0.3 1.0];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    ln_head = 0; % 5*fps;
    
    %     step_length = 0; %
    min_match_num = 250;
    %     track_type = {'KeyFrame';};
    gf_slam_list = {'whatever'};
    
    style = 'latex';
    
    %     slam_path_list = {
    % %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/LineOnly/';
    % %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/Cut_LineOnly_alt/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/PointLine/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/Cut_PointLine/';
    %       %
    % %       '/mnt/DATA/tmp/Gazebo/PointLine/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_reprod/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_old/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_new/';
    %       '/mnt/DATA/tmp/Gazebo/PointLine_brute/';
    %       '/mnt/DATA/tmp/Gazebo/PointLine_orb/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_brute_alt/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_hybrid/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_proj/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_maxVol_0.15/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_maxVol_0.3/';
    % % '/mnt/DATA/tmp/Gazebo/PointLine_maxVol_0.15_slow/';
    % %       '/mnt/DATA/tmp/Gazebo/PointLine_minEig_0.15/';
    %       %
    %       '/mnt/DATA/tmp/Gazebo/PointOnly_P150_brute/';
    %       '/mnt/DATA/tmp/Gazebo/PointOnly_P150_proj/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/PointOnly/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/ORBSLAM_P150/';
    %       };
    % %     legend_arr = {'L'; 'L+cut'; 'P+L'; 'P+L+cut'; 'P+L_best'; 'P'; 'ORB';};
    % legend_arr = {
    %   'P+L';
    %   'P+L+cut';
    % %   'P+L_notwork';
    % %   'P+L_v1';
    % %   'P+L_old';
    % %   'P+L_new';
    %   'P+L\_brute';
    %   'P+L\_orb';
    % %   'P+L\_brute\_alt';
    % %   'P+L\_hybrid';
    % %   'P+L\_proj';
    % %   'P+L\_maxVol\_.15';
    % %   'P+L\_maxVol\_.15\_slow';
    % %   'P+L\_maxVol\_.30';
    % %   'P+L\_minEig\_.15';
    %   'Point\_150\_brute';
    %   'Point\_150\_proj';
    %   'Point\_old';
    %   'ORB';
    %   };
    
    slam_path_list = {
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/PointLine/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/Cut_PointLine/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/PointLine_lvl4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/PointLine_maxVol_0.15/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/PointLine_maxVol_0.15_ext/';
      %       '/mnt/DATA/tmp/Gazebo/PointLine_maxVol_0.30/';
      %       '/mnt/DATA/tmp/Gazebo/PointLine_orb/';
      %
      %       '/mnt/DATA/tmp/Gazebo/PointOnly_P150_brute/';
      %       '/mnt/DATA/tmp/Gazebo/PointOnly_P150_proj/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/PointOnly_lvl4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/PointOnly_lvl8/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/PointOnly/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/ORBSLAM_lvl4/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/ORBSLAM_lvl8/';
      '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_ECCV18/Gazebo/SVO2/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Line_SLAM/Experimental_CVPR18/PL-SLAM_evaluation/Gazebo/final/ORBSLAM_P150/';
      };
    legend_arr = {
      %   'P+L';
      %   'P+L+cut';
      'Line';
      'P+L';
      'P+L+maxVol';
      %       'P+L+maxVol-2';
      %   'P+L\_orb';
      %   'Point\_150\_brute';
      %   'Point\_150\_proj';
      'Point\_lvl4';
      %       'Point\_lvl8';
      %   'Point\_proj';
      %   'Point\_old';
      'ORB\_lvl4';
      'ORB\_lvl8';
      'SVO2';
      %   'ORB\_150';
      };
    
    
    %
    ref_path             = '/mnt/DATA/Datasets/GazeboMaze/Pose_GT'
    save_path            = './output/PL_SLAM/Full_0.1/'
    %
    
    
    %% ICRA 2019 related
    
  case 'XWing_ICRA19_Desktop'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      }
    baseline_slam_list = {
      %       'ObsNumber_600';
      %       'ObsNumber_800';
      %       'ObsNumber_1000';
      'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    
    
    %
    seq_list = {
      %       'eo_wide_left-1526659828';
      'eo_wide_right-1526659828';
      };
    seq_duration = [
      2634.139;
      ];
    
    lmk_number_list = [60 80 100 130 160 200 240]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [1500]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1];
    %     baseline_number_list = [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    %     baseline_taken_index = [8];
    
    step_length = int32(0); %
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    track_loss_ratio = [0.98 0.98]; % [0.3 0.98]; %
    
    valid_by_duration = true;
    maxNormTrans = 999999;
    % NOTE
    seq_start_time = [
      30;
      ];
    
    baseline_num = 3; % 2 %
    baseline_orb = 3;
    round_num = 3; % 1; %
    
    slam_path_list  = {
      
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_Baseline_LargeWindow/Site_1/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_MapHash_LargeWindow/Site_1/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_Auto4_LargeWindow/Site_1/';
    %
    '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_Baseline_LargeWindow/Site_2/';
    '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_MapHash_LargeWindow/Site_2/';
    '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_Auto4_LargeWindow/Site_2/';
    
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Xwing/ORBv1_LC_Baseline/';
    % '/mnt/DATA/tmp/XWing/ORBv1_MapHash_LargeWindow/Site_1/';
    % '/mnt/DATA/tmp/XWing/ORBv1_MapHash_LargeWindow/Site_2/';
    % '/mnt/DATA/tmp/XWing/ORBv1_Baseline_LargeWindow/Site_2/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/NewCollege/ORBv1_Maphash_tableSelect_v3/';
    %       %
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/NewCollege/Lmk_800/GoodFeature_v3/';
    %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/Lmk_800/ORBv1_info_measErr_MapHash_v3/';
    };
  
  pipeline_type = {
    'vo';
    'vo';
    'vo';
    %       'vo';
    };
  
  legend_arr = {
    'ORB';
    'MIH - 32';
    'MIH - x/32';
    %       'AMatch';
    %       'Comb';
    };
  
  marker_styl = {
    '--o';
    ':s';
    ':s';
    ':s';
    };
  marker_color = {
    [0 0 1];
    [1 0 0];
    [0 1 0];
    [0 0 0];
    };
  
  table_index = [1 1 1];
  
  %
  ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/XWing_POSE_GT'
  save_path           = './output/XWing/'
  
  case 'UMichigan_ICRA19_Desktop'
    %
    plot3DTrack = 1;
    fps = 5;
    gf_slam_list = {
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    baseline_slam_list = {
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      '2012-09-28_cam5';
      };
    seq_duration = [
      700;
      ];
    
    lmk_number_list = [600 800 1000 1500]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [600 800 1000 1500 2000]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [2];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.9 0.98]; % [0.3 0.98];
    
    % NOTE
    seq_start_time = [
      1;
      ];
    
    baseline_num = 1; % 2 %
    baseline_orb = 1;
    
    slam_path_list  = {
      '/mnt/DATA/tmp/UMich/ORBv1_Baseline/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      };
    
    marker_styl = {
      '--o';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [0 1 0];
      [0 0 0];
      [0.3 0.1 0.5];
      };
    
    table_index = [3]; % [2 2 2 2 2 2 2]; % [2 2 3];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/UMich_POSE_GT'
    save_path           = './output/ICRA19/Desktop/'
    %
    
  case 'NewCollege_ICRA19_Desktop'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      %       'ObsNumber_60';
      %       'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_240';
      %
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    baseline_slam_list = {
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    
    %
    seq_list = {
      'left_cam';
      };
    seq_duration = [
      2634.139;
      ];
    
    lmk_number_list = [100 130 160 200 240 600 800 1000 1500 2000]; %
    %
    baseline_number_list = [600 800 1000 1500 2000]; %
    baseline_taken_index = [2];
    
    step_length = int32(0); %
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    seq_start_time = [
      30;
      ];
    
    baseline_num = 2; % 0; %
    baseline_orb = 1; % 0; %
    
    %     round_num = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege_old/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/LDSO_Mono_Baseline_v2/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege_old/Lmk_800/GoodFeature_v3/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/ORBv1_Map_Random/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/ORBv1_Map_LongLive/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/ORBv1_Map_Random_v2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/ORBv1_Map_LongLive_v2/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T1_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T4_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T8_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T16_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T32_B10/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/NewCollege/T_Auto8_B10/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'LDSO';
      'GF';
      %       'MIH-1/32';
      %       'MIH-4/32';
      %       'MIH-8/32';
      %       'MIH-16/32';
      %       'MIH-32/32';
      'Random';
      'Longlife';
      'MIH-x/32';
      };
    
    marker_styl = {
      '--o';
      '--*';
      ':s';
      ':s';
      ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 1];
      [1 0 0];
      [0 1 0];
      [0 1 1];
      [0 0 0];
      %       [0.3 0.1 0.5];
      };
    
    table_index = [2 2 3 7 7 7]; % [2 2 2 2 2 2]; %
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/NewCollege_POSE_GT'
    save_path           = './output/ICRA19/NewCollege/'
    %
    
  case 'EuRoC_ICRA19_Desktop'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    baseline_slam_list = {
      'ObsNumber_100';
      'ObsNumber_200';
      'ObsNumber_300';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [600 800 1000 1500 2000]; % [800] %
    baseline_number_list = [100 200 300 400 600 800 1000 1500 2000]; % [800]; %
    baseline_taken_index = [6]; % [1]; %
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 3; % 0 %
    baseline_orb = 1; % 0; %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/DSO_Mono_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T1_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T4_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T8_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T16_B10/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T32_B10/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/ORBv1_Map_Random/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/ORBv1_Map_LongLive/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/EuRoC/T_Auto8_B10/'
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'SVO';
      'DSO';
      %       'MIH-1/32';
      %       'MIH-4/32';
      %       'MIH-8/32';
      %       'MIH-16/32';
      %       'MIH-32/32';
      'Random';
      'Longlife';
      'MIH-x/32';
      };
    
    marker_styl = {
      '--o';
      '--+';
      '--*';
      %       ':s';
      %       ':s';
      %       ':s';
      ':s';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [0 1 1];
      [1 0 1];
      [1 0 0];
      [0 1 0];
      [0 0 0];
      };
    
    table_index = [6 6 6 2 2 2]; % [1 1 1 1 1 1]; %
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/ICRA19/EuRoC/'
    %
    
  case 'EuRoC_ICRA19_OnDevice_Euclid'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_60';
      %       'ObsNumber_80';
      %       'ObsNumber_100';
      %       'ObsNumber_130';
      %       'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_240';
      }
    baseline_slam_list = {
      %       'ObsNumber_25';
      %       'ObsNumber_100';
      %       'ObsNumber_150';
      %       'ObsNumber_200';
      %       'ObsNumber_300';
      'ObsNumber_400';
      %       'ObsNumber_600';
      %       'ObsNumber_800';
      %       'ObsNumber_1000';
      %       'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [60]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [400]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 4;
    baseline_orb = 2;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/ORBv1_Baseline_lvl3_fac2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/ORBv1_MapHash_tableSelect_v3/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/SVO2_Mono_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/DSO_Mono_Baseline/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/vins_Mono_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/rovio_Mono_Baseline/';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/Lmk_400/ORBv1_info_measErr_fac2_25ms/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/OnDevice/Lmk_400/ORBv1_info_measErr_MapHash_v3/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vins';
      %       'vins';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'MHash';
      'SVO';
      'DSO';
      %       'VINS-Mono';
      %       'ROVIO';
      'AMatch';
      'Comb';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 1 0];
      [0 0 0];
      };
    
    
    table_index = [1 1 1 1 1 1];
    %     table_index = [6 6 6 6 3 1 3 3];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/ICRA19/Euclid/'
    %
    
    RMSE_VINS = [
      0.29 0.48 0.20 ;
      0.31 0.40 0.18 ;
      0.66 0.45 0.17 ;
      2.02 0.67 0.12 ;
      0.87 0.48 0.35 ;
      0.36 0.25 0.05 ;
      0.78 0.22 0.12 ;
      nan 0.63 0.10 ;
      0.33 0.17 0.08 ;
      0.59 0.18 0.08 ;
      nan 1.86 0.17 ;
      ];
    
    time_VINS = [
      40.31129245304476, 53.006312863744085, 152.39906024738463;
      44.71015399010792, 51.76893363124561, 143.90504992948289;
      38.61439816222534, 51.71760303479471, 180.090119249208;
      41.5672627406639, 49.22274453141832, 168.85724263600525;
      38.45534664913262, 50.36748714239482, 153.8327836374322;
      31.11650502786033, 51.97679441316372, 188.55670100164204;
      32.03208114444445, 46.512963840722506, 170.89565506382976;
      nan, 40.48963765896981, 115.2418642188082;
      34.53929937227723, 50.79091160689655, 167.15673794011977;
      36.57105348473636, 48.00802083240224, 156.80929511680142;
      nan, 37.98306740369231, 109.9514429991251;
      ];
    
    
    %% RAL 2019 related
    
  case 'RobotCar_RAL19_Desktop'
    %
    plot3DTrack = 1;
    fps = 5;
    gf_slam_list = {
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      '2014-07-14-15-16-36';
      '2014-11-18-13-20-12';
      '2014-12-05-11-09-10';
      };
    seq_duration = [
      967;
      1200;
      2100;
      ];
    
    lmk_number_list = [600 800 1000 1500 2000]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [150 200 400 600 800 1000 1500 2000]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1];
    
    round_num = 5;
    step_length = int32(0); %
    
    track_loss_ratio = [0.9 0.98]; % [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    % NOTE
    seq_start_time = [
      1;
      1;
      1;
      ];
    
    baseline_num = 1; % 2 %
    baseline_orb = 0;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/RobotCar/vins_Mono_Baseline/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      };
    
    legend_arr = {
      %       'ORB';
      'VINS-Fusion';
      };
    
    marker_styl = {
      '--o';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [0 1 0];
      [0 0 0];
      [0.3 0.1 0.5];
      };
    
    table_index = [2]; % [2 2 2 2 2 2 2]; % [2 2 3];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/RAL19/Desktop/'
    %
    
  case 'Hololens_RAL19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_200';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      '2019-01-25-15-10_stereo';
      '2019-01-25-17-30_stereo';
      '2019-01-24-18-09_stereo';
      };
    
    % NOTE
    seq_start_time = [
      1;
      1;
      1;
      ];
    seq_duration = [
      300;
      130;
      277;
      ];
    
    lmk_number_list = [200]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [150 200 400 600 800 1000 1500 2000];
    baseline_taken_index = [1];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    baseline_num = 2;
    baseline_orb = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/ORB2_Stereo_Baseline/'
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/vins_Mono_Baseline/'
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'VINS-Fusion';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 1 0];
      [0 0 0];
      };
    
    table_index = [2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Hololens_POSE_GT'
    save_path           = './output/RAL19/Hololens/'
    %
    
  case 'NewCollege_RAL19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_200';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
    seq_list = {
      'stereo_cam';
      };
    
    % NOTE
    seq_start_time = [
      1;
      ];
    seq_duration = [
      2634.139;
      ];
    
    lmk_number_list = [200]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [150 200 400 600 800 1000 1500 2000];
    baseline_taken_index = [1];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    baseline_num = 2;
    baseline_orb = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/NewCollege/ORB2_Stereo_Baseline/'
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/NewCollege/vins_Mono_Baseline/'
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      'VINS-Fusion';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 1 0];
      [0 0 0];
      };
    
    table_index = [2 5];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/NewCollege_POSE_GT'
    save_path           = './output/RAL19/NewCollege/'
    %
    
  case 'EuRoC_RAL19_Desktop'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      }
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    lmk_number_list = [80, 100, 130, 160]; %
    %
    baseline_number_list = [150 200 400 600 800 1000 1500 2000];
    baseline_taken_index = [5];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    baseline_num = 0 % 2;
    baseline_orb = 0 % 2;
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB2_Stereo_Baseline/'
      '/mnt/DATA/tmp/EuRoC/GF_Stereo_pyr3_v3/';
      '/mnt/DATA/tmp/EuRoC/GF_Stereo_pyr8_v3/';
      '/mnt/DATA/tmp/EuRoC/GF_Stereo_pyr8_v4/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'GF-l3';
      'GF-l8';
      'GF-l8-new';
      %       'VINS-Fusion';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 1 0];
      [0 0 0];
      };
    
    table_index = [2 2 2];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC/'
    %
    
    
  case 'EuRoC_Mono_RAL19_FastMo_Demo'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_100';
      % 'ObsNumber_600';
      % 'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [1, 1]; % [2, 1, 1]; %
    
    baseline_number_list = [100] % [100, 600, 800];
    
    round_num = 1;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.6 0.98];
    
    sensor_type = 'mono';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 2;
    baseline_orb = 0;
    max_y_lim = 500;
    
    fast_mo_list = [4.0]; % [1.0] %
    
    slam_path_list  = {
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/DSO_Mono_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/svo_Mono_Speedx';
      %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_BaseBA_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_BaseBA_Mono_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_SWF_Mono_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Covis_Mono_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAntic_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticv2_Mono_Speedx';
      };
    
    pipeline_type = {
      % 'vo';
      % 'vo';
      % 'vo';
      'vo';
      % 'vo';
      % 'vo';
      'vo';
      };
    
    legend_arr = {
      % 'DSO';
      % 'SVO';
      %
      % 'ORB';
      'GF';
      % 'GF+SW';
      % 'GF+CV';
      'GF+GG';
      };
    
    marker_styl = {
      % '--o';
      % '--+';
      %
      % ':o';
      ':+';
      % ':x';
      % ':x';
      ':s';
      };
    
    marker_color = {
      % [0 0 1];
      %       [1 0 1];
      % [1.0000    0.8276         0];
      %
      % [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      % [0.6207    0.3103    0.2759];
      % [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/Demo/'
    %
    
    
  case 'EuRoC_Mono_RAL19_FastMo_OnlFAST'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_100';
      'ObsNumber_600';
      'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [2, 3, 3, 1, 1, 1, 1];
    
    baseline_number_list = [100, 600, 800];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.6 0.98];
    
    sensor_type = 'mono';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 7;
    baseline_orb = 0;
    
    fast_mo_list = [1.0 2.0 3.0 4.0 5.0]; % [1.0, 3.0, 5.0] % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/DSO_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/svo_Mono_Speedx';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_BaseBA_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_BaseBA_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_SWF_Mono_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Covis_Mono_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAntic_Mono_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticv2_Mono_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticv3_Mono_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraph_Mono_Speedx';
      '/mnt/DATA/tmp/EuRoC/GF_GGraph_Mono_Speedx';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'DSO';
      'SVO';
      %
      'ORB';
      'GF';
      'GF+SW';
      'GF+CV';
      'GF+GG';
      };
    
    marker_styl = {
      '--o';
      '--+';
      %
      ':o';
      ':+';
      ':x';
      ':x';
      ':s';
      };
    
    marker_color = {
      [0 0 1];
      %       [1 0 1];
      [1.0000    0.8276         0];
      %
      [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC_Mono_PC/'
    %
    
    
  case 'EuRoC_RAL19_FastMo_PreFAST'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_130';
      %       'ObsNumber_150';
      %       'ObsNumber_200';
      %       'ObsNumber_400';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    %     table_index = [3, 2, 2, 3, 4, 1, 1, 1, 1, 1];
    table_index = [1 1 1 1];
    
    baseline_number_list = [130]; % [130, 150, 200, 400]; %
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.35 0.98]; % [0.45 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 4; % 10; % 6 %
    baseline_orb = 0;
    
    fast_mo_list = [1.0 2.0 3.0 4.0 5.0]; % [1.0, 3.0, 5.0] % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/iceBA_Stereo_Extra_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_IMU_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/svo_Stereo_Speedx';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_Stereo_preP_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_preP_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_SWF_Stereo_preP_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Covis_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraph_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAntic_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticV4_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticV5_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNL_Stereo_preP_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNLv2_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNH_Stereo_preP_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/tmp/GF_GGraphAnticNoisyV2_Stereo_preP_Speedx';
      %
      % DEBUG results
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_pyr8_preLv2_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_SWF_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/tmp/EuRoC/GF_GGraph_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_GGraphInc_v2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_GGraphInc_v3_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v2/GF_GGraphInc_v4_Stereo_Speedx';
      %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v3/GF_GGraphInc_numeric_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v3/GF_GGraphInc_analytical_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v3/GF_GGraphInc_predv2_Stereo_Speedx';
      %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_SWF_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_Covis_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_GGraphInc_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_GGraphInc_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_GGraphIncAntic_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GF_GGraphIncAntic_anal_Stereo_Speedx';
      %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_SWF_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_Covis_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphInc_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphInc_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAntic_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAntic_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOL_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOL_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOLv2_numr_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOLv2_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOL_b1_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v4/GFPreP_GGraphIncAnticOL_b3_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v1_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v2_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v3_anal_Stereo_Speedx';
      % %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v1pred_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v2pred_anal_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v5/GFPreP_GGraphIncAnticOL_b1v3pred_anal_Stereo_Speedx';
      %
      %
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV1_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV2_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV3_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV4_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV4_2_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV5_Stereo_preP_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Debug_v6/GF_GGraphAnticV6_Stereo_preP_Speedx';
      };
    
    pipeline_type = {
      %       'vins';
      %       'vins';
      %       'vins';
      %       'vo';
      'vo';
      %
      'vo';
      'vo';
      %       'vo';
      %       'vo';
      'vo';
      };
    
    legend_arr = {
      %       'MSC';
      %       'ICE';
      %       'VIMU';
      %       'VIVis';
      %       'SVO';
      %
      %       'ORB';
      'GF';
      'GF + SWF';
      'GF + Covis';
      'GF + GG';
      %       'GF + GG_{ant}';
      %       'GF + GG_{antNL}';
      %       'GF + GG_{antNH}';
      %       'GF + GG_{ant1}';
      %             'GF + GG_{ant2}';
      %
      % DEBUG sets
      %
      %       'GF + GGv2'; % all covis KF for selection
      %       'GF + GGv3'; % part of covis KF for selection
      %       'GF + GGv4'; % analytical Jacobian
      %       'GG_{num}'; % numerical Jacobian
      %       'GG_{anal}'; % analytical Jacobian
      %       'GF + GG_{pred}'; % predicted numerical Jacobian
      %       'GGAnt_{num}'; % numerical Jacobian with anticipation
      %       'GGAnt_{anal}'; % analytical Jacobian with anticipation; current best solution!
      %       'GGAntOL_{num}'; % numerical Jacobian with anticipation and online estimation
      %       'GGAntOL_{anal}'; % analytical Jacobian with anticipation and online estimation
      %       'GGAntOL2_{num}'; % numerical Jacobian with anticipation and online estimation
      %       'GGAntOL2_{anal}'; % analytical Jacobian with anticipation and online estimation
      %       'GGAntOLb1_{anal}'; % potentially better solution
      %       'GGAntOLb3_{anal}';
      % 'GGAntOLb1v1_{anal}';
      % 'GGAntOLb1v2_{anal}'; % best combo solution so far
      % 'GGAntOLb1v3_{anal}';
      % 'GGAntOLb1v1pd_{anal}';
      % 'GGAntOLb1v2pd_{anal}';
      % 'GGAntOLb1v3pd_{anal}';
      % 'GGAntV1';
      % 'GGAntV2';
      % 'GGAntV3';
      % 'GGAntV4';
      % 'GGAntV4_2';
      % 'GGAntV5';
      % 'GGAntV6';
      };
    
    marker_styl = {
      %       '--o';
      %       '--+';
      %       '--*';
      %       '--*';
      %       '--d';
      %
      %      ':o';
      ':+';
      ':x';
      ':x';
      %       ':x';
      %             ':s';
      ':s';
      };
    marker_color = {
      %       [     0         0    1.0000];
      %       [1.0000         0         0];
      %       [     0    1.0000         0];
      %       [1.0000    0.1034    0.7241];
      %       [1.0000    0.8276         0];
      %          [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      %       [     0    0.5172    0.5862];
      %     [     0         0    0.4828];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC_PC_PreFAST/'
    %
    
    
  case 'EuRoC_RAL19_FastMo_OnlFAST'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_130';
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [3, 2, 2, 4, 5, 1, 1, 1, 1];
    %     table_index = [3, 2, 2, 3, 4, 5, 1, 1, 1, 1, 1];
    % table_index = [2 1 1 1 1 1 1];
    
    baseline_number_list = [130, 150, 200, 400, 800]; % [160];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.6 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = 3;
    baseline_num = 9; % 11; % 7; % 5; %
    baseline_orb = 0;
    
    fast_mo_list = [1.0 2.0 3.0 4.0 5.0]; % [1.0, 3.0, 5.0] % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/iceBA_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_IMU_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/svo_Stereo_Speedx';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_SWF_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraph_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAntic_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNL_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNLv2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNLv3_Stereo_Speedx';
      % '/mnt/DATA/swp_2/GF_GGraphAnticNL_Stereo_Speedx';
      % '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNH_Stereo_Speedx';
      %
      };
    
    pipeline_type = {
      'vins';
      'vins';
      'vins';
      %       'vo';
      'vins';
      %
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      %             'vo';
      'vo';
      };
    
    legend_arr = {
      'MSC';
      'ICE';
      'VIF';
      %       'VIVis';
      'SVO';
      %
      'ORB';
      'GF';
      'GF+SW';
      'GF+CV';
      'GF+GG';
      %          'GF+GG2';
      %       'GF+GG_{ant}';
      %       'GF + GG_{antNL}';
      %       'GF + GG_{antNH}';
      };
    
    marker_styl = {
      '--o';
      '--+';
      '--*';
      %       '--*';
      '--d';
      %
      ':o';
      ':+';
      ':x';
      ':x';
      %       ':x';
      %             ':s';
      ':s';
      };
    
    marker_color = {
      [     0         0    1.0000];
      [1.0000         0         0];
      [     0    1.0000         0];
      %       [1.0000    0.1034    0.7241];
      [1.0000    0.8276         0];
      [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      %       [     0    0.5172    0.5862];
      %           [     0         0    0.4828];
      [     0         0    0.1724];
      };
    
    %     marker_color = {
    %       [0 0 1];
    %       [1 0 0];
    %       [1 0 1];
    %       [0 1 1];
    %       [1 0.84 0];
    %       %
    %       [0.49 0.18 0.56];
    %       [0.64,0.56,0.88];
    %       [0 1 0];
    %       [0 0 0];
    %       [0.09,0.73,0.89];
    %       [0 0 1];
    %       [1 0 0];
    %       };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC_PC/'
    %
    
    
  case 'Hololens_RAL19_FastMo_Demo'
    %
    plot3DTrack = 1;
    fps = 30;
    baseline_slam_list = {
      'ObsNumber_130';
      %       'ObsNumber_800';
      }
    
    %
    seq_list = {
      '2019-01-25-15-10_stereo';
      '2019-01-25-17-30_stereo';
      '2019-01-24-18-09_stereo';
      };
    
    % NOTE
    seq_start_time = [
      1;
      1;
      1;
      ];
    seq_duration = [
      300;
      130;
      277;
      ];
    
    table_index = [1 1] % [2 1 1 1 1]; %
    
    baseline_number_list = [130] % [130 800]; %
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.6 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    vins_idx = -1;
    baseline_num = 2 % 3; % 5 %
    baseline_orb = 0;
    max_y_lim = 1000;
    
    fast_mo_list = [1.0]; % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/SVO2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/hold_ORB2_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_SWF_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_GGraphAntic_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_GGraphAnticv2_Stereo_Speedx';
      };
    
    pipeline_type = {
      %       'vo';
      'vo';
      %       'vo';
      %       'vo';
      'vo';
      };
    
    legend_arr = {
      %       'ORB';
      'GF';
      %       'GF+SW';
      %       'GF+CV';
      'GF+GG';
      };
    
    marker_styl = {
      %       ':o';
      ':+';
      %       ':x';
      %       ':x';
      ':s';
      };
    
    marker_color = {
      %       [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      %       [0.6207    0.3103    0.2759];
      %       [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Hololens_POSE_GT'
    save_path           = './output/RAL19/Demo/'
    %
    
    
  case 'Hololens_RAL19_FastMo_OnlFAST'
    %
    plot3DTrack = 1;
    fps = 30;
    baseline_slam_list = {
      'ObsNumber_130';
      'ObsNumber_600';
      'ObsNumber_800';
      }
    
    %
    seq_list = {
      '2019-01-25-15-10_stereo';
      '2019-01-25-17-30_stereo';
      '2019-01-24-18-09_stereo';
      };
    
    % NOTE
    seq_start_time = [
      1;
      1;
      1;
      ];
    seq_duration = [
      300;
      130;
      277;
      ];
    
    table_index = [2, 3, 1, 1, 1, 1];
    
    baseline_number_list = [130, 600, 800];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.99 0.98]; % [0.40 0.98]; %
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 6;
    baseline_orb = 0;
    
    fast_mo_list = [1.0, 2.0, 4.0]; % [1.0 2.0 3.0 4.0 5.0]; %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/SVO2_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/hold_ORB2_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_SWF_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_GGraphAntic_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Hololens/GF_GGraphAnticv2_Stereo_Speedx';
      
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'SVO';
      %
      'ORB';
      'GF';
      'GF+SW';
      'GF+CV';
      'GF+GG';
      };
    
    marker_styl = {
      '--d';
      ':o';
      ':+';
      ':x';
      ':x';
      ':s';
      };
    
    marker_color = {
      [1.0000    0.8276         0];
      [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Hololens_POSE_GT'
    save_path           = './output/RAL19/Hololens_PC/'
    %
    
    
  case 'EuRoC_RAL19_Jetson'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_130';
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [3, 2, 2, 4, 5, 1, 1, 1, 1];
    %     table_index = [3, 2, 2, 3, 4, 5, 1, 1, 1, 1, 1];
    % table_index = [2 1 1 1 1 1 1];
    
    baseline_number_list = [130, 150, 200, 400, 800]; % [160];
    
    round_num = 10;
    step_length = int32(0); %
    
    % relax robust check condition
    %     track_loss_ratio = [0.4 0.98];
    track_loss_ratio = [0.6 0.98];
    track_fail_thres = 5; % 3 %
    
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = 3;
    baseline_num = 9; % 11; % 7; % 5; %
    baseline_orb = 0;
    
    fast_mo_list = [1.0]; % [1.0 2.0 3.0 4.0 5.0]; % [1.0, 3.0, 5.0] %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/msckf_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/iceBA_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/vins_Stereo_IMU_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/vins_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/svo_Stereo_Speedx';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/ORB_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_SWF_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraph_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraphAntic_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraphAnticV2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraphAnticNL_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraphAnticNH_Stereo_Speedx';
      %
      };
    
    legend_arr = {
      'MSC';
      'ICE';
      'VIF';
      %       'VIVis';
      'SVO';
      %
      'ORB';
      'GF';
      'GF+SW';
      'GF+CV';
      'GF+GG';
      %       'GF+GG_{ant}';
      %       'GF + GG_{antNL}';
      %       'GF + GG_{antNH}';
      };
    
    pipeline_type = {
      'vins';
      'vins';
      'vins';
      %       'vo';
      'vins';
      %
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      %       'vo';
      'vo';
      };
    
    marker_styl = {
      '--o';
      '--+';
      '--*';
      %       '--*';
      '--d';
      %
      ':o';
      ':+';
      ':x';
      ':x';
      %       ':x';
      %       ':s';
      ':s';
      };
    
    marker_color = {
      [     0         0    1.0000];
      [1.0000         0         0];
      [     0    1.0000         0];
      %       [1.0000    0.1034    0.7241];
      [1.0000    0.8276         0];
      [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      %       [     0    0.5172    0.5862];
      %     [     0         0    0.4828];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC_Jetson/'
    %
    
    
  case 'EuRoC_RAL19_FastMo_Demo'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_130';
      %       'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [1, 1]; % [2, 1, 1]; %
    
    baseline_number_list = [130] % [130, 800]; %
    
    round_num = 1;
    step_length = int32(0); %
    
    track_loss_ratio = [0.40 0.98]; % [0.9 0.98]; % [0.6 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 2 % 3; %
    baseline_orb = 0;
    max_y_lim = 800;
    
    fast_mo_list = [2.0]; % [1.0] %
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_SWF_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraph_Stereo_Speedx';
%             '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticNLv2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticDemo_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_GGraphAnticDemoV2_Stereo_Speedx';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/ORB_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/Jetson/GF_GGraphAntic_Stereo_Speedx';
      
      };
    
    pipeline_type = {
      'vo';
      %       'vo';
      'vo';
      };
    
    legend_arr = {
      %       'ORB';
      'GF';
      %       'GF+SW';
      %       'GF+CV';
      %       'GF+GG';
      'GF+GG';
      };
    
    marker_styl = {
      %       ':o';
      ':+';
      %       ':x';
      %       ':x';
      %       ':s';
      ':s';
      };
    
    marker_color = {
      %       [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      %       [0.6207    0.3103    0.2759];
      %       [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/Demo/'
    %
    
    
    
  case 'EuRoC_RAL19_FastMo_MinSet'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_70';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_150';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [7, 5, 5, 7, 8, 10, 6, 6];
    
    baseline_number_list = [70 80 100 130 150 160 200 400 600 800 1000 1500];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = true;
    
    baseline_num = 8 % 2;
    baseline_orb = 0 % 2;
    
    fast_mo_list = [1.0, 2.0, 4.0];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/msckf_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/iceBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/iceBA_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/vins_Stereo_IMU_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/vins_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/svo_Stereo_Speedx';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/ORB_Stereo_pyr8_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/GF_Stereo_pyr8_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/param_sweep/GF_Stereo_pyr3_Speedx';
      };
    
    pipeline_type = {
      'vins';
      %       'vins';
      'vins';
      'vins';
      'vo';
      %       'vo';
      'vo';
      %
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'MSC';
      %       'ICE-BA';
      'ICE';
      'VIMU';
      'VIVis';
      %       'VINS-Vis-Extra';
      'SVO';
      %
      'ORB-8';
      'GF-8';
      'GF-3';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 1 0];
      [0 0 0];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC/'
    %
    
    
  case 'EuRoC_RAL19_FastMo'
    %
    plot3DTrack = 1;
    fps = 20;
    baseline_slam_list = {
      'ObsNumber_150';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_800';
      }
    
    %
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
    
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [3, 1, 1, 3, 4, 5, 5, 2, 2, 2];
    %     table_index = [5, 5, 5, 2, 2, 2, 2];
    
    baseline_number_list = [150 160 200 400 800];
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    baseline_num = 10 % 9 % 7 % 2;
    baseline_orb = 0 % 2;
    
    fast_mo_list = [1.0, 2.0, 3.0, 4.0, 5.0];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/msckf_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/iceBA_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_IMU_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/vins_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/svo_Stereo_Speedx';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_Stereo_pyr8_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_Stereo_pyr8_preLv2_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/ORB_Stereo_pyr8_prePv2_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_pyr8_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_pyr8_preLv2_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_pyr8_prePv2_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/EuRoC/GF_Stereo_pyr3_preL_Speedx';
      };
    
    pipeline_type = {
      'vins';
      %       'vins';
      'vins';
      'vins';
      'vo';
      %       'vo';
      'vo';
      %
      %       'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'MSC';
      %       'ICE-BA';
      'ICE';
      'VIMU';
      'VIVis';
      %       'VINS-Vis-Extra';
      'SVO';
      %
      'ORB-8-L';
      'ORB-8-P';
      'GF-8-L';
      'GF-8-P';
      'GF-3-L';
      };
    
    marker_styl = {
      '--o';
      ':s';
      '--+';
      '--*';
      '--d';
      '--x';
      '--x';
      ':s';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0.64,0.56,0.88]; % [0.69 0.38 0.36];
      [0 1 0];
      [0 0 0];
      [0.09,0.73,0.89];
      };
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/RAL19/EuRoC/'
    %
    
    
  case 'FPV_RAL19_FastMo_OnlFAST'
    %
    plot3DTrack = 1;
    fps = 30;
    baseline_slam_list = {
      'ObsNumber_80';
      %             'ObsNumber_100';
      %       'ObsNumber_130';
      'ObsNumber_150';
      'ObsNumber_200';
      'ObsNumber_400';
      'ObsNumber_800';
      }
    
    %
    seq_list = {
      'indoor_forward_3';
      'indoor_forward_5';
      'indoor_forward_6';
      'indoor_forward_7';
      'indoor_forward_9';
      'indoor_forward_10';
      };
    
    seq_duration = [
      54.7; % 92.1;
      50.0; % 150.0;
      33.0; % 69.6;
      73.2; % 118.0;
      42.0; % 54.7; % 76.8;
      42.5; % 50.0; % 76.3;
      ];
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    %     table_index = [5, 4, 4, 5, 6, 7, 3, 3, 3, 3, 1];
    table_index = [3, 2, 2, 4, 5, 1, 1, 1, 5]; % 1];
    % table_index = [2 1 1 1 1 1 1];
    
    baseline_number_list = [80 150 200 400 800]; % [130, 160]; %
    %     baseline_number_list = [80 100 130 150 200 400 800]; % [130, 160]; %
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.47 0.98]; % [0.35 0.98]; %
    
    %     % relax robust check condition
    %     track_fail_thres = 1 % 5 % 3 %
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = 3;
    baseline_num = 9; % 5;
    baseline_orb = 0;
    
    fast_mo_list = [1.0]; % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/msckf_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/iceBA_Stereo_Extra_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/vins_Stereo_IMUv2_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/vins_Stereo_IMU_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/vins_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/svo_Stereo_Speedx';
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/ORB_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_SWF_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraph_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraphAntic_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraphAnticNLv2_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/ORB_GGraphAnticNL_Stereo_Speedx';
      %
      };
    
    pipeline_type = {
      'vins';
      'vins';
      'vins';
      %       'vo';
      'vins';
      %
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      'vo';
      %       'vo';
      };
    
    legend_arr = {
      'MSC';
      'ICE';
      'VIF';
      %       'VIVis';
      'SVO';
      %
      'ORB';
      'GF';
      'GF+SW';
      'GF+CV';
      'GF+GG';
      %       'GF + GG_{ant}';
      %       'GF + GG_{antNL}';
      %       'GF + GG_{antNH}';
      };
    
    marker_styl = {
      '--o';
      '--+';
      '--*';
      %       '--*';
      '--d';
      %
      ':o';
      ':+';
      ':x';
      ':x';
      %       ':x';
      %       ':s';
      ':s';
      };
    
    marker_color = {
      [     0         0    1.0000];
      [1.0000         0         0];
      [     0    1.0000         0];
      %       [1.0000    0.1034    0.7241];
      [1.0000    0.8276         0];
      [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      [0.6207    0.3103    0.2759];
      [     0    1.0000    0.7586];
      %       [     0    0.5172    0.5862];
      %     [     0         0    0.4828];
      [     0         0    0.1724];
      };
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/UZH_FPV_POSE_GT'
    save_path           = './output/RAL19/FPV/'
    %
    
    
  case 'FPV_RAL19_FastMo_Demo'
    %
    plot3DTrack = 1;
    fps = 30;
    baseline_slam_list = {
      'ObsNumber_80';
      %       'ObsNumber_800';
      }
    
    %
    seq_list = {
      'indoor_forward_3';
      'indoor_forward_5';
      'indoor_forward_6';
      'indoor_forward_7';
      'indoor_forward_9';
      'indoor_forward_10';
      };
    
    seq_duration = [
      54.7; % 92.1;
      50.0; % 150.0;
      33.0; % 69.6;
      73.2; % 118.0;
      42.0; % 54.7; % 76.8;
      42.5; % 50.0; % 76.3;
      ];
    
    seq_start_time = [
      0;
      0;
      0;
      0;
      0;
      0;
      ];
    
    table_index = [1 1] % [2 1 1 1 1]; %
    
    baseline_number_list = [80] % [80 800]; %
    
    round_num = 10;
    step_length = int32(0); %
    
    track_loss_ratio = [0.47 0.98]; % [0.55 0.98]; % [0.6 0.98]; %
    
    % relax robust check condition
    %     track_fail_thres = 1 % 5 % 3 %
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    %     benchmark_type = 'KITTI';
    valid_by_duration = false; % true;
    
    vins_idx = -1;
    baseline_num = 2 % 3; % 5 %
    baseline_orb = 0;
    max_y_lim = 800;
    
    fast_mo_list = [1.0]; % [0.5 1.0 1.5]; %
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/ORB_BaseBA_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_BaseBA_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_SWF_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_Covis_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraph_Stereo_Speedx';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraphAntic_Stereo_Speedx';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/UZH_FPV/GF_GGraphAnticNLv2_Stereo_Speedx';
      %
      };
    
    pipeline_type = {
      %       'vo';
      'vo';
      %       'vo';
      %       'vo';
      'vo';
      };
    
    legend_arr = {
      %       'ORB';
      'GF';
      %       'GF+SW';
      %       'GF+CV';
      'GF+GG';
      };
    
    marker_styl = {
      %       ':o';
      ':+';
      %       ':x';
      %       ':x';
      ':s';
      };
    
    marker_color = {
      %       [     0    0.3448         0];
      [0.5172    0.5172    1.0000];
      %       [0.6207    0.3103    0.2759];
      %       [     0    1.0000    0.7586];
      [     0         0    0.1724];
      };
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/UZH_FPV_POSE_GT'
    save_path           = './output/RAL19/Demo/'
    %
    
    
    %% CDC & RAS 2019 related
    
  case 'Gazebo_ORB_CDC19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_120';
      }
    baseline_slam_list = {
      'ObsNumber_800';
      }
    
    %
    seq_list = {
      'loop';
      'long';
      'square';
      'zigzag';
      'infinite';
      'two_circle';
      };
    seq_duration = [
      40;
      50;
      105;
      125;
      245;
      200;
      ];
    
    lmk_number_list = [60, 80, 100, 120];
    %
    baseline_number_list = [800];
    baseline_taken_index = [1];
    
    round_num = 1;
    step_length = int32(0); %
    
    track_loss_ratio = [0.9 0.98]; % [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    % NOTE
    seq_start_time = [
      1;
      ];
    
    baseline_num = 1; % 2;
    baseline_orb = 1; % 2;
    
    %     data_dir  = '/mnt/DATA/tmp/ClosedNav_v4/';
    %     data_dir = '/media/yipuzhao/1399F8643500EDCD/ClosedNav_v4/';
    data_dir = '/media/yipuzhao/651A6DA035A51611/Exp_ClosedLoop/Simulation/laptop/';
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'Lazy-ORB';
      %       'MH';
      'Lazy-GF-ORB';
      %       'Comb';
      };
    
    marker_styl = {
      '--o';
      %       ':s';
      ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      };
    marker_color = {
      [0 0 1];
      %       [1 0 0];
      %       [1 0 1];
      %       [0 1 1];
      %       [0 1 0];
      [0 0 0];
      %       [0.3 0.1 0.5];
      };
    
    table_index = [1 2]; % [1 1 1 1]; % [2 2 2 2 2 2 2]; % [2 2 3];
    
    %
    %     ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/RAS19/Gazebo/'
    %
    
    
  case 'Gazebo_Baseline_CDC19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_120';
      }
    baseline_slam_list = {
      'ObsNumber_120';
      'ObsNumber_240';
      'ObsNumber_600';
      'ObsNumber_1200';
      }
    
    %
    seq_list = {
      'loop';
      'long';
      'square';
      'zigzag';
      'infinite';
      'two_circle';
      };
    seq_duration = [
      40;
      50;
      105;
      125;
      245;
      200;
      ];
    
    lmk_number_list = [60, 80, 100, 120];
    %
    baseline_number_list = [120, 240, 600, 1200];
    baseline_taken_index = [3];
    
    round_num = 1;
    step_length = int32(0); %
    
    track_loss_ratio = [0.9 0.98]; % [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    % NOTE
    seq_start_time = [
      1;
      ];
    
    baseline_num = 2; % 3; % 1; %
    baseline_orb = 0; % 1; % 2; %
    
    %     data_dir  = '/mnt/DATA/tmp/ClosedNav_v4/';
    % data_dir = '/media/yipuzhao/1399F8643500EDCD/ClosedNav_v4/';
    data_dir = '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_CDC19/gazebo_simulation/desktop/ClosedNav_latency/';
    
    pipeline_type = {
      'vo';
      'vo';
      %       'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'Lazy-ORB';
      %       'MH';
      'Lazy-GF-ORB';
      %       'Comb';
      %       'MSC';
      %       'VINS';
      %       'SVO';
      };
    
    marker_styl = {
      '--o';
      ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      %       ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      %       [1 0 1];
      %       [0 1 1];
      %       [0 1 0];
      %       [0 0 0];
      %       [0.3 0.1 0.5];
      };
    
    table_index = [1 3]; % [1 1 1 1]; % [1 1 3]; %
    
    %
    %     ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/RAS19/Gazebo/'
    %
    
    
  case 'TSRB_RGBD_RAS19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      }
    baseline_slam_list = {
      'ObsNumber_800';
      }
    
    %
    seq_list = {
      '2019-04-04-17-17-25_RGBD';
      };
    seq_duration = [
      400;
      ];
    
    lmk_number_list = [100, 130, 160, 200]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [800]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1];
    
    round_num = 3;
    step_length = int32(0); %
    
    track_loss_ratio = [0.9 0.98]; % [0.3 0.98];
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    % NOTE
    seq_start_time = [
      1;
      ];
    
    baseline_num = 1;
    baseline_orb = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/ORB_RGBD/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Lmk800/GF_RGBD/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB';
      %       'MH';
      'GF';
      %       'Comb';
      };
    
    marker_styl = {
      '--o';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [0 1 0];
      [0 0 0];
      [0.3 0.1 0.5];
      };
    
    table_index = [1 1]; % [2 2 2 2 2 2 2]; % [2 2 3];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/RAS19/TSRB/'
    %
    
    
  case 'TSRB_Stereo_RAS19_Desktop'
    %
    plot3DTrack = 1;
    fps = 30;
    gf_slam_list = {
      'ObsNumber_100';
      'ObsNumber_130';
      'ObsNumber_160';
      'ObsNumber_200';
      'ObsNumber_800';
      }
    baseline_slam_list = {
      'ObsNumber_800';
      }
    
    %
    seq_list = {
      '2019-02-08-17-16-08';
      '2019-05-03-17-48-01';
      '2019-05-07-19-46-48';
      };
    seq_duration = [
      530;
      530;
      1170;
      ];
    
    lmk_number_list = [100, 130, 160, 200, 800]; % [60, 80, 100, 130, 160, 200]; %
    %
    baseline_number_list = [800]; % [25 100 150 200 300 400 600 800 1000 1500 2000]; %
    baseline_taken_index = [1];
    
    round_num = 3;
    step_length = int32(0); %
    
    track_loss_ratio = [0.7 0.98]; % [0.4 0.98]; %
    valid_by_duration = true;
    
    sensor_type = 'stereo';
    rel_interval_list = [10];  % [20]; %  [3, 5, 10]; %
    benchmark_type = 'KITTI';
    
    % NOTE
    seq_start_time = [
      1;
      1;
      1;
      ];
    
    baseline_num = 1;
    baseline_orb = 1;
    
    slam_path_list  = {
      %
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/ORB2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/Lmk_800/ORB2_Stereo_MapHash_v2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/Lmk_800/ORB2_Stereo_GF_v2/';
      %       %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/Lmk_800/ORB2_Stereo_GF_gpu/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/Lmk_800/ORB2_Stereo_Comb_v2/';
      %       %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_desktop/Lmk_800/ORB2_Stereo_Comb_gpu/';
      %
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/ORB2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/Lmk_800/ORB2_Stereo_MapHash_v2/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/Lmk_800/ORB2_Stereo_GF_v2/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/Lmk_800/ORB2_Stereo_GF_gpu/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/Lmk_800/ORB2_Stereo_Comb_v2/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_RAS19/Map_Reusing/Turtlebot_laptop/Lmk_800/ORB2_Stereo_Comb_gpu/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      'vo';
      %       'vo';
      };
    
    legend_arr = {
      'ORB';
      'MIH-x/32';
      'GF';
      %       'GF-gpu';
      'MIH-x/32 + GF';
      %       'Comb-gpu';
      };
    
    marker_styl = {
      '--o';
      ':s';
      ':s';
      ':s';
      ':s';
      ':s';
      %       ':s';
      };
    marker_color = {
      [0 0 1];
      [1 0 0];
      [1 0 1];
      [0 1 1];
      [0 1 0];
      [0 0 0];
      %       [0.3 0.1 0.5];
      };
    
    table_index = [1 5 3 3 3 3]; % [2 2 2 2 2 2 2]; % [2 2 3];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/Oxford_Robocar_POSE_GT'
    save_path           = './output/RAS19/TSRB/'
    %
    
    
    %% Slow-mo related
    
  case 'TUM_VI_SlowMo'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      }
    baseline_slam_list = {
      'ObsNumber_1000';
      }
    
    round_num = 1;
    maxNormTrans = 9999999;
    
    %
    seq_list = {
      'corridor1_512_16';
      'corridor2_512_16';
      'corridor3_512_16';
      'corridor4_512_16';
      'corridor5_512_16';
      %
      'magistrale1_512_16';
      'magistrale2_512_16';
      'magistrale3_512_16';
      'magistrale4_512_16';
      'magistrale5_512_16';
      'magistrale6_512_16';
      %
      'outdoors1_512_16';
      'outdoors2_512_16';
      'outdoors3_512_16';
      'outdoors4_512_16';
      'outdoors5_512_16';
      'outdoors6_512_16';
      'outdoors7_512_16';
      'outdoors8_512_16';
      };
    seq_duration = [
      300;
      338;
      290;
      96;
      295;
      %
      772;
      540;
      485;
      624;
      446;
      574;
      %
      1281;
      922;
      844;
      699;
      887;
      1470;
      1122;
      810;
      ];
    
    lmk_number_list = []; %
    baseline_number_list = [1000];
    baseline_taken_index = [1];
    
    sensor_type = 'stereo';
    
    min_match_num = 100;
    track_type = {'AllFrame';};
    step_length = int32(200); %
    %     track_type = {'KeyFrame';};
    %     step_length = int32(15); %
    %     step_def = 9999;
    
    track_loss_ratio = [1.0 1.0];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;
      ];
    
    baseline_num = 1;
    baseline_orb = 1;
    
    slam_path_list  = {
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/vanilla_ORBv2_Stereo_Baseline/';
      %       '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/TUM_VI/delayed_ORBv2_Stereo_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/SlowMo/TUM_VI/ORBv2_Stereo_SlowMo/';
      };
    
    pipeline_type = {
      'vo';
      };
    
    legend_arr = {
      %       'ORB';
      %       'Lz-ORB';
      'SlowMo-ORB';
      };
    
    marker_styl = {
      '--o';
      };
    marker_color = {
      [0 0 1];
      };
    
    table_index = [1];
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/TUM_VI_POSE_GT'
    save_path           = './output/SlowMo/TUM_VI/'
    %
    
  case 'EuRoC_Propo_OnDevice_Euclid'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      %       'ObsNumber_60';
      'ObsNumber_80';
      'ObsNumber_100';
      'ObsNumber_120';
      'ObsNumber_140';
      'ObsNumber_160';
      %       'ObsNumber_200';
      %       'ObsNumber_250';
      %       'ObsNumber_300';
      }
    baseline_slam_list = {
      %       'ObsNumber_150';
      %       'ObsNumber_200';
      %       'ObsNumber_300';
      %       'ObsNumber_400';
      %       'ObsNumber_600';
      'ObsNumber_800';
      %       'ObsNumber_1000';
      %       'ObsNumber_1500';
      %       'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [80, 100, 120, 140, 160]; % [100]; % [100, 150, 200, 250, 300]; % [1500]; % [30 40 60 80 100 120 160 200 250 300]; % [30 40 60 80 100 120 160 200]; % [ 80 100 120 ]; %
    baseline_number_list = [800]; % [90 125 170 220 255 325 390]; %
    baseline_taken_index = [1]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    baseline_num = 3;
    baseline_orb = 3;
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Euclid/ORBv1_Baseline_lvl3_fac2/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Euclid_Test/ORBv1_Baseline_slow_v2/';
      '/mnt/DATA/DropboxContainer/Dropbox/PhD/Projects/Visual_SLAM/Euclid_Test/Lmk_800/ORBv1_info_measErr_v2/';
      };
    
    pipeline_type = {
      'vo';
      'vo';
      'vo';
      'vo';
      };
    
    legend_arr = {
      'ORB-l8-Desktop';
      'ORB-l3-Euclid';
      'ORB-l8-Euclid';
      'GF-l8-Euclid';
      };
    
    marker_styl = {
      '--o';
      '--o';
      '--o';
      '--o';
      };
    marker_color = {
      [0 0 1];
      [0 1 0];
      [1 0 0];
      [0 0 0];
      };
    
    table_index = [1 1 1 3]; % [5 5 5 3]; %
    
    %
    ref_path            = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    save_path           = './output/SlowMo/Euclid/'
    %
    
    
    
    %% Tightly-coupled VINS Related
    
  case 'EuRoC_VIN'
    %
    plot3DTrack = 1;
    fps = 20;
    gf_slam_list = {
      %       'ObsNumber_200';
      'LmkNumber_400';
      'LmkNumber_600';
      'LmkNumber_800';
      'LmkNumber_1000';
      'LmkNumber_1500';
      'LmkNumber_2000';
      };
    baseline_slam_list = {
      'ObsNumber_400';
      'ObsNumber_600';
      'ObsNumber_800';
      'ObsNumber_1000';
      'ObsNumber_1500';
      'ObsNumber_2000';
      }
    
    %
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
    seq_duration = [
      182;
      150;
      132;
      99;
      111;
      143;
      84;
      105;
      112;
      115;
      115;
      ];
    
    lmk_number_list = [400, 600, 800, 1000, 1500, 2000]; % [60, 80, 100, 130, 160, 200]; %
    baseline_number_list = [400, 600, 800, 1000, 1500, 2000]; %
    baseline_taken_index = [1]; % [1, 2, 3, 5]; % [6]; % [ 6, 7 ];
    
    step_length = int32(0); %
    
    track_loss_ratio = [0.3 0.98]; % [0.5 0.98];
    
    % NOTE
    % for better comparison between subset and full optimization,
    % remove beginning 5 seconds that are not properly initialzied (most
    % likely due to subset selection in pose optimization)
    %     ln_head = 5*fps;
    %     seq_start_time = [
    %       30;
    %       30;
    %       15;
    %       15;
    %       15;
    %       5;
    %       %       5;
    %       %       5;
    %       5;
    %       5;
    %       %       5;
    %       ];
    seq_start_time = [
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      5;
      ];
    
    baseline_num = 1;
    baseline_orb = 1;
    
    slam_path_list  = {
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/EuRoC/ORBv1_Baseline/';
      '/mnt/DATA/Dropbox/PhD/Projects/Visual_Inertial_Navigation/Experimental_VIN/VINSORB_win10_RT_new/';
      };
    
    pipeline_type = {
      'vo';
      'vins';
      };
    
    legend_arr = {'Mono-ORB'; 'VIN-ORB'; };
    
    marker_styl = {
      '--o';
      '--+';
      '--*';
      '--d';
      '--d';
      ':s';
      ':x';
      ':x';
      };
    marker_color = {
      [0 0 1];
      [1 0 1];
      [0 1 1];
      [1 0.84 0];
      [0.49 0.18 0.56];
      [0 0 0];
      [1 0 0];
      [0 1 0];
      };
    
    table_index = [1 1];
    
    %
    ref_path        = '/home/yipuzhao/ros_workspace/package_dir/ORB_Data/EuRoC_POSE_GT'
    %     save_path       = './output/VIN/win10_fix_offset/'
    save_path       = './output/VIN/win10_RT/'
    
    
  otherwise
    disp 'unknown benchmark name!'
    return ;
end