close all;
clear all;

%%  load data 

dataPath = '/mnt/DATA/GoogleDrive/ORB_SLAM/KITTI_POSE_GF_SLAM'

b = cell(1);
count = 0;

for n = 1:10
  
  val = dir([dataPath '/Test2_100percent_Round' num2str(n) '/Seq0*_10_FrameObsRec.txt']);
  
  for m = 6 % m = 1:length(val)
    
    count = count + 1;
    
    b{n}{m} = dlmread([dataPath '/Test2_100percent_Round' num2str(n) '/' val(m).name], ' ', 1, 0);
    
    % parse data
    
    Stats.(sprintf('run_%05d', count)).time =  b{n}{m}(:,1);
    
    Stats.(sprintf('run_%05d', count)).ref =  b{n}{m}(:,2:8);
    
    Stats.(sprintf('run_%05d', count)).ObsThres =  b{n}{m}(:,9);
    
    Stats.(sprintf('run_%05d', count)).featKept =  b{n}{m}(:,10);
    
    Stats.(sprintf('run_%05d', count)).featOrig =  b{n}{m}(:,11);
    
    Stats.(sprintf('run_%05d', count)).optRef =  b{n}{m}(:,12:18);
    
    Stats.(sprintf('run_%05d', count)).optErr =  b{n}{m}(:,19:20);
    
    Stats.(sprintf('run_%05d', count)).oriErr =  b{n}{m}(:,21:22);
    
    % add the speed variables
    b{n}{m}(1,23:27) = 0;
    for t=2:size(b{n}{m}, 1)
      %
      homm_t = transform44(b{n}{m}(t,2:8));
      homm_t_1 = transform44(b{n}{m}(t-1,2:8));
      homm_speed = homm_t * inv(homm_t_1);
      
      cur_position_err_vec = homm_speed(1:3,4);
      cur_position_err = norm(homm_speed(1:3,4));
      %       cur_orientation_err_vec = vrrotmat2vec(homm_speed(1:3, 1:3));
      %       cur_orientation_err = cur_orientation_err_vec(4);
      cur_orientation_err_vec = rotm2quat(homm_speed(1:3, 1:3));
      %       cur_orientation_err_vec = rotm2eul(homm_speed(1:3, 1:3));
      
      b{n}{m}(t, 23:25) = cur_position_err_vec;
      %       b{n}{m}(t,26:29) = cur_orientation_err_vec;
      b{n}{m}(t, 26:29) = cur_orientation_err_vec;
      %       b{n}{m}(t,25:27) = cur_orientation_err_vec(1:3);
    end
    %
    %     figure;
    %     subplot(2,3,1)
    %     scatter(b{n}{m}(:,9), b{n}{m}(:,23))
    %     subplot(2,3,2)
    %     scatter(b{n}{m}(:,9), b{n}{m}(:,24))
    %     subplot(2,3,3)
    %     scatter(b{n}{m}(:,9), b{n}{m}(:,25))
    %     subplot(2,3,4)
    %     scatter(b{n}{m}(:,9), b{n}{m}(:,26))
    %     subplot(2,3,5)
    %     scatter(b{n}{m}(:,9), b{n}{m}(:,27))
    %
    %     figure;
    %     subplot(2,3,1)
    %     scatter(b{n}{m}(:,10)./b{n}{m}(:,11), b{n}{m}(:,23))
    %     subplot(2,3,2)
    %     scatter(b{n}{m}(:,10)./b{n}{m}(:,11), b{n}{m}(:,24))
    %     subplot(2,3,3)
    %     scatter(b{n}{m}(:,10)./b{n}{m}(:,11), b{n}{m}(:,25))
    %     subplot(2,3,4)
    %     scatter(b{n}{m}(:,10)./b{n}{m}(:,11), b{n}{m}(:,26))
    %     subplot(2,3,5)
    %     scatter(b{n}{m}(:,10)./b{n}{m}(:,11), b{n}{m}(:,27))
    %     figure;plot(b{n}{m}(:,9));hold on;plot(100*b{n}{m}(:,26));
    %     legend({'obs thres'; 'qy (*100)'})
    
  end
  
end

d = arrayfun(@(x) cell2mat(b{x}(:)), 1:length(b), 'UniformOutput', false);
D = cell2mat(d(:));

% motionVec = D(:, 23:29);
% [coe, sc, lat] = pca(motionVec);
%
% figure;
% plot3(sc(:,1), sc(:,2), D(:,9), '.');
% grid on
% xlabel('V_x')
% ylabel('V_z')
% zlabel('Obs_{thres}')

figure;
plot3(D(:,23), D(:,25), D(:,9), '.');
grid on
xlabel('V_x')
ylabel('V_z')
zlabel('Obs_{thres}')
saveas(gcf, 'Vx_Vz_Obs')

figure;
plot3(D(:,26), D(:,27), D(:,9), '.');
grid on
xlabel('R_x')
ylabel('R_y')
zlabel('Obs_{thres}')
saveas(gcf, 'Rx_Ry_Obs')

figure;
plot3(D(:,27), D(:,28), D(:,9), '.');
grid on
xlabel('R_x')
ylabel('R_z')
zlabel('Obs_{thres}')
saveas(gcf, 'Rx_Rz_Obs')

figure;
plot3(D(:,26), D(:,28), D(:,9), '.');
grid on
xlabel('R_y')
ylabel('R_z')
zlabel('Obs_{thres}')
saveas(gcf, 'Ry_Rz_Obs')

%%  learn the regressor

% construct tree to learn mapping of prior ego motion to current desired
% threshold
% tree_method = fitrtree(D(1:end-1,23:29), D(2:end,9)); % predicts one frame ahead

tree_regressor = fitensemble(D(1:end-1,23:29), D(2:end,9), 'Bag', 200, 'Tree',...
  'Type', 'Regression');

vec = bsxfun(@times, rand(1000, 7), [40 10 10 1 0.02 0.02 0.02]);
out = tree_regressor.predict(vec);

figure;
subplot(3,3,1);
plot(vec(:,1), out','.')
subplot(3,3,2);
plot(vec(:,2), out','.')
subplot(3,3,3);
plot(vec(:,3), out','.')
subplot(3,3,4);
plot(vec(:,4), out','.')
subplot(3,3,5);
plot(vec(:,5), out','.')
subplot(3,3,6);
plot(vec(:,6), out','.')
subplot(3,3,7);
plot(vec(:,7), out','.')

save([dataPath '/regressor.mat'], 'tree_regressor')


% figure;plot(D(:,9));hold on;plot(500*D(:,26));
% legend({'obs thres'; 'qy (*500)'})

%
% figure(1);
% scatter(D(:,9), abs(D(:,24)));
% figure(2);
% scatter(D(:,9), abs(D(:,25)));
% figure(3);
% scatter(D(:,9), abs(D(:,26)));
% figure(4);
% scatter(D(:,9), abs(D(:,27)));