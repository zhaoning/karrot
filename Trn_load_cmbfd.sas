* Load CMB Fund history;

data karrot.history_cmbfd;
	length
		account $20
		owner $10
		sec_code $10
		sec_name $20
		trd_type $10
		currency $10
		trd_price 8
		trd_settle 8
		trd_units 8
		trd_expense 8
		trn_date 4
		app_sn $16
		status $10
		comments $10
		comments2 $10
		man_tag $1
	;
	infile "&history_cmbfd" dlm=',' dsd firstobs=2;
	informat trn_date yymmdd10.;
	format trn_date yymmdd10.;
	input
		account
		owner
		sec_code
		sec_name
		trd_type
		currency
		trd_price
		trd_settle
		trd_units
		trd_expense
		trn_date
		app_sn
		status
		comments
		comments2
		man_tag
	;
run;

data trn_cmbfd_temp;
	merge trn_template karrot.history_cmbfd;

	system="CMBFD";
	sec_code=%align_right(sec_code,6,0);
	sec_code=compress(sec_code)||'.FD';

	select (trd_type);
		when ('�Ϲ����','�깺') trn_type='BUY';
		when ('�Ϲ�') delete;
		when ('���') trn_type='SEL';
		when ('����') trn_type='DIV';
		when ('�ֺ�ѡ��') delete;
		when ('ǿ�е���','ǿ�е���') do;
			if trn_date='04Jul2011'd then delete;
			else trn_type='SPL';
		end;
		otherwise do;
			trn_type='ERR';
			errmsg='ҵ������"'||compress(trn_type)||'"�޷�����';
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
		trd_expense=.;
		settlement=abs(trd_settle);
	end;
	else if trn_type='SPL' then do;
		trd_price=0;
		trd_units=trd_units;
		trd_expense=0;
		settlement=0;
	end;

	trd_amount=abs(abs(settlement)-abs(trd_expense));

	if man_tag='D' then delete;
run;

data trn_cmbfd;
	set trn_template;
run;
proc append base=trn_cmbfd data=trn_cmbfd_temp force;
run;

