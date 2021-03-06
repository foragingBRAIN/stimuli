

clear all
close all

g = gpuDevice(1);
reset(g);

nFrames = 100;
stimsize = [10000,10000];
stimFolder = 'C:\Users\angelakiVR\Documents\stimuli\';


%% pink noise texture params
% spatial spectrum
beta = -2;

u = [(0:floor(stimsize(1)/2)) -(ceil(stimsize(1)/2)-1:-1:1)]'/stimsize(1);
u = repmat(u,1,stimsize(2));
v = [(0:floor(stimsize(2)/2)) -(ceil(stimsize(2)/2)-1:-1:1)]/stimsize(2);
v = repmat(v,stimsize(1),1);

S_f = (u.^2 + v.^2).^(beta/2); 
S_f(S_f==Inf) = 0;
S_f = gpuArray(S_f.^0.5);
% temporal weighting
speedchange = 20;
k = sqrt(u.^2 + v.^2);
invk = gpuArray(exp(-k.*speedchange));
invk(isinf(invk)) = 0;

oldSpectrum = gpuArray(2*pi*rand(stimsize));
oldSpectrum = S_f .* (cos(oldSpectrum) + 1i.*sin(oldSpectrum));

for ff=1:nFrames
    fprintf('\nGenerating frames...%i%%',ceil(round(100*ff/nFrames)));
    
    newSpectrum = gpuArray(2*pi*rand(stimsize));
    newSpectrum = S_f .* (cos(newSpectrum) + 1i.*sin(newSpectrum));
    newSpectrum = sqrt(1-invk.^2).*newSpectrum;
    
    oldSpectrum = invk.*oldSpectrum;
    oldSpectrum = oldSpectrum + newSpectrum;

    Xmat = ifft2(oldSpectrum);
    Xmat = real(Xmat);
    Xmat = Xmat./std(Xmat(:))*128/3+128;
    Xmat = round(Xmat);
    Xmat = max(Xmat,0);
    Xmat = min(Xmat,255);
    
    fileName = sprintf('%sstimulus%s%i.png',stimFolder,repmat('0',1,5-fix(log10(ff))),ff);
    imwrite(uint8(gather(Xmat)),fileName);
end


% tempSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
% compSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
% 
% for ff=1:nFrames
%     fprintf('\nGenerating frames...%i%%',ceil(round(100*ff/nFrames)));
%     tempSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
%     compSpectrum = invk.*compSpectrum + sqrt(1-invk.^2).*tempSpectrum;
% 
%     Xmat = ifft2(compSpectrum);
% %     Xmat = angle(Xmat + colvar*exp(1i*colmean));
% %     Xgray = angle(Xgray + E.stimConcentration.*exp(1i.*(-0.5*pi+0.5*lambdaVec(frameNum)*pi)));
%     Xabs = abs(Xmat);
%     Xgray = (Xabs/std(Xabs(:)))*128/6 + 128;
%     Xgray = min(max(round(Xgray),0),255);
% 
%     fileName = sprintf('%sstimulus%s%i.png',stimFolder,repmat('0',1,5-fix(log10(ff))),ff);
%     
%     imwrite(Xgray,fileName);
%     
% end



