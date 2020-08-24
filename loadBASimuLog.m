function [log_data] = loadBASimuLog(log_fname, ratios_num, round_num, method_num)

fileID = fopen(log_fname);
raw_data = textscan(fileID, '%f', 'Delimiter', ',');
fclose(fileID);

log_data = zeros(round_num, ratios_num, method_num);
% length(subgraph_ratios), round_num, 4
for i=1:ratios_num
  % fill in full BA content
  log_data(1:round_num, i, 1) = raw_data{1}(1:round_num);
  
  for j=2:method_num
    log_data(1:round_num, i, j) = raw_data{1}(((method_num-1)*i-(method_num-j))*round_num + [1:round_num]);
  end
end

end