clear all
close all

path_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO21/SfM/venice/GGvariants'

%%
path_gt     = [path_data '/../graph_GT_v2.graph'];
graph_gt    = loadGraph(path_gt, true);

%%
fprintf('=============== Evaluation on raw graph ===============\n');
%
path_tar_1  = [path_data '/graph_fullOpt.graph'];
graph_tar_1 = loadGraph(path_tar_1, true, true);
[rmse_1, inlier_index_1] = rmse_Graph(graph_gt, graph_tar_1);
fprintf('Full BA rmse = %.05f with %d points\n', rmse_1, length(inlier_index_1));

path_tar_2  = [path_data '/v1/graph_goodOpt.graph'];
graph_tar_2 = loadGraph(path_tar_2, true, true);
[rmse_2, inlier_index_2] = rmse_Graph(graph_gt, graph_tar_2);
fprintf('N.C.G. rmse = %.05f with %d points\n', rmse_2, length(inlier_index_2));

path_tar_3  = [path_data '/v2/graph_goodOpt.graph'];
graph_tar_3 = loadGraph(path_tar_3, true, true);
[rmse_3, inlier_index_3] = rmse_Graph(graph_gt, graph_tar_3);
fprintf('N.C.L. rmse = %.05f with %d points\n', rmse_3, length(inlier_index_3));

path_tar_4  = [path_data '/v3/graph_goodOpt.graph'];
graph_tar_4 = loadGraph(path_tar_4, true, true);
[rmse_4, inlier_index_4] = rmse_Graph(graph_gt, graph_tar_4);
fprintf('N.I.L. rmse = %.05f with %d points\n', rmse_4, length(inlier_index_3));

path_tar_5  = [path_data '/v4/graph_goodOpt.graph'];
graph_tar_5 = loadGraph(path_tar_5, true, true);
[rmse_5, inlier_index_5] = rmse_Graph(graph_gt, graph_tar_5);
fprintf('A.I.L. rmse = %.05f with %d points\n', rmse_5, length(inlier_index_5));

path_tar_6  = [path_data '/v5/graph_goodOpt.graph'];
graph_tar_6 = loadGraph(path_tar_6, true, true);
[rmse_6, inlier_index_6] = rmse_Graph(graph_gt, graph_tar_6);
fprintf('C.G.G. rmse = %.05f with %d points\n', rmse_6, length(inlier_index_6));


%% find common GT inliers for fair comparison
comm_inlier_index = intersect(inlier_index_1, inlier_index_2);
comm_inlier_index = intersect(comm_inlier_index, inlier_index_3);
comm_inlier_index = intersect(comm_inlier_index, inlier_index_4);
comm_inlier_index = intersect(comm_inlier_index, inlier_index_5);
comm_inlier_index = intersect(comm_inlier_index, inlier_index_6);
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
%
tmp_overlap_index = ismembertol(inlier_index_5, comm_inlier_index, 1e-3);
overlap_index_5 = find(tmp_overlap_index > 0);
%
tmp_overlap_index = ismembertol(inlier_index_6, comm_inlier_index, 1e-3);
overlap_index_6 = find(tmp_overlap_index > 0);

%% rerun evaluation with common inliers

fprintf('=============== Evaluation on common subgraph ===============\n');
[rmse_1, ~] = rmse_Graph(graph_gt, graph_tar_1, overlap_index_1);
fprintf('Full BA rmse = %.05f with %d points\n', rmse_1, length(overlap_index_1));
[rmse_2, ~] = rmse_Graph(graph_gt, graph_tar_2, overlap_index_2);
fprintf('N.C.G. rmse = %.05f with %d points\n', rmse_2, length(overlap_index_2));
[rmse_3, ~] = rmse_Graph(graph_gt, graph_tar_3, overlap_index_3);
fprintf('N.C.L. rmse = %.05f with %d points\n', rmse_3, length(overlap_index_3));
[rmse_4, ~] = rmse_Graph(graph_gt, graph_tar_4, overlap_index_4);
fprintf('N.I.L. rmse = %.05f with %d points\n', rmse_4, length(overlap_index_4));
[rmse_5, ~] = rmse_Graph(graph_gt, graph_tar_5, overlap_index_5);
fprintf('A.I.L. rmse = %.05f with %d points\n', rmse_5, length(overlap_index_5));
[rmse_6, ~] = rmse_Graph(graph_gt, graph_tar_6, overlap_index_6);
fprintf('C.G.G. rmse = %.05f with %d points\n', rmse_6, length(overlap_index_6));
