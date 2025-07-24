%% "Quantum image distillation" - simulation
% 全画素における強度相関関数
% 行列演算を利用したプログラム

function result = intensity_correlation_all_3(photon_distribution, intensity_corr1, intensity_corr2)
% photon_distribution：光子分布画像
% intensity_corr1, intensity_corr2 : 更新前の強度相関関数（height×width, height×width）
% result：構造体．更新後の相関関数の各項を返す.

% 光子分布画像のサイズ
height = size(photon_distribution,1);
width = size(photon_distribution,2);
N = size(photon_distribution,3);

reshaped_array = reshape(permute(photon_distribution,[2,1,3]), 1,height*width,[]); 
reshaped_array = squeeze(reshaped_array);

% 第1項の計算
intensity_corr1 = intensity_corr1 + (reshaped_array * reshaped_array')/N;
intensity_corr1(1:size(intensity_corr1,1)+1:end) = 0; % 自己相関は０
result.corr1 = intensity_corr1; % 更新後の第1項を返す

% 第2項の計算
reshaped_array_1 = photon_distribution(:,:,1:N-1);
reshaped_array_1 = reshape(permute(reshaped_array_1,[2,1,3]), 1,height*width,[]);
reshaped_array_1 = squeeze(reshaped_array_1);

reshaped_array_2 = photon_distribution(:,:,2:N);
reshaped_array_2 = reshape(permute(reshaped_array_2,[2,1,3]), 1,height*width,[]);
reshaped_array_2 = squeeze(reshaped_array_2);

intensity_corr2 = intensity_corr2 + (reshaped_array_1*reshaped_array_2' + reshaped_array_2*reshaped_array_1')/(2*(N-1));
intensity_corr2(1:size(intensity_corr2,1)+1:end) = 0;
result.corr2 = intensity_corr2; % 更新後の第2項を返す


end
