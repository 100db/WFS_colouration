run ('/Users/clockart/Dropbox/Uni/Bachelorarbeit/software/toolbox/sfs-master/SFS_start.m'); 
conf=SFS_config;
conf.array='circle';
L=3;
no_of_speaker=2*14;
conf.dx0 = pi*L/no_of_speaker;
conf.useplot =1;

conf.N = 2^15; % Samplelaenge der IR, für speed runter auf 2^13

% Frequenzgang bestimmen
conf.usehcomp = false;
irs=dummy_irs;
conf.usehpre=1;
conf.hpreflow=125;

ir_wfs = ir_wfs_25d([0 0], pi/2, [0 2.5], 'ps',L,irs,conf);
[a,pf,f]=easyfft(ir_wfs(:,1),conf);
%semilogx(f,db(a)); 
%xlim([1 length(a)+10^4]);

lowcut=1200;

normalizedamplitde=db(a(1:lowcut))/abs(max(db(a(1:50))))+1;
semilogx(f(1:lowcut),normalizedamplitde);
mean(normalizedamplitde)