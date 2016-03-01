function[roundval]=tickround(val,tick)
val=val+1e-12;
roundval=round((val/tick))*tick;