function printErrStat(err_summ, legend_arr, style)

if nargin < 3
  style = 'info';
end

for i=1:length(legend_arr)
  
  mean_tmp = nanmean(err_summ(i, :, :));
  med_tmp = nanmedian(err_summ(i, :, :));
  std_tmp = nanstd(err_summ(i, :, :));
  
  switch style
    case 'info'
      fprintf([ legend_arr{i} ': mean = ' num2str(mean_tmp(:)') '\n' ])
    case 'stat'
      fprintf([ legend_arr{i} ': median = ' num2str(med_tmp(:)') ...
        '; mean = ' num2str(mean_tmp(:)')
        '; std = ' num2str(std_tmp(:)') '\n' ])
    case 'latex'
      if i == length(legend_arr)
        fprintf(' %.3f\n', mean_tmp(:)')
      else
        fprintf(' %.3f &', mean_tmp(:)')
      end
  end
  
end

end