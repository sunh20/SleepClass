% sambox 
%% load data
clear all; close all; clc

addpath('ecog')
filename = 'processed_a0f66459_6.h5';

info = h5info(filename);
datasets = info.Datasets;
dataset_names = {datasets.Name};

data = struct;

for idx = 1:length(dataset_names)
    data.(dataset_names{idx}) = h5read(filename,strcat('/',dataset_names{idx}));
end

fs = double(data.f_sample);

clearvars -except data info filename fs

%% view one dataset - 1 hour of data
hours = 3;

t = linspace(0,60,fs*60);
figure;
for idx = 0:hours-1
    subplot(hours,1,idx+1)
    plot(t,data.dataset(idx*fs*60+1:(idx+1)*fs*60,2))
    xlabel('Minutes')
    ylabel('Electric Potential (uV)')
    title(sprintf('Hour %d',idx+1))
end

clear t idx hours

%% separate out grid channels (1-64) and sleep vs. wake (1 hour each)
% remove first column - no data there
ECOG_data = data.dataset(:,2:65);

% figure out sleep/wake chunks of data using timestamps - continuous
% recordings preferred
% fs = 500, 2ms (probably downsampled)
% data start time: 8:13:24:???
% wake video timestamps: 8:59:36:752000 - 11:59:36:664000
% sleep video timestamps: 0:59:35:16000 - 2:59:35:357000

%t_start = datetime(data.start_timestamp,'ConvertFrom','posixtime');
t_start = 8*60*60 + 13*60 + 24; % seconds

t = 0:1/fs:24*60*60;        % entire day in seconds
t = t + t_start;
t = t(1:length(data.dataset(:,2)));     % cut to fit dataset

% get sleep and wake times
t_wake = 8*60*60 + 59*60 + 36 + 0.752;
t_sleep = 8*60*60 + 16*60*60 + 59*60 + 36 + 0.752;

% adjust to get start indices for wake + sleep
t_wake = (t_wake - t_start)*fs;
t_sleep = (t_sleep - t_start)*fs;
t_1hr = 1/fs:1/fs:60*60;

data_wake = ECOG_data(t_wake+1:t_wake+fs*t_1hr(end),:);
data_sleep = ECOG_data(t_sleep+1:t_sleep+fs*t_1hr(end),:);

figure;
ax1 = subplot(2,1,1);
plot(t_1hr/60,data_wake(:,1))
xlabel('Minutes')
ylabel('Electric Potential (uV)')
title('1hr of wake data')

ax2 = subplot(2,1,2);
plot(t_1hr/60,data_sleep(:,1))
xlabel('Minutes')
ylabel('Electric Potential (uV)')
title('1hr of sleep data')

linkaxes([ax1 ax2],'xy')

%% get data to Ekram
t = t_1hr;

% save('ECOG_sleep_wake.mat','data_sleep','data_wake','fs','t')

%% get arbitrary 1 hour of data to Ekram - deprecated
% Note: this isn't cleaned up data
ECOG_grid = data.dataset(:,2:65);
ECOG_grid = ECOG_grid';
ECOG_1hr = ECOG_grid(:,1:fs*60*60);
ECOG_1hr = ECOG_1hr';
t_1hr = 1/fs:1/fs:60*60;
% plot(t_1hr,ECOG_1hr(:,1))

% make a 3 min version - since we'll be doing power spectrum on 
% each 3 mins of data
ECOG_1hr_3m_stacks = reshape(ECOG_1hr,[fs*3*60,64,20]);
ECOG_3m = ECOG_1hr_3m_stacks(:,:,1);    % sample
t_3m = 1/fs:1/fs:3*60;

% save('ECOG_3m.mat','ECOG_3m','t_3m','fs')

%% plot all channels 
clearvars

load('ECOG_sleep_wake.mat')

data = data_wake(1:90000,:);

plotChans(data,fs,64)

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

figure;
plot(t_split,data_sleep_split(:,1,1))
xlabel('time (s)')
ylabel('voltage')
title('first channel first trial example')

clear idx1 idx2 three_m trial data
% save('ECOG_sleep_wake_segmented.mat')
%% get_power_bands
% for each trial, get the mean band + ste + save it to a vector
% end vector wil be 20 x 5

P_sleep = zeros(20,5); % 20 trials, 5 power bands
P_wake = zeros(20,5);

for tr = 1:20
    tic
    test_sleep = squeeze(data_sleep_split(:,:,tr));
    test_wake = squeeze(data_wake_split(:,:,tr));

    P_sleep(tr,:) = get_power_bands(test_sleep,fs);
    P_wake(tr,:) = get_power_bands(test_wake,fs);
    
    fprintf('completed trial %d: %.2f seconds\n',tr,toc)

    % % plot
    % figure;
    % bar([P_sleep, P_wake])
    % xlabel('Frequency bins')
    % xticklabels(["delta (1-4)","theta (4-7)","alpha (8-13)","beta (13-30)","gamma(30-70)"])
    % ylabel('Band Power')
    % title('Mean power across frequency bands')
    % legend('sleep','wake')
end

% save stats matrix so don't have to run again
% save('pow_bands.mat','P_sleep','P_wake')

%% stats

load('pow_bands.mat')

mean_P_sleep = mean(P_sleep);
mean_P_wake = mean(P_wake);
ste_P_sleep = std(P_sleep)/length(P_sleep);
ste_P_wake = std(P_wake)/length(P_wake);
[hyp, p_val] = ttest(P_sleep,P_wake);

% plot 
figure;
bar([mean_P_sleep' mean_P_wake'])
hold on
xlabel('Frequency bins')
xticklabels(["\delta (1-4)","\theta (4-7)","\alpha (8-13)","\beta (13-30)","\gamma (30-70)"])
ylabel('Band Power')
title('Mean power across frequency bands')


errorbar_sig(mean_P_sleep',mean_P_wake',ste_P_sleep',ste_P_wake',hyp,p_val)
legend('sleep','wake')



