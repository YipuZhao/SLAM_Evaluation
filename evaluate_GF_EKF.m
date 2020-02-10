clear all
close all

% addpath('/home/peterzhao/SDK/aboxplot');
addpath('~/SDK/altmany-export_fig');
addpath('~/Codes/VSLAM/GF_EKF_SLAM/ExperimentalResults');

%%

do_viz = 1;

step_length = 10; %1 % 0; %
min_match_num = 10 % 200
seg_length = 1000000; % 150 % 800 %
fps = 10;
max_asso_val = 0.03;
rel_interval = 3; % [1, 3, 5, 10];

FIG_FORMAT = '.png'
FRAME_NUM = 300%140%100%120%
REPEAT_NUM = 10%15

lmkSelectMethd = {'StateSpace_Sum_GF'; 'StateSpace_Min_GF'; 'GF_3'; 'INFOGAIN'; 'COV RATIO'; 'ALL'; 'RANDOM'};
stdLmkObsErrStr = {'stdErr=0.5'; 'stdErr=1.5'; 'stdErr=2.5'; };
stdLmkObsErr = [0.5, 1.5, 2.5]; % [1.0, 2.0]; %
lmkSelectNum = [4, 5, 6, 8, 10, 15, 20];

err_type_list = {'rms';};

load('Simulation_scene1_StateSpace.mat');

for pn = 1:length(stdLmkObsErr)
  %
  for ln=1:length(lmkSelectMethd)
    tErr_eval{ln} = [];
    rErr_eval{ln} = [];
    tCost_eval{ln} = [];
  end
  
  for fn = 1:length(lmkSelectNum)
    %
    for ln = 1:length(lmkSelectMethd)
      %
      eval_res_tmp = parseResultBuf(res_buf, pn, fn, ln, REPEAT_NUM);
%       legend_arr{ln} = eval_res_tmp.lmk_sel_md
      
      tErr_tmp = [];
      rErr_tmp = [];
      for rn = 1:REPEAT_NUM
        track_dat(:,:) = eval_res_tmp.poseRec(rn, :, [1:4, 6:8, 5]);
        track_ref(:,:) = eval_res_tmp.poseGT(rn, :, [1:4, 6:8, 5]);
        
        %% associate the data to the model quat with timestamp
        asso_dat_2_ref = associate_track(track_dat, track_ref, 1, max_asso_val);
        
        %% perform evaluation per part
        [abs_drift, abs_orient, rel_drift, rel_orient, track_loss_rate, track_fit] = ...
          getErrorMetric_align(track_dat, track_ref, asso_dat_2_ref, ...
          1, min_match_num, step_length, fps, rel_interval, false, FRAME_NUM / fps);
        
        err_rms_abs_drift = sqrt(sum(abs_drift(:,2) .* abs_drift(:,2)) / length(abs_drift(:,2)));
        tErr_tmp = [tErr_tmp; err_rms_abs_drift];
        
        err_rms_abs_orient = sqrt(sum(abs_orient(:,2) .* abs_orient(:,2)) / length(abs_orient(:,2)));
        rErr_tmp = [rErr_tmp; err_rms_abs_orient];
      end
      
      %
      tErr_eval{ln} = cat(2, tErr_eval{ln}, tErr_tmp);
      rErr_eval{ln} = cat(2, rErr_eval{ln}, rErr_tmp);
      
    end
  end
  
  tErr_summ = [];
  rErr_summ = [];
  tCost_summ = [];
  for ln = 1:length(lmkSelectMethd)
    tErr_summ = cat(1, tErr_summ, reshape(tErr_eval{ln}, [1 size(tErr_eval{ln})]));
    rErr_summ = cat(1, rErr_summ, reshape(rErr_eval{ln}, [1 size(rErr_eval{ln})]));
    tCost_summ = cat(1, tCost_summ, reshape(tCost_eval{ln}, [1 size(tCost_eval{ln})]));
  end
  
  subplot(2, length(stdLmkObsErr), pn)
  aboxplot(tErr_summ, 'labels', lmkSelectNum, 'OutlierMarker', 'x', 'whisker', 100); % Advanced box plot
  legend(lmkSelectMethd);
  %         ylim([0 1.5]);
  ylim([0 5]);
  xlabel('Number of lmk selected');
  ylabel('L2 Error of Transition (m)');
  title(['Meas. noise std = ' num2str(stdLmkObsErr(pn), '%.01f') ' (pix)']);
  %
  subplot(2, length(stdLmkObsErr), pn+length(stdLmkObsErr))
  aboxplot(rErr_summ, 'labels', lmkSelectNum, 'OutlierMarker', 'x', 'whisker', 100); % Advanced box plot
  legend(lmkSelectMethd);
  %         ylim([0 10]);
  ylim([0 20]);
  xlabel('Number of lmk selected');
  ylabel('L2 Error of Axis Angle (deg)');
  title(['Meas. noise std = ' num2str(stdLmkObsErr(pn), '%.01f') ' (pix)']);
  %
  
end