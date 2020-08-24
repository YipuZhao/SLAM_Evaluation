clear all
close all

addpath('/mnt/DATA/SDK/altmany-export_fig');

methods = {
  'SVO';
  'MSC';
  'GF';
  'ORB';
  'VINS';
  %
    'SVO';
  'MSC';
  'GF';
  'ORB';
  'VINS';
  %
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
  %
    '+';
  'd';
  's';
  'o';
  '*';
  %
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
  %
    [0 0 1];              % svo
  [1 0 0];              % msc
  [0 0 0];              % gf
  [0.3 0.1 0.5];        % orb
  [0 1 0];              % vins
  %
    [0 0 1];              % svo
  [1 0 0];              % msc
  [0 0 0];              % gf
  [0.3 0.1 0.5];        % orb
  [0 1 0];              % vins
  };

ATE = [
  0.23, 0.65, 0.11, 0.24, 10.0, 0.56, 0.26, 0.12, 0.28, 1.36 , 0.49 , 0.22 ,0.14, 0.23, 0.37;
  0.18 , 0.46 , 0.09 , 0.43 ,  10.0, 1.13 , 0.38 , 0.08 ,  10.0  ,  10.0, 1.21 , 0.33 , 0.09 , 3.26 ,  10.0;
  0.92 , 1.54 , 0.12 , 0.31 ,  10.0,  10.0  , 1.01 , 0.10 , 0.23 ,  10.0, 1.26 , 0.81 , 0.11 , 2.10 ,  10.0;
  0.36 , 2.23 , 0.14 ,  10.0  ,  10.0 , 0.86 , 1.53 , 0.12 ,  10.0  ,  10.0, 1.87 , 0.68 , 0.14 ,  10.0  ,  10.0 ;
  2.12 , 2.73 ,  10.0  ,  10.0  ,  10.0, 1.79 , 6.67 , 0.15 ,  10.0  ,  10.0, 1.22 , 2.13 , 0.22 ,  10.0  ,  10.0;
  0.87 , 2.62 , 0.36 , 0.24 ,  10.0, 1.27 , 3.25 , 0.35 , 0.31 ,  10.0, 2.78 , 2.66 , 0.35 , 0.37 ,  10.0;
  ];

latency = {
  8.9,  17.7,  32.8, 52.4, 55.0, 8.9, 16.9, 32.4 , 51.7 , 73.9 , 8.9 , 16.7 , 32.0, 50.6, 64.1
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

legend()

xlabel('Visual Estimation Latency (ms)');
ylabel('Closed-loop ATE (m)');

legend_style = gobjects(5,1);
for i=1:5
  legend_style(i) = plot(nan, nan, marker_symbol{i}, ...
    'color', marker_color{i});
end
legend(legend_style, methods{1:5}, 'Location', 'best')

set(gca, 'YScale', 'log');

export_fig(h, [save_path '/CloseLoop.fig']); % , '-r 200');
export_fig(h, [save_path '/CloseLoop.png']); % , '-r 200');
