function colors = create_color(start, last, N)
    % 指定起始颜色和结束颜色
    % start = [0.2, 0.2, 1]; % 蓝色
    % last = [1, 0.2, 0.2];   % 红色
    % 生成渐变色
    colors = zeros(N, 3);
    for i = 1:3
        colors(:, i) = linspace(start(i), last(i), N);
    end
end