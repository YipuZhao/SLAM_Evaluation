function [logStruct] = loadLogVINS(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  logStruct.lmkTrackMotion{rn} = [];
  logStruct.lmkTrackFrame{rn} = [];
  logStruct.lmkTrackIMU{rn} = [];
  logStruct.lmkTrackMap{rn} = [];
  logStruct.lmkBA{rn} = [];
  %
  logStruct.timeOrbExtr{rn} = [];
  logStruct.timeTrackMotion{rn} = [];
  logStruct.timeTrackFrame{rn} = [];
  logStruct.timeTrackIMU{rn} = [];
  logStruct.timeTrackMap{rn} = [];
  logStruct.timeTrackMapIMU{rn} = [];
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
logStruct.timeTrackIMU{rn}      = log_orb_slam(:, 5) * 1000;
logStruct.timeTrackMap{rn}      = log_orb_slam(:, 6) * 1000;
logStruct.timeTrackMapIMU{rn}   = log_orb_slam(:, 7) * 1000;

logStruct.timeTotal{rn}         = logStruct.timeOrbExtr{rn} + ...
  logStruct.timeTrackMotion{rn} + logStruct.timeTrackFrame{rn} + logStruct.timeTrackIMU{rn} + ...
  logStruct.timeTrackMap{rn} + logStruct.timeTrackMapIMU{rn};
logStruct.timeDirect{rn} = [];

%
logStruct.lmkTrackMotion{rn}     = log_orb_slam(:, 8);
logStruct.lmkTrackFrame{rn}      = log_orb_slam(:, 9);
logStruct.lmkTrackIMU{rn}        = log_orb_slam(:, 10);
logStruct.lmkTrackMap{rn}        = log_orb_slam(:, 11);
logStruct.lmkBA{rn}              = log_orb_slam(:, 12);

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end