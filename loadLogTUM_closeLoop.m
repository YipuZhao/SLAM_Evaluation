function [logStruct] = loadLogTUM_closeLoop(log_path, rn, logStruct, ln_head)

if nargin < 4
  ln_head = 0;
end

fid = fopen(log_path, 'rt');
if fid ~= -1
  if ln_head > 0
    log_orb_slam = cell2mat(textscan(fid, ...
      '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', ...
       'HeaderLines', ln_head));
  else
    log_orb_slam = cell2mat(textscan(fid, ...
      '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  logStruct.lmkInitTrack{rn} = [];
  logStruct.lmkMapTrack{rn} = [];
  logStruct.lmkMapLocal{rn} = [];
  logStruct.lmkBA{rn} = [];
  logStruct.lmkMapHash{rn} = [];
  %
  logStruct.timeOrbExtr{rn} = [];
  logStruct.timeTrackMotion{rn} = [];
  logStruct.timeTrackFrame{rn} = [];
  logStruct.timeTrackMap{rn} = [];
  logStruct.timeMapMatch{rn} = [];
  logStruct.timeMapSelect{rn} = [];
  logStruct.timeMapOpt{rn} = [];
  logStruct.timeMatPredict{rn} = [];
  logStruct.timeMatOnline{rn} = [];
  %
  logStruct.timeTotal{rn} = [];
  logStruct.timeDirect{rn} = [];
  return ;
end

logStruct.timeStamp{rn}         = log_orb_slam(:, 1);
%
logStruct.timeOrbExtr{rn}       = log_orb_slam(:, 2) * 1000;
logStruct.timeTrackMotion{rn}   = log_orb_slam(:, 3) * 1000;
logStruct.timeTrackFrame{rn}    = log_orb_slam(:, 4) * 1000;
logStruct.timeTrackMap{rn}      = log_orb_slam(:, 5) * 1000;
logStruct.timeMapMatch{rn}      = log_orb_slam(:, 6) * 1000;
logStruct.timeMapSelect{rn}     = log_orb_slam(:, 7) * 1000;
logStruct.timeMapOpt{rn}        = log_orb_slam(:, 8) * 1000;

logStruct.timeMatPredict{rn}    = log_orb_slam(:, 13) * 1000;
logStruct.timeMatOnline{rn}     = log_orb_slam(:, 14) * 1000;

logStruct.timeTotal{rn}         = logStruct.timeOrbExtr{rn} + ...
  logStruct.timeTrackMotion{rn} + logStruct.timeTrackFrame{rn} + logStruct.timeTrackMap{rn};
logStruct.timeDirect{rn} = [];
%
logStruct.lmkInitTrack{rn}      = log_orb_slam(:, 17);
logStruct.lmkMapTrack{rn}       = log_orb_slam(:, 19);
logStruct.lmkMapLocal{rn}       = log_orb_slam(:, 20);
logStruct.lmkBA{rn}             = log_orb_slam(:, 21);
logStruct.lmkMapHash{rn}        = log_orb_slam(:, 22);

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end