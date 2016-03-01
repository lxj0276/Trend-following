function[maxdd,sharp,annret,annvol,trdnum,winrate,singlept,singleret,totpt,totret,winloss]=Kindicators(tableK,type)

Ksignals=table2array(tableK(:,3));
Kpoints=table2array(tableK(:,6));
Kreturns=table2array(tableK(:,7));
Knetval=cumprod(1+Kreturns);
len=length(Knetval);

idx=find(Ksignals~=0);
lenidx=length(idx);
firstsig=Ksignals(idx(1));

if type==0 % long short
    if mod(lenidx,2)
        idx(lenidx+1)=len;
    end
    trdnum=length(idx)-1;
    earnnum=0;
    win=0;
    loss=0;
    rets=0;
    for i=1:trdnum
        pts=sum(Kpoints(idx(i):idx(i+1)));
        rets=rets+(prod(1+Kreturns(idx(i):idx(i+1)))-1);
        if pts >0
            earnnum=earnnum+1;
            win=win+pts;
        else
            loss=loss+pts;
        end
    end
else
    if type % long only
        if mod(lenidx,2)
            if firstsig
                idx(lenidx+1)=len;
            else
                idx(1)=[];
            end
        end
    else  % short only
        if mod(lenidx,2)
            if firstsig
                idx(1)=[];                
            else
                idx(lenidx+1)=len;
            end
        end
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