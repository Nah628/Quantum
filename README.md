# Quantum Codes
コードは基本的にMatlabで書いていますが、tiffファイルの読み込みはPythonの方が速いかも？？？  
> [!WARNING]  
> 基本的に実行時間が長いので注意してください。
> 特に、３次元tiffファイルの読み込み中は、パソコンの動作が遅くなったりします。

## Coincidence Measurement  
強度相関測定関連のプログラム。光子対の同時計測性を評価します。
|ファイル名|内容|
|----|----|
|calc_intensityCorr|強度相関関数を計算|
|JPD_momentum.m|運動量相関の結合確率分布を計算|
|JPD_position.m|位置相関の結合確率分布を計算|
|sum_coordinate.m|和座標投影（運動量相関）を計算|
|minus_coordinate.m|差座標投影（位置相関）を計算|

## Distillation Simulation
量子画像蒸留シミュレーション
|ファイル名|内容|
|----|----|
|main.m|mainプログラム。<br>シミュレーションを行うときはこのプログラムを実行する|
|Functions|光子分布作成などの細々とした関数が保存されているフォルダ|
|alive_cat.bmp <br> dead_cat.bmp|二値の画像マスク|

## Distillation
実験で取得したデータに対して、量子画像蒸留を実施。
|ファイル名|内容|
|----|----|
|Distillation.m|量子画像蒸留を行う。<br> 全画素における強度相関関数を計算して積分|
