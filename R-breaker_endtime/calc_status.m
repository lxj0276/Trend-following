function[status]=calc_status(emptyBreak,emptyEnter,posBreak,posEnter)
% pos1 and pos2 should never be equal!
if emptyBreak && emptyEnter
    status=0;
elseif emptyBreak && ~emptyEnter
    status=-1;
elseif ~emptyBreak && emptyEnter
    status=1;
else
    status=(posBreak<posEnter)-(posBreak>posEnter);
end