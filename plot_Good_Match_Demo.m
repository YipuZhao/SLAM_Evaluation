clear all
close all

data_path = '/mnt/DATA/DropboxContainer/Dropbox/PhD/Projects/Visual_SLAM/Good_Feature_Demo/';
% data_path = '/mnt/DATA/tmp/Demo/'

method_list = { 'ORB'; 'Rnd'; 'Long'; 'GF_c50'; };
marker_styl = { '-bo'; '-ro'; '-go'; '-ko'; };

frame_list = dir([data_path 'ORB/*.log']);
start_frame_idx = 200; % 1000;

%%
for i=start_frame_idx:length(frame_list)
  for j=1:length(method_list)
    log_path = [data_path method_list{j} '/' frame_list(i).name];
    fid = fopen(log_path, 'rt');
    if fid ~= -1
      log_tmp = cell2mat(textscan(fid, '%f %f', 'HeaderLines', 1));
      %
      log_data{i, j} = log_tmp;
      fclose(fid);
    end
  end
  %
  
  % viz per frame
  %   figure;
  %   hold on
  %   for j=1:length(method_list)
  %     plot(log_data{i, j}(:,1), log_data{i, j}(:,2), marker_styl{j});
  %   end
  %   legend(method_list);
  %   xlabel('Num. of Matching Trys');
  %   ylabel('logDet of Pose Tracking');
  
end

% figure;
% hold on
% for j=1:length(method_list)
%   for i=start_frame_idx:length(frame_list)
%     if ~isempty(log_data{i, j})
%       plot(log_data{i, j}(:,1), log_data{i, j}(:,2), marker_styl{j});
%     end
%   end
% end
% legend(method_list);
% xlabel('Num. of Matching Trys');
% ylabel('logDet of Pose Tracking');

%%
sz_bucket = 3000; % 450;
plot_idx = 1:sz_bucket; %  [1:10:sz_bucket]; %
box_final = nan(length(frame_list)-start_frame_idx+1, length(plot_idx)*length(method_list));
for j=1:length(method_list)
  box_method = cell(sz_bucket, 1);
  for i=start_frame_idx:length(frame_list)
    if ~isempty(log_data{i, j})
      for k=1:length(log_data{i, j}(:,1))
        ii = log_data{i, j}(k,1) + 1;
        box_method{ii} = [box_method{ii} log_data{i, j}(k,2)];
      end
      %
      for k=max(log_data{i, j}(:,1))+1:sz_bucket-1
        box_method{k+1} = [box_method{k+1} nan];
      end
    end
  end
  %
  box_matrix{j} = cell2mat(box_method)';
  %   box_arr = cat(3, box_arr, box_method);
  box_final(1:size(box_matrix{j},1), ...
    ([1:length(plot_idx)]-1)*length(method_list)+j) = box_matrix{j}(:,plot_idx);
  %   C    = cell(length(plot_idx),1);
  %   C(:) = {method_list{j}};
  %   grp_final = {grp_final; C};
  %   boxplot(box_matrix{j}(:,1:10:sz_bucket),'PlotStyle','compact',...
  %     'Colors',marker_styl{j}(2),'symbol','');
  %   set(gca,'XTickLabel',{' '});
end

q25_final = prctile(box_final, 25, 1);
mean_final = nanmean(box_final, 1);
q75_final = prctile(box_final, 75, 1);
median_final = nanmedian(box_final, 1);

% min_init = min(mean_final(1:length(method_list)));
% min_init = mean_final(1);
% for j=1:length(method_list)
%   offset{j} = mean_final(j) - min_init;
% end

%%
figure;
hold on
for j=1:length(method_list)
  plot(box_final(:, 50*length(method_list) + j),marker_styl{j}(1:end-1));
end
legend(method_list);
xlabel('Frames');
ylabel('logDet');

%%
figure;
hold on
for j=1:length(method_list)
  plot(plot_idx, median_final(([1:length(plot_idx)]-1)*length(method_list)+j),marker_styl{j}(1:end-1))
end
legend(method_list);
xlabel('Num. of Matching Trys');
ylabel('Median of logDet');

%%
samp_rate = 10;
figure;
hold on
for j=1:length(method_list)
  sample_idx = [1:samp_rate:length(plot_idx)];
  errorbar(plot_idx(sample_idx), ...
    mean_final((sample_idx-1)*length(method_list)+j), ...
    q25_final((sample_idx-1)*length(method_list)+j) - mean_final((sample_idx-1)*length(method_list)+j), ...
    q75_final((sample_idx-1)*length(method_list)+j) - mean_final((sample_idx-1)*length(method_list)+j), ...
    marker_styl{j},'MarkerSize',5) ;
end
legend(method_list);
xlabel('Num. of Matching Trys');
ylabel('logDet');

%%
% grp_final = {};
% for i=1:length(plot_idx)
%   for j=1:length(method_list)
%     grp_final{(i-1)*length(method_list)+j} = method_list{j};
%   end
% end
%
% grp_idx = repmat(plot_idx, 4, 1);
%
% figure;
% boxplot(box_final, {grp_idx(:),grp_final'}, ...
%   'colors', repmat('bgrk',1,length(plot_idx)),...
%   'labelverbosity','minor','symbol','');
% % legend(method_list);
% xlabel('Num. of Matching Trys');
% ylabel('logDet of Pose Tracking');

