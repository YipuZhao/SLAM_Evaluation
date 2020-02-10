clear all;
close all;

% GT_path = '/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GT/';
MD_path = '/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM/Test1_80percent_Round1/';
% MD_path = '/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_REF_SLAM/Test1_Round3/';

for sn = [0,2,6,7,8,9]
  %% load TUM pose file
  %   tum_fname = [TUM_path '/' num2str(sn, '%02d') '_tum.txt'];
%   gt_fname = [GT_path '/' num2str(sn, '%02d') '_tum.txt'];
%   file_in = fopen(gt_fname);
%   dat = textscan(file_in, '%f %f %f %f %f %f %f %f %f %f %f %f');
%   fclose(file_in);
%   gt_dat = cell2mat(dat);
  %
  md_fname = [MD_path '/Seq' num2str(sn, '%02d') '_10_KeyFrameTrajectory.txt'];
  file_in = fopen(md_fname);
  dat = textscan(file_in, '%f %f %f %f %f %f %f %f %f %f %f %f');
  fclose(file_in);
  md_dat = cell2mat(dat);
  
  %% visualization
  figure;
  subplot(3,3,[1,2,4,5,7,8])
  %   scatter(ndat(:, 2), ndat(:, 4), 5, ndat(:, 1));
  cline(md_dat(:, 2), md_dat(:, 4), md_dat(:, 3), md_dat(:, 1));
  axis equal;
  colorbar
  title('2D Trajectory')
  
  subplot(3,3,3)
  plot(md_dat(:, 1), md_dat(:, 2), '--gs',...
    'LineWidth',1,...
    'MarkerSize',2,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
  xlim([0 md_dat(end, 1)])
  title('Position - X')
  
  subplot(3,3,6)
  plot(md_dat(:, 1), md_dat(:, 3), '--gs',...
    'LineWidth',1,...
    'MarkerSize',2,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
  xlim([0 md_dat(end, 1)])
  title('Position - Y')
  
  subplot(3,3,9)
  plot(md_dat(:, 1), md_dat(:, 4), '--gs',...
    'LineWidth',1,...
    'MarkerSize',2,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5]);
  xlim([0 md_dat(end, 1)])
  title('Position - Z')
  
  saveas(gcf, [MD_path '/Seq' num2str(sn, '%02d') '_10_Map.png' ]);
end