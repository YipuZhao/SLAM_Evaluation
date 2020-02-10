clear all;

for sn = 0 : 10
  
  %% load KITTI pose file
  kitti_fname = ['/mnt/DATA/Datasets/Kitti_Dateset/dataset/poses/' num2str(sn, '%02d') '.txt'];
  file_in = fopen(kitti_fname);
  dat = textscan(file_in, '%f %f %f %f %f %f %f %f %f %f %f %f');
  fclose(file_in);
  ndat = cell2mat(dat);
  
  %% load KITTI time file
  time_fname = ['/mnt/DATA/Datasets/Kitti_Dateset/dataset/sequences/' num2str(sn, '%02d') '/times.txt'];
  file_in = fopen(time_fname);
  dat = textscan(file_in, '%f');
  fclose(file_in);
  tdat = cell2mat(dat);
  
  %% save as TUM pose file
  tum_fname = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GT/' num2str(sn, '%02d') '_tum.txt'];
  file_out = fopen(tum_fname, 'w');
  for tn = 1 : size(ndat, 1)
    tvec = ndat(tn, [4, 8, 12]);
    rmat = [ndat(tn, [1:3]); ndat(tn, [5:7]); ndat(tn, [9:11])];
    qvec = rotm2quat(rmat);
    %
    fprintf(file_out, '%.06f %.07f %.07f %.07f %.07f %.07f %.07f %.07f\n', tdat(tn), tvec, qvec(2:4), qvec(1));
  end
  fclose(file_out);
  
end