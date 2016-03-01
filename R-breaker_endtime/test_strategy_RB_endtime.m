clear;
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
breakpct=0.005;
paras=[0.07,0.35,0.25];
data=csvread('D:\Works\collected data\期货5秒数据\K_if.csv',1,0);


%%
maxtrdnum=2;
tic
[tableD,tableK]=RBreaker_5seconds(data,paras,transactioncost,breakpct,tol,maxtrdnum);
toc
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)



%%
tableK(find(table2array(tableK(:,1))==20100419),:)
%%
tableD(find(table2array(tableD(:,1))==20150825),:)


