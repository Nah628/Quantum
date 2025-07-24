%% "Quantum image distillation" 

clear; clc; close all;
fprintf('"Quantum image distillation"\n');
fprintf('-----------------------------------------------------\n');
addpath('C:\MATLAB\intensity correlation\Functions\');

% フォルダのパスを指定
folderPath = 'E:\実験データ\1127_BBO';
%フォルダ内のtifファイルを取得
fileList = dir(fullfile(folderPath, '*.tif'));
% 計算するセット数
dataSet = length(fileList);


% 画像サイズ
height = 75;
width = 75;

% 強度相関関数
intensity_corr1 = zeros(height^2,width^2); % 第1項
intensity_corr2 = zeros(height^2,width^2); % 第2項

% 50万枚ごとの再構成結果を格納
mapNumber = 1;
%{
temp_intensityCorr_all = zeros(height,width,dataSet/6); % 6setで50万枚
filtering_temp_intensityCorr_all = zeros(height,width,dataSet/6);
%}

temp_intensityCorr_all = zeros(height,width,dataSet); 
filtering_temp_intensityCorr_all = zeros(height,width,dataSet);

num_frames = zeros(1,dataSet); % 枚数を格納する配列

all_sum = zeros(height,width);
numFrames = 0;
figNumber = 1;

tic
for dataSetNumber = 1:dataSet
    fprintf('Dataset : %d\n', dataSetNumber);
    filePath = fullfile(folderPath, fileList(dataSetNumber).name);
   
    % tifファイル読み込み
    fprintf(' Loading files...\n');
    clear original_array
    original_array = readFile(filePath);
    N = size(original_array,3);

    % 総フレーム数
    numFrames = numFrames + N;
    num_frames(dataSetNumber) = numFrames;
    %総和画像
    all_sum = all_sum + sum(original_array,3);

    fprintf(' Calculation of intensity correlation...\n');

    % 第１項
    fprintf('  corr1.\n');
    tic
    reshaped_array = reshape(permute(original_array,[2,1,3]), 1,height*width,[]); 
    reshaped_array = squeeze(reshaped_array);
    intensity_corr1 = intensity_corr1 + (reshaped_array * reshaped_array')/N;
    intensity_corr1(1:size(intensity_corr1,1)+1:end) = 0; % 自己相関は０
    toc

    % 第２項
    fprintf('  corr2.\n');
    tic
    reshaped_array_1 = original_array(:,:,1:N-1);
    reshaped_array_1 = reshape(permute(reshaped_array_1,[2,1,3]), 1,height*width,[]);
    reshaped_array_1 = squeeze(reshaped_array_1);

    reshaped_array_2 = original_array(:,:,2:N);
    reshaped_array_2 = reshape(permute(reshaped_array_2,[2,1,3]), 1,height*width,[]);
    reshaped_array_2 = squeeze(reshaped_array_2);

    intensity_corr2 = intensity_corr2 + (reshaped_array_1*reshaped_array_2' + reshaped_array_2*reshaped_array_1')/(2*(N-1));
    intensity_corr2(1:size(intensity_corr2,1)+1:end) = 0;
    toc

        fprintf('Now... %d frames used.\n',numFrames);
        temp_maps = intensity_corr1 - intensity_corr2;
        temp_maps(1:size(temp_maps,1)+1:end) = 0;
        temp_maps = reshape(temp_maps',[width,height,height*width]);
        temp_maps = permute(temp_maps,[2,1,3]);

        filtering_images = temp_maps;
        index = 1;
        for y_value = 1:height
            for x_value = 1:width
                temp = temp_maps(:,:,index);

                % クロストークの補正
                for dp = -3 : 3          
                  % 猫のとき
                  if (x_value + dp >= 1 && x_value + dp <= width && y_value - 1 >= 1 && y_value + 1 <= height)
                      temp(y_value, x_value + dp) = (temp(y_value-1 , x_value+ dp) + temp(y_value+1,x_value+ dp)) / 2;
                  end
                end
                temp_maps(:,:,index) = temp;
            
                % フィルタリング
                mask = zeros(height,width);
                if y_value > 1 && y_value < height && x_value > 1 && x_value < width
                    mask(y_value-1:y_value+1,x_value-1:x_value+1) = 1;
                    temp = temp .* mask;
                elseif x_value == 1 || x_value == width
                    temp = temp .* mask;
                end
                filtering_images(:,:,index) = temp;

                index = index + 1;

            end
        end

        % フィルタリングなしの再構成画像
        temp_reconstructed_image = sum(temp_maps,3);
        temp_reconstructed_image(:,1) = temp_reconstructed_image(:,2);
        temp_reconstructed_image(:,end) = temp_reconstructed_image(:,end-1);
        
        % フィルタリングありの再構成画像
        filtering_temp_reconstructed_image = sum(filtering_images,3);
        filtering_temp_reconstructed_image(:,1) = filtering_temp_reconstructed_image(:,2);
        filtering_temp_reconstructed_image(:,end) = filtering_temp_reconstructed_image(:,end-1);

        % 保存用配列
        temp_intensityCorr_all(:,:,mapNumber) = temp_reconstructed_image;
        filtering_temp_intensityCorr_all(:,:,mapNumber) = filtering_temp_reconstructed_image;
        mapNumber = mapNumber + 1;

end
toc

% 最終計算結果
intensityCorr_all = intensity_corr1 - intensity_corr2; % ここでは(height×width)×(height×width) 配列
intensityCorr_all(1:size(intensityCorr_all,1)+1:end) = 0;

% 相関マップの形になおす
corrMap_all = reshape(intensityCorr_all',[width,height,height*width]);
corrMap_all = permute(corrMap_all,[2,1,3]);

% クロストークの補正
index = 1;
for y_value = 1 : height 
    for x_value = 1 : width
        temp = corrMap_all(:,:,index);
        % クロストーク補正
        for dp = -3 : 3
            % y_value + dpが1以上height以下、x_value - 1が1以上、x_value + 1がwidth以下であることを確認
            if (x_value + dp >= 1 && x_value + dp <= width && y_value - 1 >= 1 && y_value + 1 <= height)
                temp(y_value, x_value + dp) = (temp(y_value-1 , x_value+ dp) + temp(y_value+1,x_value+ dp)) / 2;
            end           
        end
       corrMap_all(:,:,index) = temp;
       index = index + 1;
    end
end

% 再構成結果
reconstructed_image = sum(corrMap_all,3);
%reconstructed_image = filtering_temp_intensityCorr_all(:,:,end);
%reconstructed_image(1,:) = reconstructed_image(2,:);
%reconstructed_image(end,:) = reconstructed_image(end-1,:);

%% 図示
% 総和画像
all_sum_test = (all_sum - min(all_sum(:))) / (max(all_sum(:))-min(all_sum(:)));
figure(1);
imagesc(all_sum_test);
axis equal tight
title(sprintf('Sum of all images'));
xlabel('X')
ylabel('Y')
colorbar

% 量子物体
quantum_image = (reconstructed_image - min(reconstructed_image(:)))/(max(reconstructed_image(:)) - min(reconstructed_image(:)));
figure(2);
imagesc(quantum_image);
axis equal tight
title(sprintf('Quantum image'));
xlabel('X')
ylabel('Y')
colorbar

% 古典物体
classical_image = all_sum_test - quantum_image;
classical_image = (classical_image - min(classical_image(:)))/(max(classical_image(:)) - min(classical_image(:)));
figure(3);
imagesc(classical_image);
axis equal tight
title(sprintf('Classical image'));
xlabel('X')
ylabel('Y')
colorbar

%% filtering
num_pixels = height * width;
filtering_images = corrMap_all;

for p = 1:num_pixels
    temp_image = filtering_images(:,:,p);

    h = ceil(p / width);       % 行インデックス
    w = mod(p - 1, width) + 1; % 列インデックス

    mask = zeros(height, width);
    mask_width = 1;

    % マスクの境界を制限
    row_start = max(1, h - mask_width);
    row_end = min(height, h + mask_width);
    col_start = max(1, w - mask_width);
    col_end = min(width, w + mask_width);

    mask(row_start:row_end, col_start:col_end) = 1;
    temp_image = temp_image .* mask;

    filtering_images(:,:,p) = temp_image;
end

filtered_image = sum(filtering_images,3);

filtered_image(:,1) = filtered_image(:,2);
filtered_image(:,end) = filtered_image(:,end-1);
filtered_image = (filtered_image - min(filtered_image(:)))/(max(filtered_image(:)) - min(filtered_image(:)));

figure(4);
set(gcf, 'Position', [500, 400, 600, 300]);
imagesc(filtered_image);
axis equal tight
title(sprintf('Quantum image (After filtering)'));
xlabel('X')
ylabel('Y')
colorbar

filtered_classical = all_sum_test - filtered_image;
filtered_classical = (filtered_classical - min(filtered_classical(:)))/(max(filtered_classical(:)) - min(filtered_classical(:)));
figure(5);
imagesc(filtered_classical);
axis equal tight
title(sprintf('Classical image (After filtering)'));
xlabel('X')
ylabel('Y')
colorbar

%% ファイルを読み込む関数
function spdc_photons0 = readFile(tiff_photonsFile)
  spdc_photons0 = tiffreadVolume(tiff_photonsFile);
  spdc_photons0 = single(spdc_photons0);
  % spdc_photons0 = spdc_photons0 / 255;
end
