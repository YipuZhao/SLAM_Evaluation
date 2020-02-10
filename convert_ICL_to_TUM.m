
clear all
close all

% raw_tum_fname = '/mnt/DATA/Datasets/ICL-NUIM dataset/living_room_traj0n_frei_png/livingRoom0n.gt.freiburg'
% cor_tum_fname = '/mnt/DATA/Datasets/ICL-NUIM dataset/living_room_traj0n_frei_png/livingRoom0n_tum.txt'
raw_tum_fname = '/home/yipuzhao/Downloads/traj2.gt.freiburg'
cor_tum_fname = '/home/yipuzhao/Downloads/traj2_tum.txt'

%% load the original orb slam track
fid = fopen(raw_tum_fname, 'rt');
% NOTICE the additional column at the end to save lmk number per
% frame
track_dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1));
fclose(fid);

eul_arr = quat2eul(track_dat(:, [8, 5:7]));

%% save the convert tum track
file_out = fopen(cor_tum_fname, 'w');
for i = 1 : size(track_dat, 1)
    quat = eul2quat([-eul_arr(i, 1), eul_arr(i, 2), -eul_arr(i, 3)]);
    %
    fprintf(file_out, '%.06f %.07f %.07f %.07f %.07f %.07f %.07f %.07f\n', ...
        track_dat(i, 1), track_dat(i, 2), -track_dat(i, 3), track_dat(i, 4), ...
        quat(2:4), quat(1));
end
fclose(file_out);

%% visualization
% chk_idx = 1031
figure(1);
hold on
cline(track_dat(:, 2), -track_dat(:, 3), track_dat(:, 4), track_dat(:, 1));
% scatter3(track_dat(chk_idx, 2), -track_dat(chk_idx, 3), track_dat(chk_idx, 4));
% plot3(track_dat(:, 2), track_dat(:, 3), track_dat(:, 4), '-o', 'MarkerSize', 3);
axis equal
view([1,1,1])

figure(2);
hold on
plot(-eul_arr(:, 1));
plot(eul_arr(:, 2));
plot(-eul_arr(:, 3));