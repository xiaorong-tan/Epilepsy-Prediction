% import data using EEGLAB interface
% wavelet packets trees
function [outEEG] = wptica(data, eeg)
[rows, cols] = size(data);
for i = 1:rows
    T(:,:,i) = wpdec(data(i,:),7,'dmey');
end
%plot(T(:,:,10));
sAll = read(T(:,:,1),'sizes');
[r, c] = size(sAll);

% caculate wavelet energy for each node across all channels
egy = zeros(rows,128);
for i = 1:rows
    for j = 127:r-1
        X = wpcoef(T(:,:,i),j);
        egy(i,j-126) = sum(X.^2);
    end
end
% standard deviation 
egySTD = zeros(rows,128);
egySTD2 = zeros(1,128);
for i = 1:rows
    for j = 1:128
        egySTD(i,j) = (egy(i,j) - mean(egy(:,j)))^2;
    end
end
for i = 1:128
    egySTD2(1,i) = sum(egySTD(:,i)) / (r-1);
end
% find the node with maximum std of wavelet energy (7th level)
a = max(egySTD2);
for i=1:128
    if(egySTD2(1,i) == a)
        index = i;
    end
end
% reject the node with maximum std of wavelet energy --------------------

% reject the node by setting coefficients to 0
for i = 1:rows
    X = wpcoef(T(:,:,i),126+index);
    [rX, cX] = size(X);
    X = zeros(rX, cX);
    T(:,:,i) = write(T(:,:,i),'cfs',126+index,X);
end
% store the trees
wptEEG = zeros(rows, cols);
for j = 1:rows
    [T(:,:,j),wptEEG(j,:)] = wpjoin(T(:,:,j),0);
end

% % test the results
% plot(data(1,:),'r');
% hold on
% plot(wptEEG(1,:),'b');
% legend('original data', 'WPT');
% title('Data applied WPT');

% apply fastICA -----------------------------------
rawEEG = data;
eeg.data = wptEEG;
% [icasig, A, W] = fastica(EEG.data);
eeg = pop_runica(eeg, 'icatype', 'fastica');
% wptICA contains all components
wptICA = eeg.icaweights*eeg.icasphere*eeg.data;
[rICA, cICA] = size(wptICA);
stdICA = zeros(rICA,1);
stdICA = std(wptICA,0,2);
for i = 1:rICA
    if(stdICA(i,1)==max(stdICA))
        idx = i;
    end
end
fprintf('Remove No.%d component\n', idx);
% reject the component
eeg = pop_subcomp(eeg,idx);

% figure;
% for i = 1:4
%     subplot(2,2,i);
%     plot(eeg.data(i,:),'r')  
%     hold on 
%     plot(rawEEG(i,:),'b');
%     title(sprintf('Channel %d', i));
% end
% legend('WPTICA','raw EEG');

outEEG = eeg;
end

