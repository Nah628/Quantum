%% "Quantum image distillation" - simulation
% 全画素における強度相関関数を計算する

function result_all = intensity_correlation_all(photon_distribution, mask_1, mask_2,num_selected_pixels)
% photon_distribution：光子分布画像
% mask_1, mask_2：マスク画像（0のところは強度相関関数を計算しない）
% result_all：構造体．更新した相関関数の各項を返す

% 画像サイズの取得
[height, width, depth] = size(photon_distribution);

% マスク画像で選択された画素のインデックスを取得
[mask_y, mask_x] = find(mask_1 == 255 | mask_2 == 255);

% 光子が到達している画素のみ計算の対象とする
result_all = struct('corr1', zeros(height, width, num_selected_pixels), ...
                    'corr2', zeros(height, width, num_selected_pixels));

% 選択された画素ごとに相関計算
for index = 1:num_selected_pixels
    if index > length(mask_y)
        break;
    end

    % 注目画素が1である場合だけを抽出する
    logicalArray = photon_distribution(mask_y(index), mask_x(index), :) == 1;
    positivePages = photon_distribution(:, :, logicalArray);
    positivePages(mask_y(index), mask_x(index), :) = 0;

    % 注目画素が1であるページの次のページのみを抽出する
    nextPageIndices = find(logicalArray) + 1;
    % インデックスが有効な範囲内であるかを確認
    validIndices = nextPageIndices(nextPageIndices <= depth);
    % nextPageIndicesが示すページだけを抽出
    next_positivePages = photon_distribution(:, :, validIndices);
    next_positivePages(mask_y(index),mask_x(index),:) = 0;

    % 強度相関関数(第1項と第2項）の計算
    result_all.corr1(:, :, index) = sum(positivePages, 3);
    result_all.corr2(:, :, index) = sum(next_positivePages, 3);

    %fprintf('calculation progress : %d/%d\n' , index, num_selected_pixels);
end

end
