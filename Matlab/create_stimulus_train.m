function [ noise_pulse_train ] = create_stimulus_train( total_duration, noise_duration, silence_duration,fadein,fadeout,noisetype,regenerate_noise,fs )
%CREATE_STIMULUS_TRAIN Summary of this function goes here
%   Detailed explanation goes here

Fs=fs;
total_samples=total_duration*Fs; %Set total length
noise_samples=noise_duration*Fs; %Set noise length
silence_samples=silence_duration*Fs; %Set silence length

attack_samples=fadein*Fs; %Set onset time
release_samples=fadeout*Fs; %Set release time
total_noise_samples=noise_samples+attack_samples+release_samples; %Calculate the amount of noise samples including attack and release
total_pulse_samples=total_noise_samples+silence_samples; %Calculate the total amount of samples per burst, including noise and silence

pulse = zeros(1,total_pulse_samples+1); %Generate one silent pulse
pulse(1:total_noise_samples) = generate_noise(noise_duration,fadein,fadeout,noisetype,Fs); %fill the beginning with noise
noise_pulse_train = zeros(1,total_samples); %create ouput

no_of_pulse = floor(total_samples/(total_noise_samples+silence_samples)); %calculate amount of pulses that fit so we always end in silence
for k=0:no_of_pulse
   if regenerate_noise
    pulse(1:total_noise_samples) = generate_noise(noise_duration,fadein,fadeout,noisetype,Fs); %regenerate noise for every pulse
   end
   noise_pulse_train(k*total_pulse_samples+1:(k+1)*total_pulse_samples+1) = pulse;
end

end
