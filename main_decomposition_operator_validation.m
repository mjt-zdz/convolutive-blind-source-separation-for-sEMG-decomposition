clear all;
close all;
clc;

path_data='/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/Experimental_data_edited'; % change path_data to the location of the dataset
path_results='/media/root/majinting_data/doctoral_project/datasets/raw-emg-with-manual-spikes-label/cbss_results'; % change path_results to the location to save decomposition results

muscles = {'GL','GM','TA'};
mvcs_gmgl = {'10','30','50','70'};
mvcs_ta = {'35','50','70'};
fs = 2048;

for op = 1:8
    for muscle_idx = 1:3
        if strcmp(muscles(muscle_idx),'GM') || strcmp(muscles(muscle_idx),'GL') 
            for mvc_idx = 1:4
                data_dir = [path_data, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'.mat'];
                result_dir = [path_results, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'_results.mat'];
                load(data_dir);
                load(result_dir);
                isi_var = isi_varcal(results.MUPulses,fs);
                results.MUPulses_good = results.MUPulses;
                results.MUPulses_good(find(isi_var>0.5)) = [];
                [roa,cj] = RoA(MUPulses, results.MUPulses_good,fs,fs,0.5);
                results.roa = roa;
                results.cj = cj;
                save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'_roa.mat'],'roa','-v7.3');
                save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'_results.mat'],'results','-v7.3');
            end
        else
            for mvc_idx = 1:3
                data_dir = [path_data, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_gmgl{mvc_idx},'.mat'];
                result_dir = [path_results, '/op', num2str(op), '/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx},'_results.mat'];
                load(data_dir);
                load(result_dir);
                isi_var = isi_varcal(results.MUPulses,fs);
                results.MUPulses_good = results.MUPulses;
                results.MUPulses_good(find(isi_var>0.5)) = [];
                [roa,cj] = RoA(MUPulses, results.MUPulses_good,fs,fs,0.5);
%                 roa = RoA(MUPulses, results.MUPulses,2048,2048,0.5);
                save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx},'_roa.mat'],'roa','-v7.3');
                save([path_results,'/op',num2str(op),'/', muscles{muscle_idx}, '_', mvcs_ta{mvc_idx},'_results.mat'],'results','-v7.3');
            end
        end
    end
end