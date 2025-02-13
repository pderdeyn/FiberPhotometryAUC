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
%'THCtoNicCohortOne(onethird)'
%'THCtoNicCohortTwo'
%'VehicletoNicCohorTwo'
%'VehtoNicCohortOne(onethird)'
tstarts1 = [6 7 6 6; 
    5 5 5 5; 
    6.6 5 6 4;
    6 6 5 6];
%tends1 = [
%    27    28    27    29
%    25    25    25    25
%    28    25    25    25
%    28    27    26    27
%];
tstarts2 = [38 39 36.67 38; 
    35 36 35 35; 
    35 35 35 35;
    40 38 37 37];
tends2 = [
    60 60 55 55
    59 nan nan 59
    63 60 nan 50
    57 58 63 55
];
tends1 = tstarts1+25;

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
        %if contains(groups(i-idelta),"Veh") && contains(exps(i-idelta,j-jdelta),"M10")
        %    savefigs=true;
        %else
        %    savefigs=false;
        %    continue
        %end

        mat_files = dir(exppath+"\*.mat");

        A = load(exppath+"\"+mat_files(1+mat_delta).name);
        x = A.sig_405_RS;
        y = A.timeFP_RS;
        %y = y / 60;
        z = A.sig_472_RS;

        f = figure;
        pControl = plot(y,x,'black');
        hold on
        pGCAMP = plot(y,z,'b');
        grid on
        xlabel('time'); 
        ylabel('signal');
        grid on;
        title(mat_files(1+mat_delta).name,'interpreter','none');
        xline([y(round(tstarts1(i-idelta,j-jdelta)*60*100)),y(round(tends1(i-idelta,j-jdelta)*60*100))],'-',{'tstart1','tend1'})
        if isnan(tends2(i-idelta,j-jdelta))
            xstop = y(end);
        else
            xstop = y(round(tends2(i-idelta,j-jdelta)*60*100));
        end
        xline([y(round(tstarts2(i-idelta,j-jdelta)*60*100)),xstop],'-',{'tstart2','tend2'})
        legend([pControl pGCAMP],{'Control','GCAMP'},'location','southeast')

        savename = groups(i-idelta)+"."+exps(i-idelta,j-jdelta);

        saveas(f,"plots\"+savename+".png")
        saveas(f,"plots\"+savename+".fig")
        
        thresh=0;
        %[peaks1,avg1] = plotAUC(exppath+"\channel_1\"+mat_files(1+mat_delta).name,true);
        %averages1(i-idelta,j-jdelta)=avg1;
        %numpeaks1(i-idelta,j-jdelta)=peaks1;
        [peaks2,avg2,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savename+".first",tstarts1(i-idelta,j-jdelta)*60*100,(tends1(i-idelta,j-jdelta))*60*100);
        averages2(i-idelta,j-jdelta)=avg2;
        numpeaks2(i-idelta,j-jdelta)=peaks2;
        [peaks3,avg3,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savename+".second",tstarts2(i-idelta,j-jdelta)*60*100,(tends2(i-idelta,j-jdelta))*60*100);
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

f=figure;

b = bar(averages2);
set(gca,'XTickLabel',groups)
title('aucs first')
saveas(f,"plots\first.aucs.png")

f=figure;

bar(averages3)
set(gca,'XTickLabel',groups)
title('aucs second')
saveas(f,"plots\second.aucs.png")

% figure
% 
% bar(numpeaks1)
% set(gca,'XTickLabel',groups)

f=figure;

bar(numpeaks2)
set(gca,'XTickLabel',groups)
title('peaks first')
saveas(f,"plots\first.peaks.png")

f=figure;

bar(numpeaks3)
set(gca,'XTickLabel',groups)
title('peaks second')
saveas(f,"plots\second.peaks.png")

% [h,p,ci,stats] = ttest2(averages,averages2) 
% if p<0.01
%     yt = get(gca, 'YTick');
%     axis([xlim    0  ceil(max(yt)*1.2)])
%     xt = [1 2];
%     hold on
%     plot(xt([1 2]), [1 1]*max(yt)*1.1, '-k',  mean(xt([1 2])), max(yt)*1.15, '*k')
%     hold off
% end