clear;
transactioncost=3/10000;
lasttime=0;
tol=1e-9;
breakpct=0.005;
maxtrdnum=2;
paras=[0.07,0.35,0.25];
data=csvread('D:\Works\collected data\期货5秒数据\K_if.csv',1,0);


%%
tic
[tableK]=RBreaker_5seconds(data,paras,transactioncost,breakpct,tol,maxtrdnum);
toc
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=RBindicators(tableK)


%%
tic
[positions,signals,prices]=RBreaker_signals(data,paras,breakpct,tol,maxtrdnum);
toc

%%
date=data(:,1);
time=data(:,2);

Ktrdtime=time;
Ktrddate=date;
Ksignal=signals;
Ktrdprc=zeros(length(prices),1);
Ktrdprc(signals~=0)=prices(signals~=0);

[returns,points]=calc_earnings(positions,signals,prices,transactioncost);
tableK1=array2table([Ktrddate Ktrdtime Ktrdprc Ksignal positions points returns],...
    'VariableNames',{'date','time','trdprc','signal','position','points','returns'});
%%
[maxdds1,sharps1,annrets1,annvols1,trdnums1,winrates1,singlepts1,singlerets1,totpts1,totrets1,winlosses1]=RBindicators(tableK1)

%%
tableK(find(table2array(tableK(:,1))==20110419),:)
%tableK1(find(table2array(tableK1(:,1))==20110419),:)







