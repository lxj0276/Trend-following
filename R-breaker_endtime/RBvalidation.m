function[tableK,maxbreaks,totpoints]=RBvalidation(data,paras,tol,maxtrdnum,transactioncost,size)

date=data(:,1);
time=data(:,2);
close=data(:,6);
delta=data(:,end-1);
len=length(data);

% year=ceil(date/10000);
% month=ceil(date/100)-year*100;
% monthmark=[1;(month(1:(end-1))~=month(2:end))];
monthmark=[1;(delta(1:(end-1))<delta(2:end))];
cummonmark=cumsum(monthmark);
trainmonth=24;
paranum=30;

%parpool(2);

% initialize data structure to be stored
interdata=struct('positions',{zeros(len,1)},...
                 'signals',{zeros(len,1)},...
                 'points',{zeros(len,1)},...
                 'returns',{zeros(len,1)});

for i=2:paranum
    interdata(i).signals=zeros(len,1);
    interdata(i).positions=zeros(len,1);
    interdata(i).points=zeros(len,1);
    interdata(i).returns=zeros(len,1);
end


% first training
maxbreaks=zeros(cummonmark(end)-trainmonth+1,1);
totpoints=zeros(paranum,cummonmark(end)-trainmonth+1);
idx=(cummonmark<=trainmonth);
traindata=data(idx,:);
trainclose=close(idx);
for i=1:paranum
    breakpct=i/1000;
    [positions,signals]=RBreaker_signals_v2(traindata,paras,breakpct,tol,maxtrdnum);
    [returns,points]=calc_earnings(positions,signals,trainclose,transactioncost);
    interdata(i).positions(idx)=positions;
    interdata(i).signals(idx)=signals;
    interdata(i).points(idx)=points;
    interdata(i).returns(idx)=returns;
    totpoints(i,1)=sum(points);
end
maxbreak=find(totpoints(:,1)==max(totpoints(:,1)),1)/1000;
maxbreaks(1)=maxbreak;

% rolling and training with step=1 month each time, lastday of previous
% month should be included as the firstday of the data in RBreaker will be
% skiped
trdpositions=zeros(len,1);
trdsignals=zeros(len,1);
trdpoints=zeros(len,1);
trdreturns=zeros(len,1);
trdprc=zeros(len,1);
for i=(trainmonth+1):cummonmark(end)
    idx=(cummonmark==i);
    monpos=find(idx,1);
    dayidx=(monpos-size):(monpos-1);    
    testdata=[data(dayidx,:);data(idx,:)];
    testclose=[close(dayidx);close(idx)];
    for j=1:paranum
        breakpct=j/1000;
        [positions,signals]=RBreaker_signals_v2(testdata,paras,breakpct,tol,maxtrdnum);
        [returns,points]=calc_earnings(positions,signals,testclose,transactioncost);
        interdata(j).positions(idx)=positions((size+1):end);
        interdata(j).signals(idx)=signals((size+1):end);
        interdata(j).points(idx)=points((size+1):end);
        interdata(j).returns(idx)=returns((size+1):end);
        totpoints(j,i-trainmonth+1)=totpoints(j,i-trainmonth)+sum(points);
    end
    n=maxbreak*1000;
    trdpositions(idx)=interdata(n).positions(idx);
    trdsignals(idx)=interdata(n).signals(idx);
    trdpoints(idx)=interdata(n).points(idx);
    trdreturns(idx)=interdata(n).returns(idx);
    maxbreak=find(totpoints(:,i-trainmonth+1)==max(totpoints(:,i-trainmonth+1)),1)/1000;
    maxbreaks(i-trainmonth+1)=maxbreak;
end

%parpool close;

trdprc(trdsignals~=0)=close(trdsignals~=0);
tableK=array2table([date time trdprc trdsignals trdpositions trdpoints trdreturns],...
    'VariableNames',{'date','time','trdprc','signal','position','points','returns'});

