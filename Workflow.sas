%let karrot_dir=Y:\Documents\��ͥ����\Karrot;
libname karrot "&karrot_dir";

%let history_citic=&karrot_dir\Ͷ�����ݱ���\���ױ���-����֤ȯ����.csv;
%let history_cmb=&karrot_dir\Ͷ�����ݱ���\���ױ���-�����������.csv;
%let history_cmbfd=&karrot_dir\Ͷ�����ݱ���\���ױ���-���л�������.csv;
%let asset_price=&karrot_dir\Ͷ�����ݱ���\�ʲ��۸�-��ʷ�۸��.csv;
%let asset_properties=&karrot_dir\Ͷ�����ݱ���\�ʲ�����-��������.csv;

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
