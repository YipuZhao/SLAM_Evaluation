function [logStruct] = loadLogSVO(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

%
logStruct.timeOrbExtr{rn} = [];
logStruct.timeTrackMotion{rn} = [];
logStruct.timeTrackFrame{rn} = [];
logStruct.timeTrackMap{rn} = [];
logStruct.timeMapMatch{rn} = [];
logStruct.timeMapOpt{rn} = [];
logStruct.timeDirect{rn} = [];
logStruct.timeStereo{rn} = [];

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_svo = cell2mat(textscan(fid, '%f %f %f', 'HeaderLines', ln_head));
  else
    log_svo = cell2mat(textscan(fid, '%f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  %
  logStruct.timeInitTrack{rn} = [];
  logStruct.timeRefTrack{rn} = [];
  %
  logStruct.timeTotal{rn} = [];
  return ;
end

logStruct.timeStamp{rn}     = log_svo(:, 1);
%
logStruct.timeInitTrack{rn} = log_svo(:, 2) * 1000;
logStruct.timeRefTrack{rn}  = log_svo(:, 3) * 1000;

logStruct.timeTotal{rn}     = logStruct.timeRefTrack{rn};
logStruct.timeDirect{rn}    = logStruct.timeTotal{rn};

end