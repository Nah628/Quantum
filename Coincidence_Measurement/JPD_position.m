%% Joint Probability Distribution - Position

clear; clc; close all;

% フォルダのパスを指定
folderPath = 'E:\実験データ\0627_2';
% フォルダ内のtifファイルを取得
fileList = dir(fullfile(folderPath, '*.tif'));
% 計算するセット数
dataSet = length(fileList);

% 使用するデータのサイズを取得
filePath = fullfile(folderPath, fileList(1).name);
%original_array = readFile(filePath);
height = 100;%size(original_array,1);
width = 100;%size(original_array,2);
N = 100000;%size(original_array,3);

% 計算用の配列を初期化
intensity_corr1 = zeros(height, width); % 第1項
intensity_corr2 = zeros(height, width); % 第2項


all_sum = zeros(height, width); % 全データの合計

% 相関を計算する列
y1 = 50;

tic;
for dataSetNumber = 1:dataSet
    fprintf('Dataset : %d\n', dataSetNumber);
    filePath = fullfile(folderPath, fileList(dataSetNumber).name);
    
    tic;
    % tifファイルを読み込む
    fprintf(' Loading files...\n');
    original_array = readFile(filePath);

    fprintf(' Calculation of intensity correlation...\n');
   
    for x1 = 1:width
        fprintf('No %d >>> calculation progress : %d/%d \n', dataSetNumber, x1, width);
        self_signal = original_array(y1,x1,1:N-1);
        
        temp_array = original_array; 
        
        for dp = -3:3
            x1_dp = x1 + dp;
            if (x1_dp >= 1)&&(x1_dp <= width)
                % 範囲内のときは上下の画素の平均をとる
                temp_array(y1, x1_dp,:) = (temp_array(y1-1, x1_dp,:) + temp_array(y1+1, x1_dp,:)) / 2;
            end
        end


        % クロストークを補正したデータとの相関を計算する
        temp_1 = sum(temp_array(y1,:,1:N-1) .* self_signal,3);
        temp_2 = sum(temp_array(y1,:,2:N) .* self_signal,3);

        % 強度相関関数の累積
        intensity_corr1(:,x1) = intensity_corr1(:,x1) + temp_1';
        intensity_corr2(:,x1) = intensity_corr2(:,x1) + temp_2';

    end
   
    fprintf('Done! %d / %d \n', dataSetNumber, dataSet);
    
end

% 強度相関関数の最終計算
intensity_corr = intensity_corr1 / (N * dataSet) - intensity_corr2 / (N * dataSet - 1);

for x1 = 1:width
    if x1 < width
        intensity_corr(x1,x1) = intensity_corr(x1,x1+1);
    else
        intensity_corr(x1,x1) = intensity_corr(x1-1,x1);
    end
end

toc

%% 図示
figure(1);
set(gcf, 'Position', [500, 400, 600, 300]);
imagesc(intensity_corr);
axis equal tight;
title(sprintf('joint probability distribution'));
xlabel('X1');
ylabel('X2');
colorbar;

%% ファイルを読み込む関数
function spdc_photons0 = readFile(tiff_photonsFile)
    spdc_photons0 = tiffreadVolume(tiff_photonsFile);
    spdc_photons0 = single(spdc_photons0);
end
