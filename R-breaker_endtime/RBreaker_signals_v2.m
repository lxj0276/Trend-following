function[positions,signals]=RBreaker_signals_v2(data,paras,breakpct,tol,maxtrdnum)
[nrow,ncol]=size(data);
tick=0.2;
positions=zeros(nrow,1);
signals=zeros(nrow,1);

p1=paras(1);
p2=paras(2);
p3=paras(3);

date=data(:,1);
high=data(:,4);
low=data(:,5);
close=data(:,6);
zeroprc=data(:,end); % 0 for missing and 1 for not

% calculate the high,low and close of previos day
newday=[1;date(1:(nrow-1))~=date(2:nrow)];
days=find(newday);
lendays=length(days);
dhigh=zeros(lendays,1);
dlow=zeros(lendays,1);
dclose=zeros(lendays,1);
delta=data(days,end-1);

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
for dum_i=2:lendays
    BBbreak=tickround(BB(dum_i-1)*(1-breakpct),tick);
    SEbreak=tickround(SE(dum_i-1)*(1+breakpct),tick);
    BEbreak=tickround(BE(dum_i-1)*(1-breakpct),tick);
    SBbreak=tickround(SB(dum_i-1)*(1+breakpct),tick);
    trdnum=0;
    Start=days(dum_i);
    lastday=(delta(dum_i)==1);
    if dum_i==lendays
        End=nrow;
    else
        End=days(dum_i+1)-1;
    end
    while(trdnum<maxtrdnum && Start<=End)
        prices=close(Start:End);
        missprc=zeroprc(Start:End);
        if currenthold==0
            reachSS=(prices>=SS(dum_i-1)-tol) & missprc;
            reachBS=(prices<=BS(dum_i-1)+tol) & missprc;
            posSS=find(reachSS,1);
            posBS=find(reachBS,1);
            emptySS=isempty(posSS);
            emptyBS=isempty(posBS);
            reachstatus=calc_status(emptySS,emptyBS,posSS,posBS);
            if reachstatus==0
                break;
            elseif reachstatus==1 % reach SS
                reachSS(posSS:end)=1;
                touchBB=(prices>=BB(dum_i-1)-tol) & reachSS;
                touchSE=(prices<=SE(dum_i-1)+tol) & reachSS;
                touchSB=(prices<=SB(dum_i-1)+tol) & reachSS;
                enterBB=find(touchBB,1)+Start-1;
                enterSE=find(touchSE,1)+Start-1;
                enterSB=find(touchSB,1)+Start-1;
                emptyBB=isempty(enterBB);
                emptySE=isempty(enterSE);
                emptySB=isempty(enterSB);
                if trdnum==0
                    touchstatus=calc_status(emptyBB,emptySE,enterBB,enterSE);
                else
                    touchstatus=calc_status(emptyBB,emptySB,enterBB,enterSB);
                end
                if touchstatus==0
                    break;
                elseif touchstatus==1 %buy break
                    signals(enterBB)=1;
                    brkBB=(prices<=BBbreak+tol) & missprc;
                    outBB=find(brkBB((enterBB+1:End)+1-Start),1)+enterBB;
                    if isempty(outBB)
                        positions(enterBB+1:End)=1;
                        if lastday
                            signals(End)=-1;
                        else
                            currenthold=2;
                        end
                        break;
                    else
                        signals(outBB)=-1;
                        positions(enterBB+1:outBB)=1;
                        trdnum=trdnum+1;
                        Start=outBB+1;
                        continue;
                    end
                elseif touchstatus==-1 && trdnum==0 % sell enter
                    signals(enterSE)=-1;
                    brkSE=(prices>=SEbreak-tol) & missprc;
                    outSE=find(brkSE((enterSE+1:End)+1-Start),1)+enterSE;
                    if isempty(outSE)
                        positions(enterSE+1:End)=-1;
                        if lastday
                            signals(End)=1;
                        else
                            currenthold=-1;
                        end
                        break;
                    else
                        signals(outSE)=1;
                        positions(enterSE+1:outSE)=-1;
                        trdnum=trdnum+1;
                        Start=outSE+1;
                        continue;
                    end
                elseif touchstatus==-1 && trdnum>0 % sell break
                    signals(enterSB)=-1;
                    brkSB=(prices>=SBbreak-tol) & missprc;
                    outSB=find(brkSB((enterSB+1:End)+1-Start),1)+enterSB;
                    if isempty(outSB)
                        positions(enterSB+1:End)=-1;
                        if lastday
                            signals(End)=1;
                        else
                            currenthold=-2;
                        end
                        break;
                    else
                        signals(outSB)=1;
                        positions(enterSB+1:outSB)=-1;
                        trdnum=trdnum+1;
                        Start=outSB+1;
                        continue;
                    end
                end
            elseif reachstatus==-1 % reach BS
                reachBS(posBS:end)=1;
                touchBB=(prices>=BB(dum_i-1)-tol) & reachBS;
                touchBE=(prices>=BE(dum_i-1)-tol) & reachBS;
                touchSB=(prices<=SB(dum_i-1)+tol) & reachBS;
                enterBB=find(touchBB,1)+Start-1;
                enterBE=find(touchBE,1)+Start-1;
                enterSB=find(touchSB,1)+Start-1;
                emptyBB=isempty(enterBB);
                emptyBE=isempty(enterBE);
                emptySB=isempty(enterSB);
                if trdnum==0
                    touchstatus=calc_status(emptySB,emptyBE,enterSB,enterBE);
                else
                    touchstatus=calc_status(emptySB,emptyBB,enterSB,enterBB);
                end
                if touchstatus==0
                    break;
                elseif touchstatus==1
                    signals(enterSB)=-1;
                    brkSB=(prices>=SBbreak-tol) & missprc;
                    outSB=find(brkSB((enterSB+1:End)+1-Start),1)+enterSB;
                    if isempty(outSB)
                        positions(enterSB+1:End)=-1;
                        if lastday
                            signals(End)=1;
                        else
                            currenthold=-2;
                        end
                        break;
                    else
                        signals(outSB)=1;
                        positions(enterSB+1:outSB)=-1;
                        trdnum=trdnum+1;
                        Start=outSB+1;
                        continue;
                    end
                elseif touchstatus==-1 && trdnum==0 % buy enter
                    signals(enterBE)=1;
                    brkBE=(prices<=BEbreak+tol) & missprc;
                    outBE=find(brkBE((enterBE+1:End)+1-Start),1)+enterBE;
                    if isempty(outBE)
                        positions(enterBE+1:End)=1;
                        if lastday
                            signals(End)=-1;
                        else
                            currenthold=1;
                        end
                        break;
                    else
                        signals(outBE)=-1;
                        positions(enterBE+1:outBE)=1;
                        trdnum=trdnum+1;
                        Start=outBE+1;
                        continue;
                    end
                elseif touchstatus==-1 && trdnum>0
                    signals(enterBB)=1;
                    brkBB=(prices<=BBbreak+tol) & missprc;
                    outBB=find(brkBB((enterBB+1:End)+1-Start),1)+enterBB;
                    if isempty(outBB)
                        positions(enterBB+1:End)=1;
                        if lastday
                            signals(End)=-1;
                        else
                            currenthold=2;
                        end
                        break;
                    else
                        signals(outBB)=-1;
                        positions(enterBB+1:outBB)=1;
                        trdnum=trdnum+1;
                        Start=outBB+1;
                        continue;
                    end
                end
            end
        elseif currenthold==2 % should come to this branch in a new day or never
            brkBB=(prices<=BBbreak+tol) & missprc;
            outBB=find(brkBB,1)+Start-1;
            if isempty(outBB)
                positions(Start:End)=1;
                if lastday
                    signals(End)=-1;
                    currenthold=0;
                end
                break;
            else
                signals(outBB)=-1;
                positions(Start:outBB)=1;
                trdnum=trdnum+1;
                Start=outBB+1;
                currenthold=0;
                continue;
            end
        elseif currenthold==1
            brkBE=(prices<=BEbreak+tol) & missprc;
            outBE=find(brkBE,1)+Start-1;
            if isempty(outBE)
                positions(Start:End)=1;
                if lastday
                    signals(End)=-1;
                    currenthold=0;
                end
                break;
            else
                signals(outBE)=-1;
                positions(Start:outBE)=1;
                trdnum=trdnum+1;
                Start=outBE+1;
                currenthold=0;
                continue;
            end
        elseif currenthold==-1
            brkSE=(prices>=SEbreak-tol) & missprc;
            outSE=find(brkSE,1)+Start-1;
            if isempty(outSE)
                positions(Start:End)=-1;
                if lastday
                    signals(End)=1;
                    currenthold=0;
                end
                break;
            else
                signals(outSE)=1;
                positions(Start:outSE)=-1;
                trdnum=trdnum+1;
                Start=outSE+1;
                currenthold=0;
                continue;
            end
        elseif currenthold==-2
            brkSB=(prices>=SBbreak-tol) & missprc;
            outSB=find(brkSB,1)+Start-1;
            if isempty(outSB)
                positions(Start:End)=-1;
                if lastday
                    signals(End)=1;
                    currenthold=0;
                end
                break;
            else
                signals(outSB)=1;
                positions(Start:outSB)=-1;
                trdnum=trdnum+1;
                Start=outSB+1;
                currenthold=0;
                continue;
            end
        end
    end
end
