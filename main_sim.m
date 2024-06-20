clear all;
close all;
clc;

% change path_data to the location of the dataset
path_data='/media/root/data/doctoral_project/dynamic/data_sim';
% change path_results to the location to save decomposition results
path_results='/media/root/data/doctoral_project/dynamic/results_cbss'; 
if ~exist(path_results,'dir')
    mkdir(path_results);
end

fs=2048; % 采样频率
bandpass = true;
order = 2;
center = true;
Fc1 = 10; % Hz
Fc2 = 500; % Hz

R = 4; % Extension parameter 扩展参数
M = 100; % iteration number 迭代次数
check_sil = true;
check_pnr = true;
sil_th = 0.9; % threshold to select motor units
pnr_th = 15; % threshold to select motor units
Tolx=1e-4; % tolerance
contrast_fun='log_cosh'; % log_cosh, exp_xsq,  kurtosis, rati
max_iter_sep=100; % maximum iterations for fixed point algorithm
max_iter_ref=100; % maximum iterations for refinement
mpd= 21; %31; % 15 ms
verbose=true; % if ture, decomposition information is printed

files = {dir(path_data).name};
for f = 3:length(files)
    data_dir = fullfile(path_data, files{f}); 
    load(data_dir);
    semg = reshape(sEMG, size(sEMG,1)*size(sEMG,2),size(sEMG,3));
    results = decompose_1(semg, R, M=M, fs=fs, bandpass=bandpass, low_cut=Fc1, high_cut=Fc2, filt_order=order, center = center, ...
                          cont_fun=contrast_fun, verbose=true, max_iter_ref=max_iter_ref, max_iter_sep=max_iter_sep, ...
                          l_peaks=mpd, check_sil=true, check_pnr=true, sil_th=sil_th,pnr_th=pnr_th, method='zca', pcs=100);
    isi_var = isi_varcal(results.MUPulses, fs);
    results.MUPulses_isi = results.MUPulses;
    results.MUPulses_isi(find(isi_var>0.5)) = [];
    results.isi_var = isi_var;
    % remove duplicates
    % RoA
    spikes = results.MUPulses;
    for ii = 1:numel(spikes)
        spikes{ii} = spikes{ii}/fs;
    end
    [roa,cj] = RoA_sim(spikes, spike_trains, 0.5);
    results.roa = roa;
    results.cj = cj;
    save(fullfile(path_results,files{f}), 'results', '-v7.3');
end