loss_rate_thres = 0.6;
mn=1;

%
for vn=1:length(Fwd_Vel_List)
  err_summ = [];
  
  if plot_msc
    % plot msf
    for fn = 1:length(Number_MF_List)
      if isempty(err_nav_msc{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        return ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_msc, err_est_msc, ...
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
  end
  
  if plot_vif
    % plot vins-fusion
    for fn = 1:length(Number_MF_List)
      if isempty(err_nav_vif{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_vif, err_est_vif, ...
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
  end
  
  if plot_svo
    % plot svo
    for fn = 1:length(Number_SF_List)
      if isempty(err_nav_svo{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_svo, err_est_svo, ...
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
  end
  
  if plot_orb
    % plot orb
    for fn = 1:length(Number_AF_List)
      if isempty(err_nav_orb{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_orb, err_est_orb, ...
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
  end
  
  if plot_lazy
    % plot orb lazy
    for fn = 1:length(Number_AF_List)
      if isempty(err_nav_lazy{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_lazy, err_est_lazy, ...
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
  end
  
  if plot_gf
    % plot the gf
    for fn = 1:length(Number_GF_List)
      if isempty(err_nav_gf{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_gf, err_est_gf, ...
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
  end
  
  if plot_gg
    % plot the gg
    for fn = 1:length(Number_GF_List)
      if isempty(err_nav_gg{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_gg, err_est_gg, ...
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
  end
  
%   if plot_gg_v2
%     % plot the gg v2
%     for fn = 1:length(Number_GF_List)
%       if isempty(err_nav_gf{sn, vn, fn})
%         err_summ = [err_summ nan(round_num, 1)];
%         continue ;
%       end
%       %
%       err_all_rounds = getErrorAllRounds(err_nav_ggv2, err_est_ggv2, ...
%         ii, sn, vn, fn, metric_type{mn}, round_num);
%       %
%       % remove any config with failed run
%       if any(isnan(err_all_rounds))
%         err_summ = [err_summ nan(round_num, 1)];
%         continue ;
%       end
%       %
%       err_summ = [err_summ err_all_rounds];
%     end
%   end
  
  if plot_truth
    % plot the perfet estimator
    for fn = 1:length(Vis_Latency_List)
      if isempty(err_nav_truth{sn, vn, fn})
        err_summ = [err_summ nan(round_num, 1)];
        continue ;
      end
      %
      err_all_rounds = getErrorAllRounds(err_nav_truth, err_est_truth, ...
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
  disp(['==================' metric_type{mn} ' at vel: ' ...
    num2str(Fwd_Vel_List(vn)) ' m/s=================='])
  %   print_idx = [1, 3, 5, 9, 13, 15, 16];
  % print_idx = [1, 2];
%   print_idx = [1, 3, 5, 7, 11, 15, 17, 18];
  print_idx = [5, 1, 3, 7, 11, 15];
% print_idx = [1:size(err_summ,2)];
  err_avg = nanmean(err_summ(:, print_idx));
  for j=1:length(err_avg)
    if j == length(err_avg)
      fprintf(' %.3f \\\\ \n', round( err_avg(j), 4) )
    else
      fprintf(' %.3f &', round( err_avg(j), 4) )
    end
  end
  
end