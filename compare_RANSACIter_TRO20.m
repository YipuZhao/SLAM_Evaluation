clc
close ALL
clear ALL

num_lmk_out = [30:30:180];
num_lmk_all = 600;
iter_ransac = [300 200 100 50 20]';

%%
time_avg = [
  0.000567494 0.000605648 0.000637435 0.000682884 0.000731352 0.000800726 
  0.000573989 0.000607069 0.000633778 0.00067508 0.000730899 0.000801207 
  0.000567642 0.000605097 0.000635853 0.000676845 0.000735944 0.000809378 
  0.000568144 0.000598029 0.000626552 0.000671303 0.000732489 0.000799397 
  0.00057488 0.000609654 0.000641258 0.000685715 0.000736116 0.000814997 
  ] * 1000;

time_max = [
  0.00126261 0.00102901 0.00128199 0.00110197 0.00122245 0.00133057 
  0.00134817 0.00115746 0.00124327 0.00126889 0.00126543 0.00144714 
  0.00137658 0.00113649 0.000983811 0.00119177 0.00120882 0.00200676 
  0.00141833 0.00112267 0.00319713 0.00124384 0.00114638 0.00128734 
  0.00131756 0.00111273 0.00119857 0.00119086 0.0012636 0.00151134 
  ] * 1000;

time_min = [
  0.000505388 0.000518066 0.000547462 0.000589267 0.000617948 0.000666702
  0.000503002 0.00051621 0.000542092 0.000583416 0.000615063 0.000674992 
  0.00048692 0.000520326 0.000558724 0.000564878 0.00061455 0.000663641 
  0.000480231 0.000505032 0.000536084 0.000579384 0.000603785 0.000664364 
  0.000483159 0.00053628 0.000543198 0.000593825 0.000623928 0.000672362 
  ] * 1000;

diff_avg = [
  13.0556 12.5866 10.7034 9.796 9.596 9.4232
  12.22 12.5246 11.3444 10.2922 9.6308 9.4296 
  12.6858 11.1046 10.7192 10.1422 9.8682 9.6102
  12.9252 11.6762 11.0414 10.01 9.5998 9.309 
  13.7618 12.6586 10.941 11.149 9.6268 10.4962 
  ];

diff_max = [
  85 127 100 92 85 99 
  90 108 114 90 96 105 
  113 106 112 90 92 90 
  104 117 95 105 99 85 
  121 165 101 107 161 197 
  ];

diff_min = [
  0 0 0 0 0 0
  0 0 0 0 0 0
  0 0 0 0 0 0
  0 0 0 0 0 0
  0 0 0 0 0 0
  ];

%%
figure;
for i=1:length(num_lmk_out)
  subplot(3, 2, i)
  yyaxis left
  errorbar(iter_ransac, diff_avg(:, i), ...
    diff_avg(:, i) - diff_min(:, i), ...
    diff_max(:, i) - diff_avg(:, i));
  xlabel('iter no')
  ylabel('diff. inlier extracted')
  %   xlim([0.5 1.6])
  %   ylim([0 40])
  %
  yyaxis right
  errorbar(iter_ransac + 5, time_avg(:, i), ...
    time_avg(:, i) - time_min(:, i), ...
    time_max(:, i) - time_avg(:, i));
  ylabel('time cost')
  set(gca, 'YScale', 'log')
  
  title([ num2str(num_lmk_out(i)) '/' num2str(num_lmk_all) ])
end