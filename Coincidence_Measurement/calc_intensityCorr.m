clear; clc; close all;
addpath('C:\MATLAB\intensity correlation\Functions\');

% 計算結果保存
dataSave1 = false; % 最終結果の保存有無
saveDir1 = 'E:\強度相関\0627_pos';

% 実験データの格納フォルダ
folderPath = 'F:\BiBO_momentum';

%フォルダ内のtifファイルを取得
fileList = dir(fullfile(folderPath, '*.tif'));
% 計算するセット数
dataSet = length(fileList);

% 画像サイズ
height = 200;
width = 200;
%N = size(original_array,3);

intensity_corr1 = zeros(height,width); % 第1項
intensity_corr2 = zeros(height,width); % 第2項
allData = zeros(height,width,dataSet); % 各セットごとのデータを格納する変数
finalCorMap = zeros(height,width); % 相関マップ
all_sum = zeros(height,width);

% 相関を計算する画素を決める
x_value = 135;
y_value = 63;


num_frames = 0;

tic
for dataSetNumber = 1:dataSet
    fprintf('Dataset : %d\n', dataSetNumber);
   
    % tifファイルを読み込む
    fprintf(' Loading files...\n');
    clear original_array
    filePath = fullfile(folderPath, fileList(dataSetNumber).name);
    tic
    original_array = readFile(filePath);
    toc
    N = size(original_array,3);
    % ここまでのフレーム数
    num_frames = num_frames + N;

    all_sum = all_sum + sum(original_array, 3);

    fprintf(' Calculation of intensity correlation...\n');

    % 強度相関計算
    self_signal = original_array(y_value, x_value, 1:N);
    % 第１項
    temp_1 = sum(original_array(:,:,1:N) .* self_signal,3);
    % 第２項
    if dataSetNumber == 1
        temp_2 = sum(original_array(:,:,2:N) .* self_signal(:,:,1:N-1),3);
    else
        temp_2 = sum(lastPage .* original_array(:,:,1),3);
        temp_2= temp_2 + sum(original_array(:,:,2:N) .* self_signal(:,:,1:N-1),3);
    end

    % 強度相関関数の累積
    intensity_corr1 = intensity_corr1 + temp_1;  % <C_ij>
    intensity_corr2 = intensity_corr2 + temp_2;  % <C_i><C_j>

    lastPage = original_array(:,:,end);
   
    % 各データセットごとの強度相関関数
    allData(:, :, dataSetNumber) = intensity_corr1 / num_frames - intensity_corr2 / (num_frames - 1);
    for dp = -3:3
        allData(y_value, x_value + dp,dataSetNumber) = (allData(y_value-1 , x_value+ dp, dataSetNumber) + allData(y_value+1,x_value+ dp, dataSetNumber))/2;
    end

    fprintf('Done! %d / %d \n', dataSetNumber, dataSet);
    
    % 強度相関関数の最終計算
    % allData(:, :, dataSetNumber) = intensity_corr1 / (N * dataSet) - intensity_corr2 / (N * dataSet - 1);
    
end
toc

% 計算結果
intensity_corr = intensity_corr1/(num_frames) - intensity_corr2/(num_frames-1);

%% 自己相関，およびその隣接画素の相関の処理
for dp = -3 : 3
    intensity_corr(y_value, x_value + dp) = (intensity_corr(y_value-1 , x_value+ dp) + intensity_corr(y_value+1,x_value+ dp))/2;
end

%% 図示
figure(1);
imagesc(intensity_corr);
axis equal tight
titleText = sprintf('Correlation with (%d, %d) %d frames', x_value, y_value, N*dataSet);
title(titleText);
xlabel('X')
ylabel('Y')
colorbar

% 正規化した相関マップ
normalized_intensity_corr = (intensity_corr-fig_min)/(fig_max-fig_min);
figure(2);
%imagesc(all_sum);
imagesc(normalized_intensity_corr);
axis equal tight
titleText = sprintf('Correlation with (%d, %d) %d frames (Normalized)', x_value, y_value, N*dataSet);
title(titleText);
xlabel('X')
ylabel('Y')
colorbar

%% ファイルを読み込む関数
function spdc_photons0 = readFile(tiff_photonsFile)
spdc_photons0 = tiffreadVolume(tiff_photonsFile);
spdc_photons0 = single(spdc_photons0);
% spdc_photons0 = spdc_photons0 / 255;
end