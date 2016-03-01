function[dif,dea]=MACD(short,long,m,prices)
len=length(prices);
short_a=2/(short+1);
short_b=1-short_a;
long_a=2/(long+1);
long_b=1-long_a;
dif_a=2/(m+1);
dif_b=1-dif_a;

emas=prices(1);
emal=prices(1);
dif=zeros(len,1);
dea=zeros(len,1);

for i=2:len
    emas=prices(i)*short_a+emas*short_b;
    emal=prices(i)*long_a+emal*long_b;
    dif(i)=emas-emal;
    dea(i)=dif(i)*dif_a+dea(i-1)*dif_b;
end