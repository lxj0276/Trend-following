function[tableD,tableK]=RBreaker_update8(data,paras,transactioncost,breakpct,tol,maxtrdnum)
% may hold overnight, break based on previous max price and trade more than
% once a day

[nrow ncol]=size(data);
tick=0.2;
endtime=151500;

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

% calculate the high,low and close of previos day
newday=[1;date(1:(nrow-1))~=date(2:nrow)];
days=find(newday);
trddays=date(days);
trdday=trddays(2:end);
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

currenthold=0;
reachSS=0;
reachBS=0;
returns=zeros(lendays-1,1);
points=zeros(lendays-1,1);
direction=zeros(lendays-1,1);
ovnight=zeros(lendays-1,1);

trdtime=time(days(2):end);
Ktrddate=date(days(2):end);
Kreturns=zeros((nrow-days(2)+1),1);
Kpoints=zeros((nrow-days(2)+1),1);
Kposition=zeros((nrow-days(2)+1),1);
Ktrdprc=zeros((nrow-days(2)+1),1);
daycount=2;
overnight=0;
trdnum=0;
for minuteK=days(2):nrow
    if minuteK==days(min(daycount,lendays))
        %currenthold=0;
        reachSS=0;
        reachBS=0;
        pass=0;
    end
    if pass  % set pass =1 only when a round trade is done!!!
        continue
    end
    if currenthold==0 && (~zeroprc(minuteK))%no position
        if reachSS==0 && reachBS==0
            % update holding positions first
            buy=(high(minuteK)-BB(daycount-1)>=-tol);
            sell=(low(minuteK)-SB(daycount-1)<=tol);            
            buyprice=max(open(minuteK),BB(daycount-1));
            sellprice=min(open(minuteK),SB(daycount-1));   
            if buy+sell==0  % update reach states, and NO change in currenthold
                reachSS=(high(minuteK)-SS(daycount-1)>=-tol);
                reachBS=(low(minuteK)-BS(daycount-1)<=tol);
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif buy+sell==2  % worst condition, break with loss
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;          
                trdnum=trdnum+1;
                if trdnum==maxtrdnum
                    daycount=daycount+1;
                    trdnum=0;
                    pass=1;
                    continue
                end
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            else  % either buy or sell, update the holding position, transaction fee of daily returns/points will be counted at last
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;
                Kposition(minuteK-days(2)+1)=currenthold;
                if buy
                    maxbuy=high(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/buyprice-1);
                    Kpoints(minuteK-days(2)+1)=-buyprice*transactioncost+(close(minuteK)-buyprice);                    
                    Ktrdprc(minuteK-days(2)+1)=buyprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/buyprice-1);
                        points(daycount-1)=(close(minuteK)-buyprice);
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                else
                    minsell=low(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/sellprice+1);
                    Kpoints(minuteK-days(2)+1)=-sellprice*transactioncost+(sellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=sellprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/sellprice+1);
                        points(daycount-1)=(sellprice-close(minuteK));
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                end
            end
        elseif reachSS==0 && reachBS==1
            BBbuy=(high(minuteK)-BB(daycount-1)>=-tol)&&(trdnum>0);
            buy=((high(minuteK)-BE(daycount-1)>=-tol)&&(trdnum==0))|| BBbuy;
            sell=(low(minuteK)-SB(daycount-1)<=tol);            
            buyprice=max(max(open(minuteK),BE(daycount-1)),BB(daycount-1)*BBbuy);
            sellprice=min(open(minuteK),SB(daycount-1));                       
            if buy+sell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif buy+sell==2  % break with loss
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;             
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;  
                trdnum=trdnum+1;
                if trdnum==maxtrdnum
                    daycount=daycount+1;
                    trdnum=0;
                    pass=1;
                    continue
                end
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            else %either buy or sell, update the holding position
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;           
                Kposition(minuteK-days(2)+1)=currenthold;
                if buy
                    maxbuy=high(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/buyprice-1);
                    Kpoints(minuteK-days(2)+1)=-buyprice*transactioncost+(close(minuteK)-buyprice);                    
                    Ktrdprc(minuteK-days(2)+1)=buyprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/buyprice-1);
                        points(daycount-1)=(close(minuteK)-buyprice);
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                else
                    minsell=low(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/sellprice+1);
                    Kpoints(minuteK-days(2)+1)=-sellprice*transactioncost+(sellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=sellprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/sellprice+1);
                        points(daycount-1)=(sellprice-close(minuteK));
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                end
            end
        elseif reachSS==1 && reachBS==0
            SBsell=(low(minuteK)-SB(daycount-1)<=tol)&&(trdnum>0);
            buy=(high(minuteK)-BB(daycount-1)>=-tol);
            sell=((low(minuteK)-SE(daycount-1)<=tol)&&(trdnum==0)) || SBsell;            
            buyprice=max(open(minuteK),BB(daycount-1));
            sellprice=min(min(open(minuteK),SE(daycount-1)),SB(daycount-1)/SBsell);            
            if buy+sell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif buy+sell==2  % worst condition, break the day
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1; 
                trdnum=trdnum+1;
                if trdnum==maxtrdnum
                    daycount=daycount+1;
                    trdnum=0;
                    pass=1;
                    continue
                end
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            else %either buy or sell, update the holding position
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;
                Kposition(minuteK-days(2)+1)=currenthold;
                if buy
                    maxbuy=high(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/buyprice-1);
                    Kpoints(minuteK-days(2)+1)=-buyprice*transactioncost+(close(minuteK)-buyprice);                    
                    Ktrdprc(minuteK-days(2)+1)=buyprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/buyprice-1);
                        points(daycount-1)=(close(minuteK)-buyprice);
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                else
                    minsell=low(minuteK);
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/sellprice+1);
                    Kpoints(minuteK-days(2)+1)=-sellprice*transactioncost+(sellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=sellprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/sellprice+1);
                        points(daycount-1)=(sellprice-close(minuteK));
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                end
            end
        else    % reach both SS and BS, break without any trade
            if time(minuteK)==endtime
                daycount=daycount+1;
                trdnum=0;
            end
            continue
        end
    elseif currenthold==1 %long position, hold the position till a break or endtime
        breakprc=tickround(maxbuy*(1-breakpct),tick);        
        if (low(minuteK)-breakprc<=tol)   %break
            price=(buyprice*(1-overnight)+close(days(daycount)-1)*overnight);
            ind=open(minuteK)<breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;
            returns(daycount-1)=(breakprc/price-1)-2*transactioncost;
            points(daycount-1)=(breakprc-price)-(breakprc+buyprice)*transactioncost;
            direction(daycount-1)=2;
            Kreturns(minuteK-days(2)+1)=(breakprc/close(minuteK-1)-1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(breakprc-close(minuteK-1))-breakprc*transactioncost;
            Kposition(minuteK-days(2)+1)=2;
            Ktrdprc(minuteK-days(2)+1)=breakprc;
            currenthold=0;            
            overnight=0;
            trdnum=trdnum+1;
            if trdnum==maxtrdnum
                daycount=daycount+1;
                trdnum=0;
                pass=1;
                continue
            end
            if time(minuteK)==endtime
                daycount=daycount+1;
                trdnum=0;
            end
            continue
        elseif time(minuteK)==endtime   %endtime
            price=(buyprice*(1-overnight)+close(days(daycount)-1)*overnight);
            returns(daycount-1)=(open(minuteK)/price-1);
            points(daycount-1)=(open(minuteK)-price);
            Kreturns(minuteK-days(2)+1)=(close(minuteK)/close(minuteK-1)-1);
            Kpoints(minuteK-days(2)+1)=(close(minuteK)-close(minuteK-1));
            overnight=1;            
            ovnight(daycount-1)=overnight;
            daycount=daycount+1;
            trdnum=0;
            if high(minuteK)>maxbuy
                maxbuy=high(minuteK);
            end
            continue
        else % keep holding
            Kreturns(minuteK-days(2)+1)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK-days(2)+1)=close(minuteK)-close(minuteK-1); 
            if high(minuteK)>maxbuy
                maxbuy=high(minuteK);
            end
            continue
        end
    else %short position, hold the position till a break or endtime  
        breakprc=tickround(minsell*(1+breakpct),tick);
        if (high(minuteK)-breakprc>=-tol)  %break
            price=(sellprice*(1-overnight)+close(days(daycount)-1)*overnight);
            ind=open(minuteK)>breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;
            returns(daycount-1)=(-breakprc/price+1)-2*transactioncost;
            points(daycount-1)=(price-breakprc)-(breakprc+sellprice)*transactioncost;
            direction(daycount-1)=-2;
            Kreturns(minuteK-days(2)+1)=(-breakprc/close(minuteK-1)+1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(close(minuteK-1)-breakprc)-breakprc*transactioncost;
            Kposition(minuteK-days(2)+1)=-2;
            Ktrdprc(minuteK-days(2)+1)=breakprc;     
            currenthold=0;
            overnight=0;
            trdnum=trdnum+1;
            if trdnum==maxtrdnum
                daycount=daycount+1;
                trdnum=0;
                pass=1;
                continue
            end
            if time(minuteK)==endtime
                daycount=daycount+1;
                trdnum=0;
            end
            continue
        elseif time(minuteK)==endtime  %endtime
            price=(sellprice*(1-overnight)+close(days(daycount)-1)*overnight);
            returns(daycount-1)=(-open(minuteK)/price+1);
            points(daycount-1)=(price-open(minuteK));
            Kreturns(minuteK-days(2)+1)=(-close(minuteK)/close(minuteK-1)+1);
            Kpoints(minuteK-days(2)+1)=(close(minuteK-1)-close(minuteK));     
            overnight=1;            
            ovnight(daycount-1)=overnight;
            daycount=daycount+1;
            trdnum=0;
            if low(minuteK)<minsell
                minsell=low(minuteK);
            end
            continue        
        else % keep holding
            Kreturns(minuteK-days(2)+1)=-close(minuteK)/close(minuteK-1)+1;
            Kpoints(minuteK-days(2)+1)=-close(minuteK)+close(minuteK-1); 
            if low(minuteK)<minsell
                minsell=low(minuteK);
            end
            continue
        end
    end
end
tableD=array2table([trdday direction points returns ovnight]);
tableK=array2table([Ktrddate trdtime Ktrdprc Kposition Kpoints Kreturns]);