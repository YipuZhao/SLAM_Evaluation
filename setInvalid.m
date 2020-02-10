function [arr_set] = setInvalid(arr_ori, invalid_flg)

invalid_idx = [arr_ori == invalid_flg];
arr_set = arr_ori;
arr_set(invalid_idx) = nan;

end