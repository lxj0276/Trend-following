function[dma,ama]=DMA(short,long,m,prices)
len=length(prices);
sums=sum(prices((long-short+1):long));
suml=sum(prices(1:long));
dma=zeros(len,1);
dma(1:(long-1))=NaN;
dma(long)=sums/short-suml/long;
ama=zeros(len,1);
ama(1:(long+m-2))=NaN;
sumama=0;

for i=(long+1):len
    sums=sums+prices(i)-prices(i-short);
    suml=suml+prices(i)-prices(i-long);
    mas=sums/short;
    mal=suml/long;
    dma(i)=mas-mal;
    if i==long+m-1
       sumama=sum(dma((i-m+1):i));
       ama(i)=sumama/m;
    end
    if i>long+m-1
        sumama=sumama+dma(i)-dma(i-m);
        ama(i)=sumama/m;
    end
end