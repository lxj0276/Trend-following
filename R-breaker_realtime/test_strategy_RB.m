clear;
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
breakpct=0.005;
paras=[0.07,0.35,0.25];
data=csvread('D:\Works\collected data\期货分钟数据\K_if_min.csv',1,0);
%data=csvread('D:\Works\collected data\期货5秒数据\K_ic.csv',1,0);

% %%
% tic
% [tableD,tableK]=RBreaker_base(data,paras,lasttime,transactioncost,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=indicators(tableK,tableD,0)
% 
% %%
% tic
% [tableD,tableK]=RBreaker_update1(data,paras,lasttime,transactioncost,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=indicators(tableK,tableD,0)
% 
% %%
% tic
% [tableD,tableK]=RBreaker_update2(data,paras,lasttime,transactioncost,breakpct,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=indicators(tableK,tableD,0)
%
% %%
% tic
% [tableD,tableK]=RBreaker_update3(data,paras,transactioncost,breakpct,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)

% %%
% tic
% [tableD,tableK]=RBreaker_update4(data,paras,transactioncost,breakpct,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)
% %%

% %%
% breakpara=1;
% tic
% [tableD,tableK]=RBreaker_update5(data,paras,transactioncost,breakpara,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)
% 
% %%
% breakpara=3.7;
% tic
% [tableD,tableK]=RBreaker_update6(data,paras,transactioncost,breakpara,tol);
% toc
% %%
% [maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)

%%
maxtrdnum=2;
tic
[tableD,tableK]=RBreaker_update7(data,paras,transactioncost,breakpct,tol,maxtrdnum);
toc
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)

%%
maxtrdnum=2;
tic
[tableD,tableK]=RBreaker_update8(data,paras,transactioncost,breakpct,tol,maxtrdnum);
toc
%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnight]=indicators(tableK,tableD,1)



%%
tableK(find(table2array(tableK(:,1))==20150901),:)
%%
tableK(find(table2array(tableK(:,1))==20150828),:)


% check=tableK(:,[1,2,5]);
% %check(:,3)=table(cumsum(table2array(check(:,3))));
% load('C:\Users\Jiapeng\Desktop\aaa.mat')
% points=aaa(2:end,3)-aaa(1:(length(aaa)-1),3);
% points=points(270:end);
% zh=aaa(271:end,:);
% zh(:,3)=points;
% total=[zh table2array(check)];
% diffs=find(abs(total(:,3)-total(:,6))>1e-6);
% ttdif=total(diffs,:);


%% 
%with current parameters, looking for break percentage 
tic
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
maxtrdnum=2;
paras=[0.07,0.35,0.25];

num=30;
breakpcts=zeros(num,1);
maxdds=zeros(num,1);
sharps=zeros(num,1);
annrets=zeros(num,1);
annvols=zeros(num,1);
trdnums=zeros(num,1);
winrates=zeros(num,1);
singlepts=zeros(num,1);
singlerets=zeros(num,1);
totpts=zeros(num,1);
totrets=zeros(num,1);
winlosses=zeros(num,1);

for i=1:num
   breakpcts(i)=0.001*i;
   [tableD,tableK]=RBreaker_update8(data,paras,transactioncost,breakpcts(i),tol,maxtrdnum);
   [maxdds(i),sharps(i),annrets(i),annvols(i),trdnums(i),winrates(i),singlepts(i),singlerets(i),totpts(i),totrets(i),winlosses(i)]=indicators(tableK,tableD,1);
end
toc

%%
results=array2table([breakpcts,maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses],...
    'VariableName',{'breakpct','maxdd','sharp','annret','annvol','trdnum','winrate','singlept','singleret','totpt','totret','winloss'});



%% 
%with current parameters, looking for breakpara 
tic
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
paras=[0.07,0.35,0.25];

num=50;
breakparas=zeros(num,1);
maxdds=zeros(num,1);
sharps=zeros(num,1);
annrets=zeros(num,1);
annvols=zeros(num,1);
trdnums=zeros(num,1);
winrates=zeros(num,1);
singlepts=zeros(num,1);
singlerets=zeros(num,1);
totpts=zeros(num,1);
totrets=zeros(num,1);
winlosses=zeros(num,1);
maxovnights=zeros(num,1);

for i=1:num
   breakparas(i)=0.1*i;
   [tableD,tableK]=RBreaker_update5(data,paras,transactioncost,breakparas(i),tol);
   [maxdds(i),sharps(i),annrets(i),annvols(i),trdnums(i),winrates(i),singlepts(i),singlerets(i),totpts(i),totrets(i),winlosses(i),maxovnights(i)]=indicators(tableK,tableD,1);
end
toc

%%
results=array2table([breakparas,maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses,maxovnights],...
    'VariableName',{'breakpara','maxdd','sharp','annret','annvol','trdnum','winrate','singlept','singleret','totpt','totret','winloss','maxov'});





%%
%parameters search
tic
transactioncost=3/10000;
lasttime=0;
tol=1e-8;
breakpct=0.005;
n1=10;
n2=1;
n3=1;

num=n1*n2*n3;
p1s=zeros(num,1);
p2s=zeros(num,1);
p3s=zeros(num,1);
maxdds=zeros(num,1);
sharps=zeros(num,1);
annrets=zeros(num,1);
annvols=zeros(num,1);
trdnums=zeros(num,1);
winrates=zeros(num,1);
singlepts=zeros(num,1);
singlerets=zeros(num,1);
totpts=zeros(num,1);
totrets=zeros(num,1);
winlosses=zeros(num,1);


for i=1:n1
    for j=1:n2
        for k=1:n3
            idx=((i-1)*n2+j-1)*n3+k;
            p1s(idx)=i*0.01;
            p2s(idx)=j*0.35;
            p3s(idx)=k*0.25;
            paras=[p1s(idx) p2s(idx) p3s(idx)];
            [tableD,tableK]=RBreaker_update2(data,paras,lasttime,transactioncost,breakpct,tol);
            [maxdds(i),sharps(i),annrets(i),annvols(i),trdnums(i),winrates(i),singlepts(i),singlerets(i),totpts(i),totrets(i),winlosses(i)]=indicators(tableK,tableD);
        end
    end
end
toc

%%
results2=array2table([p1s,p2s,p3s,maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses],...
    'VariableName',{'p1','p2','p3','maxdd','sharp','annret','annvol','trdnum','winrate','singlept','singleret','totpt','totret','winloss'});
