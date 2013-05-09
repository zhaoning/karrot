options mprint;

proc sort data=sashelp.vextfl out=temp;
	where substrn(fileref,1,3)='#LN' and index(lowcase(xpath),'.sas')>0;
	by descending fileref;
data _null_;
	set temp(obs=1);
	lastbs=length(xpath)-length(scan(xpath,-1,'\'));
	call symput('karrot_dir',substrn(xpath,1,lastbs-1));
run;

libname karrot "&karrot_dir";

%let history_citic=&karrot_dir\raw\History-CITIC_ZN.csv;
%let history_cmb=&karrot_dir\raw\History-CMB_ZN.csv;
%let history_cmbfd=&karrot_dir\raw\History-CMBFD_ZN.csv;
%let asset_price=&karrot_dir\raw\Asset Price-History.csv;
%let asset_properties=&karrot_dir\raw\Asset Properties-Basic.csv;

%include "Y:\CodeLib\sas_utils\all.sas";

%include "&karrot_dir\Macros.sas";
%include "&karrot_dir\Formats.sas";
%include "&karrot_dir\Trn_load.sas";
%include "&karrot_dir\Position.sas";
%include "&karrot_dir\Asset_price.sas";

%include "&karrot_dir\Report.sas";
