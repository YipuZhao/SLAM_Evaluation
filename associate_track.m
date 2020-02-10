function [asso_dat_2_ref] = associate_track(track_dat, track_ref, asso_idx, asso_thres, step_def)
%%
if isempty(track_dat) || isempty(track_ref)
  asso_dat_2_ref = [];
  return ;
end

if nargin < 5
  step_def = 600;
end

asso_dat_2_ref = int32(zeros(size(track_dat, 1), 1));

for pn=1:size(track_dat, 1)
  if pn == 1
    pn_ref = 0;
    pn_rng = size(track_ref, 1);
  end
  
  [tmp_val, tmp_idx] = min(...
    abs( track_ref(pn_ref+1 : min(size(track_ref, 1), pn_ref+pn_rng), asso_idx) - ...
    track_dat(pn, asso_idx) ) ...
    );
  if tmp_val < asso_thres
    asso_dat_2_ref(pn) = int32(tmp_idx + pn_ref);
    %
    pn_rng = step_def;
    pn_ref = max(0, round(asso_dat_2_ref(pn) - pn_rng / 2));
  end
  
end

%% TEST
% test_dat_2_ref = int32(zeros(size(track_dat, 1), 1));
% for pn=1:size(track_dat, 1)
%     [tmp_val, tmp_idx] = min(abs(track_ref(:,asso_idx) - track_dat(pn,asso_idx)));
%     if tmp_val < asso_thres
%         test_dat_2_ref(pn) = tmp_idx;
%     end
% end
% 
% isequal(asso_dat_2_ref, test_dat_2_ref)

end