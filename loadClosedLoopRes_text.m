save_to_matlab = true;
Prefix = 'ObsNumber_';

for sn=1:length(Seq_Name_List)
  for vn = 1:length(Fwd_Vel_List)
    
    for fn = 1:length(Number_SF_List)
      err_nav_svo{sn, vn, fn} = [];
      err_est_svo{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_MF_List)
      err_nav_msc{sn, vn, fn} = [];
      err_est_msc{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_MF_List)
      err_nav_vif{sn, vn, fn} = [];
      err_est_vif{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_AF_List)
      err_nav_orb{sn, vn, fn} = [];
      err_est_orb{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_AF_List)
      err_nav_lazy{sn, vn, fn} = [];
      err_est_lazy{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_GF_List)
      err_nav_gf{sn, vn, fn} = [];
      err_est_gf{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_GF_List)
      err_nav_gg{sn, vn, fn} = [];
      err_est_gg{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Vis_Latency_List)
      err_nav_truth{sn, vn, fn} = [];
      err_est_truth{sn, vn, fn} = [];
    end
    
    for rn = 1 : round_num
      if plot_msc
        %% load msckf results
        for fn = 1:length(Number_MF_List)
          
          [err_nav_msc{sn, vn, fn}, err_est_msc{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'MSCKF', ...
            Prefix, Number_MF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_msc{sn, vn, fn}, err_est_msc{sn, vn, fn});
          
        end
      end
      
      if plot_vif
        %% load vins-fusion results
        for fn = 1:length(Number_MF_List)
          
          [err_nav_vif{sn, vn, fn}, err_est_vif{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'VIFusion', ...
            Prefix, Number_MF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_vif{sn, vn, fn}, err_est_vif{sn, vn, fn});
          
        end
      end
      
      if plot_svo
        %% load svo results
        for fn = 1:length(Number_SF_List)
          
          [err_nav_svo{sn, vn, fn}, err_est_svo{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'SVO', ...
            Prefix, Number_SF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_svo{sn, vn, fn}, err_est_svo{sn, vn, fn});
          
        end
      end
      
      if plot_orb
        %% load orb results
        for fn = 1:length(Number_AF_List)
          
          [err_nav_orb{sn, vn, fn}, err_est_orb{sn, vn, fn}, arr_plan{sn, vn, fn}] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'ORB', ... 'ORB_skf_gpu', ...
            Prefix, Number_AF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_orb{sn, vn, fn}, err_est_orb{sn, vn, fn});
          
        end
      end
      
      if plot_lazy
        %% load lazy orb results
        for fn = 1:length(Number_AF_List)
          
          [err_nav_lazy{sn, vn, fn}, err_est_lazy{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'ORB_lazy', ...
            Prefix, Number_AF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_lazy{sn, vn, fn}, err_est_lazy{sn, vn, fn});
          
          End_Point_List{sn} = arr_plan{sn, vn, fn}(end, 2:3);
          
        end
      end
      
      if plot_gf
        %% load gf results
        for fn = 1:length(Number_GF_List)
          
          %% load msf results
          [err_nav_gf{sn, vn, fn}, err_est_gf{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'GF_skf', ...'GF_gpu_skf', ...
            Prefix, Number_GF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_gf{sn, vn, fn}, err_est_gf{sn, vn, fn});
          
        end
      end
      
      if plot_gg
        %% load gg results
        for fn = 1:length(Number_GF_List)
          
          %% load msf results
          [err_nav_gg{sn, vn, fn}, err_est_gg{sn, vn, fn}, ~] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'GF_GG_skf', ...'GF_GG_skf_gpu', ...
            Prefix, Number_GF_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_gg{sn, vn, fn}, err_est_gg{sn, vn, fn});
          
        end
      end
      
      if plot_truth
        %% load perfect estimator results
        for fn = 1:length(Vis_Latency_List)
          
          %% load msf results
          [err_nav_truth{sn, vn, fn}, err_est_truth{sn, vn, fn}, arr_plan{sn, vn, fn}] = ...
            processClosedLoopText(data_dir, Seq_Name_List{sn}, imu_type, 'ideal', ...
            'Latency_', Vis_Latency_List(fn), Fwd_Vel_List(vn), rn, ...
            err_nav_truth{sn, vn, fn}, err_est_truth{sn, vn, fn});
          
        end
      end
      
      %% debug viz
      %       figure;
      %       plot3(arr_plan(:, 2), arr_plan(:, 3), arr_plan(:, 4));
      %       hold on
      %       plot3(arr_odom(:, 2), arr_odom(:, 3), arr_odom(:, 4));
      %       plot3(arr_msf(:, 2), arr_msf(:, 3), arr_msf(:, 4));
      
    end
  end
end