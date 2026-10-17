--------------------------------------**** SQL Day 4 *****---------------------------------------------------
-------Topics-------*
-------******-------*
--------------------* Aggregated Function
--------------------* Sub-Query
--------------------* Data Type
--------------------* Query Order
--------------------* Transaction
--------------------* Union Set Operation
--------------------* Some Of Built-In Function (DB)
--------------------* 

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** Aggregated Function *****---------------------------------------------------
--Built-In Scalar Function Take Only ONE Parameter and Return One Value
--------------------* Sum *-------------------
select Salary,*
from Employee


--delete from  Employee 
--WHERE Emp_ID > = 11

select sum(Salary)
from Employee

select sum(Salary +1000)
from Employee
--------------------* Max *-------------------
select max(Salary)
from Employee
--------------------* Min *-------------------
select min(Salary)
from Employee
--------------------* Max , Min*-------------------
select max(Salary), min (salary)
from Employee
--------------------* Count *-------------------
select Count(Emp_ID)
from Employee

select Count(Salary)
from Employee
--------------------* Avg *-------------------
select avg(Salary)
from Employee
--------------------------------------**** Aggregated Function Grouping And Conditions
SELECT SUM(Salary),d.Dep_Name
FROM Employee e
LEFT JOIN Department d
ON e.Dep_ID = d.Dep_ID
GROUP BY Dep_Name

SELECT SUM(Salary),Dep_ID
FROM Employee
GROUP BY Dep_ID

SELECT COUNT(Emp_ID),[Address]
FROM Employee
GROUP BY [Address]

SELECT COUNT(Emp_ID),[Address]
FROM Employee
WHERE [Address] IS NOT NULL
GROUP BY [Address]

SELECT SUM(Salary),Dep_ID
FROM Employee
GROUP BY Dep_ID
HAVING SUM(Salary) >3000

SELECT SUM(Salary),Dep_ID
FROM Employee
WHERE Age > 55
GROUP BY Dep_ID
HAVING SUM(Salary) >3000

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------****      Sub-Query     *****---------------------------------------------------
Select *
from Employee
where Salary < Avg(Salary) --??

--1)Scalar SubQuery
Select *
from Employee
where Salary < (Select Avg(Salary) 
				From Employee)

--2)Multi-Row SubQuery
select Dep_Name
from   Department
where  Dep_ID in (select  Dep_ID
				from Employee)

--OR
select  Dep_Name
from Department
where Dep_ID in (select distinct Dep_ID
				from Employee
				where Dep_ID is not null)
--3)Multirow Subquery with Multiple Columns (Joins)
SELECT *
FROM Employee e INNER JOIN Department d
ON d.Dep_ID = e.Dep_ID

SELECT
  d.Dep_Name ,d.Dep_Code,EmpData.Dep_ID,EmpData.TotalSalaries
FROM Department d
JOIN (
    SELECT Dep_ID, SUM(Salary) AS TotalSalaries
    FROM Employee
    GROUP BY Dep_ID
  ) AS EmpData
  ON d.Dep_ID =EmpData.Dep_ID

--4)Correlated SubQuery
Select Emp_ID,FirstName,LastName,(select count(Emp_ID) from Employee where [Address] ='Cairo') AS TotalCairoEmployee 
from Employee
where [Address] ='Cairo'

SELECT Ins_ID,FirstName,
(SELECT Count(Crs_ID) FROM Instructor_Course WHERE Ins_ID = Instructor.Ins_ID )
FROM Instructor

--------------------* Sub Query With D.M.L *-------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** Data Type *****---------------------------------------------------
--------------------------------------**** From File 

--SP_HELP Data Type Name
SP_HELP Int 
GO
SP_HELP Bigint

--------------------* Query Order *-------------------
Select St_ID,Address 
from Student
Where Address='Alex'

Select St_ID,Address AS StudentAddress
from Student
ORDER BY StudentAddress

Select St_ID,Address AS StudentAddress
from Student
Where StudentAddress='Alex'

--1)FROM
--2)ON
--3)JOIN
--4)WHERE
--5)GROUP BY
--6)WITH CUBE or WITH ROLLUP
--7)HAVING
--8)SELECT
--9)DISTINCT
--10)ORDER BY
--11)TOP
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--------------------* Transaction *-------------------
use test
Create Table TransParent
(
ID Int Primary Key,
FullName NVarchar(50)
)

Create Table TransChild
(
ParentID Int Foreign Key References TransParent(ID)
)

Insert Into TransParent
Values (1,'Ahmed'),(2,'Ali'),(3,'Eman')

--------------------* Transaction - RollBack*-------------------
Begin Transaction
Insert into TransChild Values (1)
Insert into TransChild Values (2)
Insert into TransChild Values (3)
RollBack

Select * From TransChild

--------------------* Transaction - Commit*-------------------
Begin Transaction
Insert into TransChild Values (1)
Insert into TransChild Values (2)
Insert into TransChild Values (3)
Commit

Select * From TransChild

--------------------* Transaction - Commit , RollBack*-------------------
Begin Try
	Begin Transaction
	Insert into TransChild Values (1)
	Insert into TransChild Values (2)
	Insert into TransChild Values (3)
	Commit
End Try

Begin Catch
	RollBack
End Catch

Select * From TransChild

Begin Try
	Begin Transaction
	Insert into TransChild Values (1)
	Insert into TransChild Values (20)
	Insert into TransChild Values (3)
	Commit
End Try

Begin Catch
	RollBack
    Print 'Error'
End Catch

Select * From TransChild

--------------------* Transaction - Commit , RollBack Used Some Built-In Functions*-------------------
Begin Try
	Begin Transaction
	Insert into TransChild Values (1)
	Insert into TransChild Values (20)
	Insert into TransChild Values (3)
	Commit
End Try

Begin Catch
	RollBack
    Select ERROR_NUMBER(),ERROR_LINE(),ERROR_MESSAGE()
End Catch

Select * From TransChild

--------------------* Read About ACID Properties in Transaction*-------------------
--Atomic
--Consistency
--Isolation
--Durability

--------------------* Transaction -Case Truncate Logged Into Log File*-------------------
--------------------- To Able Make RollBack
Begin Try
	Begin Transaction
	Insert into TransChild Values (1)
	Truncate Table TransChild
	Insert into TransChild Values (3)
	Commit
End Try

Begin Catch
	RollBack
End Catch

Select * From TransChild

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** Union Set Operation *****---------------------------------------------------
--Union			--Union All			--[Optional] INTERSECT			--[Optional] EXCEPT
use DEPI_System

select  FirstName
from Student 

select FirstName
from Instructor
--------------------* Union *-------------------
select  Salary
from Employee 
Union
select Salary
from Instructor

select  Salary
from Employee 
Where Salary IS NOT NULL
Union
select Salary
from Instructor
Where Salary IS NOT NULL

--------------------* Union ALL *-------------------
select  Salary
from Employee 
Union ALL
select Salary
from Instructor

--------------------* Some Of Built-In Function (DB , User , IsNull, Concat)
Select Suser_name(),db_name()
