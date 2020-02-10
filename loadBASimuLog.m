function [log_data] = loadBASimuLog(log_fname, ratios_num, round_num)

fileID = fopen(log_fname);
raw_data = textscan(fileID, '%f', 'Delimiter', ',');
fclose(fileID);

log_data = zeros(round_num, ratios_num, 4);
% length(subgraph_ratios), round_num, 4
for i=1:ratios_num
  % fill in full BA content
  log_data(1:round_num, i, 1) = raw_data{1}(1:round_num);
  % fill in good graph BA content
  log_data(1:round_num, i, 2) = raw_data{1}((3*i-2)*round_num + [1:round_num]);
  % fill in covis BA content
  log_data(1:round_num, i, 3) = raw_data{1}((3*i-1)*round_num + [1:round_num]);
  % fill in random BA content
  log_data(1:round_num, i, 4) = raw_data{1}((3*i)*round_num + [1:round_num]);
end

end