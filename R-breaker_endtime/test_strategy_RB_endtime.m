clear;
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
breakpct=0.005;
maxtrdnum=2;
paras=[0.07,0.35,0.25];
data=csvread('D:\Works\collected data\期货5秒数据\K_if.csv',1,0);


%%
tic
[tableD,tableK]=RBreaker_5seconds(data,paras,transactioncost,breakpct,tol,maxtrdnum);
toc
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=indicators(tableK,tableD,1)


%%

date=data(:,1);
time=data(:,2);
close=data(:,6);

%%
maxtrdnum=2;
tic
[positions,signals]=RBreaker_signals(data,paras,breakpct,tol,maxtrdnum);
toc

%%
date=data(:,1);
time=data(:,2);
close=data(:,6);

Ktrdtime=time;
Ktrddate=date;
Ksignal=signals;
Ktrdprc=zeros(length(close),1);
Ktrdprc(signals~=0)=close(signals~=0);

[returns,points]=calc_earnings(positions,signals,close,transactioncost);
tableK=array2table([Ktrddate Ktrdtime Ksignal positions Ktrdprc points returns],...
    'VariableNames',{'date','time','signal','position','trdprc','points','returns'});
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=RBindicators(tableK)



