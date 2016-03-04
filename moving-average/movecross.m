function[tableK]=movecross(data,paras,transactioncost,type,skip,select)
[nrow,ncol]=size(data);

mas=paras(1);
mal=paras(2);
macds=paras(3);
macdl=paras(4);
macdm=paras(5);
dmas=paras(6);
dmal=paras(7);
dmam=paras(8);
trixn=paras(9);
trixm=paras(10);

% deal with zero prices
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

% generate raw signals
signals=signalgen(mas,mal,macds,macdl,macdm,dmas,dmal,dmam,trixn,trixm,close,skip,select);

positions_ma=calc_positions(signals(:,1),type);
positions_macd=calc_positions(signals(:,2),type);
positions_dma=calc_positions(signals(:,3),type);
positions_trix=calc_positions(signals(:,4),type);

cumpositions=positions_ma+positions_macd+positions_dma+positions_trix;
positions=(cumpositions>3)-(cumpositions<-3);
finalsignals=calc_signals(positions);

close=close((skip+1):end);
Ktrdtime=time((skip+1):end);
Ktrddate=date((skip+1):end);
Ksignal=finalsignals;
Ktrdprc=zeros(length(close),1);
Ktrdprc(finalsignals~=0)=close(finalsignals~=0);

[returns,points]=calc_earnings(positions,finalsignals,close,transactioncost);

if type
    rname='lret';
    pname='lpts';
elseif type==-1
    rname='sret';
    pname='spts';
else
    rname='lsret';
    pname='lspts';
end

tableK=array2table([Ktrddate Ktrdtime Ksignal positions Ktrdprc points returns],...
    'VariableNames',{'date','time','signal','position','trdprc',pname,rname});



