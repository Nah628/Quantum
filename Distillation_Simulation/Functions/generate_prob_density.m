% "Quantum image distillation"

function prob_density = generate_prob_density(height, width)
    % 光子の確率密度分布を作成する
    size = [height,width];

%{
    % 確率密度分布の生成
    lambda = [5.5, 5.5]; % % ポアソン分布の平均値（x軸とy軸のそれぞれ）
    x = linspace(0, 10, 256);
    y = linspace(0, 10, 256);
    [X, Y] = meshgrid(x, y);

    % 各座標におけるポアソン分布の確率密度を計算
    prob_density = poisspdf(X, lambda(1)) .* poisspdf(Y, lambda(2));
    prob_density = prob_density / max(prob_density(:));
    assignin('base', 'prob_density',prob_density);  % debug用
%}


    % リングのパラメータ設定
    ring_radius = floor(min(size) / 2); % 半径
    ring_center = [size(1)/2+1, size(2)/2+1]; % 中心座標

    % リングの確率分布を生成
    [X, Y] = meshgrid(1:size(2), 1:size(1));
    distance_to_center = sqrt((X - ring_center(1)).^2 + (Y - ring_center(2)).^2);
    prob_density = double(distance_to_center <= ring_radius);
    assignin('base', 'prob_density',prob_density);  % debug用

    % 確率分布をガウスフィルタで平滑化
    %prob_density = imgaussfilt(double(prob_density), ring_thickness);
    % 正規分布で確率密度分布を平滑化
    sigma = ring_radius / 5; % 標準偏差
    filter = fspecial('gaussian', size, sigma);
    prob_density = imfilter(prob_density, filter, 'replicate');

end