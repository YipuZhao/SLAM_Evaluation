function [logStruct] = loadLogDSO(log_path, rn, seq_idx, logStruct, ln_head)

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

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_dso = cell2mat(textscan(fid, '%f %f %f', 'HeaderLines', ln_head));
  else
    log_dso = cell2mat(textscan(fid, '%f %f %f'));
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

% only use normal frames
[count_bar, time_bar] = hist(log_dso(:, 3), 30);

lmin_flg = islocalmin(count_bar);
for i=10:20
  if lmin_flg(i) == true
    break ;
  end
end

valid_idx = log_dso(:, 3) < time_bar(i);
fprintf('isolate %d logs for normal frame from in total %d logs!\n', ...
  sum(valid_idx), size(log_dso, 1));

logStruct.timeStamp{rn}     = log_dso(valid_idx, 1);
%
logStruct.timeInitTrack{rn} = log_dso(valid_idx, 2) * 1000;
logStruct.timeRefTrack{rn}  = log_dso(valid_idx, 3) * 1000;

logStruct.timeTotal{rn}     = logStruct.timeRefTrack{rn};
logStruct.timeDirect{rn}    = logStruct.timeTotal{rn};

end