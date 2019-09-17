function [power_bands] = get_power_bands(data, fs)
% This function computes the alpha, beta, theta, delta, gamma and HG 
% bands for data (time x trials or time x channels)
% borrowed from buildDataProperties.m

alpha_pwr = zeros(size(data));
beta_pwr = zeros(size(data));
theta_pwr = zeros(size(data));
delta_pwr = zeros(size(data));
gamma_pwr = zeros(size(data));
HG_pwr = zeros(size(data));

for i=1:size(data,2)
    delta_pwr(:,i) = hilbAmp(data(:,i), [1, 4], fs).^2; 
    theta_pwr(:,i) = hilbAmp(data(:,i), [4, 7], fs).^2;
    alpha_pwr(:,i) = hilbAmp(data(:,i), [8, 13], fs).^2;
    beta_pwr(:,i) = hilbAmp(data(:,i), [13, 30], fs).^2;
    gamma_pwr(:,i) = hilbAmp(data(:,i), [30, 70], fs).^2;
    HG_pwr(:,i) = hilbAmp(data(:,i), [70, 200], fs).^2;
end

% power_bands.alpha = mean(mean(alpha_pwr));
% power_bands.beta = mean(mean(beta_pwr));
% power_bands.theta = mean(mean(theta_pwr));
% power_bands.delta = mean(mean(delta_pwr));
% power_bands.gamma = mean(mean(gamma_pwr));
% power_bands.hg = mean(mean(HG_pwr));

power_bands = [ mean(mean(delta_pwr))
                mean(mean(theta_pwr))
                mean(mean(alpha_pwr))
                mean(mean(beta_pwr))
                mean(mean(gamma_pwr))
                mean(mean(HG_pwr))];
end

