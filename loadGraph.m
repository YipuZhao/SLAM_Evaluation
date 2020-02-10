function [graph] = loadGraph(file_name, skip_edges)

graph.cam_poses = [];
graph.cam_ids = [];
graph.cam_num = 0;
graph.pts_poses = [];
graph.pts_ids = [];
graph.pts_num = 0;
graph.edge_raw = [];
graph.edge_num = 0;

fid = fopen(file_name);
tline = fgetl(fid);
while ischar(tline)
  %    disp(tline)
  entries = split(tline,  " ");
  %
  if strcmp(entries{1}, "VERTEX_CAM")
    id = str2double(entries{2});
    if length(entries) == 14
      graph.cam_poses = [graph.cam_poses;
        % id                    xyz                     quat                intrinsic
        id, str2double(entries{3}), str2double(entries{4}), str2double(entries{5}), str2double(entries{6}), str2double(entries{7}), str2double(entries{8}), str2double(entries{9}), str2double(entries{10}), str2double(entries{11}), str2double(entries{12}), str2double(entries{13}), str2double(entries{14})
        ];
%     elseif length(entries) == 13
%       graph.cam_poses = [graph.cam_poses;
%         % id                    xyz                     quat                intrinsic
%         id, str2double(entries{3}), str2double(entries{4}), str2double(entries{5}), str2double(entries{6}), str2double(entries{7}), str2double(entries{8}), str2double(entries{9}), str2double(entries{10}), str2double(entries{11}), str2double(entries{12}), str2double(entries{13})
%         ];
    else
      printf('undefined camera row!')
    end
    graph.cam_ids = [graph.cam_ids; id];
    graph.cam_num = graph.cam_num + 1;
    %
  elseif strcmp(entries{1}, "VERTEX_XYZ")
    id = str2double(entries{2});
    graph.pts_poses = [graph.pts_poses;
      % id                      xyz
      id, str2double(entries{3}), str2double(entries{4}), str2double(entries{5})
      ];
    graph.pts_ids = [graph.pts_ids; id];
    graph.pts_num = graph.pts_num + 1;
    %
  elseif strcmp(entries{1}, "CONSISTENCY_MARKER")
    % not valid graph component, skip
    %
  else
    % edges
    if skip_edges
      % do nothing
    else
      % TODO
      if strcmp(entries{1}, "EDGE_PROJECT_P2MC")
        id1 = str2double(entries{2});
        id2 = str2double(entries{3});
        graph.edge_raw = [graph.edge_raw;
          % id1 id2 measurement             covariance
          id1, id2, str2double(entries{4}), str2double(entries{5}), str2double(entries{6}), str2double(entries{7}), str2double(entries{8})
          ];
      elseif strcmp(entries{1}, "EDGE_PROJECT_P2SC")
%         id1 = str2double(entries{2});
%         id2 = str2double(entries{3});
%         graph.edge_raw = [graph.edge_raw;
%           % id1 id2 measurement             covariance
%           id1, id2, str2double(entries{4}), str2double(entries{5}), str2double(entries{6}), str2double(entries{7}), str2double(entries{8}), str2double(entries{9}), str2double(entries{10}), str2double(entries{11}), str2double(entries{12})
%           ];
        id1 = str2double(entries{2});
        id2 = str2double(entries{3});
        graph.edge_raw = [graph.edge_raw;
          % id1 id2 measurement             covariance
          id1, id2, str2double(entries{4}), str2double(entries{5}), str2double(entries{7}), str2double(entries{8}), str2double(entries{12})
          ];
      else
        printf('undefined edge row!')
      end
      graph.edge_num = graph.edge_num + 1;
    end
  end
  %
  tline = fgetl(fid);
end
fclose(fid);

end