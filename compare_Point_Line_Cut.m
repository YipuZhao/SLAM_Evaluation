clear all
close all

%%
addpath('/home/yipuzhao/SDK/aboxplot');
addpath('/home/yipuzhao/SDK/altmany-export_fig');

% set up parameters for each benchmark
benchMark =  'EuRoC_Point_Line_Cut' %  'Gazebo_Point_Line_Cut' %  
setParam
legend_arr = {'L-SLAM'; 'L-SLAM + cut'; 'PL-SLAM'; 'PL-SLAM + cut'; 'P-SLAM';};

gn = 1;
for sn = 1:length(seq_list) %
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %%
  for rn = 1:round_num
    %% Load Trajectory Files
    % load the point only slam track
    track_point = loadTrackTUM([point_slam_path '/Round' num2str(rn) '/' ...
      seq_idx '_' track_type{1} 'Trajectory.txt']);
    
    % load the line only slam track
    track_line = loadTrackTUM([line_slam_path '/Round' num2str(rn) '/' ...
      seq_idx '_' track_type{1} 'Trajectory.txt']);
    
    % load the line cut slam track
    track_lineCut = loadTrackTUM([lineCut_slam_path '/Round' num2str(rn) '/' ...
      seq_idx '_' track_type{1} 'Trajectory.txt']);
    
    % load the point & line slam track
    track_pointline = loadTrackTUM([pointline_slam_path '/Round' num2str(rn) '/' ...
      seq_idx '_' track_type{1} 'Trajectory.txt']);
    
    % load the point & line cut slam track
    track_pointlineCut = loadTrackTUM([pointlineCut_slam_path '/Round' num2str(rn) '/' ...
      seq_idx '_' track_type{1} 'Trajectory.txt']);
    
    % load the ground truth track
    track_ref = loadTrackTUM([ref_path '/' seq_idx '_tum.txt'], 0);
    
    %% associate the data to the model quat with timestamp
    asso_point_2_ref        = associate_track(track_point, track_ref, 1, max_asso_val);
    asso_line_2_ref         = associate_track(track_line, track_ref, 1, max_asso_val);
    asso_lineCut_2_ref      = associate_track(track_lineCut, track_ref, 1, max_asso_val);
    asso_pointline_2_ref    = associate_track(track_pointline, track_ref, 1, max_asso_val);
    asso_pointlineCut_2_ref = associate_track(track_pointlineCut, track_ref, 1, max_asso_val);
    
    %% Compute evaluation metrics
    % Point
    [err_point{gn}.seq{sn}.abs_drift{rn}, err_point{gn}.seq{sn}.abs_orient{rn}, ...
      err_point{gn}.seq{sn}.term_drift{rn}, err_point{gn}.seq{sn}.term_orient{rn}, ...
      err_point{gn}.seq{sn}.rel_drift{rn}, err_point{gn}.seq{sn}.rel_orient{rn}, ...
      err_point{gn}.seq{sn}.track_loss_rate(rn), err_point{gn}.seq{sn}.track_fit{rn}] = ...
      getErrorMetric_align(track_point, track_ref, asso_point_2_ref, ...
      1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
    
    % Line
    [err_line{gn}.seq{sn}.abs_drift{rn}, err_line{gn}.seq{sn}.abs_orient{rn}, ...
      err_line{gn}.seq{sn}.term_drift{rn}, err_line{gn}.seq{sn}.term_orient{rn}, ...
      err_line{gn}.seq{sn}.rel_drift{rn}, err_line{gn}.seq{sn}.rel_orient{rn}, ...
      err_line{gn}.seq{sn}.track_loss_rate(rn), err_line{gn}.seq{sn}.track_fit{rn}] = ...
      getErrorMetric_align(track_line, track_ref, asso_line_2_ref, ...
      1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
    
    % LineCut
    [err_lineCut{gn}.seq{sn}.abs_drift{rn}, err_lineCut{gn}.seq{sn}.abs_orient{rn}, ...
      err_lineCut{gn}.seq{sn}.term_drift{rn}, err_lineCut{gn}.seq{sn}.term_orient{rn}, ...
      err_lineCut{gn}.seq{sn}.rel_drift{rn}, err_lineCut{gn}.seq{sn}.rel_orient{rn}, ...
      err_lineCut{gn}.seq{sn}.track_loss_rate(rn), err_lineCut{gn}.seq{sn}.track_fit{rn}] = ...
      getErrorMetric_align(track_lineCut, track_ref, asso_lineCut_2_ref, ...
      1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
    
    % Point & Line
    [err_pointline{gn}.seq{sn}.abs_drift{rn}, err_pointline{gn}.seq{sn}.abs_orient{rn}, ...
      err_pointline{gn}.seq{sn}.term_drift{rn}, err_pointline{gn}.seq{sn}.term_orient{rn}, ...
      err_pointline{gn}.seq{sn}.rel_drift{rn}, err_pointline{gn}.seq{sn}.rel_orient{rn}, ...
      err_pointline{gn}.seq{sn}.track_loss_rate(rn), err_pointline{gn}.seq{sn}.track_fit{rn}] = ...
      getErrorMetric_align(track_pointline, track_ref, asso_pointline_2_ref, ...
      1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
    
    % Point & Line Cut
    [err_pointlineCut{gn}.seq{sn}.abs_drift{rn}, err_pointlineCut{gn}.seq{sn}.abs_orient{rn}, ...
      err_pointlineCut{gn}.seq{sn}.term_drift{rn}, err_pointlineCut{gn}.seq{sn}.term_orient{rn}, ...
      err_pointlineCut{gn}.seq{sn}.rel_drift{rn}, err_pointlineCut{gn}.seq{sn}.rel_orient{rn}, ...
      err_pointlineCut{gn}.seq{sn}.track_loss_rate(rn), err_pointlineCut{gn}.seq{sn}.track_fit{rn}] = ...
      getErrorMetric_align(track_pointlineCut, track_ref, asso_pointlineCut_2_ref, ...
      1, min_match_num, step_length, fps, rel_interval_list(1), 0, seq_duration(sn));
    
  end
  
  %% Plot Comparison Illustration
  if do_viz
    warning('off','all')
    
    %     h=figure();
    h=figure('Visible','Off');
    boxFigure_5_Methods(sn, gf_slam_list, track_loss_ratio(1), round_num, ...
      err_type_list{1}, err_line, err_lineCut, err_pointline, ...
      err_pointlineCut, err_point, legend_arr, style);
    
    warning('on','all')
    %
    set(h, 'Units', 'normalized', 'Position', [0,0,1,1]);
    %     mkdir([save_path '/' seq_idx '/']);
    export_fig(h, [save_path '/BoxFig_' seq_idx '_' track_type{1} '.png'], '-r 200');
    close(h)
  end
  
end
