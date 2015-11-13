function [ noise_pulse_train ] = create_stimulus_train( total_duration, noise_duration, silence_duration,fade_in,fade_out,noise_type,regenerate_noise,fs )
%CREATE_STIMULUS_TRAIN creates a adjustable noise train
%
%	generate_noise method must be available!
%
%   total_duration: Total duration of the pulse train in s
%   noise_duration: Duration of each noise pulse in s
%   silence_duration: Length of pause between two pulses in s
%   fade_in: Fade in time of each time pulse in s
%   fade_out: Fade out time of each time pulse in s
%   noise_type: 'white' for white noise, 'pink' for pink noise
%   regenerate_noise: Flag wether or not the noise should be regenerated
%   for each pulse
%   fs: Sampling frequency
%
% Christoph Hohnerlein, BA thesis, 03.11.2013

Fs=fs;
total_samples=total_duration*Fs;            %Set total length
noise_samples=noise_duration*Fs;            %Set noise length
silence_samples=silence_duration*Fs;        %Set silence length

attack_samples=fade_in*Fs;                  %Set onset time
release_samples=fade_out*Fs;                %Set release time
total_noise_samples=noise_samples+attack_samples+release_samples; %Calculate the amount of noise samples including attack and release
total_pulse_samples=total_noise_samples+silence_samples; %Calculate the total amount of samples per burst, including noise and silence

pulse = zeros(1,total_pulse_samples+1);     %Generate one silent pulse
pulse(1:total_noise_samples) = generate_noise(noise_duration,fade_in,fade_out,noise_type,Fs); %fill beginning with noise
noise_pulse_train = zeros(1,total_samples); %create ouput

no_of_pulse = floor(total_samples/(total_noise_samples+silence_samples)); %calculate amount of pulses that fit so train always end in silence
for k=0:no_of_pulse
   if regenerate_noise
    pulse(1:total_noise_samples) = generate_noise(noise_duration,fade_in,fade_out,noise_type,Fs); %regenerate noise for every pulse
   end
   noise_pulse_train(k*total_pulse_samples+1:(k+1)*total_pulse_samples+1) = pulse;
end

end
