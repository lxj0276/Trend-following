function[trix,matrix]=TRIX(n,m,prices)
len=length(prices);
n_a=2/(n+1);
n_b=1-n_a;

ema1=prices(1);
ema2=prices(1);
ema3=prices(1);
tr=zeros(len,1);
tr(1)=ema3;
trix=zeros(len,1);
matrix=zeros(len,1);
matrix(1:(m-1))=NaN;
sumtrix=0;
for i=2:len
    ema1=prices(i)*n_a+ema1*n_b;
    ema2=ema1*n_a+ema2*n_b;
    ema3=ema2*n_a+ema3*n_b;
    tr(i)=ema3;
    trix(i)=(tr(i)/tr(i-1)-1)*100;
    if i==m
        sumtrix=sum(trix(1:i));
    end
    if i>m
        sumtrix=sumtrix+trix(i)-trix(i-m);
    end
    matrix(i)=sumtrix/m;
end