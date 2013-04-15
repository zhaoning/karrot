/* Report.sas */

ods html body="&karrot_dir\Report.html";
ods listing close;

* Point reports;

** Portfolio;

%portfolio('14Apr2013'd,owner,portfolio_report_latest,print=YES)

* Interval reports;

** Rate of return;

%money_weighted_return(
	report_from='31Dec2011'd,
	report_to='14Apr2013'd,
	class=account owner sec_code,
	out=ror_2012,
	print=yes
)



