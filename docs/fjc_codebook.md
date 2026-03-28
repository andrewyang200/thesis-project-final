# Federal Judicial Center

**Integrated Data Base**  
**Civil Documentation**  

**Field Descriptions**

## CIRCUIT  
**(CIRCUIT)**  

Circuit in which the case was filed.  

0 - District of Columbia  
6 - Sixth Circuit  
1 - First Circuit  
7 - Seventh Circuit  
2 - Second Circuit  
8 - Eighth Circuit  
3 - Third Circuit  
9 - Ninth Circuit  
4 - Fourth Circuit  
10 - Tenth Circuit  
5 - Fifth Circuit  
11 - Eleventh Circuit  

-8 = Missing  

## DISTRICT  
**(DISTRICT)**  

District court in which the case was filed. Conforms with format established in Volume XI, Guide to Judiciary Policies and Procedures, Appendix A.  

00 - Maine  
47 - Ohio - Northern  
01 - Massachusetts  
48 - Ohio - Southern  
02 - New Hampshire  
49 - Tennessee - Eastern  
03 - Rhode Island  
50 - Tennessee - Middle  
04 - Puerto Rico  
51 - Tennessee - Western  
05 - Connecticut  
52 - Illinois - Northern  
06 - New York - Northern  
53 - Illinois - Central  
07 - New York - Eastern  
54 - Illinois - Southern  
08 - New York - Southern  
55 - Indiana - Northern  
09 - New York - Western  
56 - Indiana - Southern  
10 - Vermont  
57 - Wisconsin - Eastern  
11 - Delaware  
58 - Wisconsin - Western  
12 - New Jersey  
60 - Arkansas - Eastern  
13 - Pennsylvania - Eastern  
61 - Arkansas - Western  
14 - Pennsylvania - Middle  
62 - Iowa - Northern  
15 - Pennsylvania - Western  
63 - Iowa - Southern  
16 - Maryland  
64 - Minnesota  
17 - North Carolina  - Eastern  
65 - Missouri - Eastern  
18 - North Carolina - Middle  
66 - Missouri - Western  
19 - North Carolina - Western  
67 - Nebraska  
20 - South Carolina  
68 - North Dakota  
22 - Virginia - Eastern  
69 - South Dakota  
23 - Virginia - Western  
7- - Alaska  

24 - West Virginia  - Northern  
70 - Arizona  
25 - West Virginia  - Southern  
71 - California - Northern  
26 - Alabama - Northern  
72 - California - Eastern  
27 - Alabama - Middle  
73 - California - Central  
28 - Alabama - Southern  
74 - California - Southern  
29 - Florida - Northern  
75 - Hawaii  
3A - Florida - Middle  
76 - Idaho  
3C - Florida - Southern  
77 - Montana  
3E - Georgia - Northern  
78 - Nevada  
3G - Georgia - Middle  
79 - Oregon  
3J - Georgia - Southern  
80 - Washington - Eastern  
3L - Louisiana - Eastern  
81 - Washington - Western  
3N - Louisiana - Middle  
82 - Colorado  
36 - Louisiana - Western  
83 - Kansas  
37 - Mississippi - Northern  
84 - New Mexico  
38 - Mississippi - Southern  
85 - Oklahoma - Northern  
39 - Texas - Northern  
86 - Oklahoma - Eastern  
40 - Texas - Eastern  
87 - Oklahoma - Western  
41 - Texas - Southern  
88 - Utah  
42 - Texas - Western  
89 - Wyoming  
43 - Kentucky - Eastern  
90 - District of Columbia  
44 - Kentucky - Western  
91 - Virgin Islands  
45 - Michigan - Eastern  
93 - Guam  
46 - Michigan - Western  
94 - Northern Mariana Islands  

-8 = Missing  

## OFFICE  
**(OFFICE)**  

The code that designates the office within the district where the case is filed.  

Must conform with format established in Volume XI, Guide to Judiciary Policies and Procedures, Appendix A.  

## DOCKET NUMBER  
**(DOCKET)**  

The number assigned by the Clerks’ office; consists of 2 digit Docket Year (usually calendar year in which the case was filed) and 5 digit sequence number.  

## ORIGIN  
**(ORIGIN)**  

A single digit code describing the manner in which the case was filed in the district.  

**CODES:**  
1  - original proceeding  
2  - removed (began in the state court, removed to the district court)  
3  - remanded for further action (removal from court of appeals)  
4  - reinstated/reopened (previously opened and closed, reopened for additional action)  
5  - transferred from another district(pursuant to 28 USC 1404)  
6  - multi district litigation (cases transferred to this district by an order entered by Judicial Panel on Multi District Litigation pursuant to 28 USC 1407)  
7  - appeal to a district judge of a magistrate judge's decision  
8  - second reopen  
9  - third reopen  
10 - fourth reopen  
11 - fifth reopen  
12 - sixth reopen  
13 – multi district litigation originating in the district (valid beginning July 1, 2016)  

## FILING DATE  
**(FILEDATE)**  

The DATE on which the case was filed in the district.  

## FILING DATE USED BY AO  
**(FDATEUSE)**  

This field is used to identify cases within a given statistical or fiscal year of filing as counted by the AO in published reports. Cohorts based on actual filing dates rather than on the Used-by-AO dates are unlikely to provide counts that can be matched with published tables. For example, a case that was docketed in June 1985 but was processed late and thus fell into the range of SY86 cases instead of SY85 cases will have a value of 6/1/1985 for Filing Date Used by AO which properly places it in the statistical year in which it was filed.  

## JURISDICTION  
**(JURIS)**  

The code which provides the basis for the U.S. district court jurisdiction in the case. This code is used in conjunction with appropriate nature of suit code.  

**CODES:**  
1  - US government plaintiff  
2  - US government  defendant  
3  - federal question  
4  - diversity of citizenship  
5  - local question  

## NATURE OF SUIT  
**(NOS)**  

A 3 digit statistical code representing the nature of the action filed.  

| Code | Description |
|------|-------------|
| 110 | Insurance |
| 120 | Marine Contract Actions |
| 130 | Miller Act |
| 140 | Negotiable Instruments |
| 150 | Overpayments & Enforcement of Judgments |
| 151 | Overpayments under the Medicare Act |
| 152 | Recovery of Defaulted Student Loans |
| 153 | Recovery of Overpayments of Vet Benefits |
| 160 | Stockholder's Suits |
| 190 | Other Contract Actions |
| 195 | Contract Product Liability |
| 196 | Franchise |
| 210 | Land Condemnation |
| 220 | Foreclosure |
| 230 | Rent, Lease, Ejectment |
| 240 | Torts to Land |
| 245 | Real Property Product Liability |
| 290 | Other Real Property Actions |
| 310 | Airplane Personal Injury |
| 315 | Airplane Product Liability |
| 320 | Assault, Libel, and Slander |
| 330 | Federal Employers' Liability |
| 340 | Marine Personal Injury |
| 345 | Marine Product Liability |
| 350 | Motor Vehicle Personal Injury |
| 355 | Motor Vehicle Product Liability |
| 360 | Other Personal Injury |
| 362 | Medical Malpractice |
| 365 | Personal Injury - Product Liability |
| 367 | Health Care / Pharma |
| 368 | Asbestos Personal Injury - Prod.liab. |
| 370 | Other Fraud |
| 371 | Truth in Lending |
| 375 | False Claims Act |
| 376 | Qui Tam False Claims Act |
| 380 | Other Personal Property Damage |
| 385 | Property Damage - Product Liabilty |
| 400 | State Reapportionment |
| 410 | Antitrust |
| 422 | Bankruptcy Appeals Rule 28 USC 158 |
| 423 | Bankruptcy Withdrawal 28 USC 157 |
| 430 | Banks and Banking |
| 440 | Other Civil Rights |
| 441 | Civil Rights Voting |
| 442 | Civil Rights Employment |
| 443 | Civil Rights Accommodations |
| 445 | Americans with Disabilities Act - Employment |
| 446 | Americans with Disabilities Act - Other |
| 448 | Education |
| 450 | Interstate Commerce |
| 460 | Deportation |
| 462 | Naturalization, Petition For Hearing of Denial |
| 463 | Habeas Corpus - Alien Detainee |
| 465 | Other Immigration Actions |
| 470 | Civil (Rico) |
| 480 | Consumer Credit |
| 485 | Telephone Consumer Protection Act |
| 490 | Cable/ Satellite TV |
| 510 | Prisoner Petitions - Vacate Sentence |
| 530 | Prisoner Petitions - Habeas Corpus |
| 535 | Habeas Corpus - Death Penalty |
| 540 | Prisoner Petitions - Mandamus and Other |
| 550 | Prisoner - Civil Rights |
| 555 | Prisoner - Prison Condition |
| 560 | Civil Detainee |
| 625 | Drug Related Seizure of Property |
| 690 | Other Forfeiture and Penalty Suits |
| 710 | Fair Labor Standards Act |
| 720 | Labor Management Relations Act |
| 740 | Railway Labor Act |
| 751 | FMLA |
| 790 | Other Labor Litigation |
| 791 | Employee Retirement Income Security Act (ERISA) |
| 820 | Copyright |
| 830 | Patent |
| 835 | Patent--Abbreviated New Drug Application |
| 840 | Trademark |
| 850 | Securities, Commodities, Exchange |
| 861 | Social Security - HIA (1395 ff) |
| 862 | Social Security - Black Lung (923) |
| 863 | Social Security - DIWC/DIWW (405(g)) |
| 864 | Social Security - SSID Title XVI |
| 865 | Social Security - RSI (405(g)) |
| 870 | Tax Suits |
| 871 | IRS 3rd Party Suits 26 USC 7609 (U.S. plaintiff) |
| 880 | Defend Trade Secrets Act |
| 890 | Other Statutory Actions |
| 891 | Agricultural Acts |
| 893 | Environmental Matters |
| 895 | Freedom of Information Act of 1974 |
| 896 | Arbitration |
| 899 | APA Review/Appeal |
| 950 | Constitutionality of State Statutes |

Must have appropriate jurisdiction.  

## TITLE  
**(TITL)**  

This field is optional.  

## SECTION  
**(SECTION)**  

This field is optional.  

## SUBSECTION  
**(SUBSECT)**  

This field is optional.  

## DIVERSITY RESIDENCE  
**(RESIDENC)**  

Involves diversity of citizenship for the plaintiff and defendant. First position is the citizenship of the plaintiff, second position is the citizenship of the defendant.  

1 – Citizen of this State  
2 – Citizen of another State  
3 – Citizen or Subject of a Foreign Country  
4 – Incorporated or principal place of business in this State  
5 – Incorporated and principal place of business in another State  
6 – Foreign Nation  

This two digit code is used only when the jurisdiction = 4.  

## JURY DEMAND  
**(JURY)**  

Indicates the party or parties demanding a jury trial.   

B – Both plaintiff and defendant demand jury  
D – Defendant demands jury  
P – Plaintiff demands jury  
N – Neither plaintiff nor defendant demands jury  
-8 - missing  

## CLASS ACTION  
**(CLASSACT)**  

Involves an allegation by the plaintiff that the complaint meets the prerequisites of a "Class Action" as provided in Rule 23 - F.R.CV.P.  

1 – indicates the case filed is a class action suit  
-8 - missing  

## MONETARY AMOUNT DEMANDED  
**(DEMANDED)**  

The monetary amount sought by plaintiff (in thousands).  

- Money amounts less than $500 appear as 1, and amounts over $10,000 appear as 9999.  
- Dollar figure is rounded to the nearest thousand.(eg.$1,234.56 would appear as a single digit (1).  
- In the past, courts have not always reported this field in thousands of dollars, therefore data may not be accurate.  

## FILING JUDGE  
**(FILEJUDG)**  

The statistical code for the judge to whom the case was originally assigned.  

-8 – missing  

Blank on public use files  

## FILING MAGISTRATE JUDGE  
**(FILEMAG)**  

The code of the magistrate judge to whom all or part of the case was originally referred.  

-8 – missing  

Blank on public use files  

## COUNTY OF RESIDENCE  
**(COUNTY)**  

The code for the county of residence of the first listed plaintiff.  

- If the US Government is the plaintiff, the county listed is that of the first listed defendant.   
- If a land condemnation case, the code is associated with the tract of land.  
- If the location is within the U.S. but, outside the home state, the code is 88888.  
- If the location is outside the U.S. the code is 99999.  

NOTE: For County Codes refer to the manual - "City and Town Locations and County Statistical Codes" January 1984.  

## ARBITRATION AT FILING  
**(ARBIT)**  

This field is used only by the courts participating in the Formal Arbitration Program. It is not used for any other purpose.  

**Method of Participation:**  
M - mandatory  
V - voluntary  
E - exempt  
Y - yes, but type unknown  
-8 – missing  

There are approximately twenty (20) courts participating in this program.  

## MULTIDISTRICT LITIGATION DOCKET NUMBER  
**(MDLDOCK)**  

A 4-digit multi district litigation docket number.  

## PLAINTIFF  
**(PLT)**  

First listed plaintiff.  

## DEFENDANT  
**(DEF)**  

First listed defendant.  

## RANSFER DATE  
**(TRANSDAT)**  

The date when the papers were received in the receiving district for a transferred case.  

## TRANSFER OFFICE  
**(TRANSOFF)**  

The office number of the district losing the case.  

-8 - missing  

## TRANSFER DOCKET NUMBER  
**(TRANSDOC)**  

The docket number of the case in the losing district.  

-8 - missing  

## TRANSFER ORIGIN  
**(TRANSORG)**  

The origin number of the case in the losing district.  

-8 - missing  

## TERMINATION DATE  
**(TERMDATE)**  

The DATE the district court received the final judgment or the order disposing of the case.  

## TERMINATION DATE USED BY AO  
**(TDATEUSE)**  

This field is used to identify cases within a given statistical or fiscal year of termination as counted by the AO in published reports. Cohorts based on actual termination dates rather than on the Used-by-AO dates are unlikely to provide counts that can be matched with published tables. For example, a case that was docketed in June 1985 but was processed late and thus fell into the range of SY86 cases instead of SY85 cases will have a value of 6/1/1985 for Termination Date Used by AO which properly places it in the statistical year in which it was terminated.  

## TERMINATION CLASS ACTION  
**(TRCLACT)**  

A code that indicates a case involving allegations of class action.   

2  - denied  
3  - granted  
-8 - missing  

Must have a 1 in the CLASSACT field.  

## TERMINATION JUDGE  
**(TERMJUDG)**  

The statistical code for the judge assigned at the time of disposition.  

The judge who opened the case and the judge who disposed of the case do not have to be the same.  

-8 – missing  

Blank on public use files  

## TERMINATION MAGISTRATE JUDGE  
**(TERMMAG)**  

The statistical code for the magistrate judge assigned at the time of disposition.  

As with the termination judge, the termination magistrate judge does not have to be the same as the magistrate judge who open the case.  

-8 – missing  

Blank on public use files  

## PROCEDURAL PROGRESS  
**(PROCPROG)**  

The point to which the case had progressed when it was disposed of. These codes are separated in two groups:  
a) before issue joined  
1    -no court action  
2    -order entered  
11   -hearing held  
12   -order decided  
b) after issued joined  
3    -no court action  
4    -judgement on motion  
5    -pretrial conference held  
6    -during court trial  
7    -during jury trial  
8    -after court trial  
9    -after jury trial  
10   -other  
13   -request for trial de novo after arbitration  

See Appendix A: CIVIL CODE SHEETS, under procedural progress, for explanation of the two groups.  

## DISPOSITION  
**(DISP)**  

The manner in which the case was disposed of.  
Cases transferred or remanded:  
0 – transfer to another district  
1 – remanded to state court  
10 – multi district litigation transfer  
11 – remanded to U.S. Agency  
Dismissals:  
2 – want of prosecution  
3 – lack of jurisdiction  
12 – voluntarily  
13 – settled  
14 – other  
Judgment on:  
4 – default  
5 – consent  
6 – motion before trial  
7 – jury verdict  
8 – directed verdict  
9 - court trial  
15 – award of arbitrator  
16 – stayed pending bankruptcy  
17 – other  
18 – statistical closing  
19 – appeal affirmed (magistrate judge)  
20 – appeal denied (magistrate judge)  

-8 – missing  

See Appendix A: CIVIL CODE SHEETS, under disposition, for explanation of the three manners.  

## NATURE OF JUDGMENT  
**(NOJ)**  

Cases disposed of by an entry of a final judgment.  

**CODES:**  
0  - no monetary award  
1  - monetary award only  
2  - monetary award and other  
3  - injunction  
4  - forfeiture/foreclosure/condemnation, etc.  
5  - costs only  
6  - costs and attorney fees  

These cases should only be present for disposition involving a judgement.  

## AMOUNT RECEIVED  
**(AMTREC)**  

Dollar amount received (in thousands) when appropriate.  

This variable is not used uniformly by the 94 district courts. The Statistics Division advises against the use for this data for analysis purposes because it is not a mandatory data field. (Some courts may be using "9999" to indicate amounts over $1 million while others may be using it as a filler or for an unknown amount.)  

## JUDGEMENT  
**(JUDGMENT)**  

Cases disposed of by entry of a final judgment in favor of:  

1    - plaintiff  
2    - defendant  
3    - both  
4    - unknown  
0/-8 - missing  

## DATE ISSUE JOINED  
**(DJOINED)**  

Data rarely entered in the past.  
This field is no longer being used.  

## PRETRIAL CONFERENCE DATE  
**(PRETRIAL)**  

Data rarely entered in the past.  
This field is no longer being used.  

## TRIAL BEGIN DATE  
**(TRIBEGAN)**  

Data rarely entered in the past.  
This field is no longer being used.  

## TRIAL END DATE  
**(TRIALEND)**  

Data rarely entered in the past.  
This field is no longer being used.  

## ARBITRATION AT TERMINATION  
**(TRMARB)**  

Termination arbitration code.  

M  - mandatory  
V  - voluntary  
E  - exempt  
-8 - missing  

This field must be completed if the field ARBIT has an entry.  

## PRO SE  
**(PROSE)**  

0  - no Pro Se plaintiffs or defendants  
1  - one or more Pro Se plaintiffs, but no Pro Se defendants  
2  - one or more Pro Se defendants, but no Pro Se plaintiffs  
3  - one or more Pro Se plaintiffs, one or more Pro Se defendants  
-8 - missing  

Pro Se field is blank in records posted before October 1995.  

## FEE STATUS  
**(IFP)**  

FP - Informa Pauperis (IFP cases)  
-8 - not IFP cases  

This field captured since October 2000.  

## STATUS CODE  
**(STATUSCD)**  

Status code to identify the type of record.  

S – pending record  
L – terminated record  

This field captured since October 2000.  

## YEAR OF TAPE  
**(TAPEYEAR)**  

Statistical year label on data files obtained from the Administrative Office of the United States Courts. 2099 on pending case records.  

---

**Appendix A: CIVIL CODE SHEETS**

## PROCEDURAL PROGRESS  
**(PROCPROG)**  

Procedural Progress at Termination: mark the one category that best indicates the point to which the action had progressed when it was disposed of.  

Special Note: For the purposes of this report, date issue was joined is defined as the date on which the last answer or reply of the defendant was filed before the first proceeding in the case began. In multi-defendant cases where the case proceeds before all answers are received, use the date of the last answer filed prior to initiation of action in the case. Indicate date issue was joined in the proper space under Procedural Dates.  

**(a) Before Issue Joined:** the civil case was terminated before the defendant filed an answer to the complaint.  

(01) No Court Action: the action was withdrawn by the plaintiff or settled by the parties with no participation by a judge or magistrate. (Note: Include in this category all prisoner petitions and other actions which are withdrawn or otherwise disposed of without activity of a judge or magistrate before issue is joined.)  

(02) Order Entered: final order was entered by the court to dispose of the action before a motion was made by the plaintiff and before a hearing was conducted by a judge or magistrate.  

(11) Hearing Held: in the defendant's absence, a hearing was held before a judge or magistrate which effected a termination of the action and the decision to terminate was not decided on a motion to terminate by plaintiff.  

(12) Order Decided: the action was disposed of by a judge or magistrate upon plaintiff's motion to terminate (Note: Include in this category prisoner petitions disposed of where issue was not joined and no pretrial occurred.)  

**(b) After Issue Joined:** issue is considered joined after defendant has answered the complaint in accordance with Rule 12(a), F.R.Cv.P. or as mandated otherwise by court. Indicate date issue was joined in Procedural Dates (see instruction on page 19).  

(03) No Court Action: the action was disposed of with no action by either a judge or magistrate after an answer was filed. Indicate the date issue was joined in the Procedural Dates section of the JS-6. (NOTE: Include in this category all prisoner petitions and other actions which are withdrawn or otherwise disposed of without activity by a judge or magistrate, after issue is joined.)  

(04) Judgement on Motion: an answer was filed and the action was disposed of after some judicial action by a judge or magistrate, but before any pretrial conference began in the Procedural Dates section of the JS-6.  

(05) Pretrial Conference Held: the action was disposed of before a trial began but after an answer was filed, and a pretrial conference as defined in Rule 16, F.R.Cv.P., was held before a judge or magistrate. Indicate the dates issue was joined and pretrial conference began in the Procedural dates section of the JS-6.  

Special Note: For the purposes of this report, a trial is defined as "a contested proceeding where evidence is introduced." A trial is considered completed when a verdict is returned by a jury or a decision is rendered by the court.  

(06) During Court Trial: the action was disposed of after a court trial (before a judge or magistrate but not a jury) began, but before the trial was concluded. Indicate the dates issue was joined, pretrial conference began, trial began and trial ended in the Procedural Dates section of the JS-6.  

(07) During Jury Trial: the action was disposed of after a jury trial began, but before the trial concluded. Indicate the dates issue was joined, pretrial conference began, and trial ended in the Procedural Dates section of the JS-6.  

(08) After Court Trial: the action was disposed of after the completion of a trial before a judge or magistrate. Indicate the dates issue was joined, pretrial conference began, trial began and trial ended in the Procedural Dates section of the JS-6.  

(09) After Jury Trial: the action was disposed of after the completion of a trial before a jury. Indicate the dates issue was joined, pretrial conference began, trial began and trial ended in the Procedural Dates section of the JS-6.  

(10) Other: where none of the above categories properly reflect the procedural progress.  

(13) Request for trial de novo after arbitration  

## DISPOSITION  
**(DISP)**  

Disposition: mark the category that best describes the method of disposition of the civil action. Mark only one of the following categories:  

**Transferred or Remanded:** the case was transferred to another Federal court for action or was remanded to a state court or other jurisdiction from which it arose. Specify one of the following:  

(00) Transfer to Another District: the case was transferred to another district. This category includes actions transferred under Title 28 U.S.C. Section 1404(a).  

(01) Remanded to State Court.  

(10) MDL Transfer: the case was transferred by the judicial panel on multidistrict litigation as authorized by Title 28 U.S.C. Section 1407(a).  

(11) Remanded to U.S. Agency.  

**Dismissals:** the case was terminated by order of dismissal arising from one of the situations listed below:  

(02) Want of Prosecution: the case was disposed of by the clerk pursuant to local rule after a specified inactive period.  

(03) Lack of Jurisdiction: the case was terminated on a motion to dismiss because of lack of jurisdiction over the subject matter or lack of jurisdiction over the person.  

(12) Voluntarily: plaintiff voluntarily withdrew the action from judicial review in accordance with Rule 41(a), F.R.Cv.P.  

(13) Settled: the action was disposed of after settlement between parties out of court.  

(14) Other: any other dismissal not covered by the preceding categories.  

**Judgement On:** the case was terminated by a judgment as follows:  

(04) Default: the action was disposed of by a default judgment entered by the court or the clerk of court pursuant to Rule 55, F.R.Cv.P.  

(05) Consent: the action was disposed of by an order of judgment agreed to by all parties and signed by the judge or magistrate, which grants some form of affirmative relief to one of the parties. This category should be indicated even though the agreement was entered into after a trial began.  

(06) Motion Before Trial: the action was disposed of by a final judgment based on a motion for judgment on the pleadings, as defined in Rule 12(c), F.R.Cv.P.; any other contested motion which results in disposition before trial; or any order dismissing a prisoner petition.  

(07) Jury Verdict: the action was disposed of by entry of a final judgment resulting from a verdict by a jury (other than a directed verdict). Enter dates trial began and ended in the Procedural Dates section of the JS-6.  

(08) Directed Verdict: the action was disposed of by entry of a final judgment resulting from a verdict directed to a jury by the court. Enter dates trial began and ended in the Procedural Dates section of the JS-6.  

(09) Court Trial: the action was disposed of by entry of a final judgment resulting from a decision by a judge or magistrate during or after a trial (other than a jury trial). Indicate dates trial began and ended in the Procedural Dates section of the JS-6.  

(15) Award of Arbitrator: the matter was disposed of by an award of an arbitrator through formal arbitration procedures adopted by the court.  

(16) Stayed Pending Bankruptcy: the matter was disposed of by an order granting a formal stay of a current civil action because a bankruptcy case was filed by one of the parties.  

(17) Other: the action was disposed of by entry of a final judgment by a method not sufficiently covered by any of the categories 04 through 09,15 or 16.  

(18) Statistical Closing: the action was pending for more than 3 years, no activity occurred for more than 12 months, and all presently contemplated proceedings were completed.  

(19) Appeal Affirmed (Magistrate Judge)  

(20) Appeal Denied (Magistrate Judge)  