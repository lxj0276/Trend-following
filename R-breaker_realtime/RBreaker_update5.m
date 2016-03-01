function[tableD,tableK]=RBreaker_update5(data,paras,transactioncost,breakpara,tol)
% may hold overnight, break based on previous DAY's change size : dif=high-low 
[nrow ncol]=size(data);
tick=0.2;
endtime=151500;

p1=paras(1);
p2=paras(2);
p3=paras(3);

date=data(:,1);
time=data(:,2);
open=data(:,3);
high=data(:,4);
low=data(:,5);
close=data(:,6);


for dum_i=1:nrow
   if any([high(dum_i) low(dum_i) close(dum_i)]==0)
       high(dum_i)=high(dum_i-1);
       low(dum_i)=low(dum_i-1);
       close(dum_i)=close(dum_i-1);
   end    
end

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
for minuteK=days(2):nrow
    if minuteK==days(min(daycount,lendays))
        reachSS=0;  % need to reinitialize coz SS and BS differs everyday
        reachBS=0;
        pass=0;
        BBbuyprice=BB(daycount-1);
        BEbuyprice=BE(daycount-1);
        SEsellprice=SE(daycount-1);
        SBsellprice=SB(daycount-1);
        diff=dhigh(daycount-1)-dlow(daycount-1);
    end
    if pass  % set pass =1 only when a round trade is done!!!
        continue
    end
    if currenthold==0 %no position
        if reachSS==0 && reachBS==0
            % update holding positions first
            BBbuy=(high(minuteK)-BB(daycount-1)>=-tol);
            SBsell=(low(minuteK)-SB(daycount-1)<=tol); 
            BEbuy=0;
            SEsell=0;
            BBbuyprice=max(open(minuteK),BB(daycount-1));
            SBsellprice=min(open(minuteK),SB(daycount-1));   
            BEbuyprice=0;
            SEsellprice=0;
            if BBbuy+SBsell==0  % update reach states, and NO change in currenthold
                reachSS=(high(minuteK)-SS(daycount-1)>=-tol);
                reachBS=(low(minuteK)-BS(daycount-1)<=tol);
                if time(minuteK)==endtime
                    daycount=daycount+1;
                end
                continue
            elseif BBbuy+SBsell==2  % worst condition, break with loss
                returns(daycount-1)=(SBsellprice/BBbuyprice-1)-2*transactioncost;
                points(daycount-1)=(SBsellprice-BBbuyprice)-(BBbuyprice+SBsellprice)*transactioncost;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                daycount=daycount+1;
                pass=1;
                continue
            else  % either buy or sell, update the holding position, transaction fee of daily returns/points will be counted at last
                currenthold=BBbuy-SBsell;
                direction(daycount-1)=currenthold;
                Kposition(minuteK-days(2)+1)=currenthold;
                if BBbuy
                    openprice=BBbuyprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/BBbuyprice-1);
                    Kpoints(minuteK-days(2)+1)=-BBbuyprice*transactioncost+(close(minuteK)-BBbuyprice);
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/BBbuyprice-1);
                        points(daycount-1)=(close(minuteK)-BBbuyprice);
                        daycount=daycount+1;
                    end
                    continue                    
                else
                    openprice=SBsellprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/SBsellprice+1);
                    Kpoints(minuteK-days(2)+1)=-SBsellprice*transactioncost+(SBsellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/SBsellprice+1);
                        points(daycount-1)=(SBsellprice-close(minuteK));
                        daycount=daycount+1;
                    end
                    continue                                      
                end
            end
        elseif reachSS==0 && reachBS==1
            BEbuy=(high(minuteK)-BE(daycount-1)>=-tol);
            SBsell=(low(minuteK)-SB(daycount-1)<=tol);      
            BBbuy=0;
            SEsell=0;
            BEbuyprice=max(open(minuteK),BE(daycount-1));
            SBsellprice=min(open(minuteK),SB(daycount-1));      
            BBbuyprice=0;
            SEsellprice=0;
            if BEbuy+SBsell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                end
                continue
            elseif BEbuy+SBsell==2  % break with loss
                returns(daycount-1)=(SBsellprice/BEbuyprice-1)-2*transactioncost;
                points(daycount-1)=(SBsellprice-BEbuyprice)-(BEbuyprice+SBsellprice)*transactioncost;             
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              
                daycount=daycount+1;
                pass=1;
                continue
            else %either buy or sell, update the holding position
                currenthold=BEbuy-SBsell;
                direction(daycount-1)=currenthold;
                Kposition(minuteK-days(2)+1)=currenthold;
                if BEbuy
                    openprice=BEbuyprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/BEbuyprice-1);
                    Kpoints(minuteK-days(2)+1)=-BEbuyprice*transactioncost+(BEbuy*(close(minuteK)-BEbuyprice));
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/BEbuyprice-1);
                        points(daycount-1)=(close(minuteK)-BEbuyprice);
                        daycount=daycount+1;
                    end
                    continue
                else
                    openprice=SBsellprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/SBsellprice+1);
                    Kpoints(minuteK-days(2)+1)=-SBsellprice*transactioncost+(SBsellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/SBsellprice+1);
                        points(daycount-1)=(SBsellprice-close(minuteK));
                        daycount=daycount+1;
                    end
                    continue
                end
            end
        elseif reachSS==1 && reachBS==0
            BBbuy=(high(minuteK)-BB(daycount-1)>=-tol);
            SEsell=(low(minuteK)-SE(daycount-1)<=tol);   
            BEbuy=0;
            SBsell=0;
            BBbuyprice=max(open(minuteK),BB(daycount-1));
            SEsellprice=min(open(minuteK),SE(daycount-1));     
            BEbuyprice=0;
            SBsellprice=0;
            if BBbuy+SEsell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                end
                continue
            elseif BBbuy+SEsell==2  % worst condition, break the day
                returns(daycount-1)=(SEsellprice/BBbuyprice-1)-2*transactioncost;
                points(daycount-1)=(SEsellprice-BBbuyprice)-(BBbuyprice+SEsellprice)*transactioncost;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              
                daycount=daycount+1;
                pass=1;
                continue
            else %either buy or sell, update the holding position
                currenthold=BBbuy-SEsell;
                direction(daycount-1)=currenthold;
                Kposition(minuteK-days(2)+1)=currenthold;
                if BBbuy
                    openprice=BBbuyprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(close(minuteK)/BBbuyprice-1);
                    Kpoints(minuteK-days(2)+1)=-BBbuyprice*transactioncost+(close(minuteK)-BBbuyprice);
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(close(minuteK)/BBbuyprice-1);
                        points(daycount-1)=(close(minuteK)-BBbuyprice);
                        daycount=daycount+1;
                    end
                    continue
                else
                    openprice=SEsellprice;
                    Kreturns(minuteK-days(2)+1)=-transactioncost+(-close(minuteK)/SEsellprice+1);
                    Kpoints(minuteK-days(2)+1)=-SEsellprice*transactioncost+(SEsellprice-close(minuteK));
                    Ktrdprc(minuteK-days(2)+1)=openprice;
                    if time(minuteK)==endtime
                        returns(daycount-1)=(-close(minuteK)/SEsellprice+1);
                        points(daycount-1)=(SEsellprice-close(minuteK));
                        daycount=daycount+1;
                    end
                    continue
                end
            end
        else    % reach both SS and BS, break without any trade
            daycount=daycount+1;
            pass=1;
            continue
        end
    elseif currenthold==1 %long position, hold the position till a break or endtime    
        buyprice=(BBbuy*BBbuyprice+BEbuy*BEbuyprice);
        breakprc=tickround(buyprice-breakpara*diff,tick);        
        if (low(minuteK)-breakprc<=tol)   %break
            price=(openprice*(1-overnight)+close(days(daycount)-1)*overnight);
            ind=open(minuteK)<breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;               
            returns(daycount-1)=(breakprc/price-1)-2*transactioncost;
            points(daycount-1)=(breakprc-price)-(breakprc+openprice)*transactioncost;
            direction(daycount-1)=2;       
            Kreturns(minuteK-days(2)+1)=(breakprc/close(minuteK-1)-1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(breakprc-close(minuteK-1))-breakprc*transactioncost;
            Kposition(minuteK-days(2)+1)=2;
            Ktrdprc(minuteK-days(2)+1)=breakprc;       
            daycount=daycount+1;
            currenthold=0;            
            overnight=0;
            pass=1;
            continue
        elseif time(minuteK)==endtime   %endtime
            price=(openprice*(1-overnight)+close(days(daycount)-1)*overnight);
            returns(daycount-1)=(close(minuteK)/price-1);
            points(daycount-1)=(close(minuteK)-price);
            ovnight(daycount-1)=overnight;          
            Kreturns(minuteK-days(2)+1)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK-days(2)+1)=close(minuteK)-close(minuteK-1); 
            overnight=1;            
            ovnight(daycount-1)=overnight;
            daycount=daycount+1;
            pass=1;
            continue
        else % keep holding
            Kreturns(minuteK-days(2)+1)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK-days(2)+1)=close(minuteK)-close(minuteK-1); 
            continue
        end
    else %short position, hold the position till a break or endtime 
        sellprice=(SEsell*SEsellprice+SBsell*SBsellprice);
        breakprc=tickround(sellprice+breakpara*diff,tick);        
        if (high(minuteK)-breakprc>=-tol)  %break
            price=(openprice*(1-overnight)+close(days(daycount)-1)*overnight);
            ind=open(minuteK)>breakprc;
            breakprc=ind*open(minuteK)+(1-ind)*breakprc;
            returns(daycount-1)=(-breakprc/price+1)-2*transactioncost;
            points(daycount-1)=(price-breakprc)-(breakprc+openprice)*transactioncost;
            direction(daycount-1)=-2;            
            Kreturns(minuteK-days(2)+1)=(-breakprc/close(minuteK-1)+1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(close(minuteK-1)-breakprc)-breakprc*transactioncost;
            Kposition(minuteK-days(2)+1)=-2;
            Ktrdprc(minuteK-days(2)+1)=breakprc;     
            daycount=daycount+1;
            currenthold=0;
            overnight=0;
            pass=1;
            continue
        elseif time(minuteK)==endtime   %endtime
            price=(openprice*(1-overnight)+close(days(daycount)-1)*overnight);
            returns(daycount-1)=(-close(minuteK)/price+1);
            points(daycount-1)=(-close(minuteK)+price);            
            Kreturns(minuteK-days(2)+1)=-close(minuteK)/close(minuteK-1)+1;
            Kpoints(minuteK-days(2)+1)=-close(minuteK)+close(minuteK-1);             
            overnight=1;
            ovnight(daycount-1)=overnight;
            daycount=daycount+1;
            pass=1;
            continue    
        else % keep holding
            Kreturns(minuteK-days(2)+1)=-close(minuteK)/close(minuteK-1)+1;
            Kpoints(minuteK-days(2)+1)=-close(minuteK)+close(minuteK-1); 
            continue
        end
    end
end
tableD=array2table([trdday direction points returns ovnight]);
tableK=array2table([Ktrddate trdtime Ktrdprc Kposition Kpoints Kreturns]);



