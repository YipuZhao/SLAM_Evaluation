function saveLogSVO(logFileName, logArray)

fid = fopen(logFileName, 'w');
if fid ~= -1
  %
  fprintf(fid, '#frame_time_stamp time_front time_back num_tracks num_states\n');
  for i=1:size(logArray, 1)
    fprintf(fid, '%f %f %f %f %f\n', [logArray(i,1) logArray(i,2) logArray(i,3) logArray(i,4) logArray(i,5)]);
  end
  fclose(fid);
else
  disp 'error! cannot create the log file to write!'
  return ;
end

end