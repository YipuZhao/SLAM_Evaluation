clear all
close all

%%
round_num = 5

fr_idx_dat = [
  555
  718
  781
  933
  1115
  1268
  1760
  2057
  2559
  2883
  ];

quat_ref = [
  0.73577, -0.66553, 0.07745, 0.09856
  0.73389	-0.66708	0.07345	0.10494
  0.73129	-0.66871	0.0691	0.11521
  0.72607	-0.673	0.03343	0.13702
  0.72262	-0.67474	0.01529	0.1494
  0.71959	-0.67581	-0.00735	0.1594
  0.69669	-0.66131	-0.10351	0.25801
  0.68219	-0.65014	-0.15599	0.29596
  0.65778	-0.62176	-0.23936	0.35135
  0.63202	-0.60728	-0.2848	0.38813
  ];

% quat_ref = [quat_ref(:,1), -quat_ref(:,3), -quat_ref(:,2), -quat_ref(:,4)];

color_opt = {'y'; 'm'; 'c'; 'r'; 'g'; 'b'};

figure(1)
% hold on
for percent = 20:20:120 %100%
  %
  ang_dif = zeros(length(fr_idx_dat), round_num);
  
  for round=1:round_num
    
    %   data_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/RNS1_flight_REF_SLAM/Test1_' ...
    %         num2str(percent, '%02d') 'percent_Round1']
    if percent == 120
      data_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/RNS1_flight_REF_SLAM/Test1_100percent_Round' num2str(round)]
    else
      data_path = ['/mnt/DATA/GoogleDrive/ORB_SLAM/RNS1_flight_GF_SLAM/Test2_' ...
        num2str(percent, '%02d') 'percent_Round' num2str(round)]
    end
    
    
    %% load the generated track
    fid = fopen([data_path '/' 'RNS1_flight_10fps_AllFrameTrajectory.txt'], 'rt');
    track_dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
    fclose(fid);
    
    %% convert the quaternion into reference coord
    ref_img_idx = 555;
    ref_quat_0 = quat_ref(1,:);
    %         qat = dat(:,[8,5:7]);
    quat_dat = quatconj(track_dat(:,[8,7,6,5]));
    %     ref_qat_fac = quatmultiply(ref_qat_0, quatinv(qat(1, :)));
    %     nqat = quatmultiply(ref_qat_fac, qat);
    rect_quat_dat = quatmultiply(quat_dat, quatinv(quat_dat(ref_img_idx, :)));
    rect_quat_dat = quatmultiply(rect_quat_dat, ref_quat_0);
    
    %% plot
    for fn = 1 : length(fr_idx_dat)
      if fr_idx_dat(fn) < length(rect_quat_dat)
        quat_dif = quatmultiply( quatinv(quat_ref(fn, :)), rect_quat_dat(fr_idx_dat(fn), :) );
        axang = quat2axang(quat_dif);
        ang_dif(fn, round) = axang(4);
      else
        ang_dif(fn, round) = NaN;
      end
    end
    
%     % validate the correctness of previous quaternion transform
%     eul_ref = quat2eul(quat_ref);
%     eul_dat = quat2eul(rect_quat_dat(fr_idx_dat(1:length(fr_idx_dat)), :));
%     h = figure(2);
%     hold on;
%     plot(fr_idx_dat, eul_ref(:,1), '-o');
%     plot(fr_idx_dat, eul_ref(:,2), '-o');
%     plot(fr_idx_dat, eul_ref(:,3), '-o');
%     plot(fr_idx_dat, eul_dat(:,1), '-.x');
%     plot(fr_idx_dat, eul_dat(:,2), '-.x');
%     plot(fr_idx_dat, eul_dat(:,3), '-.x');
%     legend({'eul\_ref\_z';'eul\_ref\_y';'eul\_ref\_x';'eul\_dat\_z';'eul\_dat\_y';'eul\_dat\_x';});
%     title('Trends of baseline and ORB-SLAM estimation in terms of euler angle')
%     close(h)
  end
  
  subplot(2,3,percent/20)
  %   boxplot(ang_dif', fr_idx_dat, 'Color', color_opt{percent/20});
  boxplot(ang_dif', fr_idx_dat);
  ylim([0, 0.3])
  xlabel('frame index')
  ylabel('axis angle difference (rad)')
  grid on
  if percent == 120
    title(['trend of difference in rotation with all features']);
  else
    title(['trend of difference in rotation with ' num2str(percent) '% GF']);
  end
  
end


% legend({'20%'; '40%'; '60%'; '80%'; '100%'})