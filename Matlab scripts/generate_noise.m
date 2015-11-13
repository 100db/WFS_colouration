function [ noise_out ] = generate_noise( noise_duration,fade_in,fade_out,noise_type,fs )
%generate_noise Generates a noise pulse of adjustable length
%
%	Returns a vector containing the desired noise pulse
%
%	noise_duration: length of noise pulse in seconds
%	fade_in: length of fade in time in seconds
%	fade_out: length of fade out time in seconds
%	noise_type: 'white' for white noise, 'pink' for pink noise
%	fs: sampling frequency
%
% Christoph Hohnerlein, BA thesis, 03.11.2013

Fs=fs;
num_samples=noise_duration*Fs;                          % Set length
attack_samples=fade_in*Fs;                              % Set onset time
release_samples=fade_out*Fs;                            % Set release time
total_duration=num_samples+attack_samples+release_samples;


NFFT = 2^nextpow2(total_duration);                      % Next power of two
wnoise=randn(1,NFFT);                                   % Create white noise

if strcmpi(noise_type, 'white')                         % ASR if white noise
    wnoise_final=ones(1,total_duration);
    wnoise_final(1:attack_samples)=linspace(0,1,attack_samples);
    wnoise_final(end-release_samples+1:end)=linspace(1,0,release_samples);
    wnoise_final=wnoise_final.*wnoise(1:total_duration);
    noise_out = wnoise_final;
    
elseif strcmpi(noise_type,'pink')
    wnoise=wnoise./max(abs(wnoise));                    % Normalize white noise
    wnoise_fft = fft(wnoise);                           % FFT of white noise
    sqrt_div = 1:(NFFT);
    sqrt_div = sqrt(sqrt_div);                          % Create array of square roots
    pnoise_fft=wnoise_fft(1:NFFT)./sqrt_div;            % Divide each frequency by its square root
    pnoise=real(ifft(pnoise_fft));                      % Transform filtered noise back to time domain
    pnoise=pnoise/max(abs(pnoise));                     % Normalize white noise so that max=1
    pnoise_final=ones(1,total_duration);                % ASR for pink noise
    pnoise_final(1:attack_samples)=linspace(0,1,attack_samples);
    pnoise_final(end-release_samples+1:end)=linspace(1,0,release_samples);
    pnoise_final=pnoise_final.*pnoise(1:total_duration);
    noise_out=pnoise_final;
else
    disp('unknown noise type');                         % return 0 if unkown noise type
    noise_out = 0;
end

end