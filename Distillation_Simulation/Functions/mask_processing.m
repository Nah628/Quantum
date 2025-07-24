%% "Quantum image distillation" - simulation

function masked_distribution = mask_processing(photon_distribution, mask_data)
% photon_distribution：光子分布
% mask_path：マスク画像
% masked_distribution：マスク処理後の光子分布

mask_data = mask_data / 255;

% マスク処理を行う
masked_distribution = bsxfun(@times, photon_distribution, mask_data);

end