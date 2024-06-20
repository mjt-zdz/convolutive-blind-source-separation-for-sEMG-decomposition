function plotallchs(emg, num_chs)
% size (channels, data points)
maxsample = max(max(emg));

screenSize = get(0, 'ScreenSize');
% 创建图形窗口，设置为屏幕的最大大小
figure('Position', screenSize);

for i=1:size(emg,1)
    plot(emg(i,:) - maxsample*(i-1),'LineWidth',2)
%     k = stem(1:52245, emg(i,:) - maxsample*(i-1), 'Marker','none');
%     set(k, 'BaseValue', -maxsample*i)
    hold on
    % line([0 size(emg,2)],[maxsample/2 - maxsample*(i-1),maxsample/2 - maxsample*(i-1)])
    hold on
end
% line([0 size(emg,2)],[maxsample/2 - maxsample*(i),maxsample/2 - maxsample*(i)])
yticks(-(maxsample*(num_chs-1)):maxsample:0)
for i=1:size(emg,1)
    ticklabels{i} = strcat('ch',num2str(num_chs-i+1));
end
yticklabels(ticklabels)
xlim([-inf,inf])
ylim([-(maxsample*num_chs),maxsample])
ylabel('channels')
xlabel('data points')

print('sEMG.tif', '-dtiff', '-r600');
end