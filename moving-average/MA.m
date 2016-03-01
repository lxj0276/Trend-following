function[sma,lma]=MA(short,long,prices)
len=length(prices);
sums=sum(prices((long-short+1):long));
suml=sum(prices(1:long));
sma=zeros(len,1);
lma=zeros(len,1);
sma(1:(long-1))=NaN;
lma(1:(long-1))=NaN;
sma(long)=sums/short;
lma(long)=suml/long;

for i=(long+1):len
    sums=sums+prices(i)-prices(i-short);
    suml=suml+prices(i)-prices(i-long);
    sma(i)=sums/min(i,short);
    lma(i)=suml/min(i,long);
end