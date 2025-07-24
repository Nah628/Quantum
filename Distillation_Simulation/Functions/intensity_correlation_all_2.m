%% "Quantum image distillation" - simulation
% 全画素における強度相関関数を計算する

function result_all = intensity_correlation_all_2(photon_distribution)
% photon_distribution：光子分布画像
% result_all：構造体．更新した相関関数の各項を返す

% 画像サイズの取得
[height, width, N] = size(photon_distribution);

% 計算結果
result_all.corr1 = zeros(height*width, height*width);
result_all.corr2 = zeros(height*width, height*width);

% 第１項
fprintf('  test1.\n');
reshaped_array = reshape(permute(photon_distribution,[2,1,3]), 1,height*width,[]); 
reshaped_array = squeeze(reshaped_array);
result_all.corr1 = (reshaped_array * reshaped_array')/N;
result_all.corr1(1:size(result_all.corr1,1)+1:end) = 0;

% 第２項
fprintf('  test2.\n');
reshaped_array_1 = photon_distribution(:,:,1:N-1);
reshaped_array_1 = reshape(permute(reshaped_array_1,[2,1,3]), 1,height*width,[]);
reshaped_array_1 = squeeze(reshaped_array_1);

reshaped_array_2 = photon_distribution(:,:,2:N);
reshaped_array_2 = reshape(permute(reshaped_array_2,[2,1,3]), 1,height*width,[]);
reshaped_array_2 = squeeze(reshaped_array_2);
result_all.corr2 = (reshaped_array_1*reshaped_array_2' + reshaped_array_2*reshaped_array_1')/(2*(N-1));
result_all.corr2(1:size(result_all.corr2,1)+1:end) = 0;

end
 
