% clc;
% clf;
% clear;
basepath = "Z:\Lab\Pieter\NacMedNicotine\";
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
tstarts1 = [
    5 5 5 5 5 5 5 5 5 5; 
    5 5 5 5 5 5 5 5 5 5
    ];
%tends1 = [
%    27    28    27    29
%    25    25    25    25
%    28    25    25    25
%    28    27    26    27
%];
tends1 = tstarts1+25;

tstarts2 = [
    35 35 35 35 35 35 35 35 35 35; 
    35 35 35 35 35 35 35 35 35 35
    ];
tends2 = tstarts2+25;


pseudonyms = string(dec2hex(randi([1 10000], 2,20)));
pseudonyms = reshape(pseudonyms,2,10,2);

times1 = [];
times2 = [];

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

        times1(i-idelta,j-jdelta) = tends1(i-idelta,j-jdelta)-tstarts1(i-idelta,j-jdelta);
        times2(i-idelta,j-jdelta) = tends2(i-idelta,j-jdelta)-tstarts2(i-idelta,j-jdelta);
        mat_files = dir(exppath+"\*.mat");
        if isnan(tends2(i-idelta,j-jdelta))
            A = load(exppath+"\"+mat_files(1+mat_delta).name);
            y = A.timeFP_RS;
            times2(i-idelta,j-jdelta) = y(end)/60-tstarts2(i-idelta,j-jdelta);
        end
        %if contains(groups(i-idelta),"THC") && contains(exps(i-idelta,j-jdelta),"M5")
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
        pseudo = pseudonyms(i-idelta,j-jdelta,1);
        pseudo = string(pseudo{1});
        pseudo = 0;
        [peaks2,avg2,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savename+".first",tstarts1(i-idelta,j-jdelta)*60*100,(tends1(i-idelta,j-jdelta))*60*100,pseudo);
        averages2(i-idelta,j-jdelta)=avg2;
        numpeaks2(i-idelta,j-jdelta)=peaks2;
        pseudo = pseudonyms(i-idelta,j-jdelta,2);
        pseudo = string(pseudo{1});
        pseudo = 0;
        [peaks3,avg3,thresh] = plotAUC(exppath+"\"+mat_files(1+mat_delta).name,savename+".second",tstarts2(i-idelta,j-jdelta)*60*100,(tends2(i-idelta,j-jdelta))*60*100,pseudo);
        averages3(i-idelta,j-jdelta)=avg3;
        numpeaks3(i-idelta,j-jdelta)=peaks3;
        
        threshes(i-idelta,j-jdelta)=thresh;
    end
end


%csvwrite('Nic.auc-whole.csv',averages1)
csvwrite('thc-nacmed.auc-first.csv',averages2)
csvwrite('thc-nacmed.auc-second.csv',averages3)
%csvwrite('Nic.peaks-whole.csv',numpeaks1)
csvwrite('thc-nacmed.peaks-first.csv',numpeaks2)
csvwrite('thc-nacmed.peaks-second.csv',numpeaks3)


writetable(table(pseudonyms(:,:,1)),'thc-nacmed.pseudonyms.first.csv')
writetable(table(pseudonyms(:,:,2)),'thc-nacmed.pseudonyms.second.csv')
writetable(table(exps),'thc-nacmed.experiments.csv')
writetable(table(times2),'thc-nacmed.times.csv')



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