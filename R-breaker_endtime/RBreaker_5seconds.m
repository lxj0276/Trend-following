function[tableK]=RBreaker_5seconds(data,paras,transactioncost,breakpct,tol,maxtrdnum)
% may hold overnight, break based on entering price and trade more than
% once a day, for the second trade of the day, take ONLY break trade, NO
% reverse trade
[nrow,ncol]=size(data);
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

Ktrdtime=time;
Ktrddate=date;
Ktrdprc=zeros(nrow,1);
Ksignals=zeros(nrow,1);
Kpositions=zeros(nrow,1);
Kpoints=zeros(nrow,1);
Kreturns=zeros(nrow,1);

daycount=2;
trdnum=0;
for minuteK=days(2):nrow
    if minuteK==days(min(daycount,lendays))
        reachSS=0;  % need to reinitialize coz SS and BS differs everyday
        reachBS=0;
        pass=0;
        BBbuyprice=BB(daycount-1);
        BEbuyprice=BE(daycount-1);
        SEsellprice=SE(daycount-1);
        SBsellprice=SB(daycount-1);
    end
    if pass  % set pass =1 only when a round trade is done!!!
        continue
    end
    if currenthold==0 && (~zeroprc(minuteK))%no position
        if reachSS==0 && reachBS==0
            % update holding positions first
            BBbuy=(close(minuteK)-BB(daycount-1)>=-tol);
            SBsell=(close(minuteK)-SB(daycount-1)<=tol); 
            BEbuy=0;
            SEsell=0;
            BBbuyprice=BB(daycount-1);
            SBsellprice=SB(daycount-1);   
            BEbuyprice=0;
            SEsellprice=0;
            if BBbuy+SBsell==0  % update reach states, and NO change in currenthold
                reachSS=(close(minuteK)-SS(daycount-1)>=-tol);
                reachBS=(close(minuteK)-BS(daycount-1)<=tol);
            else  % either buy or sell, update the holding position, transaction fee of daily returns/points will be counted at last
                currenthold=BBbuy-SBsell;
                Ksignals(minuteK)=currenthold;
                Kreturns(minuteK)=-transactioncost;
                if BBbuy
                    Kpoints(minuteK)=-BBbuyprice*transactioncost;                  
                else                   
                    Kpoints(minuteK)=-SBsellprice*transactioncost;                                  
                end
            end
        elseif reachSS==0 && reachBS==1
            BEbuy=(close(minuteK)-BE(daycount-1)>=-tol) && (trdnum==0);
            SBsell=(close(minuteK)-SB(daycount-1)<=tol);      
            BBbuy=(close(minuteK)-BB(daycount-1)>=-tol) && (trdnum>0);
            SEsell=0;
            BEbuyprice=BE(daycount-1);
            SBsellprice=SB(daycount-1);      
            BBbuyprice=BB(daycount-1);
            SEsellprice=0;
            if BEbuy+SBsell+BBbuy~=0 %either buy or sell, update the holding position
                currenthold=BEbuy+BBbuy-SBsell;
                Ksignals(minuteK)=currenthold;
                Kreturns(minuteK)=-transactioncost;
                if BEbuy
                    Kpoints(minuteK)=-BEbuyprice*transactioncost;
                elseif BBbuy
                    Kpoints(minuteK)=-BBbuyprice*transactioncost;
                else
                    Kpoints(minuteK)=-SBsellprice*transactioncost;
                end
            end
        elseif reachSS==1 && reachBS==0
            BBbuy=(close(minuteK)-BB(daycount-1)>=-tol);
            SEsell=(close(minuteK)-SE(daycount-1)<=tol)&&(trdnum==0);   
            BEbuy=0;
            SBsell=(close(minuteK)-SB(daycount-1)<=tol)&&(trdnum>0);
            BBbuyprice=BB(daycount-1);
            SEsellprice=SE(daycount-1);     
            BEbuyprice=0;
            SBsellprice=SB(daycount-1);
            if BBbuy+SEsell+SBsell~=0 %either buy or sell, update the holding position
                currenthold=BBbuy-SEsell-SBsell;
                Ksignals(minuteK)=currenthold;
                Kreturns(minuteK)=-transactioncost;
                if BBbuy
                    Kpoints(minuteK)=-BBbuyprice*transactioncost;
                elseif SEsell
                    Kpoints(minuteK)=-SEsellprice*transactioncost;
                else
                    Kpoints(minuteK)=-SBsellprice*transactioncost;
                end
            end
        end    % reach both SS and BS, break without any trade
        if time(minuteK)==endtime
            daycount=daycount+1;
            trdnum=0;
        end
        continue
    elseif currenthold==1 %long position, hold the position till a break or endtime 
        Kpositions(minuteK)=currenthold;
        buyprice=(BBbuy*BBbuyprice+BEbuy*BEbuyprice);
        breakprc=tickround(buyprice*(1-breakpct),tick);        
        if (close(minuteK)-breakprc<=tol)   %break
            ind=open(minuteK)<breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;                     
            Kreturns(minuteK)=(breakprc/close(minuteK-1)-1)-transactioncost;
            Kpoints(minuteK)=(breakprc-close(minuteK-1))-breakprc*transactioncost;
            Ksignals(minuteK)=-currenthold;     
            currenthold=0;                     
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
            Kreturns(minuteK)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK)=close(minuteK)-close(minuteK-1); 
            daycount=daycount+1;
            trdnum=0;
            continue
        else % keep holding
            Kreturns(minuteK)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK)=close(minuteK)-close(minuteK-1); 
            continue
        end
    else %short position, hold the position till a break or endtime
        Kpositions(minuteK)=currenthold;
        sellprice=(SEsell*SEsellprice+SBsell*SBsellprice);
        breakprc=tickround(sellprice*(1+breakpct),tick);        
        if (close(minuteK)-breakprc>=-tol)  %break
            ind=open(minuteK)>breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;          
            Kreturns(minuteK)=(-breakprc/close(minuteK-1)+1)-transactioncost;
            Kpoints(minuteK)=(close(minuteK-1)-breakprc)-breakprc*transactioncost;
            Ksignals(minuteK)=-currenthold; 
            currenthold=0;      
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
            Kreturns(minuteK)=-close(minuteK)/close(minuteK-1)+1;
            Kpoints(minuteK)=-close(minuteK)+close(minuteK-1);             
            daycount=daycount+1;
            trdnum=0;
            continue    
        else % keep holding
            Kreturns(minuteK)=-close(minuteK)/close(minuteK-1)+1;
            Kpoints(minuteK)=-close(minuteK)+close(minuteK-1); 
            continue
        end
    end
end
Ktrdprc(Ksignals~=0)=clsoe(Ksignals~=0);
tableK=array2table([Ktrddate Ktrdtime Ktrdprc Ksignals Kpositions Kpoints Kreturns]);
