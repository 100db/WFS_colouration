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


%lowcut=3200;
linS = {'','--',':'}; %linestyles to user after colors

norm=0;
offc=0;
compute=0;
incl_stereo=0;




if offc==1
    list_pos=[-1 0];
else
    list_pos=[0 0];
end


if incl_stereo==1
    
    ir_1_l= ir_point_source(list_pos-[0.1 0], pi/2, [1.4434 2.5],irs,conf);
    ir_2_l= ir_point_source(list_pos-[0.1 0], pi/2, [-1.4434 2.5],irs,conf);
    
    ir_1_r= ir_point_source(list_pos+[0.1 0], pi/2, [1.4434 2.5],irs,conf);
    ir_2_r= ir_point_source(list_pos+[0.1 0], pi/2, [-1.4434 2.5],irs,conf);
    
    ir_stereo=ir_1_r+ir_1_l+ir_2_l+ir_2_r;
    
    [a,pf,f]=easyfft(ir_stereo(:,1),conf);
    
    semilogx((f),db(a));
    grid on;
end


if compute
    ffts=zeros(10,4096);
    
    for i=1:10
        i
        no_of_speaker=14*2^(i-1);
        conf.dx0 = pi*L/no_of_speaker;
        conf.usehpre=1;
        conf.hpreflow  = findhprelow(no_of_speaker,L);
        conf.hprefhigh = findhprehigh(no_of_speaker,L,conf.hpreflow);
        
        ir_wfs = ir_wfs_25d(list_pos, pi/2, [0 2.5], 'ps',L,irs,conf);
        
        if norm==1
            ir_wfs = ir_wfs./max(max(abs(ir_wfs)));
        end
        
        [a,pf,f]=easyfft(ir_wfs(:,1),conf);
        
        ffts(i,:)=a';
        
        
        if offc==1
            ffts_off=ffts;
        end
        
        
    end
end
figure(4);

for  i=1:1:10
    semilogx((f),db(ffts(i,:)),linS{fix(i/8)+1});
    grid on;
    hold all; %cycles through colors
end

% %%Mark points of linearity
% hold on;
% max_linear(i)=find(abs(db(a))>(mean(db(a(1:100))+0.02)),1,'first');
%
% semilogx(f(max_linear(i)),ffts(max_linear(i)),'rx');


%xlim([find(f>1000,1) f(end)]);
xlim([100 , f(end)]);
ylim([-130,-60]);

h_legend=legend('14 speakers','28 speakers','56 speakers','112 speakers','224 speakers','448 speakers','896 speakers','1792 speakers','3584 speakers','7168 speakers');
set(h_legend,'FontSize',14);
xlabel('Frequency [Hz]','FontSize',15,'fontWeight','bold')
ylabel('Amplitude [dB]','FontSize',15,'fontWeight','bold')

%export png
pos = get(gcf,'Position');
width=1000;
pos(3:4) = [4/3*width width];
set(gcf,'Position',pos);
set(gcf, 'Color', 'w'); %weißer hintergrund

title('Frequency response of circular WFS array with variable amount of speakers, centered','FontSize',20,'fontWeight','bold');

%export_fig 'figs/freqspc_norm.png' -a1 -m2 %2fach antialiasing, 3fache auflösung
