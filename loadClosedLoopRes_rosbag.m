save_to_matlab = true;

for sn=1:length(Seq_Name_List)
  for vn = 1:length(Fwd_Vel_List)
    
    for fn = 1:length(Number_AF_List)
      err_nav_svo{sn, vn, fn} = [];
      err_est_svo{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_MF_List)
      err_nav_msc{sn, vn, fn} = [];
      err_est_msc{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_AF_List)
      err_nav_orb{sn, vn, fn} = [];
      err_est_orb{sn, vn, fn} = [];
    end
    
    for fn = 1:length(Number_GF_List)
      err_nav_gf{sn, vn, fn} = [];
      err_est_gf{sn, vn, fn} = [];
    end
    
    for rn = 1 : round_num
%       %% load msckf results
%       for fn = 1:length(Number_MF_List)
%         
%         [err_nav_msc{sn, vn, fn}, err_est_msc{sn, vn, fn}, arr_path{sn, vn, fn}] = ...
%           processClosedLoopBag(data_dir, Seq_Name_List{sn}, imu_type, 'MSCKF', ...
%           Number_MF_List(fn), Fwd_Vel_List(vn), rn, ...
%           err_nav_msc{sn, vn, fn}, err_est_msc{sn, vn, fn});
%         
%       end
%       
%       %% load svo results
%       for fn = 1:length(Number_AF_List)
%         
%         [err_nav_svo{sn, vn, fn}, err_est_svo{sn, vn, fn}, arr_path{sn, vn, fn}] = ...
%           processClosedLoopBag(data_dir, Seq_Name_List{sn}, imu_type, 'SVO', ...
%           Number_AF_List(fn), Fwd_Vel_List(vn), rn, ...
%           err_nav_svo{sn, vn, fn}, err_est_svo{sn, vn, fn});
%         
%       end
      
      %% load orb results
      for fn = 1:length(Number_AF_List)
        
        [err_nav_orb{sn, vn, fn}, err_est_orb{sn, vn, fn}, arr_plan{sn, vn, fn}] = ...
          processClosedLoopBag(data_dir, Seq_Name_List{sn}, imu_type, 'ORB', ...
          Number_AF_List(fn), Fwd_Vel_List(vn), rn, ...
          err_nav_orb{sn, vn, fn}, err_est_orb{sn, vn, fn});
        
        End_Point_List{sn} = arr_plan{sn, vn, fn}(end, 2:3);
        
      end
      
      %%
      %       figure;
      %       plot3(arr_path(:, 2), arr_path(:, 3), arr_path(:, 4));
      %       hold on
      %       plot3(arr_odom(:, 2), arr_odom(:, 3), arr_odom(:, 4));
      %       plot3(arr_msf(:, 2), arr_msf(:, 3), arr_msf(:, 4));
      
      
      %% load gf results
      for fn = 1:length(Number_GF_List)
        
        %% load msf results
        [err_nav_gf{sn, vn, fn}, err_est_gf{sn, vn, fn}, arr_plan{sn, vn, fn}] = ...
          processClosedLoopBag(data_dir, Seq_Name_List{sn}, imu_type, 'GF', ...
          Number_GF_List(fn), Fwd_Vel_List(vn), rn, ...
          err_nav_gf{sn, vn, fn}, err_est_gf{sn, vn, fn});
        
      end
    end
  end
end