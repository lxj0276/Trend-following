
function[returns,points]=calc_earnings(positions,signals,clsprc,tscost)
sigpos=find(signals~=0);
points=(clsprc(2:end)-clsprc(1:(end-1))).*positions(2:end);
returns=points./clsprc(1:(end-1));
points=[0;points];
points(sigpos)=points(sigpos)-tscost*clsprc(sigpos);
returns=[0;returns];
returns(sigpos)=returns(sigpos)-tscost;


%%
% function[returns,points,positions]=calc_earnings(signals,clsprc,tscost,type)
% 
% N=length(clsprc);
% 
% positions=zeros([N,1]);
% sigpos=find(signals~=0);
% firstsig=signals(sigpos(1));
% count=(firstsig==-1);
% len=length(sigpos);
% for i=1:len
%     if i==len
%         End=N;
%     else
%         End=sigpos(i+1);
%     end
%     positions((sigpos(i)+1):End)=(-1)^count;
%     count=count+1;
% end
% 
% positions=(positions+type)/(1+(type~=0));
% points=(clsprc(2:end)-clsprc(1:(end-1))).*positions(2:end);
% returns=points./clsprc(1:(end-1));
% points=[0;points];
% points(sigpos)=points(sigpos)-tscost*clsprc(sigpos);
% returns=[0;returns];
% returns(sigpos)=returns(sigpos)-tscost;

%%
% long=zeros([N,1]);
% short=zeros([N,1]);
% lpts=zeros([N,1]);
% spts=zeros([N,1]);
% lpos=signals;
% spos=signals;
% 
% buyfirst=0;
% sellfirst=0;
% buysum=(signals(1)==1);
% sellsum=(signals(1)==-1);
% 
% long(1)=-tscost*(signals(1)==1);
% short(1)=-tscost*(signals(1)==-1);
% lpts(1)=-tscost*clsprc(1)*(signals(1)==1);
% spts(1)=-tscost*clsprc(1)*(signals(1)==-1);
% 
% for dum_i=2:N
%     signal=(signals(dum_i));
%     if buysum+sellsum==1
%         buyfirst=buysum;
%         sellfirst=sellsum;
%     end
%     if type~=-1
%         long(dum_i)=-tscost*((signal==1)+(signal==-1)*(buysum>0)) + ((buysum>sellsum)*buyfirst+(buysum==sellsum)*sellfirst)*(clsprc(dum_i)/clsprc(dum_i-1)-1);
%         lpts(dum_i)=-tscost*clsprc(dum_i)*((signal==1)+(signal==-1)*(buysum>0)) + ((buysum>sellsum)*buyfirst+(buysum==sellsum)*sellfirst)*(clsprc(dum_i)-clsprc(dum_i-1));
%         lpos(dum_i)=(signal~=0)*signal+(signal==0)*((buysum>sellsum)*buyfirst+(buysum==sellsum)*sellfirst)*lpos(dum_i-1);
%     end
%     if type~=1
%         short(dum_i)=-tscost*((signal==-1)+(signal==1)*(sellsum>0)) + ((buysum<sellsum)*sellfirst+(buysum==sellsum)*buyfirst)*(-clsprc(dum_i)/clsprc(dum_i-1)+1);
%         spts(dum_i)=-tscost*clsprc(dum_i)*((signal==-1)+(signal==1)*(sellsum>0)) + ((buysum<sellsum)*sellfirst+(buysum==sellsum)*buyfirst)*(-clsprc(dum_i)+clsprc(dum_i-1));
%         spos(dum_i)=(signal~=0)*signal+(signal==0)*((buysum<sellsum)*sellfirst+(buysum==sellsum)*buyfirst)*spos(dum_i-1);
%     end
%     buysum=buysum+(signal==1);
%     sellsum=sellsum+(signal==-1);
% end
% 
% if type
%     returns=long;
%     points=lpts;
%     positions=lpos;
% elseif type==-1
%     returns=short;
%     points=spts;
%     positions=spos;
% else
%     returns=long+short;
%     points=lpts+spts;
%     idxsame=(lpos==spos);
%     idxdiff=(lpos~=spos);
%     positions(idxsame,1)=lpos(idxsame,1);
%     positions(idxdiff,1)=lpos(idxdiff,1)+spos(idxdiff,1);
% end
