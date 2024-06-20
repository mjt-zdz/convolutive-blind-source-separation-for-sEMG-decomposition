clear all;
close all;
clc;

% change path_data to the location of the dataset
path_data='/media/root/majinting_data/code/code_cbss/1';
% change path_results to the location to save decomposition results
path_results='/media/root/majinting_data/code/code_cbss/results'; 
if ~exist(path_results,'dir')
    mkdir(path_results);
end

fs=2000; % 采样频率
order = 8;
Fc1 = 10; % Hz
Fc2 = 500; % Hz

R = 32; % Extension parameter 扩展参数
M = 100; % iteration number 迭代次数
check_sil = true;
check_pnr = true;
sil_th = 0.9; % threshold to select motor units
pnr_th = 15; % threshold to select motor units
Tolx=1e-4; % tolerance
contrast_fun='skew'; % log_cosh, exp_xsq
% ortho_fun='source_deflation'; % gram_schmidt
max_iter_sep=100; % maximum iterations for fixed point algorithm
max_iter_ref=100; % maximum iterations for refinement
mpd=30; % 15 ms

% random_seed=[]; % 
verbose=true; % if ture, decomposition information is printed

files = {dir(path_data).name};
for f = 3:3 % length(files)
    data_dir = fullfile(path_data, files{f});
    load(data_dir);
    results = decompose_1(seg_data', R, M=M, fs=fs, bandpass=false, low_cut=Fc1, high_cut=Fc2, filt_order=order, ...
        cont_fun=contrast_fun, verbose=true, max_iter_ref=max_iter_ref, max_iter_sep=max_iter_sep, l_peaks=mpd, ...
        check_sil=check_sil, check_pnr=check_pnr, sil_th=sil_th,pnr_th=pnr_th);
    isi_var = isi_varcal(results.MUPulses,fs);
    results.MUPulses = results.MUPulses;
%     results.MUPulses_good(find(isi_var>0.5)) = [];
    results.isi_var = isi_var;
    save([path_results,'/', files{f}],'results','-v7.3');
end