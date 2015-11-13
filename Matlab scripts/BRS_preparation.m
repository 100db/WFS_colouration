%%
%	Script to create reference, anchor, stereo and WFS impulse responses of
%	variable sizes
%
%   WFS sizes are 14*2^n, output is written as 720 Channel .wav
%	First to channel will contain computed impulse responses for both ears
%
%   Christoph Hohnerlein, 03.11.13
%
%%

% SFS Settings
clear;clc;
run ('/toolbox/sfs-master-0.2.2/SFS_start.m'); 
conf=SFS_config;
conf.array='circle';
L=3;        %array diameter

%%%%%%% Setting

list_cent = true; %Listener position



if list_cent
    list_pos = [0 0]; %Listener centered
else
    list_pos = [-1 0]; %Listener off center
end

%Use kompensation for the AKG K601
conf.usehcomp = false;
conf.hcomplfile = 'compensation/QU_KEMAR_AKGK601_hcomp.wav';
conf.hcomprfile = conf.hcomplfile;
Fs=44100;

conf.usehpre=1;

%Load HRTFs
irs=read_irs('HRTF/QU_KEMAR_anechoic_3m.mat');

%%
%Create a point source IR as BRS for reference

ir_ps= ir_point_source(list_pos, pi/2, [0 2.5],irs,conf);
%normalize ps impulse response to 0.8 (max max for stereo)
ir_ps_norm=0.8.*ir_ps./(max(max(abs(ir_ps))));


%create brs output (720 channels)
ir_ps_brs = zeros(length(ir_ps_norm),720);
%fill first 2 channels with IR of ps
ir_ps_brs(:,1)= ir_ps_norm(:,1);
ir_ps_brs(:,2)= ir_ps_norm(:,2);
%write 720 chan output wav 
wavwrite(ir_ps_brs,Fs,16,'brs/off_center/ir_ps_brs.wav');


%%
%Filter point source to create anchor
%2nd Order Butterworth, cutoff at 5kHz.
cutoff=5000;
[b,a] = butter(2,cutoff/Fs,'high');
ir_ps_f = filter(b,a,ir_ps_norm);
%Normalize IR to 0.8
ir_ps_f_norm=0.8.*ir_ps_f./(max(max(abs(ir_ps_f))));
%create brs output (720 channels)
ir_ps_f_brs = zeros(length(ir_ps_f_norm),720);
%fill first 2 channels with IR of ps
ir_ps_f_brs(:,1)= ir_ps_f_norm(:,1);
ir_ps_f_brs(:,2)= ir_ps_f_norm(:,2);
%write 720 chan output wav 
wavwrite(ir_ps_f_brs,Fs,16,'brs/off_center/ir_ps_brs_anchor.wav');


%%
% Create WFS simulated stereo at 90 +- 30
% x Distance is tan alpha * 2.5 = tan(pi/6)*2.5 =1.4434
ir_1= ir_point_source(list_pos, pi/2, [1.4434 2.5],irs,conf);
ir_2= ir_point_source(list_pos, pi/2, [-1.4434 2.5],irs,conf);
ir_stereo=ir_1+ir_2;

%normalize ps impulse response to 0.8
ir_stereo_norm=0.8.*ir_stereo./(max(max(abs(ir_stereo))));


%create brs output (720 channels)
ir_stereo_brs = zeros(length(ir_stereo_norm),720);
%fill first 2 channels with IR of ps
ir_stereo_brs(:,1)= ir_stereo_norm(:,1);
ir_stereo_brs(:,2)= ir_stereo_norm(:,2);
%write 720 chan output wav 

wavwrite(ir_stereo_brs,Fs,16,'brs/no_comp/ir_stereo_brs.wav');


%%
% Create 9 WFS IR as BRS with 14 to 14*2^8=3584 speakers
for i=1:9
    %Set the number of speakers for each round
    no_of_speaker=2^(i-1)*14;
    
    %Set speaker distance based on the number of loops
    conf.dx0 = pi*L/no_of_speaker;
    
    %Set start and end of wfs_prefilter
    conf.hpreflow  = findhprelow(no_of_speaker,L);
    conf.hprefhigh = findhprehigh(no_of_speaker,L,conf.hpreflow);
    
    %Generate the impuls responses for each amount of speakers
    eval(['ir_wfs_' num2str(14*2^(i-1)) '=ir_wfs_25d(list_pos, pi/2, [0 2.5], ''ps'',L,irs,conf);'])
    %Normalize impuls response to 0.8
    eval(['ir_wfs_' num2str(14*2^(i-1)) '_norm=0.8.*ir_wfs_' num2str(14*2^(i-1)) './max(max(abs( ir_wfs_' num2str(14*2^(i-1)) ' )));'])
    %Create BRS output with 720 channels with length or the wfs_IR
    eval(['ir_wfs_brs_' num2str(14*2^(i-1)) ' = zeros(length(ir_wfs_' num2str(14*2^(i-1)) '_norm),720);'])
    %Only fill the first two channels (left & right ear at 0 deegree)
    eval(['ir_wfs_brs_' num2str(14*2^(i-1)) '(:,1) =  ir_wfs_' num2str(14*2^(i-1)) '_norm(:,1);'])
    eval(['ir_wfs_brs_' num2str(14*2^(i-1)) '(:,2) =  ir_wfs_' num2str(14*2^(i-1)) '_norm(:,2);'])
    %Write impulse response in 720chan wav file
    eval(['wavwrite(ir_wfs_brs_' num2str(14*2^(i-1)) ',Fs,16,strcat(''brs/off_center/ir_wfs_brs_'',num2str(14*2^(i-1)), ''.wav''));'])
 
end