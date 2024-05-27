clear all;
close all;
clc;

% change path_data to the location of the dataset
% path_data='/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/Experimental_data_edited'; 
path_data='/media/root/MRI_pathology/博士课题/datasets/raw-emg-with-manual-spikes-label/Experimental_data_Raw';
% change path_results to the location to save decomposition results
path_results='/media/root/MRI_pathology/博士课题/datasets/raw-emg-with-manual-spikes-label/results/cbss'; 
if ~exist(path_results,'dir')
    mkdir(path_results);
end

muscles = {'GL','GM','TA'};
mvcs_gmgl = {'10','30','50','70'};
mvcs_ta = {'35','50','70'};

fs=2048; % 采样频率
order = 8;
Fc1 = 10; % Hz
Fc2 = 500; % Hz

R = 16; % Extension parameter 扩展参数
M = 500; % iteration number 迭代次数
check_sil = true;
check_pnr = true;
sil_th = 0.9; % threshold to select motor units
pnr_th = 15; % threshold to select motor units
Tolx=1e-4; % tolerance
contrast_fun='skew'; % log_cosh, exp_xsq
% ortho_fun='source_deflation'; % gram_schmidt
max_iter_sep=100; % maximum iterations for fixed point algorithm
max_iter_ref=100; % maximum iterations for refinement
mpd=31; % 15 ms

% random_seed=[]; % 
verbose=true; % if ture, decomposition information is printed

% for op = 7:8
%     if ~exist([path_results,'/op',num2str(op)],'dir')
%         mkdir([path_results,'/op',num2str(op)]);
%     end
    for muscle_idx = 1:1
        if strcmp(muscles(muscle_idx),'GM') || strcmp(muscles(muscle_idx),'GL') 
            for mvc_idx = 1:1
%                 data_dir = [path_data, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'.mat'];
                data_dir = [path_data, '/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'.mat'];
                load(data_dir);
                results = decompose(SIG, R, M=M, fs=fs, discard=discardChannelsVec, ...
                    bandpass=true, low_cut=Fc1, high_cut=Fc2,filt_order=order, cont_fun=contrast_fun, ...
                    verbose=true, max_iter_ref=max_iter_ref, max_iter_sep=max_iter_sep, l_peaks=mpd, ...
                    check_sil=true, check_pnr=true, sil_th=sil_th,pnr_th=pnr_th);
                isi_var = isi_varcal(results.MUPulses,fs);
                results.MUPulses_good = results.MUPulses;
                results.MUPulses_good(find(isi_var>0.5)) = [];
%                 [roa,cj] = RoA(MUPulses, results.MUPulses_good,fs,fs,0.5);
%                 results.roa = roa;
%                 results.cj = cj;
                results.isi_var = isi_var;
                results.start = startSIGInt;
                results.stop = stopSIGInt;
%                 discards = reshape(discardChannelsVec',[],1);
%                 discards = find(discards==1);
%                 emg = zeros(size(SIG,1)*size(SIG,2), size(SIG{1,2},2));
%                 for ii = 1:size(SIG,1)
%                     for jj = 1:size(SIG,2)
%                         if ~(ii==1 && jj==1)
%                             emg(jj+(ii-1)*size(SIG,2),:) = SIG{ii,jj};
%                         end
%                         discards(jj+(ii-1)*size(SIG,2)) = discardChannelsVec(ii,jj); 
%                     end
%                 end
                % preprocess
%                 discards(1) = 1;
%                 emg(logical(discards),:) = [];
%                 disp('discarded.');
%                 emg = emg(:,1:2048);
% %                 hd = bandpass_filters('Fs',Fs,'N',order,'Fc1',Fc1,'Fc2',Fc2);
%                 [b,a] = butter(order, [Fc1, Fc2]/(Fs/2), "bandpass");
%                 filtered_emg = filter(b,a,emg,[],2);
%                 disp('bandpass filtered.');
% %                 filtered_emg = filter(hd,emg);
%                 centered_emg = filtered_emg - mean(filtered_emg,2)*ones(1,size(filtered_emg,2));
%                 disp('centered.');
%                 [S,B,musts,sils,pnrs,accepts] = cbss_decomposition(filtered_emg,'R',R,'M',M,'thresh',threshold,'verbose','true','sil_pnr',sil_pnr, ...
%                     'Tolx',Tolx,'contrast_fun',contrast_fun,'ortho_fun',ortho_fun,'max_iter_sep',max_iter_sep,'max_iter_ref',max_iter_ref,'minpeakdistance',l);
%                 save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'_results.mat'],'results','-v7.3');
                save([path_results,'/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'_results_new.mat'],'results','-v7.3');
            end
        else
            for mvc_idx = 1:1
%                 data_dir = [path_data, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx}];
                data_dir = [path_data,'/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx}];
                load(data_dir);
                results = decompose(SIG, R, M=M, fs=fs, discard=discardChannelsVec, ...
                    bandpass=true, low_cut=Fc1, high_cut=Fc2,filt_order=order, cont_fun=contrast_fun, ...
                    verbose=true, max_iter_ref=max_iter_ref, max_iter_sep=max_iter_sep, l_peaks=mpd, ...
                    check_sil=true, check_pnr=true, sil_th=sil_th,pnr_th=pnr_th);
                isi_var = isi_varcal(results.MUPulses,fs);
                results.MUPulses_good = results.MUPulses;
                results.MUPulses_good(find(isi_var>0.5)) = [];
%                 [roa,cj] = RoA(MUPulses, results.MUPulses_good,fs,fs,0.5);
%                 results.roa = roa;
%                 results.cj = cj;
                results.isi_var = isi_var;
                results.start = startSIGInt;
                results.stop = stopSIGInt;
%                 save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx},'_results.mat'],'results','-v7.3');
                save([path_results,'/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx},'_results.mat'],'results','-v7.3');
%                 for ii = 2:size(SIG,1)
%                     for jj = 2:size(SIG,2)
%                         emg(:,ii+(jj-1)*size(SIG,2)) = SIG{ii,jj}; 
%                     end
%                 end
%                 [S,B,musts,sils,pnrs,accepts] = cbss_decomposition(emg,'R',R,'M',M,'bandpass',false,'fs',fs,'thresh',threshold,'verbose',true);
            end
        end
    end
% end