--------------------------------------**** SQL Day 5 *****---------------------------------------------------
-------Topics-------*
-------******-------*
--------------------* Ranking Function
--------------------* Schema
--------------------* Case , IIF
--------------------* Variables
--------------------* Control Of Flow Statements (IF , EXISTS)
--------------------* Select Into
--------------------* Insert Based On Select
--------------------* Some Of Built-In Function (Convert , Format ,Date Function)
-------******-------*

------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Ranking Functions 	::
					ROW_NUMBER
					RANK With Gap
					DENSE_RANK Without Gap
					NTILE
*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------
USE DEPI_System

--ROW_NUMBER() =>> Use it when every row must have a unique number.
--	Find the latest record for each customer.
--	Remove duplicate rows.
--	Select the highest-paid employee in each department.
--  Used With Order By
SELECT FirstName, Age,
ROW_NUMBER() OVER(ORDER BY Age) AS "Age Sorted"
FROM Employee;

--RANK() =>> Use it for competition-style ranking where [tied values] share the same position.  with gap
--  Gaps: Skips subsequent numbers after a tie. [1,2,2,4]
--	Race results
--	Competition positions
--	Sales rankings
--	Exam rankings
SELECT FirstName, Age,
RANK() OVER(ORDER BY Age) AS "Rank"
FROM Employee;

--DENSE_RANK() =>> Use it when tied values should receive the same position but you do not want gaps. without gap
--  Gaps: Does not skip any numbers; ranks stay consecutive. [1,2,2,3]
--	Top three distinct salaries
--	Product rankings
--	Salary levels
--	Customer tiers
SELECT FirstName, Age,
DENSE_RANK()OVER (ORDER BY Age) AS "Group Divition"
FROM Employee

--NTILE(n) =>> Use it to distribute rows into a specified number of approximately equal groups.
--	Divide customers into four spending groups.
--	Divide students into performance groups.
--	Divide employees into salary bands.
--	Create percentiles or quartiles.
SELECT FirstName,Salary
	,ROW_NUMBER() OVER(ORDER BY Salary) AS "R_N_Age Sorted"
	,RANK() OVER(ORDER BY Salary) AS "Rank"  	
	,DENSE_RANK() OVER(ORDER BY Salary) AS "Dense Ranking"  
	,NTILE(2) OVER(ORDER BY Salary) AS group2
    FROM Employee

SELECT FirstName,Salary
	,ROW_NUMBER() OVER(ORDER BY Salary) AS "R_N_Age Sorted"
	,RANK() OVER(ORDER BY Salary) AS "Rank"  	
	,DENSE_RANK() OVER(ORDER BY Salary) AS "Dense Ranking"  
	,NTILE(3) OVER(ORDER BY Salary) AS group3  --divided into 3 groups
FROM Employee

SELECT FirstName, Address, Age,
ROW_NUMBER() OVER(ORDER BY Age DESC) AS Age_Sorted
FROM Employee

SELECT FirstName, Address, Age,
ROW_NUMBER() OVER(ORDER BY Address ,Age DESC) AS Age_Sorted
FROM Employee

SELECT FirstName, Address, Age,
ROW_NUMBER() over(PARTITION BY Address ORDER BY Age DESC) AS Age_Sorted
FROM Employee

SELECT *,
ROW_NUMBER() OVER(PARTITION BY Dep_id ORDER BY Age DESC) AS rowNumber
FROM Employee
WHERE Age IS NOT NULL

/*| Feature                  | `GROUP BY`             | `PARTITION BY`                   |
| ------------------------ | ---------------------- | ---------------------------------- |
| Main purpose             | Summarize groups       | Perform calculations within groups |
| Keeps individual rows    | No                     | Yes                                |
| Reduces row count        | Usually yes            | No                                 |
| Example result           | One row per department | Every employee with a number       |
| Common functions         | `SUM`, `AVG`, `COUNT`  | `ROW_NUMBER`, `RANK`, `SUM OVER`   |
									`min`,`max`												*/

--SELECT one course for each instructor
SELECT Ins_ID, FirstName, Crs_ID
FROM (
	SELECT I.Ins_ID, I.FirstName, Crs_ID,
	ROW_NUMBER() OVER(PARTITION BY I.Ins_ID ORDER BY IC.Crs_ID  DESC) AS rowNumber
	FROM dbo.Instructor I, dbo.Instructor_Course IC
	where I.Ins_ID = IC.Ins_ID
	)AS newtable
WHERE rowNumber = 1


-- Get Largest 2 Employee in each Department
SELECT *
FROM (
	SELECT Emp_ID,Concat(FirstName, ' ', MiddleName, ' ', LastName) As EmpFullName , Dep_ID, age,
	ROW_NUMBER() OVER(PARTITION BY Dep_ID ORDER BY Age DESC) AS rowNumber
    FROM Employee
    WHERE Dep_ID IS NOT NULL 
	)AS SelectedData
WHERE rowNumber <= 2


-- Divide Employee to 2 Group and Get First Group
SELECT *
FROM (
	SELECT *, NTILE(2)  OVER(ORDER BY Age DESC) AS grop
    FROM Employee
	) AS SelectedData
WHERE grop = 1

--Delete Sepfic Employee (7th Age and Impact directly to Table)

----- CTE

WITH NewTable AS
(
SELECT *
FROM (
	SELECT Emp_ID,
	Concat(FirstName,' ',MiddleName,' ',LastName) As EmpFullName ,Dep_ID, age,
	ROW_NUMBER() OVER(ORDER BY Age DESC) AS rowNumber
    FROM Employee
    )AS SelectedData
	WHERE rowNumber=7
)
--select * from NewTable
--DELETE FROM NewTable WHERE rowNumber = 7
--DELETE FROM NewTable
select * from NewTable


/*| Point              | CTE                                                             | Subquery                                              |
| ------------------ | --------------------------------------------------------------- | ----------------------------------------------------- |
| Definition         | Named temporary query result                                    | Query written inside another query                    |
| Location           | Defined before the main statement                               | Written inside `SELECT`, `FROM`, `WHERE`, or `HAVING` |
| Readability        | Better for long or complex logic                                | Better for short and simple logic                     |
| Reusability        | Can be referenced multiple times within the following statement | Usually must be repeated if needed multiple times     |
| Recursion          | Supports recursive queries                                      | Does not directly support recursion                   |
| Lifetime           | One statement only                                              | Exists only as part of its containing statement       |
| Stored permanently | No                                                              | No                                                    |
| Direct indexing    | No                                                              | No                                                    |
| Performance        | Not automatically faster                                        | Not automatically faster                              |
| Nesting            | Helps avoid deeply nested queries                               | Can become difficult to read when deeply nested       |
| Correlation        | Can replace many correlated patterns                            | Can be correlated with the outer query                |*/


/*| Advantages                                  | Disadvantages                         |
| ------------------------------------------- | ------------------------------------- |
| Makes queries easier to read                | Exists for one statement only         |
| Simplifies complex logic                    | Cannot be indexed directly            |
| Supports recursion                          | Does not guarantee better performance |
| Avoids deeply nested subqueries             | May repeat expensive calculations     |
| Works with `SELECT`, `UPDATE`, and `DELETE` | Recursive logic can be difficult      |
| Does not create a permanent object          | Too many CTEs can become confusing    |*/



/* Another Examples */
SELECT * 
FROM Sales

SELECT DISTINCT Prod_ID,
SUM(Qty) OVER (PARTITION BY Prod_ID) AS PartitionByProductOnly
FROM Sales
-- Same as group by 

select Prod_ID , SUM(qty) AS PartitionByProductOnly
from Sales
group by Prod_ID

--ORDER BY Prod_ID, SalesName
SELECT DISTINCT Prod_ID, SalesName,
SUM(Qty) OVER (PARTITION BY Prod_ID, SalesName) as PartitionByProductAndSalesMan
FROM Sales
ORDER BY Prod_ID, SalesName


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** Schema *****---------------------------------------------------
--Introduced By SQL Server 2005
--Fix 3 Problem 
--More Than One Object By Same Name (Table , View)
--Permission
--Grouping

--CREATE SCHEMA HR;	

-- moves the object named Bonus from its current schema into the HR schema.
Alter Schema dbo transfer HR.Bouns

select *
from Bouns

select *
from HR.Bouns

Create Table HR.Employee 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--IIF
SELECT FirstName, Salary,
IIF(Salary <= 5000  ,'Low Salary','High Salary') AS SalaryStatus
FROM Instructor

--CASE
		---Case Based On Condition
SELECT FirstName, Salary,
		CASE
		WHEN Salary < 2000 THEN 'Low Salary'
		WHEN Salary >=2000 THEN 'High Salary'
		ELSE  'No Salary'
		END AS SalaryStatus
FROM Instructor

SELECT FirstName, Salary = 
		CASE
			WHEN Salary < 2000 THEN 'Low Salary'
			WHEN Salary >=2000 THEN 'High Salary'
			WHEN Age > 50 THEN 'High Salary'
			ELSE  'No Salary'
		END
FROM Instructor

SELECT FirstName, SalaryStatus = 
		CASE
		WHEN Salary < 2000 THEN 'Low Salary'
		WHEN Salary >=2000 THEN 'High Salary'
		ELSE  'No Salary'
		END 
FROM Instructor

SELECT FirstName, 
		CASE
		WHEN Age >50 THEN 'High Salary'
		WHEN Salary < 10000 THEN 'Low Salary'
		WHEN Salary >=10000 THEN 'High Salary'
		ELSE  'No Salary'
		END AS SalaryStatus
FROM Instructor

		---Case Based On Expression
SELECT FirstName, 
		CASE Gender
		WHEN 'F' THEN 'Female'
		WHEN 'M' THEN 'Male'
		END AS Gender
FROM Instructor


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Variables *-------------------

--------------------* Local

DECLARE @empId INT 
SET @empId = 1

select @empId

-- OR One Step
DECLARE @empId INT = 1 
SELECT *
From Employee 
WHERE Emp_ID = @empId


DECLARE @empId INT = (SELECT MAX(Emp_ID) FROM Employee );
select @empId


DECLARE @age INT
SELECT  @age = Age FROM Employee WHERE Emp_ID = 1 
SELECT @age


DECLARE @age INT,@sal DECIMAL (18,2)
SELECT  @age= Age , @sal =Salary FROM Employee WHERE Emp_ID =7
SELECT @age, @sal

select * from Employee

DECLARE @age INT
--SELECT  @age = Age FROM Employee WHERE Emp_ID =5 
SELECT  @age = Age FROM Employee
SELECT @age

---Table Variable
DECLARE @empTable Table (age INT , sal DECIMAL (18,2) )
INSERT INTO @empTable
SELECT   Age , Salary FROM Employee 

SELECT * FROM @empTable

SELECT * FROM Employee WHERE Emp_ID = 5

DECLARE @employeeID INT = 1, @employeeFirstName NVARCHAR(50)= 'ahmed' , @employeeAge INT
UPDATE Employee
SET FirstName = @employeeFirstName,
@employeeAge = Age
WHERE Emp_ID = @employeeID

SELECT @employeeAge

SELECT TOP (10) * 
FROM Employee

DECLARE @topCount INT = 5
SELECT TOP (@topCount) * 
FROM Employee

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Control Of Flow Statements *-------------------
--IF
DECLARE @no_Of_DeletedRecords INT

DELETE FROM Student WHERE St_ID= 1050
--  @@ROWCOUNT-> RETURNS THE COUNT OF THE AFFECTED ROWS 
SELECT @no_Of_DeletedRecords = @@ROWCOUNT
	IF  @no_Of_DeletedRecords = 0
		SELECT  'No rows were deleted.'
	ELSE IF @no_Of_DeletedRecords =1
		SELECT  'One row was deleted.'
	ELSE 
		SELECT 'Multiple rows were deleted.'
		
--IF EXISTS , NOT EXISTS
SELECT * FROM Student

IF EXISTS(select * FROM SYS.TABLES WHERE NAME='Students')
	BEGIN
		SELECT * FROM SYS.TABLES WHERE NAME='Students'
	END
ELSE
	BEGIN
		SELECT 'Wrong Table Name'
	END

IF NOT EXISTS (SELECT * FROM Student WHERE St_ID = 10000)
	BEGIN
		INSERT INTO Student(St_ID,FirstName,LastName) VALUES (10000,'Mohamed' ,'Ahmed')
	END

   select * FROM Department WHERE Dep_ID = 1

IF NOT EXISTS (SELECT * FROM Employee WHERE Dep_ID = 1)
	DELETE FROM Department WHERE Dep_ID = 1


BEGIN TRY 
    DELETE FROM Department WHERE Dep_ID = 1
END TRY
BEGIN CATCH
	SELECT 'This Department Matched To Current Employess'
END CATCH


--------------------* Select Into [DDL]
SELECT *
Into NewStudent
FROM Student

SELECT *
Into NewStudent2
FROM Student
WHERE 1=2

select * from NewStudent
drop table NewStudent

--------------------* Insert Based On Select
Insert Into NewStudent
Select * 
From NewStudent
Where Gender = 'M'


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------****      Some Of Built-In Function     *****---------------------------------------------------

--------------------* Convert *----------------------
SELECT FirstName + Age
FROM Instructor

SELECT FirstName +' '+ CONVERT (varchar(20), Age) 
FROM Instructor


SELECT FirstName +' '+ CAST(Age as Varchar(20))
FROM Instructor


SELECT ISNULL(FirstName,'') +' '+ CONVERT (varchar(20), Age) 
FROM Instructor

SELECT CONCAT( FirstName ,' ' , Age)
FROM Instructor

SELECT CONVERT(varchar(20), GETDATE(),102)

SELECT FORMAT (getdate(), 'dd/MM/yyyy ') as date		--21/03/2021
SELECT FORMAT (getdate(), 'dd/MM/yyyy, hh:mm:ss ') as date	--21/03/2021, 11:36:14
SELECT FORMAT (getdate(), 'dddd, MMMM, yyyy') as date	--Wednesday, March, 2021
SELECT FORMAT (getdate(), 'MMM dd yyyy') as date		--Mar 21 2021
SELECT FORMAT (getdate(), 'MM.dd.yy') as date			--03.21.21
SELECT FORMAT (getdate(), 'MM-dd-yy') as date			--03-21-21
SELECT FORMAT (getdate(), 'hh:mm:ss tt') as date		--11:36:14 AM
SELECT FORMAT (getdate(), 'd','us') as date				--03/21/2021
SELECT FORMAT (getdate(), 'MM') as date				--03
SELECT FORMAT (getdate(), 'dd') as date				--25
SELECT FORMAT (getdate(), 'yy') as date				--21
SELECT FORMAT (getdate(), 'yyyy') as date		    --2021
SELECT FORMAT (getdate(), 'yyyy-MM-dd hh:mm:ss tt') as date	--2021-03-21 11:36:14 AM
SELECT FORMAT (getdate(), 'yyyy.MM.dd hh:mm:ss t') as date	--2021.03.21 11:36:14 A
SELECT FORMAT (getdate(), 'dddd, MMMM, yyyy','es-es') as date --Spanish	domingo, marzo, 2021
SELECT FORMAT (getdate(), 'dddd dd, MMMM, yyyy','ja-jp') as date --Japanese	日曜日 21, 3月, 2021

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Date Function *----------------------
SELECT YEAR(GETDATE())
SELECT MONTH(GETDATE())
SELECT DAY(GETDATE())

SELECT MONTH(GETDATE())
SELECT EOMONTH(GETDATE())
SELECT FORMAT(EOMONTH(GETDATE()),'dd')
SELECT FORMAT(EOMONTH(GETDATE()),'dddd')
SELECT EOMONTH(GETDATE(),2)
SELECT EOMONTH(GETDATE(),-2)