clear all
close all

%%

% set up parameters for each benchmark
benchMark =  'KITTI_RAL18_Debug' %
setParam

for sn = 1:length(seq_list)
  
  seq_idx = seq_list{sn};
  disp(['Sequence --------------------- ' seq_idx ' ---------------------'])
  
  %% Load Trajectory Files
  % load the ground truth track
  track_ref = loadTrackTUM([ref_path '/' seq_idx '_cam0.txt'], 0, maxNormTrans);
  
  %% grab the baseline results
  tn = 1
  for gn=1:length(baseline_slam_list)
    %%
    for rn = 1:round_num
      disp(['=================== Round ' num2str(rn) ' ==================='])
      
      %%
      % Load Track Files
      track{tn} = loadTrackTUM([slam_path_list{tn} baseline_slam_list{gn} '_Round' num2str(rn) '/' ...
        seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
      
      tic
      % associate the data to the model quat with timestamp
      asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
      toc
      
      tic
      % Compute evaluation metrics
      [err_struct_mat.abs_drift{rn}, err_struct_mat.abs_orient{rn}, ...
        err_struct_mat.term_drift{rn}, err_struct_mat.term_orient{rn}, ...
        err_struct_mat.rel_drift{rn}, err_struct_mat.rel_orient{rn}, ...
        err_struct_mat.track_loss_rate(rn), err_struct_mat.track_fit{rn}, ...
        err_struct_mat.scale_fac(rn)] = ...
        getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
        asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
        rm_iso_track, seq_duration(sn), seq_start_time(sn), false);
      toc
      %   err_struct_mat
      
      tic
      if isempty(track{tn}) || isempty(track_ref)
        err_struct_mex.scale_fac(rn) = 1.0;
        err_struct_mex.abs_drift{rn} = [];
        err_struct_mex.abs_orient{rn} = [];
        err_struct_mex.term_drift{rn} = [];
        err_struct_mex.term_orient{rn} = [];
        err_struct_mex.rel_drift{rn} = [];
        err_struct_mex.rel_orient{rn} = [];
        err_struct_mex.track_loss_rate(rn) = 1.0;
        err_struct_mex.track_fit{rn} = [];
      else
        [err_struct_mex.abs_drift{rn}, err_struct_mex.abs_orient{rn}, ...
          err_struct_mex.term_drift{rn}, err_struct_mex.term_orient{rn}, ...
          err_struct_mex.rel_drift{rn}, err_struct_mex.rel_orient{rn}, ...
          err_struct_mex.track_loss_rate(rn), err_struct_mex.track_fit{rn}, ...
          err_struct_mat.scale_fac(rn)] = ...
          getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          rm_iso_track, seq_duration(sn), seq_start_time(sn), false);
      end
      toc
      %   err_struct_mex
      
      %%
      %   isequaln(err_struct_mat, err_struct_mex)
      
      assertWithRelTol(err_struct_mex.abs_drift{rn}, err_struct_mat.abs_drift{rn}, ...
        'abs_drift: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.abs_orient{rn}, err_struct_mat.abs_orient{rn}, ...
        'abs_orient: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.term_drift{rn}, err_struct_mat.term_drift{rn}, ...
        'term_drift: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.term_orient{rn}, err_struct_mat.term_orient{rn}, ...
        'term_orient: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.rel_drift{rn}, err_struct_mat.rel_drift{rn}, ...
        'rel_drift: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.rel_orient{rn}, err_struct_mat.rel_orient{rn}, ...
        'rel_orient: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.track_loss_rate(rn), err_struct_mat.track_loss_rate(rn), ...
        'track_loss_rate: mex and matlab results do not match');
      
      
      assertWithRelTol(err_struct_mex.track_fit{rn}, err_struct_mat.track_fit{rn}, ...
        'track_fit: mex and matlab results do not match');
      
    end
  end
  
  %% grab the subset results
  for tn=2:length(slam_path_list)
    for gn=1:length(gf_slam_list)
      %%
      for rn = 1:round_num
        disp(['=================== Round ' num2str(rn) ' ==================='])
        
        %%
        % Load Track Files
        track{tn} = loadTrackTUM([slam_path_list{tn} gf_slam_list{gn} '_Round' num2str(rn) '/' ...
          seq_idx '_' track_type{1} 'Trajectory.txt'], seq_start_time(sn) * fps, maxNormTrans);
        
        tic
        % associate the data to the model quat with timestamp
        asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
        toc
        
        tic
        % Compute evaluation metrics
        [err_struct_mat.abs_drift{rn}, err_struct_mat.abs_orient{rn}, ...
          err_struct_mat.term_drift{rn}, err_struct_mat.term_orient{rn}, ...
          err_struct_mat.rel_drift{rn}, err_struct_mat.rel_orient{rn}, ...
          err_struct_mat.track_loss_rate(rn), err_struct_mat.track_fit{rn}, ...
          err_struct_mat.scale_fac(rn)] = ...
          getErrorMetric_align(track{tn}, track_ref, asso_track_2_ref{tn}, ...
          asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
          rm_iso_track, seq_duration(sn), seq_start_time(sn), false);
        toc
        %   err_struct_mat
        
        tic
        if isempty(track{tn}) || isempty(track_ref)
          err_struct_mat.scale_fac(rn) = 1.0;
          err_struct_mex.abs_drift{rn} = [];
          err_struct_mex.abs_orient{rn} = [];
          err_struct_mex.term_drift{rn} = [];
          err_struct_mex.term_orient{rn} = [];
          err_struct_mex.rel_drift{rn} = [];
          err_struct_mex.rel_orient{rn} = [];
          err_struct_mex.track_loss_rate(rn) = 1.0;
          err_struct_mex.track_fit{rn} = [];
        else
          %       asso_track_2_ref{tn}  = associate_track_mex(track{tn}, track_ref, 1, max_asso_val);
          asso_track_2_ref{tn}  = associate_track(track{tn}, track_ref, 1, max_asso_val);
          
          [err_struct_mex.abs_drift{rn}, err_struct_mex.abs_orient{rn}, ...
            err_struct_mex.term_drift{rn}, err_struct_mex.term_orient{rn}, ...
            err_struct_mex.rel_drift{rn}, err_struct_mex.rel_orient{rn}, ...
            err_struct_mex.track_loss_rate(rn), err_struct_mex.track_fit{rn}, ...
            err_struct_mat.scale_fac(rn)] = ...
            getErrorMetric_align_mex(track{tn}, track_ref, asso_track_2_ref{tn}, ...
            asso_idx, min_match_num, step_length, fps, rel_interval_list(1), benchmark_type, ...
            rm_iso_track, seq_duration(sn), seq_start_time(sn), false);
        end
        toc
        %   err_struct_mex
        
        %%
        %   isequaln(err_struct_mat, err_struct_mex)
        
        assertWithRelTol(err_struct_mex.abs_drift{rn}, err_struct_mat.abs_drift{rn}, ...
          'abs_drift: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.abs_orient{rn}, err_struct_mat.abs_orient{rn}, ...
          'abs_orient: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.term_drift{rn}, err_struct_mat.term_drift{rn}, ...
          'term_drift: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.term_orient{rn}, err_struct_mat.term_orient{rn}, ...
          'term_orient: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.rel_drift{rn}, err_struct_mat.rel_drift{rn}, ...
          'rel_drift: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.rel_orient{rn}, err_struct_mat.rel_orient{rn}, ...
          'rel_orient: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.track_loss_rate(rn), err_struct_mat.track_loss_rate(rn), ...
          'track_loss_rate: mex and matlab results do not match');
        
        
        assertWithRelTol(err_struct_mex.track_fit{rn}, err_struct_mat.track_fit{rn}, ...
          'track_fit: mex and matlab results do not match');
        
      end
    end
  end
  
  
end


function assertWithRelTol(actVal,expVal,varargin)
% Helper function to assert equality within a relative tolerance.
% Takes two values and an optional message and compares
% them within a relative tolerance of 0.01%.

relTol = 0.0001;
tf = abs(expVal - actVal) > relTol.*abs(expVal);
for i=1:size(tf, 2)
  assert(~any(tf(:, i)), varargin{:});
end

end

