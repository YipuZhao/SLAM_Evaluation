function [logStruct] = loadLogGF(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_LogGF.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  logStruct.timeMapMatch{rn} = [];
  logStruct.numLogDet{rn} = [];
  logStruct.lmkInitTrack{rn} = [];
  logStruct.lmkRefTrack{rn} = [];
  logStruct.lmkRefInlier{rn} = [];
  %
  return ;
end

valid_idx = find(log_orb_slam(:, 1) > 0);

logStruct.timeStamp{rn}         = log_orb_slam(valid_idx, 1);
%
logStruct.timeMapMatch{rn}      = log_orb_slam(valid_idx, 2) * 1000;
logStruct.numLogDet{rn}         = log_orb_slam(valid_idx, 3);
logStruct.lmkInitTrack{rn}      = log_orb_slam(valid_idx, 4);
logStruct.lmkRefTrack{rn}       = log_orb_slam(valid_idx, 5);
logStruct.lmkRefInlier{rn}      = log_orb_slam(valid_idx, 6);

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end