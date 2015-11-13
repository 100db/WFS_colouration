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

run ('/Users/clockart/Dropbox/Uni/Bachelorarbeit/software/toolbox/sfs-master_old/SFS_start.m');
conf=SFS_config;
conf.array='circle';
L=3;
no_of_speaker=2*14;
conf.dx0 = pi*L/no_of_speaker;
conf.useplot =1;
conf.N = 2^13;

conf.usehcomp = false;
irs=dummy_irs;

offc=1;

sep_ear=1;

if offc==1
    list_pos=[-1 0];
else
    list_pos=[0 0];
end


ir_1= ir_point_source(list_pos, pi/2, [1.4434 2.5],irs,conf);
ir_2= ir_point_source(list_pos, pi/2, [-1.4434 2.5],irs,conf);
ir_stereo=ir_1+ir_2;
[a,pf,f]=easyfft(ir_stereo(:,1),conf);
semilogx((f),db(a),'b--');
grid on;
hold on;

if sep_ear==1
    ir_1_l= ir_point_source(list_pos-[0.1 0], pi/2, [1.4434 2.5],irs,conf); %right speaker to left ear
    ir_2_l= ir_point_source(list_pos-[0.1 0], pi/2, [-1.4434 2.5],irs,conf); %left speaker to left ear
    
    ir_1_r= ir_point_source(list_pos+[0.1 0], pi/2, [1.4434 2.5],irs,conf);%right speaker to right ear
    ir_2_r= ir_point_source(list_pos+[0.1 0], pi/2, [-1.4434 2.5],irs,conf);%left speaker to right ear
    
    ir_stereo_sep=(ir_1_r+ir_1_l+ir_2_l+ir_2_r)/2;
    
    [a,pf,f]=easyfft(ir_stereo_sep(:,1),conf);
    hold on;
    semilogx((f),db(a),'r');
    
end

xlim([100 , f(end)]);
ylim([-110,-70]);

h_legend=legend('ideal stereo', 'real stereo');
set(h_legend,'FontSize',14);
xlabel('Frequency [Hz]','FontSize',15,'fontWeight','bold')
ylabel('Amplitude [dB]','FontSize',15,'fontWeight','bold')

%export png
pos = get(gcf,'Position');
width=1000;
pos(3:4) = [4/3*width width];
set(gcf,'Position',pos);
set(gcf, 'Color', 'w'); %weißer hintergrund

if offc==1
title('Frequency response of stereo in an off-centered position','FontSize',20,'fontWeight','bold');

else
    title('Frequency response of stereo in a centered position','FontSize',20,'fontWeight','bold');
end

%export_fig 'figs/freqspc_norm.png' -a1 -m2 %2fach antialiasing, 3fache auflösung
