function printAverageTimeCost(log_orb_slam, seq_num, round_num, timeType)

arr_tmp  = [];

for sn = 1:seq_num
  
  if isempty(log_orb_slam{sn})
    continue;
  end
  
  for rn=1:round_num
    
    switch timeType
      case {'timeTrack'}
        if ~isempty(log_orb_slam{sn}.timeTrack{rn})
          arr_tmp = [arr_tmp; log_orb_slam{sn}.timeTrack{rn}];
        end
      case {'timeInl'}
        if ~isempty(log_orb_slam{sn}.timeInl{rn})
          arr_tmp = [arr_tmp; log_orb_slam{sn}.timeInl{rn}];
        end
      case {'timeObs'}
        if ~isempty(log_orb_slam{sn}.timeObs{rn})
          arr_tmp = [arr_tmp; log_orb_slam{sn}.timeObs{rn}];
        end
      case {'timeOpt'}
        if ~isempty(log_orb_slam{sn}.timeOpt{rn})
          arr_tmp = [arr_tmp; log_orb_slam{sn}.timeOpt{rn}];
        end
    end
    
  end
  
end

%
fprintf('& %.01f ', nanmean(arr_tmp))
% fprintf('& %.01f %.01f^2 ', nanmean(arr_tmp), nanstd(arr_tmp))
% fprintf('& %.01f ', nanmedian(arr_tmp))

end