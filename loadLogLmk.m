function [logStruct] = loadLogLmk(log_path, logStruct, ln_head)

if nargin < 3
  ln_head = 0;
end

fid = fopen(log_path, 'rt');
if fid ~= -1
  if ln_head > 0
    log_lmk = cell2mat(textscan(fid, '%f %f', 'HeaderLines', ln_head));
  else
    log_lmk = cell2mat(textscan(fid, '%f %f'));
  end
  fclose(fid);
else
  
  logStruct.rec = [];
  return ;
end

logStruct.rec = log_lmk;
%
%% remove duplicate
orig_sz = size(logStruct.rec, 1);
logStruct.rec = logStruct.rec(orig_sz:-1:1, :);
[~, ind] = unique(logStruct.rec(:, 1), 'rows');
logStruct.rec = logStruct.rec(ind, :);

disp(['remove ' num2str(orig_sz - size(logStruct.rec, 1)) ' duplicates!'])

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end