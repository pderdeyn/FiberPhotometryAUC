% clc;
% clf;
% clear;
basepath = "Z:\Lab\Pieter\NacLatNicotine\";
groupdirs = dir(basepath);

groups = [""];
exps = [""];
averages1 = [];
averages2 = [];
averages3 = [];
numpeaks1 = [];
numpeaks2 = [];
numpeaks3 = [];
threshes = [];
tstarts1 = [7 8 7 9; 
    5 5 5 5; 
    8 5 5 5;
    %10 na 9 na;
    8 7 6 7];
tstarts2 = [39 40 38 39; 
    36 36 36 36; 
    36 36 36 36;
    %41 na 40 na;
    41 39 37 38];


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
        savefigs=false;
        %if contains(groups(i-idelta),"Veh") && contains(exps(i-idelta,j-jdelta),"M10")
        %    savefigs=true;
        %else
        %    savefigs=false;
        %    continue
        %end

        mat_files = dir(exppath+"\*.mat");
        thresh=0;
        %[peaks1,avg1] = plotAUC(exppath+"\channel_1\"+mat_files(1+mat_delta).name,true);
        %averages1(i-idelta,j-jdelta)=avg1;
        %numpeaks1(i-idelta,j-jdelta)=peaks1;
        [peaks2,avg2,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savefigs,tstarts1(i-idelta,j-jdelta)*60*100,(tstarts1(i-idelta,j-jdelta)+20)*60*100);
        averages2(i-idelta,j-jdelta)=avg2;
        numpeaks2(i-idelta,j-jdelta)=peaks2;
        [peaks3,avg3,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savefigs,tstarts2(i-idelta,j-jdelta)*60*100,(tstarts2(i-idelta,j-jdelta)+20)*60*100,thresh);
        averages3(i-idelta,j-jdelta)=avg3;
        numpeaks3(i-idelta,j-jdelta)=peaks3;
        
        threshes(i-idelta,j-jdelta)=thresh;
    end
end


%csvwrite('Nic.auc-whole.csv',averages1)
csvwrite('thc.auc-first.csv',averages2)
csvwrite('thc.auc-second.csv',averages3)
%csvwrite('Nic.peaks-whole.csv',numpeaks1)
csvwrite('thc.peaks-first.csv',numpeaks2)
csvwrite('thc.peaks-second.csv',numpeaks3)

% figure
% 
% bar(averages1)
% set(gca,'XTickLabel',groups)

figure

bar(averages2)
set(gca,'XTickLabel',groups)

figure

bar(averages3)
set(gca,'XTickLabel',groups)

% figure
% 
% bar(numpeaks1)
% set(gca,'XTickLabel',groups)

figure

bar(numpeaks2)
set(gca,'XTickLabel',groups)

figure

bar(numpeaks3)
set(gca,'XTickLabel',groups)

% [h,p,ci,stats] = ttest2(averages,averages2) 
% if p<0.01
%     yt = get(gca, 'YTick');
%     axis([xlim    0  ceil(max(yt)*1.2)])
%     xt = [1 2];
%     hold on
%     plot(xt([1 2]), [1 1]*max(yt)*1.1, '-k',  mean(xt([1 2])), max(yt)*1.15, '*k')
%     hold off
% end