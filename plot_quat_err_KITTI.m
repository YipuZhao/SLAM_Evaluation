clear all
close all

fr_st = 1
fr_ed = 800
seq_list = {0};

for sn = 1:length(seq_list)
  seq_idx = seq_list{sn};
  figure;
  hold on
  %   for percent = 20:20:100 %100%
  
  %% load the generated track
  data_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM/Regressed_100percent_Round1']
  
  fid = fopen([data_path '/' 'Seq' num2str(seq_idx, '%02d') '_10_AllFrameTrajectory.txt'], 'rt');
  track_dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
  fclose(fid);
  
  %% load the ground truth track
  model_path = ['/home/yipuzhao/ros_workspace/package_dir/ORB_Data/KITTI_POSE_GT']
  
  fid = fopen([model_path '/' num2str(seq_idx, '%02d') '_tum.txt'], 'rt');
  track_mod = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f'));
  fclose(fid);
  
  %% convert the quaternion into reference coord
  quat_mod = track_mod(:,[8,5:7]);
  quat_dat = track_dat(:,[8,5:7]);
  %   quat_dat = quatconj(quat_dat);
  %     ref_qat_fac = quatmultiply(ref_qat_0, quatinv(qat(1, :)));
  %     nqat = quatmultiply(ref_qat_fac, qat);
  nqat = quatmultiply(quat_dat, quatinv(quat_dat(1, :)));
  nquat_dat = quatmultiply(nqat, quat_mod(1, :));
  
  %% associate the data to the model quat with timestamp
  asso_mod_2_dat = zeros(size(track_mod, 1), 1);
  for i=1:size(track_mod, 1)
    [asso_val, asso_idx] = min(abs(track_dat(:,1) - track_mod(i,1)));
    if asso_val < 0.2
      asso_mod_2_dat(i) = asso_idx;
    end
  end
  
  %% plot
  %   ang_dif = -1*ones(size(track_mod, 1), 1);
  %   for i = 1:size(track_mod, 1)
  %     if asso_mod_2_dat(i) ~= 0
  %       quat_dif = quatmultiply( quatinv(quat_mod(i, :)), nquat_dat(asso_mod_2_dat(i), :) );
  %       axang = quat2axang(quat_dif);
  %       if abs(axang(4) + 2*pi) < abs(axang(4))
  %         axang(4) = axang(4) + 2*pi;
  %       end
  %       if abs(axang(4) - 2*pi) < abs(axang(4))
  %         axang(4) = axang(4) - 2*pi;
  %       end
  %       ang_dif(i) = axang(4);
  %     end
  %   end
  %
  %   plot(track_mod(:,1), ang_dif, '-o');
  
  eul_mod = quat2eul(quat_mod);
  eul_dat = quat2eul(nquat_dat);
  
  plot(track_mod(fr_st:fr_ed,1), eul_mod(fr_st:fr_ed,1), '-o');
  plot(track_mod(fr_st:fr_ed,1), eul_mod(fr_st:fr_ed,2), '-o');
  plot(track_mod(fr_st:fr_ed,1), eul_mod(fr_st:fr_ed,3), '-o');
  plot(track_dat(fr_st:fr_ed,1), eul_dat(fr_st:fr_ed,1), '-.x');
  plot(track_dat(fr_st:fr_ed,1), eul_dat(fr_st:fr_ed,2), '-.x');
  plot(track_dat(fr_st:fr_ed,1), eul_dat(fr_st:fr_ed,3), '-.x');
  
  xlabel('frame index')
  ylabel('axis angle difference (rad)')
  
end


% end