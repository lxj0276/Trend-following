function[positions,signals,prices]=RBreaker_signals_mat(data,paras,breakpct,tol,maxtrdnum)
[nrow,ncol]=size(data);
tick=0.2;
endtime=151500;
positions=zeros(nrow,1);
signals=zeros(nrow,1);

p1=paras(1);
p2=paras(2);
p3=paras(3);

hzeroidx=(data(:,4)==0);
lzeroidx=(data(:,5)==0);
czeroidx=(data(:,6)==0);
zeroprc=hzeroidx|lzeroidx|czeroidx;
zeroidx=find(zeroprc);
for i=1:length(zeroidx)
   data(zeroidx(i),4:6)=data((zeroidx(i)-1),4:6); 
end

date=data(:,1);
time=data(:,2);
open=data(:,3);
high=data(:,4);
low=data(:,5);
close=data(:,6);
prices=close;

% calculate the high,low and close of previos day
newday=[1;date(1:(nrow-1))~=date(2:nrow)];
days=find(newday);
lendays=length(days);
dhigh=zeros(lendays,1);
dlow=zeros(lendays,1);
dclose=zeros(lendays,1);

for dum_i=1:lendays
    Start=days(dum_i);
    if dum_i==lendays
        End=nrow;
    else
        End=days(dum_i+1)-1;
    end
    dhigh(dum_i)=max(high(Start:End));
    dlow(dum_i)=min(low(Start:End));
    dclose(dum_i)=close(End);
end

SE=((1+p1)/2*(dhigh+dlow)-p1*dlow);
BE=((1+p1)/2*(dhigh+dlow)-p1*dhigh);
SS=(dhigh+p2*(dclose-dlow));
BS=(dlow-p2*(dhigh-dclose));
BB=(SS+p3*(SS-BS));
SB=(BS-p3*(SS-BS));

SE=tickround(SE,tick);
BE=tickround(BE,tick);
SS=tickround(SS,tick);
BS=tickround(BS,tick);
BB=tickround(BB,tick);
SB=tickround(SB,tick);
