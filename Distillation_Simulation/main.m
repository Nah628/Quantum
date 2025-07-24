%% "Quantum image distillation" - simulation
clear; clc; close all;

addpath('C:\MATLAB\Distillation simulation\Functions\');
% 保存先のディレクトリ
saveDir = 'C:\Users\yoshi\OneDrive - 神戸大学【全学】\simulation';

% 出力画像のサイズ
height = 128;  width = 128;
% マスク画像
classical_mask = double(imread('alive_cat.bmp'));
quantum_mask = double(imread('dead_cat.bmp'));

noise = 10;

% 画像１枚あたりの光子対の数の平均
num_qu = 20;
num_cl = num_qu;

% データ数（num_dataSet × num_images）
num_dataSet = 25;  % 出力データセット数
num_images = 10000;  % 1セットの出力枚数

% 対称な位置に光子が発現する確率
photon_prob = 0.8;

% 相関を計算する画素
%x_value = 70;  y_value = 70;

sum_distribution = zeros(height, width);

% 強度相関関数
num_selected_pixels = height * width; % 強度相関関数を計算する画素数

% intensity_corr1 = zeros(img_size(1), img_size(2)); % 第1項
% intensity_corr2 = zeros(img_size(1), img_size(2)); % 第2項
intensity_corr1 = zeros(height*width, height*width);
intensity_corr2 = zeros(height*width, height*width);

tic 

% 確率密度分布の生成
prob_density = generate_prob_density(height,width);

for ds = 1:num_dataSet
    photon_distribution = zeros(height, width, num_images); % 光子分布用の配列を初期化
    fprintf('photon distribution progress : %d/%d\n' , ds, num_dataSet);
    for img = 1:num_images
        fprintf(' progress : %d/%d\n', img,num_images);
        photon_distribution(:, :, img) = generate_photon_distribution(height, width, photon_prob, num_qu, num_cl, noise, prob_density, quantum_mask, classical_mask);
    end
    sum_distribution = sum_distribution + sum(photon_distribution,3);
    %save_3d_tiff(ds, photon_distribution, saveDir); % 3次元のTIFFファイルとして保存
    fprintf('intensity progress : %d/%d\n' , ds, num_dataSet);
    %result = intensity_correlation(photon_distribution, x_value, y_value); % 1セット分の強度相関関数を計算
    result = intensity_correlation_all_2(photon_distribution);
    intensity_corr1 = intensity_corr1 + result.corr1;
    intensity_corr2 = intensity_corr2 + result.corr2;
        
end


% 最終計算結果
intensityCorr_all = intensity_corr1 - intensity_corr2; % ここでは(height×width)×(height×width) 配列
% 自己相関の補正
intensityCorr_all(1:size(intensityCorr_all,1)+1:end) = 0;

% 相関マップの形になおす
corrMap_all = reshape(intensityCorr_all',[width,height,height*width]);
corrMap_all_fin = permute(corrMap_all,[2,1,3]);

% 再構成結果
reconstructed_image = sum(corrMap_all_fin,3);
%testImage = sum(reconstructed_image);
    
    fig1=figure;
    set(fig1, 'Position', [500, 400, 600, 300]);
    %clims = [fig_min, fig_max];
    imagesc(reconstructed_image);
    axis equal tight
    colormap parula
    %title(sprintf('Correlation with (%d, %d) (Noise: %d)', x_value, y_value, noise));
    xlabel('X')
    ylabel('Y')
    colorbar

    fig2 = figure;
    set(fig2, 'Position', [500, 400, 600, 300]);
    %clims = [fig_min, fig_max];
    imagesc(sum_distribution);
    axis equal tight
    colormap parula
    %title(sprintf('Correlation with (%d, %d) (Noise: %d)', x_value, y_value, noise));
    xlabel('X')
    ylabel('Y')
    colorbar
toc
