/* 	Student Id : 4963571   Name: Rabindra Sah
	Student Id : 4957830   Name: Divya Mayreddy 
   
*/

-- Part 8
--8.1
SELECT D1.DAYNAME AS "WEEKDAY",SUM(DS.QTY*DS.SALEPRICE) AS "TOTAL SALES" 
FROM DWDATE D1,DWSALE DS WHERE DS.SALE_DWDATEID=D1.DATEKEY GROUP BY D1.DAYNAME ORDER BY 2 DESC;

--part 8.2
select b1.custcatname as "CUSTCATNAME",sum(d1.qty*d1.SALEPRICE) as "TOTAL SALES"from dwsale d1,dwcust b1 where d1.dwcustid = b1.dwcustid group by b1.custcatname order by 2 desc;


--PART 8.3
select b1.PRODMANUNAME as "PRODMANUNAME",sum(d1.qty*d1.SALEPRICE) as "TOTAL QTY SOLD" from dwsale d1,DWPROD b1 where d1.dwprodid = b1.dwprodid group by b1.PRODMANUNAME order by 2 desc;

--part 8.4
select * from (select d1.DWCUSTID, b1.FIRSTNAME,b1.SURNAME,sum(d1.qty*d1.SALEPRICE)as "TOTAL SALES"  from dwsale d1,dwcust b1
where d1.dwcustid = b1.dwcustid group by d1.DWCUSTID, b1.FIRSTNAME,b1.SURNAME order by 4 DESC) where rownum<11;

--PART 8.5
select * from (select d1.DWPRODID, b1.PRODNAME, sum(d1.qty*d1.SALEPRICE)as "TOTAL SALES"  from dwsale d1,dwprod b1
where d1.dwprodid = b1.dwprodid group by d1.DWPRODID, PRODNAME order by 3 ASC) where rownum<11;

--PART 8.6
select State, City, Total_sales "Total Sales" from (WITH CTE AS
(select c1.state, c1.city, sum(d1.qty*d1.SALEPRICE) as "TOTAL_SALES", 
ROW_NUMBER() over(PARTITION BY c1.state ORDER BY 3 desc) as rownumber
from DWSALE d1 ,dwcust c1 where d1.dwcustid = c1.dwcustid group by c1.state, c1.city order by  1 asc, 3 desc)
select * from CTE
where (rownumber <=1));