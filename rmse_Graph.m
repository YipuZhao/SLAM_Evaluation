function [dist_rms, inlier_index] = rmse_Graph(graph_ref, graph_tar, pts_subset_tar)

if nargin < 3
  pts_subset_tar = 1:length(graph_tar.pts_poses);
end

pcd_gt = pointCloud(graph_ref.pts_poses(:, 2:4));
g_gt = SE3( graph_ref.cam_poses(1, 2:4), quat2rotm( graph_ref.cam_poses(1, [8,5:7]) ) );

pcd_tar = pointCloud(graph_tar.pts_poses(pts_subset_tar, 2:4));
g_tar = SE3( graph_tar.cam_poses(1, 2:4), quat2rotm( graph_tar.cam_poses(1, [8,5:7]) ) );
g_to_gt = mtimes(g_gt, g_tar.inv);
% g_to_gt = mtimes(g_gt.inv, g_tar);
pcd_tar_new = pointCloud( g_to_gt.leftact(pcd_tar.Location')' );
% pcd_tar_new = pointCloud( pcd_tar.Location );

%
kdTree = KDTreeSearcher(pcd_gt.Location);
dist_lmk = [];
inlier_index = [];
for i=1:pcd_tar_new.Count
  %   [nnIdx, nnDist] = findNearestNeighbors(pcd_gt, pcd_tar_new.Location(i, :), 1);
  [nnIdx, nnDist] = knnsearch(kdTree, pcd_tar_new.Location(i, :), 'K', 1);
  if ~isempty(nnIdx)
    dist_lmk = [dist_lmk; nnDist];
    inlier_index = [inlier_index nnIdx];
  end
end

dist_rms = rms(dist_lmk);

%
% dist_cam = [];
% ang_cam = [];
% for i=1:graph_tar.cam_num
%   g_tmp = SE3( graph_tar.cam_poses(i, 1:3), quat2rotm( graph_tar.cam_poses(i, [7,4:6]) ) );
%   g_tmp_new = mtimes(g_to_gt, g_tmp);
%   %
% %   g_tmp_new
% end

end