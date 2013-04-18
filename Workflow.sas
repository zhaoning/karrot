%let karrot_dir=Y:\Documents\家庭财务\Karrot;
libname karrot "&karrot_dir";

%let history_citic=&karrot_dir\投资数据备份\交易备份-中信证券赵宁.csv;
%let history_cmb=&karrot_dir\投资数据备份\交易备份-招行理财赵宁.csv;
%let history_cmbfd=&karrot_dir\投资数据备份\交易备份-招行基金赵宁.csv;
%let asset_price=&karrot_dir\投资数据备份\资产价格-历史价格表.csv;
%let asset_properties=&karrot_dir\投资数据备份\资产属性-基本属性.csv;

options mprint;

%include "Y:\CodeLib\dt.sas";
%include "Y:\CodeLib\str.sas";
%include "Y:\CodeLib\fmt.sas";

%include "&karrot_dir\Macros.sas";
%include "&karrot_dir\Formats.sas";
%include "&karrot_dir\Trn_load.sas";
%include "&karrot_dir\Position.sas";
%include "&karrot_dir\Asset_price.sas";

%include "&karrot_dir\Report.sas";
