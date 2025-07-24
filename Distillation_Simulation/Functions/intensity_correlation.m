%% "Quantum image distillation" - simulation

function result = intensity_correlation(photon_distribution, x_value, y_value)
% photon_distribution：光子分布画像
% x_value, y_value：相関を計算する画素
% intensity_corr1, intensity_corr2：強度相関関数
% result：構造体．更新した相関関数の各項を返す

N = size(photon_distribution,3);

% photon_distributionを使った相関計算
% 注目画素が1であるページだけを抽出する
logicalArray = photon_distribution(y_value, x_value, :) == 1;
positivePages = photon_distribution(:, :, logicalArray);
positivePages(y_value, x_value, :) = 0;

% 注目画素が1であるページの次のページのみを抽出する
nextPageIndices = find(logicalArray) + 1;
% インデックスが有効な範囲内であるかを確認
validIndices = nextPageIndices(nextPageIndices <= N);
% nextPageIndicesが示すページだけを抽出
next_positivePages = photon_distribution(:, :, validIndices);
next_positivePages(y_value,x_value,:) = 0;

% 強度相関関数(第1項と第2項）
result.corr1 = sum(positivePages,3);
result.corr2 = sum(next_positivePages,3);

end

