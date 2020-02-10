close all
clear all

%%
tum_path   = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1500/ORBv2_Stereo_GF_Test/ObsNumber_200_Round5'
times_path = '/mnt/DATA/Datasets/Kitti_Dataset/dataset/sequences'
kitti_path = '/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_TRO19/Desktop/KITTI/lmk1500/ORBv2_Stereo_GF_Test/ObsNumber_200_Sub'

for si=11:21
  fileID = fopen([tum_path '/Seq' num2str(si, '%02d') '_stereo_AllFrameTrajectory.txt'], 'rt');
  if fileID == -1
    disp 'invalid input tum track!'
    continue ;
  end
  data = cell2mat(textscan(fileID, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
  fclose(fileID);
  
  times = textread([times_path '/' num2str(si, '%02d') '/times.txt']);
  N = size(times,1);
  
  %% align homo-matrix and timestamp
  fileID = fopen([kitti_path '/' num2str(si, '%02d') '.txt'], 'w');
  for i=1:N
    % check time stamp
    flag = false;
    for j=max(1,i-10) : min(N,i+10)
      if times(i) == data(j, 1)
        flag = true;
        break ;
      end
    end
    
    if flag
      % save matched tracking result
      g = SE3(data(j, 2:4), quat2rotm( data(j, [8,5:7]) ));
    else
      % save the previous traking result, if possible
      if j > 1
        g = SE3(data(j-1, 2:4), quat2rotm( data(j-1, [8,5:7]) ));
      else
        g = SE3();
      end
    end
    
    hom = g.Homog;
    
    %
    fprintf(fileID, '%.14f %.14f %.14f %.14f %.14f %.14f %.14f %.14f %.14f %.14f %.14f %.14f\n', ...
      hom(1,1), hom(1,2), hom(1,3), hom(1,4), ...
      hom(2,1), hom(2,2), hom(2,3), hom(2,4), ...
      hom(3,1), hom(3,2), hom(3,3), hom(3,4) );
  end
  fclose(fileID);
  
end