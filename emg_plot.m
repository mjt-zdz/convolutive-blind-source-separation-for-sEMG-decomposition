load('G:\doctoral_project\experiment-1\raw-emg-with-manual-spikes-label-all\raw\S10\vaMiKT_10_GM.mat');
load('G:\doctoral_project\experiment-1\raw-emg-with-manual-spikes-label-all\seg\S10\vaMiKT_10_GM_WS100_ST50.mat');
emg = flatten_interp(SIG, discardChannelsVec);
Spikes = [];
pulses = {};
for jj = 1:size(MUPulses,2)
    s = zeros(1, size(emg,2));
    if length(MUPulses{1, jj})>300
        s(1, [MUPulses{1, jj}]) = 1;
        Spikes = [Spikes; s];
        pulses = [pulses, MUPulses{1, jj}];
    end
end

screenSize = get(0, 'ScreenSize');
% 创建图形窗口，设置为屏幕的最大大小
figure('Position', screenSize);

subplot(2,4,[1,2])
% plot emg
image(emg(:,75100:75400))
set(gca,'xtick',[1,100,200,300],'xticklabel',[75100,75200,75300,75400],'FontSize',18)
set(gca,'ytick',[1,10,20,30,40,50,60],'yticklabel',[1,10,20,30,40,50,60],'FontSize',18)
ylim([0 65.5])
ylabel('HD-sEMG Channels (1 to 64)','FontSize',18)
xlabel('Data Points (n)','FontSize',18);
box off;
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2; 
rectangle('Position', [51 0 100 65],'EdgeColor','r','LineWidth',3)
rectangle('Position', [101 0 100 65],'EdgeColor','r','LineWidth',3,'LineStyle','--')

subplot(2,4,5)
% plot emg
image(squeeze(EMG_seg(1504,:,:))')
set(gca,'xtick',[1,50,100],'xticklabel',[75151, 75200, 75250],'FontSize',18)
set(gca,'ytick',[1,10,20,30,40,50,60],'yticklabel',[1,10,20,30,40,50,60],'FontSize',18)
ylim([0 64])
xlim([0 100])
xlabel('Data Points (n)','FontSize',18);
ylabel('HD-sEMG Channels (1 to 64)','FontSize',18)
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
rectangle('Position', [0 0 100 64],'LineWidth',3)
box off;

subplot(2,4,6)
% plot emg
image(squeeze(EMG_seg(1505,:,:))')
set(gca,'xtick',[1,50,100],'xticklabel',[75201, 75250, 75300],'FontSize',18)
set(gca,'ytick',[1,10,20,30,40,50,60],'yticklabel',[1,10,20,30,40,50,60],'FontSize',18)
ylim([0 64])
xlim([0 100])
xlabel('Data Points (n)','FontSize',18);
ylabel('HD-sEMG Channels (1 to 64)','FontSize',18)
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
rectangle('Position', [0 0 100 64],'LineWidth',3)
box off;

subplot(2,4,[3,4])
% plot spikes
% colors = create_color([0 0.4470 0.7410], [0.6350 0.0780 0.1840], size(Spikes,1));
% colors = colormap(colorcet('C1'));
colors = lines(size(Spikes,1)); % lines, parula, jet, hsv, hot, cool, spring, summer, autumn, winter
for ii = 1:size(Spikes,1)
    pls = pulses{1,ii}(1,logical((pulses{1,ii}>=75100).*(pulses{1,ii}<=75400)));
%     pls = pulses{1,ii};
    color = colors(ii,:);
    for jj = pls
        line([jj jj], [ii ii+1],'Color',color,'LineWidth',2);
    end
end
set(gca,'xtick',75100:100:75400,'xticklabel',75100:100:75400,'FontSize',18);
set(gca,'ytick',[1,5,10,15,20,25],'yticklabel',[1,5,10,15,20,25],'FontSize',18);
xlabel('Data Points (n)','FontSize',18);
ylabel('Discharge Times of MU# from CBSS','FontSize',18)
ylim([0 size(Spikes,1)+1]);
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
rectangle('Position', [75176 0 50 size(Spikes,1)+1],'EdgeColor','r','LineWidth',3)
rectangle('Position', [75226 0 50 size(Spikes,1)+1],'EdgeColor','r','LineWidth',3,'LineStyle','--')

subplot(2,4,7)
% plot spikes
spikes = squeeze(Spike_com(1504,:));
pls = find(spikes==1);
for p = pls
    color = colors(p,:);
    xline(p,'Color',color,'LineWidth',2)
end
set(gca,'xtick',[1,5,10,15,20,25],'xticklabel',[1,5,10,15,20,25],'FontSize',18);
set(gca,'ytick',[0,1],'yticklabel',[0,1],'FontSize',18);
xlabel('Number of MUs (MU#)','FontSize',18);
ylabel('Binary Value (0-no spike, 1-spike)','FontSize',18)
xlim([0 size(Spikes,1)]);
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
rectangle('Position', [0 0 26 1],'LineWidth',3)

subplot(2,4,8)
% plot spikes
spikes = squeeze(Spike_com(1505,:));
pls = find(spikes==1);
for p = pls
    color = colors(p,:);
    xline(p,'Color',color,'LineWidth',2)
end
set(gca,'xtick',[1,5,10,15,20,25],'xticklabel',[1,5,10,15,20,25],'FontSize',18);
set(gca,'ytick',[0,1],'yticklabel',[0,1],'FontSize',18);
xlabel('Number of MUs (MU#)','FontSize',18);
ylabel('Binary Value (0-no spike, 1-spike)','FontSize',18)
xlim([0 size(Spikes,1)]);
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;
rectangle('Position', [0 0 26 1],'LineWidth',3)

tightfig;
print('E:\WPS\WPSDrive\12914645\WPS云盘\深圳大学\博士\博士课题\SCI写作\肌电分解\EMG_MUSTs.tif', '-dtiff', '-r600');