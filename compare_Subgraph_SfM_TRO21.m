clear all
close all

% path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/debug'
% path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/cathedral'
path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/venice'

%%
path_gt     = [path_data '/graph_GT_v2.graph'];
% path_gt     = [path_data '/graph_GT.graph'];
graph_gt    = loadGraph(path_gt, true);
pcd_gt      = pointCloud(graph_gt.pts_poses(:, 2:4));

%%
%
% path_tar_1  = [path_data '/graph_fullOpt.graph'];
% graph_tar_1 = loadGraph(path_tar_1, true);
% pcd_tar_1   = pointCloud(graph_tar_1.pts_poses(:, 2:4));
% % [tform_1, ~, rmse_1] = pcregistericp(pcd_tar_1, pcd_gt);
% rmse_1 = rmse_Graph(graph_gt, graph_tar_1);
% fprintf('Full BA rmse = %.05f\n', rmse_1);

%%
percent_pref= 'debug' % '10p' % 

path_tar_2  = [path_data '/' percent_pref '/graph_goodOpt.graph'];
graph_tar_2 = loadGraph(path_tar_2, true);
pcd_tar_2   = pointCloud(graph_tar_2.pts_poses(:, 2:4));
% [tform_2, ~, rmse_2] = pcregistericp(pcd_tar_2, pcd_gt);
rmse_2 = rmse_Graph(graph_gt, graph_tar_2);
fprintf('Good Graph rmse = %.05f\n', rmse_2);

path_tar_3  = [path_data '/' percent_pref '/graph_covisOpt.graph'];
graph_tar_3 = loadGraph(path_tar_3, true);
pcd_tar_3   = pointCloud(graph_tar_3.pts_poses(:, 2:4));
% [tform_3, ~, rmse_3] = pcregistericp(pcd_tar_3, pcd_gt);
rmse_3 = rmse_Graph(graph_gt, graph_tar_3);
fprintf('Covis Graph rmse = %.05f\n', rmse_3);

fprintf('Random Graph rmse = ');
for rn=1:5
  path_tar_4    = [path_data '/' percent_pref '/round' num2str(rn) '/graph_randOpt.graph'];
  graph_tar_4   = loadGraph(path_tar_4, true);
  pcd_tar_4     = pointCloud(graph_tar_4.pts_poses(:, 2:4));
  %   [tform_4, ~, rmse_4] = pcregistericp(pcd_tar_4, pcd_gt);
  rmse_4 = rmse_Graph(graph_gt, graph_tar_4);
  fprintf('%.05f ', rmse_4);
end
fprintf('\n');

fprintf('Random Init rmse = ');
for rn=1:5
  path_tar_4  = [path_data '/' percent_pref '/round' num2str(rn) '/graph_randInit.graph'];
  graph_tar_4 = loadGraph(path_tar_4, true);
  pcd_tar_4 = pointCloud(graph_tar_4.pts_poses(:, 2:4));
  %   [tform_4, ~, rmse_4] = pcregistericp(pcd_tar_4, pcd_gt);
  rmse_4 = rmse_Graph(graph_gt, graph_tar_4);
  fprintf('%.05f ', rmse_4);
end
fprintf('\n');
