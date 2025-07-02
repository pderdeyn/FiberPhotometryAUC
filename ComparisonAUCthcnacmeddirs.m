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
    nan 4 4.5 5 5 6 6 5 4.5 5; 
    4.5 4.5 5 5 5 5.5 5 4.75 5 4.5
    ];
tends1 = [
    nan 36 36 35 36 38 37 38 36 29; 
    38 35.5 34.8 36 36 36.5 34 36 35 36
    ];
%tends1 = tstarts1+25;

tstarts2 = [
    45.5 nan 36 35 36 38 37 38 36 39; 
    38 35.5 37.5 36 35 36.5 34 36.6 35 36
    ];
tends2 = [
    60 nan nan nan nan 63 63 nan 55 nan; 
    56 nan 66.5 63 nan 59 64.4 nan 55 56
    ];


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
        if ~isnan(tstarts1(i-idelta,j-jdelta))
            xline([y(round(tstarts1(i-idelta,j-jdelta)*60*100)),y(round(tends1(i-idelta,j-jdelta)*60*100))],'-',{'tstart1','tend1'})
        end

        if ~isnan(tstarts2(i-idelta,j-jdelta))
            if isnan(tends2(i-idelta,j-jdelta))
                xstop = y(end);
            else
                xstop = y(round(tends2(i-idelta,j-jdelta)*60*100));
            end
            xline([y(round(tstarts2(i-idelta,j-jdelta)*60*100)),xstop],'-',{'tstart2','tend2'})
        end

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