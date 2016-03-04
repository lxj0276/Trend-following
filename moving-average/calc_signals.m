function[signals]=calc_signals(positions)
firstpos=positions(1:(end-1));
secondpos=positions(2:end);
difpos=(firstpos~=secondpos);
closepos=zeros([length(secondpos),1]);
closepos(difpos)=(secondpos(difpos)==0);
difidx=find(difpos);
signals=[difpos.*secondpos-closepos.*firstpos;0];
% if mod(sum(difpos),2)    
%     signals=[difpos.*secondpos-closepos.*firstpos;positions(difidx(end)+1)];
% else
%     signals=[difpos.*secondpos-closepos.*firstpos;0];
% end
