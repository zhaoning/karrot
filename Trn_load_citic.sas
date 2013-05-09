* Load CITIC history;

data karrot.history_citic;
	length
		account $20
		owner $10
		trn_date 4
		trn_time 4
		app_sn 8
		sec_code $6
		sec_name $10
		trd_type $4
		trd_price 8
		trd_units 8
		trd_amount 8
		settlement 8
		dlc_sn 8
		dlc_date 4
		srv_type $10
		xch_code $10
		acc_num $10
		clt_code $7
		clt_name $4
		xch_name $12
		comments $20
		comments2 $20
		trn_time_txt $10
		man_tag $1
	;
	infile "&history_citic" dlm=',' dsd firstobs=2;
	informat trn_date dlc_date yymmdd8.;
	format trn_date dlc_date yymmdd10. trn_time hhmm5.;
	input
		account
		owner
		trn_date
		trn_time_txt
		app_sn
		sec_code
		sec_name
		trd_type
		trd_price
		trd_units
		trd_amount
		settlement
		dlc_sn
		dlc_date
		srv_type
		xch_code
		acc_num
		clt_code
		clt_name
		xch_name
		comments
		comments2
		man_tag
	;

	* trn_time;
	colon=find(trn_time_txt,":");
	hh=input(substrn(trn_time_txt,5,colon-5),best.);
	mm=input(substrn(trn_time_txt,colon+1,length(trn_time_txt)-colon),best.);
	if substrn(trn_time_txt,1,4)='下午' then hh=mod(hh+12,24);
	trn_time=hms(hh,mm,0);

	drop hh mm colon trn_time_txt;
run;

data trn_citic_temp;
	merge trn_template karrot.history_citic;

	system="CITIC";
	sec_code=%align_right(sec_code,6,0);

	select (xch_name);
		when ('上海A股') sec_code=compress(sec_code)||'.SS';
		when ('深圳A股') sec_code=compress(sec_code)||'.SZ';
	end;

	select (srv_type);
		when ('证券买入') trn_type='BUY';
		when ('证券卖出') trn_type='SEL';
		when ('股息入账','股息入帐') trn_type='DIV';
		when ('新股入账','新股入帐') do;
			if substrn(sec_code,1,3) in ('780') then delete;
			else trn_type='BUY';
		end;
		when ('新股申购','申购配号','申购中签','申购返款') delete;
		otherwise do;
			trn_type='ERR';
			errmsg='业务名称"'||compress(trn_type)||'"无法解析';
			put errmsg;
		end;
	end;

	if trn_type not in ('BUY','SEL') then do;
		trd_price=.;
		trd_units=.;
		trd_amount=.;
	end;

	trd_expense=abs(abs(trd_amount)-abs(settlement));

	if man_tag='D' then delete;
run;

data trn_citic;
	set trn_template;
run;
proc append base=trn_citic data=trn_citic_temp force;
run;


