function[maxdd,sharp,annret,annvol,trdnum,winrate,singlept,singleret,totpt,totret,winloss,maxovnight]=indicators(tableK,tableD,overnight)

Kpositions=table2array(tableK(:,4));
Kpoints=table2array(tableK(:,5));
Kreturns=table2array(tableK(:,6));
Knetval=cumprod(1+Kreturns);
len=length(Knetval);

if overnight
    idx=find(Kpositions~=0);
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
    Dovernight=[0;table2array(tableD(:,5))];
    maxovnight=0;
    ovn=0;
    ticker=0;
    for i=2:length(Dovernight)
       if Dovernight(i)-Dovernight(i-1)==1
           ovn=1;
           ticker=1;
           continue
       elseif Dovernight(i)-Dovernight(i-1)==-1
           maxovnight=ovn*(ovn>maxovnight)+maxovnight*(ovn<=maxovnight);
           ovn=0;
           ticker=0;
           continue
       end
       ovn=ovn+ticker;
    end
else
    Dpositions=table2array(tableD(:,2));
    Dpoints=table2array(tableD(:,3));
    Dreturns=table2array(tableD(:,4));
    Dnetval=cumprod(1+Dreturns);
    rets=sum(Dreturns);
    win=sum(Dpoints(Dpoints>0));
    loss=sum(Dpoints(Dpoints<0));
    earnnum=sum(Dpoints>0);
    trdnum=sum(Dpositions~=0);
    maxovnight=NaN;
end

winrate=earnnum/trdnum;
totpt=sum(Kpoints);
totret=Knetval(end)-1;
singlept=totpt/trdnum;
singleret=rets/trdnum;
winloss=win/-loss;

annret=mean(Kreturns)*270*240;
annvol=std(Kreturns)*sqrt(270*240);
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