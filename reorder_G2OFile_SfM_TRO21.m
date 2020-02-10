clear all
close all

raw_data    = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/venice/venice_inc.txt'
proc_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/venice/venice.txt'
%
% raw_data    = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/newcollege/newcollege3500_inc.g2o'
% proc_data   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_RAL19/SfM/newcollege/newcollege3500_mono_sub.txt'

graph_raw = loadGraph(raw_data, false);

%% take all vertex and edges in the original graph 
% cam_id_map = containers.Map(graph_raw.cam_ids, 0:graph_raw.cam_num-1);
% pts_id_map = containers.Map(graph_raw.pts_ids, graph_raw.cam_num:graph_raw.cam_num+graph_raw.pts_num-1);

%% take a subset of vertex and edges in the original graph
cam_lim = 400;
pts_lim = 63691;
cam_id_map = containers.Map(graph_raw.cam_ids(1:cam_lim), 0:cam_lim-1);
pts_id_map = containers.Map(graph_raw.pts_ids(1:pts_lim), cam_lim:cam_lim+pts_lim-1);

%% write to file
fid = fopen(proc_data, 'w');
% write all cam rows
for i=1:graph_raw.cam_num
    if isKey(cam_id_map, graph_raw.cam_poses(i,1))
%          graph_raw.cam_poses(i,end-2) = 0;
%          graph_raw.cam_poses(i,end-1) = 0;
%          graph_raw.cam_poses(i,end) = 0;
        if size(graph_raw.cam_poses, 2) == 13
            fprintf(fid,'VERTEX_CAM %d %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f\n', ...
                cam_id_map(graph_raw.cam_poses(i,1)), graph_raw.cam_poses(i,2:end));
        else
            fprintf(fid,'VERTEX_CAM %d %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f\n', ...
                cam_id_map(graph_raw.cam_poses(i,1)), graph_raw.cam_poses(i,2:end));
        end
    end
end
% write all map rows
for i=1:graph_raw.pts_num
    if isKey(pts_id_map, graph_raw.pts_poses(i,1))
        fprintf(fid,'VERTEX_XYZ %d %.05f %.05f %.05f\n', ...
            pts_id_map(graph_raw.pts_poses(i,1)), graph_raw.pts_poses(i,2:end));
    end
end
% write all edge rows
for i=1:graph_raw.edge_num
    if isKey(cam_id_map, graph_raw.edge_raw(i,2)) && isKey(pts_id_map, graph_raw.edge_raw(i,1))
        if size(graph_raw.edge_raw, 2) == 7
%             graph_raw.edge_raw(i,3) = graph_raw.edge_raw(i,3) - 254.90400;
%             graph_raw.edge_raw(i,4) = graph_raw.edge_raw(i,4) - 201.89900;
            fprintf(fid,'EDGE_PROJECT_P2MC %d %d %.05f %.05f %.05f %.05f %.05f\n', ...
                pts_id_map(graph_raw.edge_raw(i,1)), cam_id_map(graph_raw.edge_raw(i,2)), ...
                graph_raw.edge_raw(i,3:end));
        else
            fprintf(fid,'EDGE_PROJECT_P2SC %d %d %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f %.05f\n', ...
                pts_id_map(graph_raw.edge_raw(i,1)), cam_id_map(graph_raw.edge_raw(i,2)), ...
                graph_raw.edge_raw(i,3:end));
        end
    end
end
%
fclose(fid);