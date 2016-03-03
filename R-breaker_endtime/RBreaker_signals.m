function[positions,signals]=RBreaker_signals(data,paras,breakpct,tol,maxtrdnum,passK)

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
zeroidx=find(hzeroidx|lzeroidx|czeroidx);
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
    if currenthold==0 %no position
        if reachSS==0 && reachBS==0
            % update holding positions first
            BBbuy=(close(minuteK)-BB(daycount-1)>=-tol);
            SBsell=(close(minuteK)-SB(daycount-1)<=tol); 
            BEbuy=0;
            SEsell=0;
            BBbuyprice=max(open(minuteK),BB(daycount-1));
            SBsellprice=min(open(minuteK),SB(daycount-1));   
            BEbuyprice=0;
            SEsellprice=0;
            if BBbuy+SBsell==0  % update reach states, and NO change in currenthold
                reachSS=(close(minuteK)-SS(daycount-1)>=-tol);
                reachBS=(close(minuteK)-BS(daycount-1)<=tol);
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif BBbuy+SBsell==2  % worst condition, break with loss, very not likely to happen
                positions(minuteK)=-2;
                signals(minuteK)=-2;
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
                currenthold=BBbuy-SBsell;
                signals(minuteK)=currenthold;
                if BBbuy
                    if time(minuteK)==endtime
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue                    
                else
                    if time(minuteK)==endtime
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue                                      
                end
            end
        elseif reachSS==0 && reachBS==1
            BEbuy=(close(minuteK)-BE(daycount-1)>=-tol) && (trdnum==0);
            SBsell=(close(minuteK)-SB(daycount-1)<=tol);      
            BBbuy=0;
            SEsell=0;
            BEbuyprice=max(open(minuteK),BE(daycount-1));
            SBsellprice=min(open(minuteK),SB(daycount-1));      
            BBbuyprice=0;
            SEsellprice=0;
            if BEbuy+SBsell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif BEbuy+SBsell==2  % break with loss
                positions(minuteK)=-2;
                signals(minuteK)=-2;
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
                currenthold=BEbuy-SBsell;
                signals(minuteK)=currenthold;
                if BEbuy
                    if time(minuteK)==endtime
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                else
                    if time(minuteK)==endtime
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                end
            end
        elseif reachSS==1 && reachBS==0
            BBbuy=(close(minuteK)-BB(daycount-1)>=-tol);
            SEsell=(close(minuteK)-SE(daycount-1)<=tol)&&(trdnum==0);   
            BEbuy=0;
            SBsell=0;
            BBbuyprice=max(open(minuteK),BB(daycount-1));
            SEsellprice=min(open(minuteK),SE(daycount-1));     
            BEbuyprice=0;
            SBsellprice=0;
            if BBbuy+SEsell==0  % hold on the current reach state
                if time(minuteK)==endtime
                    daycount=daycount+1;
                    trdnum=0;
                end
                continue
            elseif BBbuy+SEsell==2  % worst condition, break the day
                positions(minuteK)=-2;
                signals(minuteK)=-2;
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
                currenthold=BBbuy-SEsell;
                signals(minuteK)=currenthold;
                if BBbuy
                    if time(minuteK)==endtime
                        daycount=daycount+1;
                        trdnum=0;
                    end
                    continue
                else
                    if time(minuteK)==endtime
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
        positions(minuteK)=currenthold;
        buyprice=(BBbuy*BBbuyprice+BEbuy*BEbuyprice);
        breakprc=tickround(buyprice*(1-breakpct),tick);        
        if (close(minuteK)-breakprc<=tol)   %break   
            signals(minuteK)=-currenthold;
            currenthold=0;               
            trdnum=trdnum+1;
            if trdnum==maxtrdnum
                daycount=daycount+1;
                trdnum=0;
                pass=1;
                continue
            end
            continue
        elseif time(minuteK)==endtime   %endtime
            daycount=daycount+1;
            trdnum=0;
            continue
        else % keep holding
            continue
        end
    else %short position, hold the position till a break or endtime 
        positions(minuteK)=currenthold;
        sellprice=(SEsell*SEsellprice+SBsell*SBsellprice);
        breakprc=tickround(sellprice*(1+breakpct),tick);        
        if (close(minuteK)-breakprc>=-tol)  %break   
            signals(minuteK)=-currenthold;
            currenthold=0;       
            trdnum=trdnum+1;
            if trdnum==maxtrdnum
                daycount=daycount+1;
                trdnum=0;
                pass=1;
                continue
            end
            continue
        elseif time(minuteK)==endtime   %endtime             
            daycount=daycount+1;
            trdnum=0;
            continue    
        else % keep holding
            continue
        end
    end
end