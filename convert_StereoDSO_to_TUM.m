close all
clear all

%%
raw_dso_path    = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/Stereo_DSO_Baseline/stereo_dso_kitti_training'
times_path      = '/mnt/DATA/Datasets/Kitti_Dataset/dataset/sequences'
tum_dso_path    = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/Stereo_DSO_Baseline/ObsNumber_800_Round1'

for si=0:10
  data = textread([raw_dso_path '/' num2str(si, '%02d') '.txt']);
  times = textread([times_path '/' num2str(si, '%02d') '/times.txt']);
  
  assert(size(data,1) == size(times,1))
  N = size(data,1);
  
  %% align homo-matrix and timestamp
  fileID = fopen([tum_dso_path '/Seq' num2str(si, '%02d') '_stereo_AllFrameTrajectory.txt'],'w');
  fprintf(fileID, '#TimeStamp Tx Ty Tz Qx Qy Qz Qw\n');
  for i=1:N
    Rm = [data(i,[1:3]); data(i,[5:7]); data(i,[9:11]); ];
    tv = data(i,[4,8,12]);
    q = rotm2quat(Rm);
    
    %
    fprintf(fileID, '%.06f %.06f %.06f %.06f %.06f %.06f %.06f %.06f\n', ...
      times(i), ...
      tv(1), ...
      tv(2), ...
      tv(3), ...
      q(2), ...
      q(3), ...
      q(4), ...
      q(1) ...
      );
  end
  fclose(fileID);
  
end