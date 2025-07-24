%% "Quantum image distillation" - simulation

function photon_distribution = generate_photon_distribution(height, width, photon_prob, num_qu, num_cl, noise, prob_density, quantum_mask, classical_mask)
% size：光子分布画像のサイズ
% photon_prob：アイドラー光子が出現する確率
% num_pairs：光子分布画像1枚あたりの光子対（=シグナル光子）の数
% noise：ノイズの大きさ
% prob_density：確率密度分布
% photon_distribution：光子分布画像

    % 光子分布画像の初期化
    photon_distribution = zeros(height,width);

    % Step1：量子光源による光子分布を作成

    % ポアソン分布から，1枚あたりの光子数を決定
    photon_pairs_qu = poissonRnd(num_qu);
    photon_pairs_cl = poissonRnd(num_cl);

    % 量子もつれ光源
    for pair = 1:photon_pairs_qu
        % signal光子の生成：確率密度に従ってランダムに位置を選択
        %{
       [i_signal, j_signal] = chooseRandomPosition(prob_density, size);
        photon_distribution(i_signal, j_signal) = 1;
        assignin('base', 'signal', [i_signal, j_signal]);  % debug用
        %}
        while true
            i_signal = randi(height);
            j_signal = randi(width);
            if rand() < prob_density(i_signal, j_signal)
                break;
            end
        end
        photon_distribution(i_signal, j_signal) = 1;

        % idler光子の生成
        i_idler = i_signal + (poissonRnd(4) - poissonRnd(4));
        j_idler = j_signal + (poissonRnd(4) - poissonRnd(4));

        % 画像の範囲内に対称位置があることを確認し、範囲外の場合は範囲内の値にする
        i_idler = max(1, min(i_idler, height));
        j_idler = max(1, min(j_idler, width));

        % 確率photon_probでidelr光子が出現
        if rand() <= photon_prob
            photon_distribution(i_idler, j_idler) = 1;
        end

    end

    % マスク処理
    quantum_mask = quantum_mask / 255;
    photon_distribution = bsxfun(@times, photon_distribution, quantum_mask);

   % Step2：古典光源による光子分布を付け加える
   classical_image = zeros(height, width);
   for pair = 1:photon_pairs_cl
   %for pair = 1:photon_pairs
       % 確率密度に従ってランダムに位置を選択
       while true
           i_classical = randi(height);
           j_classical = randi(width);
           % 選択した画素がすでに1である場合、別の画素を選択しなおす
           if classical_image(i_classical, j_classical) ~= 1 && rand() < prob_density(i_classical, j_classical)
               break;
           end
       end
       classical_image(i_classical, j_classical) = 1;
   end
    % マスク処理
    classical_mask = classical_mask / 255;
    classical_image = bsxfun(@times, classical_image, classical_mask);

    % Step3：量子光と古典光を足し合わせる
    photon_distribution = photon_distribution + classical_image;


    % ノイズの付加
    num_noise = poissonRnd(noise); % ノイズの個数
    for nz = 1:num_noise
        rand_i = randi([1,height]); 
        rand_j = randi([1,width]); 
        photon_distribution(rand_i,rand_j) = 1; % ランダムな位置の画素を1に置き換える
    end
    

end

function prob = poisspdf(k, lambda)
    prob = (lambda .^ k) .* exp(-lambda) ./ gamma(k + 1);
    % note：kが整数の場合，Γ(k+1)=k!
end

% ポアソン分布による乱数
function r = poissonRnd(lambda)
    L = exp(-lambda);
    p = 1;
    k = 0;
    while p > L
        k = k + 1;
        p = p * rand();
    end
    r = k - 1;
end
%{
function [i, j] = chooseRandomPosition(prob_density, size)
    % 2次元確率密度からランダムに位置を選択
    index = randi(numel(prob_density));
    [i, j] = ind2sub(size, index);
end
%}
