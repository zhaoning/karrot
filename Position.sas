* Position.sas;

proc sort data=karrot.transactions presorted;
	by system account owner sec_code trn_date trn_time;
run;

data karrot.position;
	set karrot.transactions;
	by system account owner sec_code trn_date trn_time;
	length
		units_held 8
		tot_cost 8
		avg_cost 8
	;
	label
		units_held='持有数量'
		tot_cost='总成本'
		avg_cost='平均成本'
	;
	retain units_held tot_cost;
	if first.sec_code then do;
		units_held=trd_units;
		tot_cost=-settlement;
		avg_cost=tot_cost/units_held;
	end;
	else do;
		if trn_type='DIV' then units_inc=0;
		else units_inc=trd_units;
		units_held=units_held+units_inc;
		if units_held=0 then do;
			tot_cost=0;
			avg_cost=0;
		end;
		else do;
			tot_cost=tot_cost-settlement;
			avg_cost=tot_cost/units_held;
		end;
	end;
	
	drop units_inc;
run;

