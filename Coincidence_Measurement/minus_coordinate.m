%% 各画素における強度相関関数を用いて、minus-coordinateを求める

clear; clc; close all;
fprintf('"Minus-coordinate"\n');
fprintf('-----------------------------------------------------\n');
addpath('C:\MATLAB\intensity correlation\Functions\');

% フォルダのパスを指定
folderPath = 'E:\実験データ\0627_2';
%フォルダ内のtifファイルを取得
fileList = dir(fullfile(folderPath, '*.tif'));
% 計算するセット数
dataSet = length(fileList);


% 画像サイズ
height = 100;
width = 100;

% 強度相関関数
intensity_corr1 = zeros(height^2,width^2); % 第1項
intensity_corr2 = zeros(height^2,width^2); % 第2項

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

end
toc

% 最終計算結果
intensityCorr_all = intensity_corr1 - intensity_corr2; % ここでは(height×width)×(height×width) 配列
intensityCorr_all(1:size(intensityCorr_all,1)+1:end) = 0;

% 相関マップの形になおす
corrMap_all = reshape(intensityCorr_all',[width,height,height*width]);
corrMap_all = permute(corrMap_all,[2,1,3]);

% 補正前の強度相関関数
%intensityCorr_all = intensity_corr1/(N*dataSet) - intensity_corr2/(N*dataSet-1);
intensityCorr = corrMap_all;

% すべてのページに０パディング
delta = 3;
padded_intensityCorr = padarray(intensityCorr, [delta, delta, 0], 0, 'both');

% クロストークの補正
index = 1;
for y_value = delta+1 : delta+height
    for x_value = delta+1 : delta+width
        temp = padded_intensityCorr(:,:,index);
        % クロストーク補正
        
        for dp = -3 : 3
            % y_value + dpが1以上height以下、x_value - 1が1以上、x_value + 1がwidth以下であることを確認
            if (y_value + dp >= 1 && y_value + dp <= height+2*delta && x_value - 1 >= 1 && x_value + 1 <= width+2*delta)
                temp(y_value, x_value + dp) = (temp(y_value-1, x_value + dp) + temp(y_value+1, x_value + dp)) / 2;
            end
        end
        
       temp(:,x_value) = (temp(:,x_value-1) + temp(:,x_value+1))/2;
       padded_intensityCorr(:,:,index) = temp;
       index = index + 1;
    end
end

% 0パディング部分を除去
intensityCorr_all = padded_intensityCorr(delta+1:delta+height,delta+1:delta+width,:);


% minus-coordinate用の配列
minusCoordinate = zeros(2*height, 2*width);
num_pixels = height*width;

for x = 30:60
    for y = 30:60
        % 相関マップが格納されているページを求める
        idx = (y-1)*height + x;
        currentMap = intensityCorr_all(:,:,idx);

        fprintf('progress >>> (%d, %d)', x,y);
        % minus-coordinate用の配列におけるスタート位置を求める
        y_start = height + 1 - (y-1);
        y_end = y_start + (height-1);
        x_start = width + 1 - (x-1);
        x_end = x_start + (width-1);
        fprintf('    y : %d ~ %d, x : %d ~ %d\n', y_start,y_end, x_start,x_end);

        % minus-coordinate配列を更新
        minusCoordinate(y_start:y_end, x_start:x_end) = minusCoordinate(y_start:y_end, x_start:x_end) + currentMap;

    end
end

minusCoordinate(101,:) =  (minusCoordinate(101-1,:) + minusCoordinate(101+1,:))/2;

minusCoordinate_2 = minusCoordinate(51:150,51:150);

% 結果の表示
figure(1);
imagesc(minusCoordinate_2);
axis equal tight
axis xy
set(gca, 'XTick', linspace(1, width, 5), 'XTickLabel', linspace(-width/2, width/2, 5));
set(gca, 'YTick', linspace(1, height, 5), 'YTickLabel', linspace(-height/2, height/2, 5));
set(gcf, 'Position', [500, 400, 600, 300]);

title('Minus coordinate');
xlabel('x1-x2');
ylabel('y1-y2');
colorbar;


%% ファイルを読み込む関数
function spdc_photons0 = readFile(tiff_photonsFile)
  spdc_photons0 = tiffreadVolume(tiff_photonsFile);
  spdc_photons0 = single(spdc_photons0);
  % spdc_photons0 = spdc_photons0 / 255;
end