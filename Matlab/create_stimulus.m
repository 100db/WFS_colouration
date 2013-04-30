

% Bachelorarbeit
% WFS Colouring
% Christoph Hohnerlein
% 16.04.13


% Create Pink Noise as stimuli
% - 600 ms of White Noise
% - Filter with 1/f
% - Set 50ms fade-in/-out

% Todo
% decide on same noise vs new noise

Fs=44100;
num_samples=0.6*Fs; %Set length
attack_samples=0.05*Fs; %Set onset time
release_samples=0.05*Fs; %Set release time
duration=num_samples+attack_samples+release_samples;

NFFT = 2^nextpow2(duration); % Next power of 2 from desired duration
wnoise=randn(1,NFFT);        % Create white noise

wnoise=wnoise./max(wnoise);  % Normalize white noise so that max=1
wnoise_fft = fft(wnoise);    % FFT of white noise

sqrt_div = 1:(NFFT);
sqrt_div = sqrt(sqrt_div);    % Create array of square roots
pnoise_fft=wnoise_fft(1:NFFT)./sqrt_div; % divide each frequency by its square root

pnoise=real(ifft(pnoise_fft));  % Transform filtered noise back to time domain
pnoise=pnoise/max(pnoise);      % Normalize white noise so that max=1

%ASR
pnoise_final=ones(1,num_samples);
pnoise_final(1:attack_samples)=linspace(0,1,attack_samples); %attack
pnoise_final(end-release_samples+1:end)=linspace(1,0,release_samples); %Release
pnoise_final=pnoise_final.*pnoise(1:length(pnoise_final)); %Create final pink noise

% For comparison, adjust volume to match max(pnoise_web)
pnoise_final=pnoise_final*max(pnoise_web)/max(pnoise_final);

%fft
Y = fft(pnoise_final,NFFT)/duration;
Y = abs(Y(1:NFFT/2+1)); %take absolute value of first half of fft
Y=Y/max(Y);  %normalize fft

% %compare to commercial pink noise
pnoise_web=wavread('/Users/clockart/Dropbox/Uni/Bachelorarbeit/Matlab/pink_-6dBFS_3s.wav');
Y_web=fft(pnoise_web,NFFT)/duration;
Y_web = abs(Y_web(1:NFFT/2+1)); 
Y_web=Y_web/max(Y_web); %normalize fft

%plot
f = Fs/2*linspace(0,1,NFFT/2+1);
loglog(f,Y.^2,'b',f,Y_web.^2,'y',f,1./f,'-- r'),xlim([20 Fs/2]);,ylim([10^-8 10^-1]);,grid on;