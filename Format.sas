/* Format.sas */

options fmtsearch=(karrot);

data asset_properties;
	infile "&asset_properties" dsd dlm=',' firstobs=2;
	length
		sec_code $10
		sec_name $30
		asset_class $10
		risk_level $6
	;
	input
		sec_code
		sec_name
		asset_class
		risk_level
	;
run;

%fmtgen(asset_properties,sec_code,sec_name,sec_name,C,karrot)
%fmtgen(asset_properties,sec_code,asset_class,asset_class,C,karrot)
%fmtgen(asset_properties,sec_code,risk_level,risk_level,C,karrot)
