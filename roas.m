clc;
clear;
close all;


data_dir = '/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/Experimental_data_edited';
resu_dir = '/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/cbss_results/raw_3';
ckc_dir = '/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/Experimental_data_Raw';
datas = {'GL_10', 'GL_30', 'GL_50', 'GL_70', ...
            'GM_10', 'GM_30', 'GM_50', 'GM_70', ...
            'TA_35', 'TA_50', 'TA_70'};
ops = {'op1', 'op2', 'op3', 'op4', 'op5', 'op6', 'op7', 'op8'};

fs = 2048;
tolx = 0.5; % ms
nomus = zeros(numel(datas)+1,numel(ops)+1);
commons = zeros(numel(datas),numel(ops)+1);
isis = {};
pnrs = {};
sils = {};
roa_means = {};
for ii = 1:11
    load([resu_dir,'/', datas{ii}, '_results.mat']);
    ckc = load([ckc_dir,'/',datas{ii},'.mat']);
%     for k = 1:numel(results.MUPulses_good)
%         results.MUPulses_good{k}(results.MUPulses_good{k}<ckc.startSIGInt * fs)=[];
%         results.MUPulses_good{k}(results.MUPulses_good{k}>ckc.stopSIGInt * fs)=[];
%     end
    [roa,cj] = RoA(ckc.MUPulses, results.MUPulses_good, fs, fs, tolx);
    cj(cj>0.3) = 1;
    cj(cj<=0.3) = 0;
    commons(ii,1) = sum(reshape(cj,[],1));
    roa = roa.*cj;
    roa = reshape(roa,[],1);
    roa(roa==0) = [];
    roa_means{ii,1} = [mean(roa),std(roa),min(roa),max(roa)];
%     results = rmfield(results,{'roa','cj','sources'}); 
    nomus(ii,1) = numel(results.MUPulses_good);
    isis{ii} = [mean(results.isi_var(results.isi_var<0.5))*100,std(results.isi_var(results.isi_var<0.5))*100, ...
                min(results.isi_var(results.isi_var<0.5))*100,max(results.isi_var(results.isi_var<0.5))*100];
    pnrs{ii} = [mean(results.pnr_all(find(results.isi_var<0.5))),std(results.pnr_all(find(results.isi_var<0.5))), ...
                min(results.pnr_all(find(results.isi_var<0.5))),max(results.pnr_all(find(results.isi_var<0.5)))];
    sils{ii} = [mean(results.sil_all(find(results.isi_var<0.5))),std(results.sil_all(find(results.isi_var<0.5))), ...
                min(results.sil_all(find(results.isi_var<0.5))),max(results.sil_all(find(results.isi_var<0.5)))];
    for jj = 1:8
        data = load([data_dir,'/',ops{jj},'/',datas{ii},'.mat']);
        nomus(ii,jj+1) = numel(data.MUPulses);
        [roa,cj] = RoA(data.MUPulses, results.MUPulses_good, fs, fs, tolx);
        results.cjs{jj} = cj;
        cj(cj>0.3) = 1;
        cj(cj<=0.3) = 0;
        commons(ii,jj+1) = sum(reshape(cj,[],1));
        roa = roa.*cj;
        roa = reshape(roa,[],1);
        roa(roa==0) = [];
%         roa_mean = mean(roa);
        if ~isempty(roa)
            roa_means{ii,jj+1} = [mean(roa),std(roa),min(roa),max(roa)];
            results.roa_means(1,jj) = mean(roa);
            results.roa_means(2,jj) = std(roa);
            results.roa_means(3,jj) = min(roa);
            results.roa_means(4,jj) = max(roa);
        end
    end
    save([resu_dir,'/', datas{ii}, '_results.mat'],'results','-v7.3');
end
save([resu_dir,'/indexs.mat'],'nomus','commons','sils','pnrs','roa_means','isis','-v7.3');