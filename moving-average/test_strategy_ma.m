clear;
data=csvread('D:\Works\collected data\期货分钟数据\K_if_min.csv',1,0);

%%
transactioncost=0/10000;
paras=[5,20,2,25,20,5,20,10,5,20].*270;
type=0; % trade type long only, short only and long short
skip=1*270;
select=[0,0,0,1];
tic
tableK=movecross(data,paras,transactioncost,type,skip,select);
toc
%%
tableK(find(table2array(tableK(:,1))==20110607),:)


%%
[maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses]=Kindicators(tableK,type)

%%
transactioncost=0;
type=0;
select=[0,0,1,0];
skip=270;
start1=2;
start2=20;
start3=20;
step1=2;
step2=5;
step3=5;
num1=20;
num2=100;
num3=60;
num=((num1-start1)/step1+1)*((num2-start2)/step2+1)*((num3-start3)/step3+1);
%num=((num2-start)/step+(num2-num1)/step)*((num1-start)/step+1)/2;

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
%%

tic
count=1;
for i=start1:step1:num1
    for j=start2:step2:num2
        for k=start3:step3:num3
            p1=i;
            p2=j;
            p3=k;
            p1s(count)=i;
            p2s(count)=j;
            p3s(count)=k;
            paras=[5,20,2,25,20,p1,p2,p3,5,20].*270;
            if p1==p2
                [maxdds(count),sharps(count),annrets(count),annvols(count),trdnums(count),winrates(count),singlepts(count),singlerets(count),totpts(count),totrets(count),winlosses(count)]=zeros(1,11);
            else
                tableK=movecross(data,paras,transactioncost,type,skip,select);
                [maxdds(count),sharps(count),annrets(count),annvols(count),trdnums(count),winrates(count),singlepts(count),singlerets(count),totpts(count),totrets(count),winlosses(count)]=Kindicators(tableK,type);
            end
            count=count+1;
        end
    end
end
toc

  %%
results=array2table([p1s,p2s,p3s,maxdds,sharps,annrets,annvols,trdnums,winrates,singlepts,singlerets,totpts,totrets,winlosses],...
    'VariableName',{'p1s','p2s','p3s','maxdd','sharp','annret','annvol','trdnum','winrate','singlept','singleret','totpt','totret','winloss'});

results(find(table2array(results(:,12))==max(table2array(results(:,12)))),:)
