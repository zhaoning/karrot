data trn_template;
	length
		system $10
		account $20
		owner $10
		trn_date 8
		trn_time 8
		sec_code $10
		sec_name $30
		trn_type $3
		trd_price 8
		trd_units 8
		trd_amount 8
		trd_expense 8
		settlement 8
	;
	format
		trn_date yymmdd10.
		trn_time hhmm5.;
	label
		system="交易系统"
		account="账户"
		owner="归属"
		trn_date="交易日期"
		trn_time="交易时间"
		sec_code="证券代码"
		sec_name="证券名称"
		trn_type="交易类型"
		trd_price="成交价格"
		trd_units="成交数量"
		trd_amount="成交金额"
		trd_expense="交易费用"
		settlement="清算金额"
	;
	delete;
run;

%include "&karrot_dir\Trn_load_citic.sas";
%include "&karrot_dir\Trn_load_cmb.sas";
%include "&karrot_dir\Trn_load_cmbfd.sas";

data karrot.transactions;
	set
		trn_citic
		trn_cmb
		trn_cmbfd
	;
run;


