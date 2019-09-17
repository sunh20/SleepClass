%% Sleep data processing pipeline
% Frequency band power analysis between sleep + wake data sets
% subject a0f66459, day 6
clear all; close all; clc

%% options
plot_on = 1;
save_on = 0;

%% load raw data
addpath('ecog')
addpath('mat_tools')
filename = 'processed_a0f66459_6.h5';

info = h5info(filename);
datasets = info.Datasets;
dataset_names = {datasets.Name};

data = struct;

for idx = 1:length(dataset_names)
    data.(dataset_names{idx}) = h5read(filename,strcat('/',dataset_names{idx}));
end

fs = double(data.f_sample);

clearvars -except data datasets filename fs plot_on save_on

%% separate out grid channels (1-64) and sleep vs. wake (1 hour each)
% remove first column - no data there
ECOG_data = data.dataset(:,2:65);

t_start = 8*60*60 + 13*60 + 24; % seconds

% get sleep and wake times
t_wake = 8*60*60 + 59*60 + 36 + 0.752;
t_sleep = 8*60*60 + 16*60*60 + 59*60 + 36 + 0.752;

% adjust to get start indices for wake + sleep
t_wake = (t_wake - t_start)*fs;
t_sleep = (t_sleep - t_start)*fs;
t = 1/fs:1/fs:60*60;

data_wake = ECOG_data(t_wake+1:t_wake+fs*t(end),:);
data_sleep = ECOG_data(t_sleep+1:t_sleep+fs*t(end),:);

if plot_on == 1
    figure;
    ax1 = subplot(2,1,1);
    plot(t/60,data_wake(:,1))
    xlabel('Minutes')
    ylabel('Electric Potential (uV)')
    title('1hr of wake data')

    ax2 = subplot(2,1,2);
    plot(t/60,data_sleep(:,1))
    xlabel('Minutes')
    ylabel('Electric Potential (uV)')
    title('1hr of sleep data')

    linkaxes([ax1 ax2],'xy')
end

%%
% id channel 37 as bad - remove from set
chans = 1:64;
chans(37) = [];

data_sleep(:,37) = [];
data_wake(:,37) = [];

%% reshape into 20 trials 
three_m = 3*60*fs;      % three min segments
t_split = t(1:three_m); 
data_sleep_split = zeros(length(t_split),length(chans),20);
data_wake_split = zeros(length(t_split),length(chans),20);

for trial = 1:20
    idx1 = (trial-1)*three_m + 1;
    idx2 = trial*three_m;
    data_sleep_split(:,:,trial) = data_sleep(idx1:idx2,:);
    data_wake_split(:,:,trial) = data_wake(idx1:idx2,:);
end

if plot_on == 1
    figure;
    plot(t_split,data_sleep_split(:,1,1))
    xlabel('time (s)')
    ylabel('voltage')
    title('first channel first trial example')
end

clear idx1 idx2 three_m trial data

%% get_power_bands
% for each trial, get the mean band + ste + save it to a vector
% end vector wil be 6 x 20

P_sleep = zeros(6,20); % 20 trials, 6 power bands
P_wake = zeros(6,20);

for tr = 1:20
    tic
    test_sleep = squeeze(data_sleep_split(:,:,tr));
    test_wake = squeeze(data_wake_split(:,:,tr));

    P_sleep(:,tr) = get_power_bands(test_sleep,fs);
    P_wake(:,tr) = get_power_bands(test_wake,fs);
    
    fprintf('completed trial %d: %.2f seconds\n',tr,toc)
end
disp('finished calculating power bands')
%% stats

P_sleep_mean = mean(P_sleep,2);
P_wake_mean = mean(P_wake,2);
P_sleep_ste = std(P_sleep,[],2)/length(P_sleep);
P_wake_ste = std(P_wake,[],2)/length(P_wake);
[hyp, pval] = ttest(P_sleep',P_wake');

% plot 
figure;
bar([P_sleep_mean, P_wake_mean])
hold on
xlabel('Frequency bins')
xticklabels(["\delta (1-4)","\theta (4-7)","\alpha (8-13)",...
                "\beta (13-30)","\gamma (30-70)","h\gamma (70-200)"])
ylabel('Band Power')
title('Mean power across frequency bands')

errorbar_sig(P_sleep_mean,P_wake_mean,P_sleep_ste,P_wake_ste,hyp,pval)
legend('sleep','wake')

%% save workspace

if save_on == 1
    disp('Preparing to save, make sure you save any figures you want!!')
    pause
    disp('Saving to file...')
    close all
    clear ax1 ax2
    save('a0f66459_d6_analysis.mat','-v7.3')
end