%% "Quantum image distillation" - simulation
% 全画素における強度相関関数を計算する

function result_all = intensity_correlation_all(photon_distribution, num_selected_pixels)
% photon_distribution：光子分布画像
% result_all：構造体．更新した相関関数の各項を返す

% 画像サイズの取得
[height, width, depth] = size(photon_distribution);
% 全ての画素のインデックスを生成
[mask_y, mask_x] = ndgrid(1:height, 1:width);

mask_y = mask_y(:);
mask_x = mask_x(:);

% 計算結果
result_all.corr1 = zeros(height, width, num_selected_pixels);
result_all.corr2 = zeros(height, width, num_selected_pixels);

% 選択された画素ごとに相関計算
for index = 1:num_selected_pixels
    % 行列インデックスを取得
    y_idx = mask_y(index);
    x_idx = mask_x(index);

    % 注目画素が1である場合だけを抽出する
    logicalArray = photon_distribution(y_idx, x_idx, :) == 1;
    positivePages = photon_distribution(:, :, logicalArray);
    positivePages(y_idx, x_idx, :) = 0;

    % 注目画素が1であるページの次のページのみを抽出する
    nextPageIndices = find(logicalArray) + 1;
    % インデックスが有効な範囲内であるかを確認
    validIndices = nextPageIndices(nextPageIndices <= depth);
    % nextPageIndicesが示すページだけを抽出
    next_positivePages = photon_distribution(:, :, validIndices);
    next_positivePages(y_idx, x_idx, :) = 0;

    % 強度相関関数(第1項と第2項）の計算
    result_all.corr1(:, :, index) = sum(positivePages, 3);
    result_all.corr2(:, :, index) = sum(next_positivePages, 3);

    % 進行状況の表示（オプション）
    fprintf('calculation progress : %d/%d\n' , index, num_selected_pixels);
end
 
end
