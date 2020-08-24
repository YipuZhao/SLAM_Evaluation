function [vld_begin_idx] = findRowsWithBigNorm(arr, norm_thres)

vld_begin_idx = 1;
while vld_begin_idx < size(arr, 1) && norm( arr(vld_begin_idx,:) ) < norm_thres
  vld_begin_idx = vld_begin_idx + 1;
end

end