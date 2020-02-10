loss_rate_thres = 0.6;

for mn=1:length(metric_type)
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
    
    %
    hs = subplot(length(metric_type), length(Fwd_Vel_List), (mn-1)*length(Fwd_Vel_List) + vn);
    boxplot(err_summ, legend_arr, 'Symbol', 'x')
    ylabel(metric_type{mn});
    set(hs, 'YScale', 'log');
    %     boxplot(err_summ, {'ORB'; 'GF'; 'ORB'; 'GF'}, 'Symbol', '')
    set(hs, 'TickLabelInterpreter', 'tex');
    %       set(gca,'TickLabelInterpreter', 'tex');
    title(['Target Velocity ' num2str(Fwd_Vel_List(vn)) ' (m/s)'])
    
  end
end