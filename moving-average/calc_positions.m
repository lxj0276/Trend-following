function[positions]=calc_positions(signals,type)
N=length(signals);
positions=zeros([N,1]);
sigpos=find(signals~=0);
firstsig=signals(sigpos(1));
count=(firstsig==-1);
len=length(sigpos);
for i=1:len
    if i==len
        End=N;
    else
        End=sigpos(i+1);
    end
    positions((sigpos(i)+1):End)=(-1)^count;
    count=count+1;
end
positions=(positions+type)/(1+(type~=0));
