* Load Asset Price Information;

data karrot.asset_price;
	length
		sec_code $10
		trn_date 4
		close_quote 8
	;
	label
		sec_code='证券代码'
		trn_date='交易日期'
		close_quote='收盘价'
	;
	infile "&asset_price" dlm=',' dsd firstobs=2;
	informat trn_date yymmdd10.;
	format trn_date yymmdd10.;
	input
		sec_code
		trn_date
		close_quote
	;
run;
