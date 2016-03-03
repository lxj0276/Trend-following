function[maxdd,sharp,annret,annvol,trdnum,winrate,singlept,singleret,totpt,totret,winloss]=RBindicators(tableK)

Ksignals=table2array(tableK(:,4));
Kpoints=table2array(tableK(:,6));
Kreturns=table2array(tableK(:,7));
Knetval=cumprod(1+Kreturns);
len=length(Knetval);


idx=find(Ksignals~=0);
lenidx=length(idx);
if mod(lenidx,2)
    idx(lenidx+1)=len;
end
trdnum=length(idx)/2;
earnnum=0;
win=0;
loss=0;
rets=0;
for i=1:trdnum
    pts=sum(Kpoints(idx(2*i-1):idx(2*i)));
    rets=rets+(prod(1+Kreturns(idx(2*i-1):idx(2*i)))-1);
    if pts >0
        earnnum=earnnum+1;
        win=win+pts;
    else
        loss=loss+pts;
    end
end

winrate=earnnum/trdnum;
totpt=sum(Kpoints);
totret=Knetval(end)-1;
singlept=totpt/trdnum;
singleret=rets/trdnum;
winloss=win/-loss;

annret=mean(Kreturns)*270*240*12;
annvol=std(Kreturns)*sqrt(270*240*12);
sharp=annret/annvol;

maxdds=zeros(len-1,1);
maxret=1;
for dum_i=2:len
    if Knetval(dum_i)>maxret
        maxret=Knetval(dum_i);
    end
    maxdds(dum_i-1)=Knetval(dum_i)/maxret-1;
end
maxdd=min(maxdds);