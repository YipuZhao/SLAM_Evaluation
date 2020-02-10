function [logStruct] = loadLog_MSCKF(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

logStruct.timeStamp{rn}     = [];
%
logStruct.timeFrontEnd{rn}  = [];
logStruct.timeBackEnd{rn}   = [];
%
logStruct.numMeasur{rn}     = [];
logStruct.numPoseState{rn}  = [];
logStruct.numLmkState{rn}   = [];

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_ = cell2mat(textscan(fid, '%f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_ = cell2mat(textscan(fid, '%f %f %f %f %f'));
  end
  fclose(fid);
else
  return ;
end

logStruct.timeStamp{rn}     = log_(:, 1);
%
logStruct.timeFrontEnd{rn}  = log_(:, 2) * 1000;
logStruct.timeBackEnd{rn}   = log_(:, 3) * 1000;
%
logStruct.numMeasur{rn}     = log_(:, 4);
logStruct.numPoseState{rn}  = log_(:, 5);

end