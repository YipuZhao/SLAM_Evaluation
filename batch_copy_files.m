src_dir = '/mnt/DATA/swp_1'
tar_dir = '/mnt/DATA/swp_2'

% keywords = {
%   'MH_01_easy';
%   'MH_02_easy';
%   'MH_04_difficult';
%   'V1_02_medium';
%   'V2_01_easy';
%   };

keywords = {
  'MH_03_medium';
  'MH_04_difficult';
  'V1_03_difficult';
  };

for i=1:length(keywords)
  Files = dir( sprintf('%s/**/%s*.txt', src_dir, keywords{i}) );
  %
  for j=1:length(Files)
    src_path = [Files(j).folder '/' Files(j).name];
    tar_path = [tar_dir src_path(length(src_dir)+1:end)];
    status = copyfile(src_path, tar_path, 'f');
  end
end