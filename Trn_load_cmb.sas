* Load CMB history;

data karrot.history_cmb;
	length
		account $20
		owner $10
		trn_date 8
		sec_code $10
		currency $10
		trd_type $10
		trd_units 8
		trd_price 8
		trd_amount 8
		trd_settle 8
		commission 8
		contract_no $10
		comments $10
	;
	infile "&history_cmb" dlm=',' dsd firstobs=2;
	informat trn_date yymmdd10.;
	format trn_date yymmdd10.;
	input
		account
		owner
		trn_date
		sec_code
		currency
		trd_type
		trd_units
		trd_price
		trd_amount
		trd_settle
		commission
		contract_no
		comments
	;
run;

data trn_cmb_temp;
	merge trn_template karrot.history_cmb;

	system="CMB";
	sec_code=compress(sec_code)||'.CMB';

	select (trd_type);
		when ('认购委托','申购委托') trn_type='BUY';
		when ('赎回委托','还本') trn_type='SEL';
		when ('现金分红') trn_type='DIV';
		otherwise do;
			trn_type='ERR';
			errmsg='业务名称"'||compress(trn_type)||'"无法解析';
			put errmsg;
		end;
	end;

	if trn_type='BUY' then do;
		trd_units=abs(trd_units);
		settlement=-abs(trd_settle);
	end;
	else if trn_type='SEL' then do;
		trd_units=-abs(trd_units);
		settlement=abs(trd_settle);
	end;
	else if trn_type='DIV' then do;
		trd_price=.;
		trd_units=.;
		trd_amount=.;
		settlement=trd_settle;
	end;

	trd_expense=abs(abs(trd_amount)-abs(settlement));
run;

data trn_cmb;
	set trn_template;
run;
proc append base=trn_cmb data=trn_cmb_temp force;
run;
