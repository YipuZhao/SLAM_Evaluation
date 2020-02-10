loss_rate_thres = 0.6;
mn=1;

%
for vn=1:length(Fwd_Vel_List)
  err_summ = [];
  
  % plot the latency demo
  for fn = 1:length(Latency_List)
    if isempty(err_nav_delay{sn, vn, fn})
      err_summ = [err_summ nan(round_num, 1)];
      continue ;
    end
    %
    err_all_rounds = getErrorAllRounds(err_nav_delay, err_est_delay, ...
      ii, sn, vn, fn, metric_type{mn}, round_num);
    %
    % remove any config with failed run
    if any(isnan(err_all_rounds))
      err_summ = [err_summ nan(round_num, 1)];
      continue ;
    end
    %
    err_summ = [err_summ err_all_rounds];
  end
  
  %
  hs = subplot(length(Fwd_Vel_List), length(metric_type), (mn-1)*length(Fwd_Vel_List) + vn);
  boxplot(err_summ, legend_arr, 'Symbol', 'x')
  ylabel(metric_type{mn});
  set(hs, 'YScale', 'log');
  %     boxplot(err_summ, {'ORB'; 'GF'; 'ORB'; 'GF'}, 'Symbol', '')
  set(hs, 'TickLabelInterpreter', 'tex');
  %       set(gca,'TickLabelInterpreter', 'tex');
  title(['Target Velocity ' num2str(Fwd_Vel_List(vn)) ' (m/s)'])
  
  %% print out tex table
  %   disp(['==================' metric_type{mn} ' at vel: ' ...
  %     num2str(Fwd_Vel_List(vn)) ' m/s=================='])
  %   print_idx = [1, 3, 5, 9, 13];
  % %   print_idx = [1, 3, 5, 7, 9, 12, 13];
  %   err_avg = nanmean(err_summ(:, print_idx));
  %   for j=1:length(err_avg)
  %     if j == length(err_avg)
  %       fprintf(' %.3f \\\\ \n', round( err_avg(j), 4) )
  %     else
  %       fprintf(' %.3f &', round( err_avg(j), 4) )
  %     end
  %   end
  
end