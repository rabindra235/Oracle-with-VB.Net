/* 	Student Id : 4963571   Name: Rabindra Sah
	Student Id : 4957830   Name: Divya Mayreddy 
   
*/

DROP SEQUENCE errorseq;
create sequence errorseq;
DROP TABLE A2ERROREVENT;
create table A2ERROREVENT(ERRORID Integer, SOURCE_ROWID RowID, SOURCE_TABLE Varchar2(30), FILTERID Integer, 
DATETIME Date, ACTION Varchar2(6), CONSTRAINT ERROREVENTACTION CHECK( ACTION IN('SKIP', 'MODIFY')));


DROP SEQUENCE prodSeq;
Create Sequence prodSeq;
DROP TABLE DWPROD;
Create table DWPROD(DWPRODID Integer, DWSOURCETABLE Varchar2(20), DWSOURCEID Number(38), PRODNAME Varchar2(100), 
PRODCATNAME VARCHAR2(30), PRODMANUNAME Varchar2(30), PRODSHIPNAME Varchar2(30));


DROP SEQUENCE custSeq;
Create Sequence custSeq;
DROP TABLE DWCUST;
Create table DWCUST(DWCUSTID Integer , DWSOURCEIDBRIS Number(38), DWSOURCEIDMELB Number(38), FIRSTNAME Varchar2(30), 
SURNAME Varchar2(20), GENDER Varchar2(10), PHONE varchar2(20), POSTCODE Number(4), CITY varchar2(50), 
STATE varchar2(10), CUSTCATNAME varchar2(30)); 


DROP SEQUENCE saleSeq;
Create Sequence saleSeq;
DROP TABLE DWSALE;
Create table DWSALE(DWSALEID Integer, DWCUSTID Number(38), DWPRODID Number(38), DWSOURCEIDBRIS Number(38), 
DWSOURCEIDMELB Number(38), QTY Number(2), SALE_DWDATEID Number, SHIP_DWDATEID Number, SALEPRICE number(6, 2));


DROP TABLE GENDERSPELLING;
Create table GENDERSPELLING(InvalidValue Varchar2(10), NewValue Varchar2(2));

insert into GENDERSPELLING(InvalidValue, NewValue) values('MAIL', 'M');
insert into GENDERSPELLING(InvalidValue, NewValue) values('WOMAN', 'F');
insert into GENDERSPELLING(InvalidValue, NewValue) values('FEM', 'F');
insert into GENDERSPELLING(InvalidValue, NewValue) values('FEMALE', 'F');
insert into GENDERSPELLING(InvalidValue, NewValue) values('MALE', 'M');
insert into GENDERSPELLING(InvalidValue, NewValue) values('GENTLEMAN', 'M');
insert into GENDERSPELLING(InvalidValue, NewValue) values('MM', 'M');
insert into GENDERSPELLING(InvalidValue, NewValue) values('FF', 'F');
insert into GENDERSPELLING(InvalidValue, NewValue) values('FEMAIL', 'F');


/* part 2.1 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2PRODUCT', 1, SYSDATE , 'SKIP' from A2PRODUCT a where a.PRODNAME IS NULL;


/* Part 2.2 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2PRODUCT', 2, SYSDATE , 'MODIFY' from A2PRODUCT a where a.MANUFACTURERCODE IS NULL;


/* Part 2.3 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2PRODUCT', 3, SYSDATE , 'MODIFY' from A2PRODUCT where PRODCATEGORY NOT IN
(select PRODUCTCATEGORY from A2PRODCATEGORY) OR PRODCATEGORY IS NULL;

/* part 2.4.3 */
insert into DWPROD(DWPRODID, DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
  select prodSeq.nextval, 'A2PRODUCT', a1.PRODID, a1.PRODNAME, 
    (select a2.CATEGORYNAME from A2PRODCATEGORY a2 where a1.PRODCATEGORY = a2.PRODUCTCATEGORY) , 
    (select a3.MANUNAME from A2MANUFACTURER a3 where a1.MANUFACTURERCODE = a3.MANUCODE),
    (select DESCRIPTION from A2SHIPPING a4 where a1.SHIPPINGCODE = a4.SHIPPINGCODE )from 
  A2PRODUCT a1 where a1.ROWID NOT IN 
  (select SOURCE_ROWID from A2ERROREVENT);


/*Part 2.4.4  */
insert into DWPROD(DWPRODID, DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
select prodSeq.nextval, 'A2PRODUCT', a1.PRODID, a1.PRODNAME, 
(select a2.CATEGORYNAME from A2PRODCATEGORY a2 where a1.PRODCATEGORY = a2.PRODUCTCATEGORY),
'UNKNOWN',
(select DESCRIPTION from A2SHIPPING a4 where a1.SHIPPINGCODE = a4.SHIPPINGCODE ) from 
A2PRODUCT a1 where a1.ROWID IN 
(select SOURCE_ROWID from A2ERROREVENT where FILTERID = 2);

/* Part 2.4.5 */
insert into DWPROD(DWPRODID, DWSOURCETABLE, DWSOURCEID, PRODNAME, PRODCATNAME, PRODMANUNAME, PRODSHIPNAME)
select prodSeq.nextval, 'A2PRODUCT', a1.PRODID, a1.PRODNAME, 'UNKNOWN',  
    (select a3.MANUNAME from A2MANUFACTURER a3 where a1.MANUFACTURERCODE = a3.MANUCODE),
    (select DESCRIPTION from A2SHIPPING a4 where a1.SHIPPINGCODE = a4.SHIPPINGCODE ) from 
A2PRODUCT a1 where a1.ROWID IN 
(select SOURCE_ROWID from A2ERROREVENT where FILTERID = 3);


/* Part 3.1*/
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2CUSTBRIS', 4, SYSDATE , 'MODIFY' from A2CUSTBRIS a1 where CUSTCATCODE NOT IN
(select CUSTCATCODE from A2CUSTCATEGORY) OR CUSTCATCODE IS NULL;

/*Part 3.2 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2CUSTBRIS', 5, SYSDATE , 'MODIFY' from A2CUSTBRIS a1 where PHONE LIKE '%-%' OR PHONE LIKE '% %';

/*Part 3.3 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2CUSTBRIS', 6, SYSDATE , 'SKIP' 
from A2CUSTBRIS 
where Length(PHONE) != 10
AND PHONE NOT LIKE '%-%' 
AND PHONE NOT LIKE '% %';

/*Part 3.4 */
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select  errorseq.nextval, ROWID, 'A2CUSTBRIS',7, SYSDATE , 'MODIFY'
from A2CUSTBRIS 
where GENDER NOT IN ('m','f','M','F') OR GENDER IS NULL;


/*Part 3.5.1 */
insert into DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, STATE, CUSTCATNAME)
select custSeq.nextval, a1.CUSTID, a1.FNAME, a1.SNAME, UPPER(a1.GENDER), a1.PHONE, a1.POSTCODE, a1.CITY, a1.STATE, 
(select a2.CUSTCATNAME from A2CUSTCATEGORY a2 where a1.CUSTCATCODE = a2.CUSTCATCODE)
from A2CUSTBRIS a1 where a1.ROWID NOT IN 
(select SOURCE_ROWID from A2ERROREVENT);

/*Part 3.5.2 */
insert into DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, STATE, CUSTCATNAME)
select custSeq.nextval, a1.CUSTID, a1.FNAME, a1.SNAME, UPPER(a1.GENDER), a1.PHONE, a1.POSTCODE, a1.CITY, a1.STATE,'UNKNOWN' from A2CUSTBRIS a1 where a1.ROWID  IN 
(select SOURCE_ROWID from A2ERROREVENT where FILTERID=4);


/*Part 3.5.3 */
insert into DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, STATE, CUSTCATNAME)
select custSeq.nextval, a1.CUSTID, a1.FNAME, a1.SNAME, UPPER(a1.GENDER),REGEXP_REPLACE(REGEXP_REPLACE(a1.PHONE,' ',''),'-','') "PHONE", 
a1.POSTCODE, a1.CITY, a1.STATE, 
(select a2.CUSTCATNAME from A2CUSTCATEGORY a2 where a1.CUSTCATCODE = a2.CUSTCATCODE)
from A2CUSTBRIS a1 where a1.ROWID  IN 
(select SOURCE_ROWID from A2ERROREVENT where FILTERID=5);

/*Part 3.5.4 */
insert into DWCUST(DWCUSTID, DWSOURCEIDBRIS, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, STATE, CUSTCATNAME)
select custSeq.nextval, a1.CUSTID, a1.FNAME, a1.SNAME, 
CASE
  WHEN  Lower(a1.GENDER) = 'mail' OR  Lower(a1.GENDER) = 'woman' OR Lower(a1.GENDER) = 'fem' OR  Lower(a1.GENDER) = 'female' OR Lower(a1.GENDER) = 'male' OR  Lower(a1.GENDER) = 'gentleman' OR Lower(a1.GENDER) = 'mm' OR  Lower(a1.GENDER) = 'ff' OR Lower(a1.GENDER) = 'femail'
    THEN (select a2.newvalue from GENDERSPELLING a2 where Lower(a2.invalidvalue) = Lower(a1.gender))
  WHEN  Lower(a1.GENDER) = 'm' THEN 'M'
  WHEN  Lower(a1.GENDER) = 'f' THEN 'F'
  ELSE 'U'
END
, a1.PHONE, a1.POSTCODE, a1.CITY, a1.STATE, 'UNKNOWN' from A2CUSTBRIS a1
where a1.ROWID IN 
(select SOURCE_ROWID from A2ERROREVENT where FILTERID=7);


--part 4
create or replace view a2custmelb_view_merge(CUSTID,FNAME,SNAME,GENDER,PHONE,POSTCODE,CITY,STATE,CUSTCATNAME ) as
SELECT a1.CUSTID, a1.FNAME, a1.SNAME, UPPER(a1.GENDER), a1.PHONE, a1.POSTCODE, a1.CITY, a1.STATE,
(select a2.CUSTCATNAME from A2CUSTCATEGORY a2 where a1.CUSTCATCODE = a2.CUSTCATCODE) 
from A2CUSTMELB a1;

MERGE INTO DWCUST d
USING (select * from a2custmelb_view_merge) a1
ON (d.FIRSTNAME = a1.FNAME  AND d.SURNAME = a1.SNAME  AND  d.POSTCODE = a1.POSTCODE)
WHEN MATCHED THEN UPDATE SET d.DWSOURCEIDMELB = a1.CUSTID
WHEN NOT MATCHED THEN 
INSERT(DWCUSTID, DWSOURCEIDMELB, FIRSTNAME, SURNAME, GENDER, PHONE, POSTCODE, CITY, STATE,CUSTCATNAME)
VALUES(custSeq.nextval, a1.CUSTID, a1.FNAME, a1.SNAME, a1.GENDER, a1.PHONE, a1.POSTCODE, a1.CITY, a1.STATE, a1.CUSTCATNAME);


--part 5.1
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEBRIS', 8, SYSDATE , 'SKIP' from A2SALEBRIS where PRODID NOT IN
(select  DWSOURCEID from DWPROD) OR PRODID IS NULL;


--task 5.2
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEBRIS', 9, SYSDATE , 'SKIP' from A2SALEBRIS where CUSTID NOT IN
(select CUSTID from A2SALEBRIS where CUSTID IN 
(select DWSOURCEIDBRIS from DWCUST));


--task 5.3
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEBRIS', 10, SYSDATE , 'MODIFY' from A2SALEBRIS a1 where a1.SHIPDATE < a1.SALEDATE;

--task 5.4
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEBRIS', 11, SYSDATE , 'MODIFY' from A2SALEBRIS a1 where a1.UNITPRICE is null;

--task 5.5
insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
select saleSeq.nextval, 
(select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDBRIS = a1.CUSTID), 
(select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
a1.SALEID, a1.QTY , 
(select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
(select d1.DATEKEY from DWDATE d1 where a1.SHIPDATE = d1.DATEVALUE)
, a1.UNITPRICE from A2SALEBRIS a1 where a1.ROWID NOT IN
(select SOURCE_ROWID from A2ERROREVENT);

-- Part 5.6

insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
select saleSeq.nextval, 
(select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDBRIS = a1.CUSTID), 
(select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
a1.SALEID, a1.QTY , 
(select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
(select d1.DATEKEY+2 from DWDATE d1 where a1.SALEDATE = d1.DATEVALUE),
a1.UNITPRICE from A2SALEBRIS a1 where a1.ROWID IN
(select SOURCE_ROWID from A2ERROREVENT where FILTERID = 10);

-- Part 5.7
insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDBRIS, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
select saleSeq.nextval, 
(select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDBRIS = a1.CUSTID), 
(select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
a1.SALEID, a1.QTY , 
(select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
(select d1.DATEKEY from DWDATE d1 where a1.SHIPDATE = d1.DATEVALUE),
(select max(UNITPRICE) from A2SALEBRIS where PRODID = a1.PRODID GROUP BY PRODID) from A2SALEBRIS a1 where a1.ROWID IN
(select SOURCE_ROWID from A2ERROREVENT where FILTERID = 11);

-- part 6.1
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEMELB', 12, SYSDATE , 'SKIP' from A2SALEMELB a1 where a1.PRODID NOT IN
(select DWSOURCEID from DWPROD) OR PRODID IS NULL;


-- part 6.2
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEMELB', 13, SYSDATE , 'SKIP' from A2SALEMELB where CUSTID NOT IN
(select CUSTID from A2SALEMELB where CUSTID IN 
(select DWSOURCEIDMELB from DWCUST));

--task 6.3
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEMELB', 14, SYSDATE , 'MODIFY' from A2SALEMELB a1 where a1.SHIPDATE < a1.SALEDATE;

--task 6.4
insert into A2ERROREVENT(ERRORID, SOURCE_ROWID, SOURCE_TABLE, FILTERID, DATETIME, ACTION)
select errorseq.nextval, ROWID, 'A2SALEMELB', 15, SYSDATE , 'MODIFY' from A2SALEMELB a1 where a1.UNITPRICE is null;

--task 6.5
insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
select saleSeq.nextval, 
(select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDMELB = a1.CUSTID), 
(select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
a1.SALEID, a1.QTY , 
(select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
(select d1.DATEKEY from DWDATE d1 where a1.SHIPDATE = d1.DATEVALUE)
,a1.UNITPRICE from 
A2SALEMELB a1 where  a1.ROWID  NOT IN
(select SOURCE_ROWID from A2ERROREVENT);

-- Part 6.6
insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
select saleSeq.nextval, 
(select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDMELB = a1.CUSTID), 
(select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
a1.SALEID, a1.QTY , 
(select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
(select d1.DATEKEY from DWDATE d1 where a1.SALEDATE = d1.DATEVALUE),
a1.UNITPRICE from A2SALEMELB a1  where a1.ROWID IN
(select ROWID from A2SALEMELB where ROWID IN
(select SOURCE_ROWID from A2ERROREVENT where FILTERID = 14)) AND 
((select count(SOURCE_ROWID) from A2ERROREVENT where SOURCE_ROWID = a1.ROWID)=1);

-- Part 6.7

insert into DWSALE(DWSALEID, DWCUSTID, DWPRODID, DWSOURCEIDMELB, QTY, SALE_DWDATEID, SHIP_DWDATEID, SALEPRICE)
  select saleSeq.nextval, 
    (select c1.DWCUSTID from DWCUST c1 where c1.DWSOURCEIDMELB = a1.CUSTID), 
    (select p1.DWPRODID from DWPROD p1 where a1.PRODID = p1.DWSOURCEID),  
  a1.SALEID, a1.QTY , 
    (select d2.DATEKEY from DWDATE d2 where a1.SALEDATE = d2.DATEVALUE), 
    (select d1.DATEKEY from DWDATE d1 where a1.SHIPDATE = d1.DATEVALUE), 
    (select max(UNITPRICE) from A2SALEMELB where 
  PRODID = a1.PRODID GROUP BY PRODID) from A2SALEMELB a1 where a1.ROWID IN
  (select SOURCE_ROWID from A2ERROREVENT where FILTERID = 15) AND
  ((select count(SOURCE_ROWID) from A2ERROREVENT where SOURCE_ROWID = a1.ROWID)=1);

