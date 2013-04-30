function [ noise_out ] = generate_noise( noise_duration,fadein,fadeout,noisetype,fs )
%A Summary of this function goes here
%   Detailed explanation goes here

Fs=fs;
num_samples=noise_duration*Fs; %Set length
attack_samples=fadein*Fs; %Set onset time
release_samples=fadeout*Fs; %Set release time
total_duration=num_samples+attack_samples+release_samples;


NFFT = 2^nextpow2(total_duration); % Next power of 2 from desired duration
wnoise=randn(1,NFFT);        % Create white noise

if strcmpi(noisetype, 'white')
    wnoise_final=ones(1,total_duration);
    wnoise_final(1:attack_samples)=linspace(0,1,attack_samples); %attack
    wnoise_final(end-release_samples+1:end)=linspace(1,0,release_samples); %Release
    wnoise_final=wnoise_final.*wnoise(1:total_duration);
    noise_out = wnoise_final;
    
elseif strcmpi(noisetype,'pink')
    wnoise=wnoise./max(wnoise);  % Normalize white noise so that max=1
    wnoise_fft = fft(wnoise);    % FFT of white noise
    sqrt_div = 1:(NFFT);
    sqrt_div = sqrt(sqrt_div);    % Create array of square roots
    pnoise_fft=wnoise_fft(1:NFFT)./sqrt_div; % divide each frequency by its square root
    pnoise=real(ifft(pnoise_fft));  % Transform filtered noise back to time domain
    pnoise=pnoise/max(pnoise);      % Normalize white noise so that max=1
    %ASR
    pnoise_final=ones(1,total_duration);
    pnoise_final(1:attack_samples)=linspace(0,1,attack_samples); %attack
    pnoise_final(end-release_samples+1:end)=linspace(1,0,release_samples); %Release
    pnoise_final=pnoise_final.*pnoise(1:total_duration);
    noise_out=pnoise_final;
else
    disp('unknown noise type');
    noise_out = 0;
end

end