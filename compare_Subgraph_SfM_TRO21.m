clear all
close all

% path_data   = '/home/yipuzhao/ros_workspace/package_dir/GF_ORB_SLAM2/Thirdparty/SLAM++/bin'
% path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/cathedral'
path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/venice'

%%
path_gt     = [path_data '/graph_GT_v2.graph'];
% path_gt     = [path_data '/graph_GT.graph'];
graph_gt    = loadGraph(path_gt, true);
% pcd_gt      = pointCloud(graph_gt.pts_poses(:, 2:4));

%%
percent_pref = {'10p_1.5x'}; % {'10p_auto'} %
% percent_pref = {'10p_2x'; '20p_2x'; '30p_2x'; '40p_2x'; }; %  {'10p_auto'; '20p_auto'; '30p_auto'; '40p_auto'; };  %

for pn=1%:length(percent_pref)
  %%
  fprintf('=============== Evaluation on raw graph ===============\n');
  %
  path_tar_1  = [path_data '/' percent_pref{pn}  '/graph_fullOpt.graph'];
  graph_tar_1 = loadGraph(path_tar_1, true, true);
  % pcd_tar_1   = pointCloud(graph_tar_1.pts_poses(:, 2:4));
  % [tform_1, ~, rmse_1] = pcregistericp(pcd_tar_1, pcd_gt);
  [rmse_1, inlier_index_1] = rmse_Graph(graph_gt, graph_tar_1);
  fprintf('Full BA rmse = %.05f with %d points\n', rmse_1, length(inlier_index_1));
  
  path_tar_2  = [path_data '/' percent_pref{pn} '/graph_goodOpt.graph'];
  graph_tar_2 = loadGraph(path_tar_2, true, true);
  %   pcd_tar_2   = pointCloud(graph_tar_2.pts_poses(:, 2:4));
  % [tform_2, ~, rmse_2] = pcregistericp(pcd_tar_2, pcd_gt);
  [rmse_2, inlier_index_2] = rmse_Graph(graph_gt, graph_tar_2);
  fprintf('Good Graph rmse = %.05f with %d points\n', rmse_2, length(inlier_index_2));
  
  path_tar_3  = [path_data '/' percent_pref{pn} '/graph_covisOpt.graph'];
  graph_tar_3 = loadGraph(path_tar_3, true, true);
  %   pcd_tar_3   = pointCloud(graph_tar_3.pts_poses(:, 2:4));
  % [tform_3, ~, rmse_3] = pcregistericp(pcd_tar_3, pcd_gt);
  [rmse_3, inlier_index_3] = rmse_Graph(graph_gt, graph_tar_3);
  fprintf('Covis Graph rmse = %.05f with %d points\n', rmse_3, length(inlier_index_3));
  
  fprintf('Random Graph rmse = ');
  for rn=1%:5
    %   path_tar_4    = [path_data '/' percent_pref{pn} '/round' num2str(rn) '/graph_randOpt.graph'];
    path_tar_4    = [path_data '/' percent_pref{pn} '/graph_randOpt.graph'];
    graph_tar_4   = loadGraph(path_tar_4, true, true);
    %     pcd_tar_4     = pointCloud(graph_tar_4.pts_poses(:, 2:4));
    %   [tform_4, ~, rmse_4] = pcregistericp(pcd_tar_4, pcd_gt);
    [rmse_4, inlier_index_4] = rmse_Graph(graph_gt, graph_tar_4);
    fprintf('%.05f with %d points ', rmse_4, length(inlier_index_4));
  end
  fprintf('\n');
  
  % fprintf('Random Init rmse = ');
  % for rn=1:5
  %   path_tar_4  = [path_data '/' percent_pref{pn} '/round' num2str(rn) '/graph_randInit.graph'];
  %   graph_tar_4 = loadGraph(path_tar_4, true);
  %   pcd_tar_4 = pointCloud(graph_tar_4.pts_poses(:, 2:4));
  %   %   [tform_4, ~, rmse_4] = pcregistericp(pcd_tar_4, pcd_gt);
  %   rmse_4 = rmse_Graph(graph_gt, graph_tar_4);
  %   fprintf('%.05f ', rmse_4);
  % end
  % fprintf('\n');
  
  
  %% find common GT inliers for fair comparison
  comm_inlier_index = intersect(inlier_index_1, inlier_index_2);
  comm_inlier_index = intersect(comm_inlier_index, inlier_index_3);
  comm_inlier_index = intersect(comm_inlier_index, inlier_index_4);
  %
  tmp_overlap_index = ismembertol(inlier_index_1, comm_inlier_index, 1e-3);
  overlap_index_1 = find(tmp_overlap_index > 0);
  %
  tmp_overlap_index = ismembertol(inlier_index_2, comm_inlier_index, 1e-3);
  overlap_index_2 = find(tmp_overlap_index > 0);
  %
  tmp_overlap_index = ismembertol(inlier_index_3, comm_inlier_index, 1e-3);
  overlap_index_3 = find(tmp_overlap_index > 0);
  %
  tmp_overlap_index = ismembertol(inlier_index_4, comm_inlier_index, 1e-3);
  overlap_index_4 = find(tmp_overlap_index > 0);
  
  %% rerun evaluation with common inliers
  
  fprintf('=============== Evaluation on common subgraph ===============\n');
  [rmse_1, ~] = rmse_Graph(graph_gt, graph_tar_1, overlap_index_1);
  fprintf('Full BA rmse = %.05f with %d points\n', rmse_1, length(overlap_index_1));
  [rmse_2, ~] = rmse_Graph(graph_gt, graph_tar_2, overlap_index_2);
  fprintf('Good Graph rmse = %.05f with %d points\n', rmse_2, length(overlap_index_2));
  [rmse_3, ~] = rmse_Graph(graph_gt, graph_tar_3, overlap_index_3);
  fprintf('Covis Graph rmse = %.05f with %d points\n', rmse_3, length(overlap_index_3));
  [rmse_4, ~] = rmse_Graph(graph_gt, graph_tar_4, overlap_index_4);
  fprintf('Random Graph rmse = %.05f with %d points\n', rmse_4, length(overlap_index_4));
  
end
