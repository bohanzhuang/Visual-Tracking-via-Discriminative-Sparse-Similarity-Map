function [patch_idx, patch_num] = img2patch(psize,patch_size,step_size)
% block the image£¬return the pixel tags of each block and the number of blocks

BlockV = (psize(2)-patch_size)/step_size+1;
BlockH = (psize(1)-patch_size)/step_size+1;
patch_num = BlockV*BlockH;
patch_idx = [];
for i=1:BlockH
    for j=1:BlockV
        temp_patch = zeros(psize(2),psize(1));
        temp_patch((j-1)*step_size+1:(j-1)*step_size+patch_size, (i-1)*step_size+1:(i-1)*step_size+patch_size) = 1;
        temp_idx = find(temp_patch==1);
        patch_idx = [patch_idx; temp_idx];
    end
end

