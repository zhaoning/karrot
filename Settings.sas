%let karrot_dir=Y:\Documents\��ͥ����\Karrot;

options mprint;
%include "Y:\CodeLib\dt.sas";
%include "Y:\CodeLib\str.sas";
%include "&karrot_dir\Macros.sas";

libname karrot "&karrot_dir";

%let history_citic=&karrot_dir\Ͷ�����ݱ���\���ױ���-����֤ȯ����.csv;
%let history_cmb=&karrot_dir\Ͷ�����ݱ���\���ױ���-�����������.csv;
%let history_cmbfd=&karrot_dir\Ͷ�����ݱ���\���ױ���-���л�������.csv;
%let asset_price=&karrot_dir\Ͷ�����ݱ���\�ʲ��۸�-��ʷ�۸��.csv;
%let asset_properties=&karrot_dir\Ͷ�����ݱ���\�ʲ�����-��������.csv;
