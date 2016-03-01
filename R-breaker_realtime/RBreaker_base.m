function[tableD,tableK]=RBreaker_base(data,paras,lasttime,transactioncost,tol)
[nrow ncol]=size(data);
tick=0.2;
endtime=151500-100*lasttime;

p1=paras(1);
p2=paras(2);
p3=paras(3);

date=data(:,1);
time=data(:,2);
open=data(:,3);
high=data(:,4);
low=data(:,5);
close=data(:,6);

% fullfill invalid data with previous minute's value
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
trdtime=time(days(2):end);
Ktrddate=date(days(2):end);
Kreturns=zeros((nrow-days(2)+1),1);
Kpoints=zeros((nrow-days(2)+1),1);
Kposition=zeros((nrow-days(2)+1),1);
Ktrdprc=zeros((nrow-days(2)+1),1);

daycount=2;
for minuteK=days(2):nrow
%     if any(any(isnan([BB((daycount-1):daycount) SS((daycount-1):daycount) SE((daycount-1):daycount) BE((daycount-1):daycount) BS((daycount-1):daycount) SB((daycount-1):daycount)])))
%         returns(daycount-1)=0;
%         points(daycount-1)=0;
%         direction(daycount-1)=0;
%         Kreturns(minuteK-days(2)+1)=0;
%         Kpoints(minuteK-days(2)+1)=0;
%         Kposition(minuteK-days(2)+1)=0;
%         Ktrdprc(minuteK-days(2)+1)=0;  
%         daycount=daycount+1;
%         pass=1;
%         continue
%     end
    if minuteK==days(min(daycount,lendays))
        currenthold=0;
        reachSS=0;
        reachBS=0;
        %buyprice=0;
        %sellprice=0;
        pass=0;
    end
    if pass  % set pass =1 only when a round trade is done!!!
        continue
    end
    if currenthold==0 %no position
        if time(minuteK)==endtime  % no trade untill endtime, then no trade in this day          
            daycount=daycount+1;
            pass=1;
            continue
        end
        if reachSS==0 && reachBS==0
            % update holding positions first
            buy=(high(minuteK)-BB(daycount-1)>=-tol);
            sell=(low(minuteK)-SB(daycount-1)<=tol);            
            buyprice=max(open(minuteK),BB(daycount-1));
            sellprice=min(open(minuteK),SB(daycount-1));   
            if buy+sell==0  % update reach states, and NO change in currenthold
                reachSS=(high(minuteK)-SS(daycount-1)>=-tol);
                reachBS=(low(minuteK)-BS(daycount-1)<=tol);
                continue
            elseif buy+sell==2  % worst condition, break with loss
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                           
                daycount=daycount+1;
                pass=1;
                continue
            else  % either buy or sell, update the holding position, transaction fee of daily returns/points will be counted at last
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;
                Kreturns(minuteK-days(2)+1)=-transactioncost+buy*(close(minuteK)/buyprice-1)+sell*(-close(minuteK)/sellprice+1);
                Kpoints(minuteK-days(2)+1)=-(buy*buyprice+sell*sellprice)*transactioncost+(buy*(close(minuteK)-buyprice)+sell*(sellprice-close(minuteK)));
                Kposition(minuteK-days(2)+1)=currenthold;
                Ktrdprc(minuteK-days(2)+1)=buy*buyprice+sell*sellprice; 
                continue
            end
        elseif reachSS==0 && reachBS==1
            buy=(high(minuteK)-BE(daycount-1)>=-tol);
            sell=(low(minuteK)-SB(daycount-1)<=tol);            
            buyprice=max(open(minuteK),BE(daycount-1));
            sellprice=min(open(minuteK),SB(daycount-1));                       
            if buy+sell==0  % hold on the current reach state
                continue            
            elseif buy+sell==2  % break with loss
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;             
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
                daycount=daycount+1;
                pass=1;
                continue
            else %either buy or sell, update the holding position
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;
                Kreturns(minuteK-days(2)+1)=-transactioncost+buy*(close(minuteK)/buyprice-1)+sell*(-close(minuteK)/sellprice+1);
                Kpoints(minuteK-days(2)+1)=-(buy*buyprice+sell*sellprice)*transactioncost+(buy*(close(minuteK)-buyprice)+sell*(sellprice-close(minuteK)));
                Kposition(minuteK-days(2)+1)=currenthold;
                Ktrdprc(minuteK-days(2)+1)=buy*buyprice+sell*sellprice;        
                continue
            end
        elseif reachSS==1 && reachBS==0
            buy=(high(minuteK)-BB(daycount-1)>=-tol);
            sell=(low(minuteK)-SE(daycount-1)<=tol);            
            buyprice=max(open(minuteK),BB(daycount-1));
            sellprice=min(open(minuteK),SE(daycount-1));            
            if buy+sell==0  % hold on the current reach state
                continue;
            elseif buy+sell==2  % worst condition, break the day
                returns(daycount-1)=(sellprice/buyprice-1)-2*transactioncost;
                points(daycount-1)=(sellprice-buyprice)-(buyprice+sellprice)*transactioncost*2;
                direction(daycount-1)=2;
                Kreturns(minuteK-days(2)+1)=returns(daycount-1);
                Kpoints(minuteK-days(2)+1)=points(daycount-1);  
                Kposition(minuteK-days(2)+1)=2;
                Ktrdprc(minuteK-days(2)+1)=-1;         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                           
                daycount=daycount+1;
                pass=1;
                continue
            else %either buy or sell, update the holding position
                currenthold=buy-sell;
                direction(daycount-1)=currenthold;
                Kreturns(minuteK-days(2)+1)=-transactioncost+buy*(close(minuteK)/buyprice-1)+sell*(-close(minuteK)/sellprice+1);
                Kpoints(minuteK-days(2)+1)=-(buy*buyprice+sell*sellprice)*transactioncost+(buy*(close(minuteK)-buyprice)+sell*(sellprice-close(minuteK)));
                Kposition(minuteK-days(2)+1)=currenthold;
                Ktrdprc(minuteK-days(2)+1)=buy*buyprice+sell*sellprice; 
                continue
            end
        else    % reach both SS and BS, break without any trade
            daycount=daycount+1;
            pass=1;
            continue
        end
    elseif currenthold==1 %long position, hold the position till a break or endtime
        if time(minuteK)==endtime   %endtime
            returns(daycount-1)=(open(minuteK)/buyprice-1)-2*transactioncost;
            points(daycount-1)=(open(minuteK)-buyprice)-(open(minuteK)+buyprice)*transactioncost;
            Kreturns(minuteK-days(2)+1)=(open(minuteK)/close(minuteK-1)-1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(open(minuteK)-close(minuteK-1))-open(minuteK)*transactioncost;
            Kposition(minuteK-days(2)+1)=-1;
            Ktrdprc(minuteK-days(2)+1)=open(minuteK);         
            daycount=daycount+1;
            pass=1;
            continue
        elseif (low(minuteK)-SB(daycount-1)<=tol)   %break
            ind=open(minuteK)<SB(daycount-1);
            brkprc=ind*open(minuteK)+(1-ind)*SB(daycount-1);
            returns(daycount-1)=(brkprc/buyprice-1)-2*transactioncost;
            points(daycount-1)=(brkprc-buyprice)-(brkprc+buyprice)*transactioncost;
            direction(daycount-1)=2;
            Kreturns(minuteK-days(2)+1)=(brkprc/close(minuteK-1)-1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(brkprc-close(minuteK-1))-brkprc*transactioncost;
            Kposition(minuteK-days(2)+1)=2;
            Ktrdprc(minuteK-days(2)+1)=brkprc;        
            daycount=daycount+1;
            pass=1;
            continue
        else % keep holding
            Kreturns(minuteK-days(2)+1)=close(minuteK)/close(minuteK-1)-1;
            Kpoints(minuteK-days(2)+1)=close(minuteK)-close(minuteK-1); 
            continue
        end
    else %short position, hold the position till a break or endtime  % wrong in return calc
        if time(minuteK)==endtime  %endtime
            returns(daycount-1)=(-open(minuteK)/sellprice+1)-2*transactioncost;
            points(daycount-1)=(sellprice-open(minuteK))-(open(minuteK)+sellprice)*transactioncost;
            Kreturns(minuteK-days(2)+1)=(-open(minuteK)/close(minuteK-1)+1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(close(minuteK-1)-open(minuteK))-open(minuteK)*transactioncost;
            Kposition(minuteK-days(2)+1)=1;
            Ktrdprc(minuteK-days(2)+1)=open(minuteK);    
            daycount=daycount+1;
            pass=1;
            continue
        elseif (high(minuteK)-BB(daycount-1)>=-tol)  %break
            ind=open(minuteK)>BB(daycount-1);
            brkprc=ind*open(minuteK)+(1-ind)*BB(daycount-1);
            returns(daycount-1)=(-brkprc/sellprice+1)-2*transactioncost;
            points(daycount-1)=(sellprice-brkprc)-(brkprc+sellprice)*transactioncost;
            direction(daycount-1)=-2;
            Kreturns(minuteK-days(2)+1)=(-brkprc/close(minuteK-1)+1)-transactioncost;
            Kpoints(minuteK-days(2)+1)=(close(minuteK-1)-brkprc)-brkprc*transactioncost;
            Kposition(minuteK-days(2)+1)=-2;
            Ktrdprc(minuteK-days(2)+1)=brkprc;           
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

tableD=array2table([trdday direction points returns]);
tableK=array2table([Ktrddate trdtime Ktrdprc Kposition Kpoints Kreturns]);



