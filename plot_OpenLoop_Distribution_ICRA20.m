clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');

methods = {
  'SVO';
  'MSC';
  'GF';
  'ORB';
  'VINS';
  };

marker_symbol = {
  '+';
  'd';
  's';
  'o';
  '*';
  };

marker_color = {
  [0 0 1];              % svo
  [1 0 0];              % msc
  [0 0 0];              % gf
  [0.3 0.1 0.5];        % orb
  [0 1 0];              % vins
  };

ATE = [
  0.15, 0.21, 0.12, 0.14, 0.14;
  0.12, 0.14, 0.11, 0.38, 0.13;
  0.33, 0.32, 0.19, 0.16, 10.0;
  0.45, 0.29, 0.19, 0.20, 0.33;
  0.42, 0.57, 0.25, 0.09, 0.57;
  10.0, 0.51, 0.29, 0.38, 0.47;
  ];

latency = {
  9.3, 14.2, 26.2, 47.5, 62.0
  };

save_path = './output/ICRA20/';

%%
h = figure;
clf
hold on
for mn=1:length(methods)
  for sn=1:size(ATE,1)
    scatter(latency{mn}, ATE(sn, mn), 20, marker_color{mn}, marker_symbol{mn})
  end
end

xlabel('Visual Estimation Latency (ms)');
ylabel('Open-loop ATE (m)');

legend_style = gobjects(length(methods),1);
for i=1:length(methods)
  legend_style(i) = plot(nan, nan, marker_symbol{i}, ...
    'color', marker_color{i});
end
legend(legend_style, methods, 'Location', 'best')

rectangle('Position',[0,5,80,5],'FaceColor',[0 .5 .5],'EdgeColor','b',...
    'LineWidth',1)
set(gca, 'YScale', 'log');

export_fig(h, [save_path '/OpenLoop.fig']); % , '-r 200');
export_fig(h, [save_path '/OpenLoop.png']); % , '-r 200');
