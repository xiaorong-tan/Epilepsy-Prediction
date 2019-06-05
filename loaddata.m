list = dir(['D:\MSc project\data\','*.edf']);
len = length(list);
for n=1:len
	str = strcat ('D:\MSc project\data\', list(n).name);
    bandpass(str);
end
