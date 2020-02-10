function [logStruct] = loadLogVINSFusion(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

%
logStruct.timeStamp{rn} = [];
logStruct.timeTotal{rn} = [];
logStruct.timeFeatExtr{rn} = [];
logStruct.timeTrack{rn} = [];
logStruct.timeWindowOpt{rn} = [];
% 
logStruct.numKF{rn} = [];
logStruct.numPoint{rn} = [];

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
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
logStruct.numKF{rn}         = log_vins(:, 6);
logStruct.numPoint{rn}      = log_vins(:, 7);

logStruct.timeTotal{rn}     = logStruct.timeFeatExtr{rn} + logStruct.timeTrack{rn};
logStruct.timeDirect{rn}    = logStruct.timeTotal{rn};
logStruct.timeTotalBA{rn}   = logStruct.timeFeatExtr{rn} + logStruct.timeTrack{rn} + logStruct.timeWindowOpt{rn};

end