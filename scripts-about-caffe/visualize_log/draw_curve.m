%% this is a function that draws a curve about
%% iteration vs loss

close all;
clear;
clc;


%% iteration vs loss curve
figure(1)

    mat_path = '/home/archer/FCN/visual_loss_log/mat/result.mat';
    result = load(mat_path);
    iter = cellfun(@str2num, result.result.iter);
    loss = cellfun(@str2num, result.result.loss);
    %hold on

    plot(iter, loss,'b');


    xlabel 'iter'
    ylabel 'loss'
    title('fun');

    legend('loss');

saveas(gcf,'./result_img/test.jpg');
