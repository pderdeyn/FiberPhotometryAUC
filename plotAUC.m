function [num_peaks,avg,thresh] = plotAUC(filename,figs,tstart,tend,thresh)
    arguments
       filename
       figs
       tstart (1,1) double = 1 
       tend (1,1) double = 0 
       thresh (1,1) double = 0 
    end
%filepath="C:\Users\alexh\OneDrive\Documents\data for research";
%filename=uigetfile('*','Select file');

A = load(filename);
if tend==0 
    x = A.sig_405_RS(50:end);
    y = A.timeFP_RS(50:end);
    z = A.sig_472_RS(50:end);
    zmin = movmin(z,100);
else 
    x = A.sig_405_RS(tstart:tend);
    y = A.timeFP_RS(tstart:tend);
    z = A.sig_472_RS(tstart:tend);
    zmin = z - movmin(z,100);
end
%CalcNorm = z-zmin;
%CalcNorm = z-min(z);
CalcNorm = z-mean(z(1:100*100))+2*std(z(1:100*100));

figure
pControl = plot(y,x,'black');
hold on
pGCAMP = plot(y,z,'b');
grid on
pNormal = plot(y,zmin);
xlabel('time'); 
ylabel('signal');
legend([pControl pGCAMP pNormal],{'Control','GCAMP','moving min'})
grid on;
title('signal vs time:'+filename);
% 
% figure 
AreaNorm=trapz(y,CalcNorm);
% bz=bar(AreaNorm);
% legend((bz),{'normalized'})
% ylabel("area")
% title(filename)
%findpeaks(CalcNorm,y,'MinPeakHeight',mean(CalcNorm)+2*std(CalcNorm));
%pks = findpeaks(CalcNorm,y,'MinPeakHeight',mean(CalcNorm)+2*std(CalcNorm));
if thresh==0
    thresh = mean(zmin)+5*std(zmin);
end
findpeaks(zmin,y,'MinPeakHeight',thresh);
pks = findpeaks(zmin,y,'MinPeakHeight',thresh);
num_peaks = length(pks);




avg = AreaNorm;
if figs
    figure
    x=y;
    curve1 = CalcNorm';
    curve2 = ones(length(y),1)'*0;
    pGCAMP = plot(y,CalcNorm,'b');
    grid on
    x2 = [x, fliplr(x)];
    inBetween = [curve1, fliplr(curve2)];
    fill(x2, inBetween, 'g');
    xlabel('time'); 
    ylabel('signal');
    ylim([min(CalcNorm), max(CalcNorm)])
    title('signal vs time:'+filename);
else
    close all
end
end

 