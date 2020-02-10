function [logStruct] = loadLogVINSFusion_closeLoop(log_path, rn, logStruct, ln_head)

if nargin < 4
  ln_head = 0;
end

%
%
logStruct.timeOrbExtr{rn} = [];
logStruct.timeTrackMotion{rn} = [];
logStruct.timeTrackFrame{rn} = [];
logStruct.timeTrackMap{rn} = [];
logStruct.timeMapMatch{rn} = [];
logStruct.timeMapOpt{rn} = [];
logStruct.timeDirect{rn} = [];
logStruct.timeStereo{rn} = [];

logStruct.timeStamp{rn} = [];
logStruct.timeTotal{rn} = [];
logStruct.timeFeatExtr{rn} = [];
logStruct.timeTrack{rn} = [];
logStruct.timeWindowOpt{rn} = [];
% 
logStruct.numWindowPose{rn} = [];
logStruct.numWindowLmk{rn} = [];

fid = fopen(log_path, 'rt');
if fid ~= -1
  if ln_head > 0
    log_vins = cell2mat(textscan(fid, '%f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_vins = cell2mat(textscan(fid, '%f %f %f %f %f %f %f'));
  end
  fclose(fid);
else
  return ;
end

logStruct.timeStamp{rn}     = log_vins(:, 1);
%
logStruct.timeFeatExtr{rn}  = log_vins(:, 2) * 1000;
logStruct.timeTrack{rn}     = log_vins(:, 3) * 1000;
logStruct.timeWindowOpt{rn} = log_vins(:, 4) * 1000;
%
logStruct.numWindowPose{rn} = log_vins(:, 6);
logStruct.numWindowLmk{rn} = log_vins(:, 7);

% logStruct.timeTotal{rn}     = logStruct.timeFeatExtr{rn} + logStruct.timeTrack{rn};
logStruct.timeTotal{rn}     = logStruct.timeFeatExtr{rn} + logStruct.timeTrack{rn} + logStruct.timeWindowOpt{rn};
%
logStruct.timeDirect{rn}    = logStruct.timeTotal{rn};
logStruct.timeTotalBA{rn}   = logStruct.timeFeatExtr{rn} + logStruct.timeTrack{rn} + logStruct.timeWindowOpt{rn};

end