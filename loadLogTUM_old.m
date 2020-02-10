function [logStruct] = loadLogTUM_old(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  logStruct.lmkMatched{rn} = [];
  logStruct.lmkSelected{rn} = [];
  logStruct.lmkInlier{rn} = [];
  logStruct.lmkBA{rn} = [];
  %
  logStruct.timeOrbExtr{rn} = [];
  logStruct.timeInitTrack{rn} = [];
  logStruct.timeRefTrack{rn} = [];
  logStruct.timeMatch{rn} = [];
  logStruct.timeSelect{rn} = [];
  logStruct.timeSelect_Mat{rn} = [];
  logStruct.timeSelect_Grd{rn} = [];
  logStruct.timeOpt{rn} = [];
  logStruct.timeMatPredict{rn} = [];
  logStruct.timeMatOnline{rn} = [];
  %
  logStruct.timeTotal{rn} = [];
  return ;
end

logStruct.timeStamp{rn}     = log_orb_slam(:, 1);
%
logStruct.lmkMatched{rn}    = log_orb_slam(:, 13);
logStruct.lmkBA{rn}         = log_orb_slam(:, 14);
logStruct.lmkSelected{rn}   = log_orb_slam(:, 15);
logStruct.lmkInlier{rn}     = log_orb_slam(:, 16);
%
logStruct.timeOrbExtr{rn}   = log_orb_slam(:, 2) * 1000;
logStruct.timeInitTrack{rn} = log_orb_slam(:, 3) * 1000;
logStruct.timeRefTrack{rn}  = log_orb_slam(:, 4) * 1000;
logStruct.timeMatch{rn}     = log_orb_slam(:, 5) * 1000;
logStruct.timeSelect{rn}    = log_orb_slam(:, 6) * 1000;
logStruct.timeSelect_Mat{rn}= log_orb_slam(:, 7) * 1000;
logStruct.timeSelect_Grd{rn}= log_orb_slam(:, 8) * 1000;
logStruct.timeOpt{rn}       = log_orb_slam(:, 9) * 1000;

logStruct.timeMatPredict{rn} = log_orb_slam(:, 11) * 1000;
logStruct.timeMatOnline{rn} = log_orb_slam(:, 12) * 1000;

logStruct.timeTotal{rn}     = logStruct.timeOrbExtr{rn} + logStruct.timeInitTrack{rn} + logStruct.timeRefTrack{rn};

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end