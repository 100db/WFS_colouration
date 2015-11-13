%%
%	Script to create reference, anchor, stereo and WFS impulse responses at
%	different listening positions
%
%   WFS size is 56 speaker, output is written as 720 Channel .wav
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
L=3; %array durchmesser

%Set the number of speakers to 56
no_of_speaker=56;
    
%Set speaker distance based on the number of speakers
conf.dx0 = pi*L/no_of_speaker;



%Use kompensation for the AKG K601
conf.usehcomp = true;
conf.hcomplfile = 'compensation/QU_KEMAR_AKGK601_hcomp.wav';
conf.hcomprfile = conf.hcomplfile;
Fs=44100;

conf.usehpre=1;

irs=read_irs('HRTF/QU_KEMAR_anechoic_3m.mat');

%%
% Create 12 WFS IR as BRS with 58 speakers and a moving listener position

% Create array containing all listening positions
list_pos = [[0 0];[-.25 0];[-.5 0];[-.75 0];[-1 0];[-1.25 0];[-1.5 0];[-.25 -.5];[-.5 -.5];[-.75 -.5];[-1 -.5];[-1.25 -.5];];
for i=1:length(list_pos)
    
    %Set start and end of wfs_prefilter
    conf.hpreflow  = findhprelow(no_of_speaker,L);
    conf.hprefhigh = findhprehigh(no_of_speaker,L,conf.hpreflow);
    
    %Generate the impuls responses for listening position
    if list_pos(i,1) == 0
        head_angle=pi/2;
    else
        head_angle = atan2((2.5+abs(list_pos(i,2))),abs(list_pos(i,1)));
    end
    
    eval(['ir_wfs_' num2str(i) '=ir_wfs_25d(list_pos(i,:), head_angle, [0 2.5], ''ps'',L,irs,conf);'])
    
    %Normalize impuls response to 0.8
    eval(['ir_wfs_' num2str(i) '_norm=0.8.*ir_wfs_' num2str(i) './max(max(abs( ir_wfs_' num2str(i) ' )));'])
    %Create BRS output with 720 channels with length or the wfs_IR
    eval(['ir_wfs_brs_' num2str(i) ' = zeros(length(ir_wfs_' num2str(i) '_norm),720);'])
    %Only fill the first two channels (left & right ear at 0 deegree)
    eval(['ir_wfs_brs_' num2str(i) '(:,1) =  ir_wfs_' num2str(i) '_norm(:,1);'])
    eval(['ir_wfs_brs_' num2str(i) '(:,2) =  ir_wfs_' num2str(i) '_norm(:,2);'])
    %Write impulse response in 720chan wav file
    eval(['wavwrite(ir_wfs_brs_' num2str(i) ',Fs,16,strcat(''brs/moving_listener/ir_wfs_brs_'',num2str(i), ''.wav''));'])
 
end