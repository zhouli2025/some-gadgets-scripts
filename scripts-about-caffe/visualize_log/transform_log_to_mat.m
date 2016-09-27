%% Well, this is a function that writes 
%% the data about iteration and loss
%% into a mat file


%% embrace a new start

close all;
clear;
clc;


logName = './log/log_v_4.log'; % log file for caffe model
fid = fopen(logName, 'r');

result_path = './mat/result';

tline = fgetl(fid);

iter = {};
loss = {};

num_loss = 1;
num_iter = 1;
while ischar(tline)

    loss_position = strfind(tline, 'Train net output #0:');
    iter_position = strfind(tline, 'Iteration');
    iter_loss_position = strfind(tline, ', loss');


    if(~isempty(iter_position) && ~isempty(iter_loss_position))     % find the iteration line

        iter_offset = strfind(tline, 'Iteration'); % find the position of the keyword 'Iteration'

        indexStart = iter_offset+10;
        indexEnd = strfind(tline,',')-1;
        temp_iter = tline(indexStart : indexEnd); % find the value of the keyword 'Iteration'

        iter{1,num_iter} = temp_iter;
        num_iter = num_iter +1;

    elseif (loss_position)                           % find the loss line

        loss_offset = strfind(tline, 'loss');        % find the position of the keyword 'loss'

        indexStart = loss_offset+7;
        indexEnd = strfind(tline,'(')-2;
        temp_loss = tline(indexStart : indexEnd);     % find the value of the keyword 'loss'

        loss{1,num_loss} = temp_loss;
        num_loss = num_loss + 1;
    else

    end

    tline = fgetl(fid);

end

result.iter = iter;
result.loss = loss;

save(result_path,'result');  % save as a mat file
