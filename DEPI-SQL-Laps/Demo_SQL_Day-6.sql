--------------------------------------**** SQL Day 6 *****---------------------------------------------------
-------Topics-------*
-------******-------*
--------------------* Window Function (LAG , LEAD , FIRST_VALUE , LAST_VALUE)
--------------------* Index
--------------------* View
--------------------* Functions
--------------------* Table Types
--------------------* IDENTITY_INSERT
--------------------* Window Function (LAG , LEAD , FIRST_VALUE , LAST_VALUE) *-------------------
--------------------* Some Of Built-In function
--------------------* SQL Server Profiler
--------------------* Database Engine Tuning Advisor
-------******-------*

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Window Function (LAG , LEAD , FIRST_VALUE , LAST_VALUE) *-------------------
/*
| Function        | Returns                   | Typical question              |
| --------------- | ------------------------- | ----------------------------- |
| `LAG()`         | Previous row’s value      | What was the previous salary? |
| `LEAD()`        | Next row’s value          | What is the next appointment? |
| `FIRST_VALUE()` | First value in the window | What was the initial salary?  |
| `LAST_VALUE()`  | Last value in the window  | What is the latest salary?    |
*/

use DEPI_System

SELECT s.St_ID ,s.FirstName,sc.Grade, c.Crs_Name
INTO ExamResult
FROM Student s
JOIN Student_Course sc
ON s.St_ID = sc.St_ID
JOIN Course c
ON c.Crs_ID = sc.Crs_ID

/*
1. LAG() — Get a previous value
Use LAG() when you need to compare the current row with a previous row.
Common uses:
Compare this month with last month
Calculate the difference between consecutive values
Detect price or status changes
Calculate growth rates
*/

SELECT *,
		LAG(FirstName) OVER(ORDER BY Crs_Name ) AS LAG
FROM ExamResult

SELECT *,
		LAG(Grade) OVER(ORDER BY Crs_Name ) AS LAG
FROM ExamResult

/*
2. LEAD() — Get a following value
Use LEAD() when you need to compare the current row with the next row.
Common uses:
Find the next transaction date
Calculate the period until the next event
Compare the current value with the next value
Identify the final record in a sequence
*/

SELECT  emp_id,FirstName,Salary,
LAG(salary)OVER (ORDER BY emp_id) Before,
LEAD(salary)OVER (ORDER BY emp_id) After
FROM Employee

SELECT *,
	LAG(Grade)  OVER(ORDER BY Crs_Name )  AS PreviousGrade,
	LEAD(Grade) OVER (ORDER BY Crs_Name) AS NextGrade
FROM ExamResult

SELECT *,
	LAG(Grade)  OVER (PARTITION BY Crs_Name ORDER BY Crs_Name )  AS PreviousGrade,
	LEAD(Grade) OVER (PARTITION BY Crs_Name ORDER BY Crs_Name) AS NextGrade
FROM ExamResult

/*
3. FIRST_VALUE() — Get the first value
Use FIRST_VALUE() to retrieve the first value within an ordered group.
Common uses:
Compare every month with the first month
Find an employee’s initial salary
Retrieve the first transaction for every customer
Find the first status in a process
	
4. LAST_VALUE() — Get the last value
Use LAST_VALUE() to retrieve the last value within an ordered group.
Common uses:
Compare every month with the latest month
Retrieve an employee’s most recent salary
Find the final status of every order
Compare historical values with the latest value
*/

SELECT *,
First_Value(Grade) OVER (PARTITION BY Crs_Name ORDER BY Crs_Name)  AS FirstGrade,
Last_Value(Grade) OVER (PARTITION BY Crs_Name ORDER BY Crs_Name) AS LastGrade
FROM ExamResult

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Index *-------------------

/*
| Feature                   | Clustered              | Nonclustered                |
| ------------------------- | ---------------------- | --------------------------- |
| Number per table          | Only one               | Multiple                    |
| Leaf level                | Actual data rows       | Keys and row locators       |
| Controls row organization | Yes                    | No                          |
| Stored separately         | No                     | Yes                         |
| Common use                | Primary key and ranges | Frequently searched columns |
| Example                   | `EmployeeID`           | `Email`, `DepartmentID`     |
*/

CREATE INDEX Index_FirstName			-- Default Non-Unique - Non-Clustered
ON Employee(FirstName)

DROP index Employee.Index_FirstName

CREATE CLUSTERED INDEX Clust_Index_1	
ON Employee(Emp_ID)


CREATE UNIQUE CLUSTERED INDEX Unq_Clust_Index_1
ON Employee(Emp_ID)


CREATE UNIQUE NONCLUSTERED INDEX Unq_NonClust_Index_1
ON Employee(Age)

DROP INDEX table_name.index_name;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* View *-------------------
-- Types Of VIEW ::
-------------------
-------------------
--System VIEW
--User Define VIEW


-- User Define VIEW Type ::
---------------------------
---------------------------
--1 Standard VIEW
	--1.1 Simple VIEW :	
		--	1.1.1 From One Table
	--1.2 Complex VIEW :
		-- 1.1.2 From More Than One Table
--2 Partitioned VIEW
	-- Combine Data From Different Sourses "Servers"
--3 Indexed VIEW
	-- Create Index On VIEW

--System VIEW

--sys.databases: This system view contains information about all databases on the SQL Server instance, including their names, IDs, creation date,
-- compatibility level, collation, and more.
select *
from sys.databases

--sys.tables: This system view contains information about all tables in a database, including their names, IDs, schema, creation date,
-- modification date, and more.
select *
from sys.tables

--sys.columns: This system view contains information about all columns in a table, including their names, data types, nullability, maximum length, and more.
select *
from sys.columns

--sys.indexes: This system view contains information about all indexes in a table, including their names, types, columns, fragmentation, and more.
select *
from sys.indexes

--sys.dm_exec_sessions: This system view contains information about all active sessions on the SQL Server instance, including the session ID,
-- user name, login time, last request time, and more.
select *
from sys.dm_exec_sessions

--sys.dm_exec_requests: This system view contains information about all active requests on the SQL Server instance, including the session ID,
-- request ID, status, start time, and more.
select *
from sys.dm_exec_requests

--sys.dm_os_performance_counters: This system view contains information about performance counters for the SQL Server instance, including CPU usage,
-- memory usage, disk I/O, network I/O, and more.
select *
from sys.dm_os_performance_counters

-- User Define VIEW Type ::
---------------------------
---------------------------
--1 Standard VIEW
	--1.1 Simple VIEW :	
		--	1.1.1 From One Table

CREATE VIEW VW_GetStudentData
AS
SELECT * 
FROM Student

SELECT * FROM VW_GetStudentData

CREATE VIEW VW_GetPartialStudentData
AS
SELECT [St_ID] ,[FirstName],[MiddleName] ,[LastName]
FROM Student

SELECT * FROM VW_GetPartialStudentData

ALTER VIEW VW_GetPartialStudentData
AS
SELECT [St_ID] ,[FirstName],[MiddleName] 
FROM Student

SELECT * FROM VW_GetPartialStudentData

DROP VIEW VW_GetPartialStudentData



	--1.2 Complex VIEW :
		-- 1.1.2 From More Than One Table

-- Dealing With " Insert , Update , Delete" On View
--------------------------------------------------
--Command .Simple_View	. Complex_View
----------.-------------.-------------
-- Insert .Yes			. Yes With Condition (Affected ONLY One Table , Others Identity , Default , Nullable)
-- Update .Yes			. Yes (ONLY One Table)
-- Delete .Yes			. NO

-- Builtin SP 
SP_DEPENDS VW_GetPartialStudentData

SP_HELP VW_GetPartialStudentData

SP_HELPTEXT VW_GetPartialStudentData

SP_RENAME VW_Name_Old,VW_Name_New

-- ENCRYPTED VIEW
-- WITH ENCRYPTION
DROP VIEW VW_StudentData

CREATE VIEW VW_StudentData
WITH ENCRYPTION
AS
SELECT * FROM Student

SP_HELPTEXT VW_StudentData


--2 Partitioned VIEW
	-- Combine Data From Different Sourses "Servers"
CREATE VIEW VW_Sales 
AS
SELECT [DepartmentID],[name] FROM   AdventureWorks2019.HumanResources.Department
UNION ALL
SELECT dep_id, Dep_Name FROM Department

--with check option
----working with insert ,update only and on SIMPLE View ONLY
CREATE VIEW VW_Emp_Data
as
	SELECT St_ID,FirstName,[Address]
	from Student
	WHERE Address IN ('Alex','Cairo')
	WITH CHECK OPTION -- If Insert Or Update Check Address In Alex Or Cairo Only

INSERT INTO VW_Emp_Data (St_ID,FirstName,[Address])
VALUES (1050,'MOHAMED','Giza')

INSERT INTO VW_Emp_Data (St_ID,FirstName,[Address])
VALUES (1050,'MOHAMED','alex')

--3 Indexed VIEW
	-- Create Index On VIEW
--U CAN CREATE INDEX ON VIEW AS ON TABLES
--An indexed VIEW has been computed and stored. 
--You index a VIEW by creating a ((unique clustered)) index on it
--ONLY Can Create Unique Clustered Index not other index types :
--his is important for schema-bound views because they are used to enforce data integrity and consistency.
--A unique clustered index ensures that each row in the view is unique and that the data is stored physically in the order of the index. This means that the data can be accessed quickly and efficiently, which helps improve performance.

CREATE TABLE Student2
(ID int, Code Char(1))

CREATE VIEW VP
WITH schemabinding
-- It binds the view to the structure of dbo.Student2. SQL Server prevents changes that would break the view.
AS
SELECT Code
FROM dbo.Student2
--WHERE Age>10

ALTER table Student2
ADD  Age bigint


drop table Student2
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Functions *-------------------
--------------------* Built-In
---1)NULL		=> ISNULL ,Coalesce: Returns the first non-NULL value from a list.

SELECT COALESCE(NULL, NULL, 'Available', 'Other');

---2)Convertion	=> Convert, Cast
---3)System 
SELECT DB_NAME()
SELECT suser_name()
SELECT ERROR_LINE(),ERROR_MESSAGE(),ERROR_NUMBER()

------4)Aggregate Function
--COUNT() , MAX() , MIN() , SUM() , AVG()

---5)Text
SELECT UPPER(FirstName) FROM Employee
SELECT LOWER(FirstName) FROM Employee
SELECT LEN(FirstName) FROM Employee
SELECT SUBSTRING(FirstName,1,2) FROM Employee
SELECT FORMAT(DateOfBirth,'yyyy-MM-dd') FROM Instructor
SELECT CONCAT(FirstName, '-',MiddleName ,'-',LastName) FROM Instructor

---6)Math
SELECT POWER(4,2)
SELECT SIN(4)
SELECT COS(4)
SELECT LOG(4)
SELECT TAN(4)

---7)Date
SELECT GETDATE()
SELECT EOMONTH(getdate())
SELECT DAY(GETDATE())
SELECT MONTH(GETDATE())
SELECT YEAR(GETDATE())

---8)Ranking
--ROW_NUMBER()
--RANK()
--DENSE_RANK()
--NTILE()

---9)Window
--LAG , LEAD
--FIRST_VALUE , LAST_VALUE

---10)Logical
--IIF, CASE , WHILE 

--------------------* User Defined 
---1)Scalar Function
--Take Department ID and Return Total Salary for This Department 
CREATE FUNCTION CalcDepSalary (@depID INT)
RETURNS money
	BEGIN
		DECLARE @totalSalary money
		SELECT @totalSalary= SUM(Salary)
		FROM Employee
		WHERE Dep_ID = @depID
RETURN @totalSalary
	END

SELECT dbo.CalcDepSalary (1) 

DROP FUNCTION CalcDepSalary --Return One Value

---2)Inline Table Function
	--Return Table Body (Select ONLY)
--Take Student Id and Get Full Data
CREATE FUNCTION GetStudentByID (@studentID INT)
RETURNS TABLE
AS
RETURN 
(
	SELECT * FROM Student WHERE St_ID = @studentID
)

SELECT dbo.GetStudentByID (1)

SELECT * FROM dbo.GetStudentByID (1)

--- JOIN on Function 
SELECT * FROM dbo.GetStudentByID (1) as fun
JOIN Student_Course sc
on fun.St_ID = sc.St_ID


CREATE FUNCTION GetStudentByID_Address (@studentID INT)
RETURNS TABLE
AS
RETURN 
(
	SELECT St_ID,Address FROM Student WHERE St_ID = @studentID
)

SELECT * FROM GetStudentByID_Address(1)

---3)Multi Statement Table Valued Function (MSTVF)
	--Return Table Body (SELECT , IF < WHILE < DECLARE < TRY , Insert Based On Select)
CREATE FUNCTION GetStudentName (@format NVARCHAR(20)) -- First  , Last , Full
RETURNS @table table(
	StudentID INT,
	StudentName NVARCHAR(50)
)
AS
BEGIN 
	IF @format ='Full'
	INSERT INTO @table
	SELECT St_ID, CONCAT(FirstName,' ' ,LastName)
	FROM Student
	
	ELSE 
	IF @format ='First'
	INSERT INTO @table
	SELECT St_ID, FirstName	
	FROM Student
	
	ELSE 
	IF @format ='Last'
	INSERT INTO @table
	SELECT St_ID, LastName	
	FROM Student

	RETURN
END

SELECT * FROM GetStudentName ('Full')
SELECT * FROM GetStudentName ('First')
SELECT * FROM GetStudentName ('Last')

--------------------*Identity
use DEPI_system
SELECT * FROM Employee

DELETE FROM Employee WHERE Emp_ID = 9

INSERT INTO Employee (Emp_ID,FirstName,DateOfBirth) VALUES (9,'Hassan','2000-10-10')

SET IDENTITY_INSERT Employee ON;
INSERT INTO Employee (Emp_ID,FirstName,DateOfBirth,Dep_ID) VALUES (9,'Hassan','2000-10-10',1)
SET IDENTITY_INSERT Employee OFF
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Table Types *-------------------
--- Strong / Physical
---	Temp Tables
--- Temp Local (Based On Connection / Session)
CREATE TABLE #Exam
(
Exam_ID INT,
Exam_Name NVARCHAR (50)
)

INSERT INTO #Exam VALUES (10,'C#'),(11,'DB')

SELECT * FROM #Exam

---Temp Global (Shared Table)
CREATE TABLE ##Exam
(
Exam_ID INT,
Exam_Name NVARCHAR (50)
)

INSERT INTO ##Exam VALUES (10,'C#'),(11,'DB')

SELECT * FROM ##Exam

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Some Of Built-In Function *-------------------
Select Upper(FirstName),LOWER(FirstName),Len(FirstName)
From Student

Select Substring(FirstName,1,3)
From Student