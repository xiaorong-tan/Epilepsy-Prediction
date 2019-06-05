function bandpass(file)
[~,name,~] = fileparts(file);
EEG = pop_biosig(file);
EEG.data = EEG.data([3:5,7:18,20:24],:);
EEGFIR = pop_eegfiltnew(EEG, 45, 55, [], 1);
EEGref = pop_reref( EEGFIR, []);
% AB1 = wptica(EEGref.data, EEGref);
% figure;
% for i = 1:4
%     subplot(2,2,i);
%     plot(EEG.data(i,:));
%     hold on
%     plot(AB1.data(i,:));
%     legend('Original', 'WPTICA');
%     title(sprintf('Channel %d', i));
% end
% a = AB1.data';
% fid = fopen('../data-bands/AB1-1.txt','wt');
% for ii = 1:size(a,1)
%     fprintf(fid,'%f\t',a(ii,:));
%     fprintf(fid,'\n');
% end
% fclose(fid);

% band-pass -------------------------------------------------------------
figure;
plot(EEG.data(1,:));
hold on 
plot(EEGFIR.data(1,:));
hold on
plot(EEGref.data(1,:));
legend('Original data','Notch filter', 'Re-reference');
% band-pass
delta = pop_eegfiltnew(EEGref, 0, 4, [], 0);
theta = pop_eegfiltnew(EEGref, 4, 8, [], 0);
alpha = pop_eegfiltnew(EEGref, 8, 12, [], 0);
beta = pop_eegfiltnew(EEGref, 12, 22, [], 0);
gamma = pop_eegfiltnew(EEGref, 30, [], [], 0);

A = wptica(alpha.data, alpha);
B = wptica(beta.data, beta);
D = wptica(delta.data, delta);
T = wptica(theta.data, theta);
G = wptica(gamma.data, gamma);

bands = [delta, theta, alpha, beta, gamma];
bname = ["delta", "theta", "alpha", "beta", "gamma"];
bands2 = [D, T, A, B, G];

figure;
for i = 1:4
    subplot(2,2,i);
    bdata = bands(i);
    plot(bdata.data(1,:));
    xlabel(sprintf('%s-channel 1', bname(i)));
end

for j = 1:5
    figure;
    s1 = bands(j);
    s2 = bands2(j);
    s3 = bname(j);
    for i = 1:4        
        subplot(2,2,i);
        plot(s2.data(i,1:100),'r');
        hold on 
        plot(s1.data(i,1:100),'b');
        title(sprintf('Channel %d', i));
        xlabel(sprintf('%s', s3));           
    end
    legend('WPTICA','Original');
end

% write band data to txt file -------------------------------------------
[rows, cols] = size(D.data');
for i = 1:5
    fprintf('Converting %s band to txt file\n', bname(i));
    fid = fopen(sprintf('../data-bands/%s-%s.txt', name, bname(i)),'w');
    temp1 = bands2(i);
    temp2 = temp1.data';
    if(rows>150000 && rows < 300000)
        fprintf('Time frame is %d', rows);
        nrows = rows / 4;
        for n = 1:4
            dlmwrite(sprintf('../data-bands/%s-%s%d.txt', name, bname(i), n), temp2((n-1)*nrows+1:nrows*n,:), 'delimiter', ' ', 'precision', 9, 'newline', 'pc');
        end
    elseif(rows > 300000)
        fprintf('Time frame is %d', rows);
        nrows = rows / 5;
        for n = 1:5
            dlmwrite(sprintf('../data-bands/%s-%s%d.txt', name, bname(i), n), temp2((n-1)*nrows+1:nrows*n,:), 'delimiter', ' ', 'precision', 9, 'newline', 'pc');
        end
    else
        fprintf('Time frame is %d', rows);
        nrows = rows / 2;
        for n = 1:2
            dlmwrite(sprintf('../data-bands/%s-%s%d.txt', name, bname(i), n), temp2((n-1)*nrows+1:nrows*n,:), 'delimiter', ' ', 'precision', 9, 'newline', 'pc');
        end
    end       
end
fclose(fid);


% for i = 1:5
%     fprintf('Converting %s band to csv file\n', bname(i));
%     temp1 = bands2(i);
%     temp2 = temp1.data';
%     csvwrite(sprintf('../data-bands/AB1-%s.csv', bname(i)), temp2);
% end
end