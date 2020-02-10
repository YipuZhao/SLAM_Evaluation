clear all
close all

data_path = '/mnt/DATA/GoogleDrive/ORB_SLAM/RNS1_flight_GF_SLAM/Test1_60percent_Round1' 

%% load the generated track
fid = fopen([data_path '/' 'RNS1_flight_10fps_AllFrameTrajectory.txt'], 'rt');
dat = cell2mat(textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 1)); 
fclose(fid); 

%% convert the quaternion into reference coord
ref_img_idx = 555;
ref_qat_0 = [0.73577, -0.66553, 0.07745, 0.09856];
qat = dat(:,[8,5:7]);
ref_qat_fac = quatmultiply(ref_qat_0, quatinv(qat(1, :)));
nqat = quatmultiply(ref_qat_fac, qat);

%% plot the quaterion on raw images
raw_img_path = '/mnt/DATA/Datasets/RNS1_flight/RNS1_flight_RAW_FRAME'
res_img_path = '/mnt/DATA/Datasets/RNS1_flight/RNS1_flight_ORB_FRAME_60%'
mkdir(res_img_path);

parfor idx = ref_img_idx : ref_img_idx + size(nqat, 1) - 1

    % load raw image idx
    raw_img = imread([raw_img_path '/' num2str(idx, '%06d') '.png']);
%     imshow(raw_img)
    
    % paint the quaternion on the img
    text = 'Quaternion: '; 
    for qn=1:4
        text = [text, num2str(nqat(idx-ref_img_idx+1, qn), '%.05f'), ' '];
    end
    res_img = insertText(raw_img, [100, 50], text, 'FontSize', 26, ...
        'BoxOpacity', 0, 'TextColor', 'red');
%     imshow(res_img)
    
    % save the result img
    imwrite(res_img, [res_img_path '/' num2str(idx, '%06d') '.png']);
    
end
