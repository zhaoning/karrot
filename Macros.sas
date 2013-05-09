%macro irr(data,where,class,time,cf,obs_from,obs_to,out);
%if &out= %then %do;
	%let out=irr_output;
%end;

proc datasets library=work nolist;
	delete cfs;
	delete disctrial1;
	delete disctrial2;
quit;

data cfs;
	set &data;
	%if &where^= %then %do;
		where &where;
	%end;
proc sort data=cfs presorted;
	by &class;
run;

* Check: If there are cash flows on only one day,
*        or if there is no cash flow at all,
*        delete the security;
proc means data=cfs nway missing noprint;
	where &cf^=0;
	by &class &time;
	var &cf;
	output out=check sum=;
run;
proc freq data=check noprint;
	tables %dtdlm(&class,%str(*))
		/out=num_days(drop=percent);
run;
data cfs;
	merge cfs(in=main) num_days;
	by &class;
	if main and count>1;
run;

* Trial #1: Determine whole percentage point;
data disctrial1;
	set cfs;
	do pct=-99 to 500;
		d=(1+pct/100)**(-(&time-&obs_from)/365);
		dcf=&cf*d;
		output;
	end;
run;

proc means data=disctrial1 nway missing noprint;
	class &class pct;
	var dcf;
	output out=out1 sum(dcf)=pv;
run;

data out1;
	set out1;
	by &class pct;
	retain sign;
	if first.%dtlast(&class) then do;
		sign=sign(pv);
	end;
	sign_prev=sign;
	sign=sign(pv);
	sign_this=sign(pv);
	if pv=0 then output;
	else if sign_prev*sign_this=-1 then output;
	keep &class pct;
run;

data out1;
	set out1;
	pct=pct-1;
run;

* Trial #2: Determine basis points;
data disctrial2;
	merge cfs out1;
	by &class;
	do bp=1 to 100;
		d=(1+pct/100+bp/10000)**(-(&time-&obs_from)/365);
		dcf=&cf*d;
		output;
	end;
run;

proc means data=disctrial2 nway missing noprint;
	class &class pct bp;
	var dcf;
	output out=out2 sum(dcf)=pv;
run;

data out2;
	set out2;
	by &class pct bp;
	retain sign pv_prev;
	if first.%dtlast(&class) then do;
		sign=sign(pv);
		pv_prev=pv;
	end;
	sign_prev=sign;
	sign=sign(pv);
	sign_this=sign(pv);
	if pv=0 then output;
	else if sign_prev*sign_this=-1 then output;
	pv_prev=pv;
	keep &class pct bp;
run;

data &out;
	set out2;
	irr=pct/100+bp/10000;
	format irr percentn10.2;
	label irr='内部收益率';
	keep &class irr;
run;

%mend;


%macro portfolio(report_date,class,out,print);

%let output_class=&class;
%if %dtcontain(&class,sec_code)=N %then %do;
	%let class=&class sec_code;
%end;

%if &out= %then %do;
	%let out=portfolio;
%end;

data &out;
run;

* List relevant securities and date/time;
proc freq data=karrot.transactions noprint;
	tables %dtdlm(&class,%str(*))
		/out=sec_list;
data sec_list;
	set sec_list;
	length trn_date trn_time 8;
	format trn_date yymmdd10. trn_time hhmm5.;
	trn_date=&report_date;
	trn_time=hms(24,0,0);
	drop count percent;
run;

* Determine positions on reporting date;
data &out;
	set karrot.position sec_list(in=rpt);
	length report_tag $1;
	label report_tag='报表';
	if rpt then report_tag='B';
	keep &class trn_date trn_time units_held tot_cost avg_cost report_tag;
proc sort data=&out;
	by &class trn_date trn_time;
data &out;
	set &out;
	by &class trn_date trn_time;
	units_held_l=lag(units_held);
	tot_cost_l=lag(tot_cost);
	avg_cost_l=lag(avg_cost);
	if units_held=. then do;
		if first.%dtlast(&class) then do;
			units_held=0;
			tot_cost=0;
			avg_cost=0;
		end;
		else do;
			units_held=units_held_l;
			tot_cost=tot_cost_l;
			avg_cost=avg_cost_l;
		end;
	end;
	if report_tag='B';
	drop units_held_l tot_cost_l avg_cost_l;
run;

* List all assets;
proc freq data=karrot.asset_price noprint;
	tables sec_code
		/out=asset_list;
data asset_list;
	set asset_list;
	length trn_date trn_time 8;
	format trn_date yymmdd10. trn_time hhmm5.;
	trn_date=&report_date;
	trn_time=hms(24,0,0);
	drop count percent;
run;

* Determine asset prices on reporting date;
data asset_price;
	set karrot.asset_price asset_list(in=rpt);
	length report_tag $1;
	label report_tag='报表';
	if rpt then report_tag='B';
	keep sec_code trn_date trn_time close_quote report_tag;
proc sort data=asset_price;
	by sec_code trn_date trn_time;
data asset_price;
	set asset_price;
	by sec_code trn_date trn_time;
	close_quote_l=lag(close_quote);
	if close_quote=. then do;
		if first.sec_code then do;
			close_quote=.;
		end;
		else do;
			close_quote=close_quote_l;
		end;
	end;
	if report_tag='B';
	drop close_quote_l trn_time;
run;

* Merge positions and asset prices;
proc sort data=&out;
	by sec_code trn_date;
proc sort data=asset_price;
	by sec_code trn_date;
data &out;
	merge &out(in=main) asset_price;
	by sec_code trn_date;
	length market_value 8;
	label market_value='市值';
	market_value=units_held*close_quote;
	if main;
run;

* Sort the output;
proc sort data=&out;
	by &class;
run;

* Delete temporary files;
proc datasets library=work nolist;
	delete
		asset_list
		asset_price
		sec_list
quit;

%if %upcase(&print)=Y or %upcase(&print)=YES %then %do;
	%local title2;
	%let title2=%sysfunc(putn(&report_date,yymmdd10.));

	title '投资组合报告';
	title2 "&title2";
	proc print data=&out(drop=trn_date trn_time report_tag);
	run;
	title;
	title2;
%end;

%mend;


%macro money_weighted_return(report_from,report_to,class,out,print);

%if &out= %then %do;
	%let out=money_weighted_return;
%end;

data &out;
run;

%portfolio(&report_from,&class,from)
%portfolio(&report_to,&class,to)

data irr_input;
	set karrot.transactions from to;
run;

proc sort data=irr_input;
	by &class trn_date trn_time;
run;

data irr_input;
	set irr_input;
	length virtual_cf 8;
	if report_tag='' then do;
		if trn_date<=&report_from or trn_date>&report_to then
			delete;
		else
			virtual_cf=settlement;
	end;
	else if report_tag='B' then do;
		if trn_date=&report_from then
			virtual_cf=-market_value;
		else
			virtual_cf=market_value;
	end;
run;

%irr(
	data=irr_input,
	class=&class,
	time=trn_date,
	cf=virtual_cf,
	obs_from=&report_from,
	obs_to=&report_to,
	out=&out
)

%if %upcase(&print)=Y or %upcase(&print)=YES %then %do;
	%local title2;
	%let title2=%sysfunc(putn(&report_from,yymmdd10.));
	%let title2=&title2.至%sysfunc(putn(&report_to,yymmdd10.));

	title '投资收益率报告';
	title2 "&title2";
	proc print data=&out;
	run;
	title;
	title2;
%end;

%mend;
