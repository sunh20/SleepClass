function plotChans(data,fs,numChans)
% Plots specified number of channel with optimal subplot size
% Assumes data: time x channels

t = linspace(0,length(data)/fs,length(data));

% find ideal dimensions for the channel #
dim1 = round(sqrt(numChans));
while mod(numChans,dim1) ~= 0
    dim1 = dim1 + 1;
    if dim1 > numChans
        disp('your code is broken lol')
        break
    end
end

dim2 = numChans/dim1;

% keep track of axes
axees = [];

figure;
for i = 1:numChans
    axees = [axees, subplot(dim1,dim2,i)];
    plot(t,data(:,i))
    title(sprintf('ch %d',i))
    %ylim([-500 500])
end

linkaxes(axees,'xy')

end