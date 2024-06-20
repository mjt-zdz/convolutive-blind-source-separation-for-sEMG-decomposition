function isi_var = isi_varcal(MUPulses,fs)
isi_var = zeros(1,numel(MUPulses));
for ii = 1:numel(MUPulses)
    isi = diff(MUPulses{ii});
    isi = isi*1000/double(fs);
    isi(isi>250) = [];
    isi(isi<20) = [];
    isi_var(ii) = variation(isi);
end
end