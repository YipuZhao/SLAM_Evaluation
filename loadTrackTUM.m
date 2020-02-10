function [track_dat] = loadTrackTUM( track_path, ln_head, maxNormTrans )

if nargin < 3
  %   maxNormTrans = 1.0;
  maxNormTrans = 100.0;
end

if nargin < 2
  ln_head = 1;
end


fid = fopen(track_path, 'rt');
if fid ~= -1
  %
  if ln_head > 0
    track_dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', ln_head));
  else
    track_dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
  end
  
  if isempty(track_dat)
    track_dat = [];
    return;
  end
  
  % get rid of records that are NaN
  track_dat = track_dat(~isnan(track_dat(:, 2)), :);
  if isempty(track_dat)
    track_dat = [];
    return;
  end
  
  % get rid of records that are numerically unstable
  %   normT = cellfun(@norm, num2cell(track_dat(2:end, 2:4) - track_dat(1:end-1, 2:4), 2));
  %   track_dat = [ track_dat(1, :); track_dat(normT < maxNormTrans, :) ];
  normT = cellfun(@norm, num2cell(track_dat(1:end, 2:4) - track_dat(1, 2:4), 2));
  track_dat = [ track_dat(1, :); track_dat(normT < maxNormTrans, :) ];
  
  fclose(fid);
  
else
  
  track_dat = [];
  
end

end