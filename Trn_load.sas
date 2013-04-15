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
		system="����ϵͳ"
		account="�˻�"
		owner="����"
		trn_date="��������"
		trn_time="����ʱ��"
		sec_code="֤ȯ����"
		sec_name="֤ȯ����"
		trn_type="��������"
		trd_price="�ɽ��۸�"
		trd_units="�ɽ�����"
		trd_amount="�ɽ����"
		trd_expense="���׷���"
		settlement="������"
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


