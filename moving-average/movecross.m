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

date=data(:,1);
time=data(:,2);
open=data(:,3);
high=data(:,4);
low=data(:,5);
close=data(:,6);

% deal with zero prices
for dum_i=1:nrow
   if any([high(dum_i) low(dum_i) close(dum_i)]==0)
       high(dum_i)=high(dum_i-1);
       low(dum_i)=low(dum_i-1);
       close(dum_i)=close(dum_i-1);
   end    
end

% generate raw signals
signals=signalgen(mas,mal,macds,macdl,macdm,dmas,dmal,dmam,trixn,trixm,close,skip,select);

% refine signals
cumsig=sum(signals,2);
finalsignals=(cumsig>=1)-(cumsig<=-1);

% deal with continuous identical signals ex.1 1 1...
states=finalsignals(1);
for i=2:(nrow-skip)
    samecheck=(states==finalsignals(i) & finalsignals(i));
    diffcheck=(states~=finalsignals(i) & finalsignals(i));
    finalsignals(i,samecheck)=0;
    states(diffcheck)=finalsignals(i,diffcheck);
end

close=close((skip+1):end);
Ktrdtime=time((skip+1):end);
Ktrddate=date((skip+1):end);
Ksignal=finalsignals;
Ktrdprc=zeros(length(close),1);
Ktrdprc(finalsignals~=0)=close(finalsignals~=0);

[returns,points,positions]=calc_earnings(finalsignals,close,transactioncost,type);
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




