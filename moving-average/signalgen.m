function[signals]=signalgen(mas,mal,macds,macdl,macdm,dmas,dmal,dmam,trixn,trixm,prices,skip,select)
% select is a 4x1 vector of 0 and 1,indicating on and off of trend types based on the order of ma,macd,dma and trix
len=length(prices);
signals=[];

if select(1)
    [sma,lma]=MA(mas,mal,prices);
    ma_sig=zeros(len-1,1);
    ma_sig((sma(2:len)>sma(1:(len-1))) & (sma(2:len)>lma(2:len)) & (sma(1:(len-1))<lma(1:(len-1))))=1;
    ma_sig((sma(2:len)<sma(1:(len-1))) & (sma(2:len)<lma(2:len)) & (sma(1:(len-1))>lma(1:(len-1))))=-1;
    signals=[signals,ma_sig];
end
if select(2)
    [dif,dea]=MACD(macds,macdl,macdm,prices);
    macd_sig=zeros(len-1,1);
    macd_sig((dif(2:len)>dif(1:(len-1))) & (dif(2:len)>dea(2:len)) & (dif(1:(len-1))<dea(1:(len-1))) & (dif(1:(len-1))>0))=1;
    macd_sig((dif(2:len)<dif(1:(len-1))) & (dif(2:len)<dea(2:len)) & (dif(1:(len-1))>dea(1:(len-1))) & (dif(1:(len-1))<0))=-1;
    signals=[signals,macd_sig];
end
if select(3)
    [dma,ama]=DMA(dmas,dmal,dmam,prices);
    dma_sig=zeros(len-1,1);
    dma_sig((dma(2:len)>dma(1:(len-1))) & (dma(2:len)>ama(2:len)) & (dma(1:(len-1))<ama(1:(len-1))))=1;
    dma_sig((dma(2:len)<dma(1:(len-1))) & (dma(2:len)<ama(2:len)) & (dma(1:(len-1))>ama(1:(len-1))))=-1;
    signals=[signals,dma_sig];
end
if select(4)
    [trix,matrix]=TRIX(trixn,trixm,prices);
    trix_sig=zeros(len-1,1);
    trix_sig((trix(2:len)>trix(1:(len-1))) & (trix(2:len)>matrix(2:len)) & (trix(1:(len-1))<matrix(1:(len-1))))=1;
    trix_sig((trix(2:len)<trix(1:(len-1))) & (trix(2:len)<matrix(2:len)) & (trix(1:(len-1))>matrix(1:(len-1))))=-1;
    signals=[signals,trix_sig];
end

signals=signals(skip:(len-1),:);

%deal with continuous identical signals ex.1 1 1...
states=signals(1,:);
for i=2:(len-skip)
    samecheck=(states==signals(i,:) & signals(i,:));
    diffcheck=(states~=signals(i,:) & signals(i,:));
    signals(i,samecheck)=0;
    states(diffcheck)=signals(i,diffcheck);
end





