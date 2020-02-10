function [logStruct] = loadLogTUM_BA(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

logStruct.timeStamp{rn}     = [];
%
% logStruct.timeFrontEnd{rn}  = [];
logStruct.timeBackEnd{rn}   = [];
%
logStruct.timeNewKeyFrame{rn} = [];
logStruct.timeMapCulling{rn} = [];
logStruct.timeMapTriangulate{rn} = [];
logStruct.timeSrhNeighbor{rn} = [];
logStruct.timeLocalBA{rn} = [];  %
%
% logStruct.numMeasur{rn}     = [];
logStruct.numPoseState{rn}  = [];
logStruct.numLmkState{rn}   = [];

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log_Mapping.txt'], 'rt');
if fid ~= -1
%     if ln_head > 0
%       log_ = cell2mat(textscan(fid, '%f %f %f %f %f %f', 'HeaderLines', ln_head));
%     else
%       log_ = cell2mat(textscan(fid, '%f %f %f %f %f %f'));
%     end
  
  if ln_head > 0
    log_ = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_ = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f'));
  end
  
  fclose(fid);
else
  return ;
end

logStruct.timeStamp{rn}         = log_(:, 1);
%
logStruct.timeNewKeyFrame{rn}   = log_(:, 2) * 1000;
logStruct.timeMapCulling{rn}    = log_(:, 3) * 1000;
logStruct.timeMapTriangulate{rn}= log_(:, 4) * 1000;
logStruct.timeSrhNeighbor{rn}   = log_(:, 5) * 1000;
logStruct.timeLocalBA{rn}       = log_(:, 6) * 1000;

logStruct.timeBackEnd{rn}         = logStruct.timeNewKeyFrame{rn} + ...
  logStruct.timeMapCulling{rn} + logStruct.timeMapTriangulate{rn} + ...
  logStruct.timeSrhNeighbor{rn} + logStruct.timeLocalBA{rn};

% NOTE
% only free KF contributes to the state space;
% fixed ones serves as diagonal priors only
%
logStruct.numPoseState{rn}      = log_(:, 8) * 6;
logStruct.numLmkState{rn}       = log_(:, 9) * 3;

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end