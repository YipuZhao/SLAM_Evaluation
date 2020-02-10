function [logStruct] = loadLogTUM_GoodBA_v2(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

logStruct.timeStampBack{rn} = [];
%
logStruct.timeBackEnd{rn}   = [];
%
logStruct.timeNewKeyFrame{rn} = [];
logStruct.timeMapCulling{rn} = [];
logStruct.timeMapTriangulate{rn} = [];
logStruct.timeSrhNeighbor{rn} = [];
logStruct.timeLocalBA{rn} = [];  %
%
logStruct.numPoseState{rn}  = [];
logStruct.numLmkState{rn}   = [];
%
logStruct.timePrediction{rn}    = [];
logStruct.timeInsertVertex{rn}  = [];
logStruct.timeJacobian{rn}      = [];
logStruct.timeQuery{rn}         = [];
logStruct.timeSchur{rn}         = [];
logStruct.timePermute{rn}       = [];
logStruct.timeCholesky{rn}      = [];
logStruct.timePostProc{rn}      = [];
logStruct.timeOptimization{rn}  = [];
logStruct.timeBudget{rn}        = [];

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log_Mapping.txt'], 'rt');
if fid ~= -1
  
  if ln_head > 0
    log_ = cell2mat(textscan(fid, ...
      '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_ = cell2mat(textscan(fid, ...
      '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));
  end
  
  fclose(fid);
else
  return ;
end

logStruct.timeStampBack{rn}     = log_(:, 1);
%
logStruct.timeNewKeyFrame{rn}   = log_(:, 2) * 1000;
logStruct.timeMapCulling{rn}    = log_(:, 3) * 1000;
logStruct.timeMapTriangulate{rn}= log_(:, 4) * 1000;
logStruct.timeSrhNeighbor{rn}   = log_(:, 5) * 1000;
logStruct.timeLocalBA{rn}       = log_(:, 6) * 1000;

logStruct.timeBackEnd{rn}         = logStruct.timeNewKeyFrame{rn} + ...
  logStruct.timeMapCulling{rn} + logStruct.timeMapTriangulate{rn} + ...
  logStruct.timeSrhNeighbor{rn} + logStruct.timeLocalBA{rn};

logStruct.timePrediction{rn}    = log_(:, 7) * 1000;
logStruct.timeInsertVertex{rn}  = log_(:, 8) * 1000;
logStruct.timeJacobian{rn}      = log_(:, 9) * 1000;
logStruct.timeQuery{rn}         = log_(:, 10) * 1000;
logStruct.timeSchur{rn}         = log_(:, 11) * 1000;
logStruct.timePermute{rn}       = log_(:, 12) * 1000;
logStruct.timeCholesky{rn}      = log_(:, 13) * 1000;
logStruct.timePostProc{rn}      = log_(:, 14) * 1000;
logStruct.timeOptimization{rn}  = log_(:, 15) * 1000;
%
logStruct.timeBudget{rn}        = log_(:, 16) * 1000;

% NOTE
% only free KF contributes to the state space;
% fixed ones serves as diagonal priors only
%
logStruct.numPoseState{rn}      = log_(:, 18) * 6;
logStruct.numLmkState{rn}       = log_(:, 19) * 3;

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end