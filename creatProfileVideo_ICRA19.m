clear all;
close all;

%% load log
disp(['Loading ORB log...'])
log_{1} = [];
[log_{1}] = loadLogTUM_hash_mono('/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/Video_Demo/ORBv1_Demo/ObsNumber_800', ...
  1, 'left_cam', log_{1}, 1);
%
disp(['Loading MapHash log...'])
log_{2} = [];
[log_{2}] = loadLogTUM_hash_mono('/mnt/DATA/Dropbox/PhD/Projects/Visual_SLAM/Experimental_ICRA19/Video_Demo/ORBv1_MapHash_Demo/ObsNumber_800', ...
  1, 'left_cam', log_{2}, 1);

fps = 20;
N = size(log_{1}.timeStamp{1},1);
legend_arr = {'Map Size - ORB';'Map Size - MapHash'; 'Match Num - ORB';'Match Num - MapHash'};
timeStamp_ori = log_{2}.timeStamp{1}(190);

%% plot the beginning 32 sec
% h=figure(1);
% clf
% xlabel('Duration (sec)')
% ylabel('Num. of Features/Matchings')
% %
% % marker_styl = {
% %   '-';
% %   '-';
% %   '--';
% %   '--';
% %   };
% % marker_color = {
% %   [0.93,0.93,0.2];
% %   [0.09,0.73,0.09];
% %   [0 1 1];
% %   [0 1 0];
% %   };
% % legend_style = gobjects(length(legend_arr),1);
% % for i=1:length(legend_arr)
% %   legend_style(i) = plot(nan, nan, marker_styl{i}, ...
% %     'color', marker_color{i});
% % end
% % legend(legend_style, legend_arr, 'Location', 'northwest')
% %
% i=1;
% for ii=191:min(N, 190 + fps * 32)
%   hold on
%   plot([log_{1}.timeStamp{1}(ii-1) log_{1}.timeStamp{1}(ii)], ...
%     [log_{1}.lmkComb{1}(ii-1) log_{1}.lmkComb{1}(ii)], ...
%     'Color', [0.93,0.93,0.20]);
%   plot([log_{2}.timeStamp{1}(ii-1) log_{2}.timeStamp{1}(ii)], ...
%     [log_{2}.lmkComb{1}(ii-1) log_{2}.lmkComb{1}(ii)], ...
%     'Color', [0.09,0.73,0.09]);
%   plot([log_{1}.timeStamp{1}(ii-1) log_{1}.timeStamp{1}(ii)], ...
%     [log_{1}.lmkRefTrack{1}(ii-1) log_{1}.lmkRefTrack{1}(ii)], ...
%     'y--');
%   plot([log_{2}.timeStamp{1}(ii-1) log_{2}.timeStamp{1}(ii)], ...
%     [log_{2}.lmkRefTrack{1}(ii-1) log_{2}.lmkRefTrack{1}(ii)], ...
%     'g--');
%   %
% %   scatter(log_{1}.timeStamp{1}(ii), log_{1}.lmkComb{1}(ii), ...
% %     'x', 'MarkerFaceColor', [0.93,0.93,0.20], ...
% %     'MarkerEdgeColor', [0.93,0.93,0.20]);
% %   scatter(log_{2}.timeStamp{1}(ii), log_{2}.lmkComb{1}(ii), ...
% %     'x', 'MarkerFaceColor', [0.09,0.73,0.09], ...
% %     'MarkerEdgeColor', [0.09,0.73,0.09]);
% %   scatter(log_{1}.timeStamp{1}(ii), log_{1}.lmkRefTrack{1}(ii), ...
% %     's', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y');
% %   scatter(log_{2}.timeStamp{1}(ii), log_{2}.lmkRefTrack{1}(ii), ...
% %     's', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
%   hold off
%   %
%   legend(legend_arr, 'Location', 'northwest')
%   xlim([timeStamp_ori log_{2}.timeStamp{1}(ii)])
%   set(gca, 'YScale', 'log')
%   F1(i) = getframe(h);
%   i = i + 1;
%   drawnow
%   %   view([-35.6 66.8])
% %   pause(0.001)
%   %     export_fig(h, [save_path '/tmp/' seq_idx '-' num2str(ii, '%05d') '.png']);
% end
%
% % create the video writer with 1 fps
% writerObj = VideoWriter('icra19_video_part1.avi');
% writerObj.FrameRate = fps;
% % set the seconds per image
% % open the video writer
% open(writerObj);
% % write the frames to the video
% for i=1:length(F1)
%   % convert the image to a frame
%   frame = F1(i) ;
%   writeVideo(writerObj, frame);
% end
% % close the writer object
% close(writerObj);

%% plot the rest
h=figure(2);
clf
xlabel('Duration (sec)')
ylabel('Num. of Features/Matchings')
hold on
plot([log_{1}.timeStamp{1}(190:190 + fps * 32)], ...
  [log_{1}.lmkComb{1}(190:190 + fps * 32)], ...
  'Color', [0.93,0.93,0.20]);
plot([log_{2}.timeStamp{1}(190:190 + fps * 32)], ...
  [log_{2}.lmkComb{1}(190:190 + fps * 32)], ...
  'Color', [0.09,0.73,0.09]);
plot([log_{1}.timeStamp{1}(190:190 + fps * 32)], ...
  [log_{1}.lmkRefTrack{1}(190:190 + fps * 32)], ...
  'y--');
plot([log_{2}.timeStamp{1}(190:190 + fps * 32)], ...
  [log_{2}.lmkRefTrack{1}(190:190 + fps * 32)], ...
  'g--');
set(gca, 'YScale', 'log')
hold off
%
i=1;
step = 30;
for ii=190+fps*32+step:step:N
  hold on
  plot([log_{1}.timeStamp{1}(ii-step) log_{1}.timeStamp{1}(ii)], ...
    [log_{1}.lmkComb{1}(ii-step) log_{1}.lmkComb{1}(ii)], ...
    'Color', [0.93,0.93,0.20]);
  plot([log_{2}.timeStamp{1}(ii-step) log_{2}.timeStamp{1}(ii)], ...
    [log_{2}.lmkComb{1}(ii-step) log_{2}.lmkComb{1}(ii)], ...
    'Color', [0.09,0.73,0.09]);
  plot([log_{1}.timeStamp{1}(ii-step) log_{1}.timeStamp{1}(ii)], ...
    [log_{1}.lmkRefTrack{1}(ii-step) log_{1}.lmkRefTrack{1}(ii)], ...
    'y--');
  plot([log_{2}.timeStamp{1}(ii-step) log_{2}.timeStamp{1}(ii)], ...
    [log_{2}.lmkRefTrack{1}(ii-step) log_{2}.lmkRefTrack{1}(ii)], ...
    'g--');
  %
  hold off
  %
  legend(legend_arr, 'Location', 'northwest')
  xlim([timeStamp_ori log_{2}.timeStamp{1}(ii)])
  set(gca, 'YScale', 'log')
  F2(i) = getframe(h) ;
  i = i + 1;
  drawnow
end

% create the video writer with 1 fps
writerObj = VideoWriter('icra19_video_part2.avi');
writerObj.FrameRate = fps;
% set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F2)
  % convert the image to a frame
  frame = F2(i) ;
  writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
