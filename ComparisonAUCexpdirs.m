% clc;
% clf;
% clear;
basepath = "Z:\Lab\Pieter\MHb-FP-data\MHb-FP-data";
groupdirs = dir(basepath);

groups = [""];
exps = [""];
averages = [];

idelta = 0;
for i = 1:length(groupdirs)
    jdelta = 0;
    if startsWith(groupdirs(i).name,'.')
        idelta = idelta + 1;
        continue
    end
    grouppath = basepath + "\" + groupdirs(i).name;
    expdirs = dir(grouppath);
    groups(i-idelta) = string(groupdirs(i).name);
    count = 0;
    for j = 1:length(expdirs)
        mat_delta = 0;
        if startsWith(expdirs(j).name,'.')
            jdelta = jdelta + 1;
            continue
        end
        exps(i-idelta,j-jdelta) = string(expdirs(j).name);
        exppath = grouppath + "\" + expdirs(j).name;
        count = count + 1;
        
        mat_files = dir(exppath+"\channel_1\*.mat");
        if length(mat_files) ~= 4
           mat_delta = length(mat_files)-4;
        end
        [num_peaks,avg,thresh] = plotAUC(exppath+"\channel_1\"+mat_files(1+mat_delta).name,false);
        averages(i-idelta,j-jdelta)=avg;
    end
end


csvwrite('MHb-FP.auc.csv',averages)

figure

bar(averages)
set(gca,'XTickLabel',groups)
[h,p,ci,stats] = ttest2(averages,averages2) 
if p<0.01
    yt = get(gca, 'YTick');
    axis([xlim    0  ceil(max(yt)*1.2)])
    xt = [1 2];
    hold on
    plot(xt([1 2]), [1 1]*max(yt)*1.1, '-k',  mean(xt([1 2])), max(yt)*1.15, '*k')
    hold off
end