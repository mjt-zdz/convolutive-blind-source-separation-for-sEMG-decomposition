
screenSize = get(0, 'ScreenSize');
% 创建图形窗口，设置为屏幕的最大大小
figure('Position', screenSize);

colors = lines(size(MUPulses,2)); % lines, parula, jet, hsv, hot, cool, spring, summer, autumn, winter
for ii = 1:size(MUPulses,2)
    pls = MUPulses{1,ii};
    color = colors(ii,:);
    for jj = pls
        line([jj jj], [ii-0.5 ii+0.5],'Color',color,'LineWidth',2);
    end
end
% set(gca,'xtick',75100:100:75400,'xticklabel',75100:100:75400,'FontSize',18);
set(gca,'ytick',1:size(MUPulses,2),'yticklabel',1:size(MUPulses,2),'FontSize',18);
xlabel('Data Points (n)','FontSize',18);
ylabel('Discharge Times of MU# from CBSS','FontSize',18)
ylim([0 size(MUPulses,2)+1]);
ax = gca;
ax.LineWidth = 2;
ax.XAxis.LineWidth = 2;
ax.YAxis.LineWidth = 2;

print('MUSTs.tif', '-dtiff', '-r600');
