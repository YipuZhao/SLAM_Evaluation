function [logStruct] = loadLogTUM_hash_stereo(log_path, rn, seq_idx, logStruct, ln_head)

if nargin < 5
  ln_head = 0;
end

fid = fopen([log_path '_Round' num2str(rn) '/' seq_idx '_Log.txt'], 'rt');
if fid ~= -1
  if ln_head > 0
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', ...
      'HeaderLines', ln_head));
  else
    log_orb_slam = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));
  end
  fclose(fid);
else
  
  logStruct.timeStamp{rn} = [];
  logStruct.lmkTrackMotion{rn} = [];
  logStruct.lmkTrackFrame{rn} = [];
  logStruct.lmkTrackMap{rn} = [];
  logStruct.lmkLocalMap{rn} = [];
  logStruct.lmkBA{rn} = [];
  logStruct.lmkHashDynm{rn} = [];
  %
  logStruct.timeOrbExtr{rn} = [];
  logStruct.timeTrackMotion{rn} = [];
  logStruct.timeTrackFrame{rn} = [];
  logStruct.timeTrackMap{rn} = [];
  logStruct.timeMapMatch{rn} = [];
  logStruct.timeMapSelect{rn} = [];
  logStruct.timeMapOpt{rn} = [];
  %
  logStruct.timeStereoMotion{rn} = [];
  logStruct.timeStereoFrame{rn} = [];
  logStruct.timeStereoMap{rn} = [];
  logStruct.timeStereoPost{rn} = [];
  logStruct.timeProcPost{rn} = [];
  logStruct.timeMatPredict{rn} = [];
  logStruct.timeMatOnline{rn} = [];
  %
  logStruct.timeHashInsert{rn}    = [];
  logStruct.timeHashQuery{rn}     = [];
  %
  logStruct.timeStereo{rn} = [];
  logStruct.timeTotal{rn} = [];
  logStruct.timeDirect{rn} = [];
  return ;
end

logStruct.timeStamp{rn}         = log_orb_slam(:, 1);
%
logStruct.timeOrbExtr{rn}       = log_orb_slam(:, 2) * 1000;
logStruct.timeTrackMotion{rn}   = log_orb_slam(:, 3) * 1000;
logStruct.timeTrackFrame{rn}    = log_orb_slam(:, 4) * 1000;
logStruct.timeTrackMap{rn}      = log_orb_slam(:, 5) * 1000;
logStruct.timeMapMatch{rn}      = log_orb_slam(:, 6) * 1000;
logStruct.timeMapSelect{rn}     = log_orb_slam(:, 7) * 1000;
logStruct.timeMapOpt{rn}        = log_orb_slam(:, 8) * 1000;
%
logStruct.timeStereoMotion{rn}  = log_orb_slam(:, 9) * 1000;
logStruct.timeStereoFrame{rn}   = log_orb_slam(:, 10) * 1000;
logStruct.timeStereoMap{rn}     = log_orb_slam(:, 11) * 1000;
logStruct.timeStereoPost{rn}    = log_orb_slam(:, 12) * 1000;

logStruct.timeStereo{rn}         = logStruct.timeStereoMotion{rn} + ...
  logStruct.timeStereoFrame{rn} + logStruct.timeStereoMap{rn};
%
logStruct.timeMatPredict{rn}    = log_orb_slam(:, 13) * 1000;
logStruct.timeMatOnline{rn}     = log_orb_slam(:, 14) * 1000;

%
logStruct.timeHashInsert{rn}    = log_orb_slam(:, 15) * 1000;
logStruct.timeHashQuery{rn}     = log_orb_slam(:, 16) * 1000;

logStruct.timeTotal{rn}         = logStruct.timeOrbExtr{rn} + ...
  logStruct.timeTrackMotion{rn} + logStruct.timeTrackFrame{rn} + logStruct.timeTrackMap{rn};
logStruct.timeDirect{rn} = [];
%
logStruct.lmkTrackMotion{rn}    = log_orb_slam(:, 17);
logStruct.lmkTrackFrame{rn}     = log_orb_slam(:, 18);
logStruct.lmkTrackMap{rn}       = log_orb_slam(:, 19);
logStruct.lmkLocalMap{rn}       = log_orb_slam(:, 20);
logStruct.lmkBA{rn}             = log_orb_slam(:, 21);
logStruct.lmkHashDynm{rn}       = log_orb_slam(:, 22);

%
% clear log_orb_slam
%
% mkdir([save_path '/' seq_idx '/']);
% save([save_path '/' seq_idx '/Ref_' seq_idx], ...
%   'timeTrack_orb_slam', 'timeObs_orb_slam', 'timeOpt_orb_slam');

end