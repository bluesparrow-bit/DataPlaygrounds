--------------------------------------**** SQL Day 7 *****---------------------------------------------------
-------Topics-------*
-------******-------*
--------------------* Stored Proc
--------------------* Output
--------------------* Trigger
--------------------* View Menu => Template Explorer (Ctrl + Alt + A)
--------------------* Group By Oprions (Group By, RollUp , Cube, Grouping Sets)
--------------------* System Databses
-------******-------*

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Stored Proc *-------------------
--------------------* Stored Proc Types ::
--------------------* Built-In 

--------------------* System Defined 
---Read , Excution Plan (Parse,Binding , Query Optimization [Excution Plan],Query Excution)

--------------------* User Defined 
use DEPI_System

CREATE or ALTER PROC GetStudentData 
AS
	SELECT * FROM Student --- Or from View

exec GetStudentData


create or ALTER PROC GetStudentDataByAddress @StudentAddress NVARCHAR(50)
AS
	SELECT * FROM Student 
	WHERE Address = @StudentAddress

exec GetStudentDataByAddress 'alex'


CREATE or ALTER PROC InserInstructorData (@Id INT, @FirstName NVARCHAR(20),@MiddleName NVARCHAR(20),@LastName NVARCHAR(20))
AS
	INSERT INTO Instructor(Ins_ID,FirstName,MiddleName,LastName) VALUES (@Id,@FirstName,@MiddleName,@LastName)

select * from Instructor

exec InserInstructorData 111,'ahmed','mohamed','from SP'


CREATE or ALTER PROC InserInstructorData @Id INT, @FirstName NVARCHAR(20),@MiddleName NVARCHAR(20),@LastName NVARCHAR(20)
AS
	IF NOT EXISTS(SELECT * FROM Instructor WHERE Ins_ID = @Id)
		BEGIN
			INSERT INTO Instructor(Ins_ID,FirstName,MiddleName,LastName) VALUES (@Id,@FirstName,@MiddleName,@LastName)
		END


exec InserInstructorData 111,'ahmed','mohamed','from SP'

select * from Instructor


ALTER PROC InserInstructorData @Id INT, @FirstName NVARCHAR(20),@MiddleName NVARCHAR(20),@LastName NVARCHAR(20)
AS
	BEGIN TRY
		INSERT INTO Instructor(Ins_ID,FirstName,MiddleName,LastName) VALUES (@Id,@FirstName,@MiddleName,@LastName)
	END TRY
	BEGIN CATCH
		SELECT 'Data Already Added'
	END CATCH

InserInstructorData 112,'ahmed','mohamed','from SP'

select * from Instructor

---Encyrpt
SP_HELPTEXT GetStudentData

ALTER PROC GetStudentData 
WITH Encryption
AS
	SELECT * FROM Student --- Or from View

SP_HELPTEXT GetStudentData

GetStudentData


 ---Output
CREATE PROC GetInstructorSalary @InstructorID INT ,@Salary Money Output,@FirstName NVARCHAR(50) Output
AS
SELECT @Salary = Salary ,@FirstName=FirstName
FROM Instructor 
WHERE Ins_ID = @InstructorID

DECLARE @SaL Money ,@FirsT NVARCHAR(50)

EXEC GetInstructorSalary 1,@Sal Output,@First Output

SELECT @SaL,@FirsT

select * from Instructor

select*from Instructor


 ---Dynamic Stored Proc
CREATE PROC DynamicSelect (@ColumnName NVARCHAR(MAX),@TableName NVARCHAR(MAX),@WhereClause NVARCHAR(MAX))
AS
	EXECUTE('SELECT '+@ColumnName+' FROM '+@TableName+' WHERE '+@WhereClause)
	
exec DynamicSelect '*','Instructor','1=1'
 
/*
| Feature              | Function                                | Stored procedure                                      |
| -------------------- | --------------------------------------- | ----------------------------------------------------- |
| Main purpose         | Calculate and return a value or table   | Perform a process or operation                        |
| Return value         | Must return a value or table            | Does not have to return anything                      |
| Parameters           | Input parameters only                   | Input and output parameters                           |
| Call syntax          | `SELECT dbo.FunctionName()`             | `EXEC ProcedureName`                                  |
| Modify tables        | Generally cannot modify database tables | Can `INSERT`, `UPDATE`, and `DELETE` , `SELECT`                  |
| Transactions         | Cannot use transaction control          | Can use `BEGIN TRANSACTION`, `COMMIT`, and `ROLLBACK` |
| Error handling       | Cannot use `TRY...CATCH` or `RAISERROR` | Can use `TRY...CATCH`, `RAISERROR`, and `THROW`       |
| Dynamic SQL          | Not allowed                             | Allowed                                               |
| Multiple result sets | No                                      | Yes                                                   |
| Stored location      | Database → Programmability → Functions  | Database → Programmability → Stored Procedures        |
*/

--------------------* Trigger
---After	 , Instead Of 
--Level	(Server , DB , Tables)

--After Insert

CREATE TRIGGER Insturctor_Select_trig
On Instructor
After Insert
AS
SELECT 'Welcome Instructor '+ FirstName from inserted
	
Insert Into Instructor (Ins_ID,FirstName) Values (114,'ali')

select * from Instructor


Alter Table Instructor Disable Trigger Insturctor_Select_trig

Alter Table Instructor Enable Trigger Insturctor_Select_trig

Drop Trigger Insturctor_Select_trig

--Trigger Prevent -ve Salary
Create Trigger PreventNegativeSalary
On Instructor
After Insert 
AS
Declare @Salary Money = (Select Salary From inserted)
IF @Salary < 0
BEGIN
	Raiserror ('Not Allowed to insert negative Salary',16,10)
	RollBack
END


SELECT * FROM Instructor

Insert Into Instructor (Ins_ID,Salary) Values (118,-11000)

/*
16 — Severity level

Severity indicates how serious the error is.

0–10: Informational message or warning
11–16: Errors caused by the user 
17–19: More serious system/resource errors
20–25: Fatal errors that may terminate the connection

16: General user-defined error, such as invalid input
So, 16 is suitable here because inserting a negative salary is invalid user input.

10 — State
State is a number from 0 to 255 that helps identify where the error originated.
*/

--After Update
Create Trigger instructorChanges
On instructor
After Update
AS
SELECT * FROM inserted
SELECT * FROM deleted

SELECT * FROM Instructor

Update Instructor
Set FirstName = 'ahmed'
Where Ins_ID = 100


Create Table AuditHistory
(
[UserName] Nvarchar(50),
Old_Value Nvarchar(50),
New_Value Nvarchar(50),
UpdatedColumn Nvarchar(50)
)

create or Alter Trigger SalaryTrack
On instructor
After Update 
AS
If UPDATE(Salary)
	BEGIN
		Declare @salaryOld money ,@salaryNew money
		Select @salaryOld =salary from deleted
		Select @salaryNew =salary from inserted

		Insert Into AuditHistory
		Values (SUSER_NAME(),@salaryOld , @salaryNew,'Salary')
	END

SELECT * FROM Instructor

Update Instructor
Set FirstName = 'Data'
Where Ins_ID = 100

Update Instructor
Set Salary = 7000
Where Ins_ID = 100


Select * From AuditHistory

--After Delete

-- Trigger InsteadOf INSERT
create or Alter TRIGGER InsteadOfInsertTrigger
ON Student
INSTEAD OF INSERT
AS
INSERT INTO AuditHistory 
VALUES (SUSER_NAME(),null ,null,COncat( 'Trying to Insert new ID =',  (select st_id from inserted)) )


Insert Into Student (St_ID , FirstName) Values (101,'ahmed')

SELECT * FROM AuditHistory

SELECT * FROM Student

SELECT * FROM AuditHistory


-- Trigger InsteadOf UPDATE
CREATE or alter TRIGGER InsteadOfUpdateTrigger
ON Student
INSTEAD OF UPDATE
AS
IF Update(DateOfBirth)
INSERT INTO AuditHistory 
VALUES (SUSER_NAME(),(select DateOfBirth from deleted) ,(select DateOfBirth from inserted),
Concat( 'Trying to Update St ID =',  (select st_id from inserted)) )

SELECT * FROM AuditHistory

UPDATE Student
SET DateOfBirth = '20000101'
WHERE St_ID = 2;

SELECT * FROM Student

SELECT * FROM AuditHistory


-- Trigger InsteadOf DELETE
CREATE or alter TRIGGER InsteadOfDeleteTrigger
ON Student
INSTEAD OF DELETE
AS
INSERT INTO AuditHistory 
VALUES (SUSER_NAME(),(select st_id from deleted) ,null,
Concat( 'Trying to Delete St ID =',  (select st_id from deleted)) )

SELECT * FROM AuditHistory

delete FROM Student

/*
This error means your InsteadOfDeleteTrigger expects only one deleted row, but the DELETE statement affected more than one row.
*/

SELECT * FROM Student

delete FROM Student where st_id = 100

SELECT * FROM AuditHistory

select * from Instructor

DELETE FROM Instructor
Output deleted.*
WHERE Ins_ID = 102

--Drop Trigger
--Enable/Disable

Alter Table Student Disable Trigger InsteadOfDeleteTrigger

Alter Table Student Enable Trigger InsteadOfDeleteTrigger

Drop Trigger InsteadOfDeleteTrigger

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* Group By Options (Group By, RollUp , Cube, Grouping Sets) *-------------------

TRUNCATE TABLE Sales
select * from Sales

INSERT INTO Sales
VALUES  (1,'ahmed',10),
		(1,'khalid',20),
		(1,'ali',45),
		(2,'ahmed',15),
		(2,'khalid',30),
		(2,'ali',20),
		(3,'ahmed',30),
		(4,'ali',80),
		(1,'ahmed',25),
		(1,'khalid',10),
		(1,'ali',100),
		(2,'ahmed',55),
		(2,'khalid',40),
		(2,'ali',70),
		(3,'ahmed',30),
		(4,'ali',90),
		(3,'khalid',30),
		(4,'khalid',90)

SELECT *  
	Into Pivoting 
FROM Sales 
PIVOT (SUM(Qty) FOR SalesName IN ([Ahmed],[Khalid],[Ali])) PVT --Must Use AliAS Name

SELECT * FROM Pivoting

--how to get the table
SELECT * FROM pivoting 
UNPIVOT (Qty FOR SalesName IN ([Ahmed],[Khalid],[Ali])) UNPVT
		
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT * FROM Sales

SELECT Prod_ID,SalesName,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY Prod_ID,SalesName


SELECT Prod_ID,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY ROLLUP(Prod_ID)

SELECT SalesName,Prod_ID,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY ROLLUP(Prod_ID,SalesName) --RollUp Working on first only rollup


SELECT SalesName,Prod_ID,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY ROLLUP(SalesName,Prod_ID) --RollUp Working on first only rollup


SELECT Prod_ID,SalesName,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY CUBE(Prod_ID,SalesName) --Work AS Rollup in 2 col


--grouping sets
SELECT Prod_ID,SalesName,SUM(Qty) AS "Quantities"
FROM Sales
GROUP BY GROUPING SETS(Prod_ID,SalesName)

SELECT ISNULL(Product,'') ,ISNULL( Sales,'-') , Quantities
FROM
(
	SELECT 
		Prod_ID as Product,SalesName As Sales,SUM(Qty) AS "Quantities"
	FROM 
		Sales
	GROUP BY 
		GROUPING SETS(Prod_ID,SalesName)
) as SalesData

/*
| Option          | Detail groups | Hierarchical subtotals | All combinations | Custom combinations |
| --------------- | ------------: | ---------------------: | ---------------: | ------------------: |
| `GROUP BY`      |           Yes |                     No |               No |                  No |
| `ROLLUP`        |           Yes |                    Yes |               No |                  No |
| `CUBE`          |           Yes |                    Yes |              Yes |                  No |
| `GROUPING SETS` |      Optional |               Optional |         Optional |                 Yes |

*/
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------* System Databses *-------------------
--((Master Database)):
--The master database is the most important system database in SQL Server. 
--It contains information about all the other databases on the server, 
--including database metadata, security information, and configuration settings. 
--It is created when SQL Server is installed and should not be deleted or modified.

--((Model Database)):
--The model database is used as a template for creating new databases. 
--When a new database is created, SQL Server uses the model database as a basis for the new database. 
--Therefore, any changes made to the model database will be reflected in all new databases created on the server.

--((MSDB Database)):
--The msdb database is used by SQL Server Agent to manage jobs, alerts, and operators. 
--It also stores information about backups and restores, maintenance plans, and other system activities.

--((TempDB Database)):
--The tempdb database is used to store temporary data. 
--such as temporary tables, stored procedure output, and other intermediate results. 
--It is recreated every time SQL Server is started and its contents are emptied when SQL Server is shut down.
