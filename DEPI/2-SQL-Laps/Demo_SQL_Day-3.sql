-- Create,Use,Drop =>> Database
--**********Create**********
create Database Test

--**********Use**********
USE Test;

--**********Drop**********
USE master;

ALTER DATABASE Test
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

DROP DATABASE Test;
--**************************************

-- Create,drop =>> Schemas
--**********Create**********
CREATE SCHEMA HR;
GO

CREATE SCHEMA Sales;
GO

--**********drop**********
DROP SCHEMA Sales;
GO
--**************************************

-- DDL "Create,Alter,Truncate,Drop,Select Into" =>> Tables
--**********Create**********
CREATE TABLE HR.Employees
(
    EmployeeID INT PRIMARY KEY identity(1,1),
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10,2)
);
GO

INSERT INTO HR.Employees
VALUES
('Ahmed', 10000),
('Sara', 12000),
('Omar', 9000);
GO

select * from HR.Employees

--**********FK**********
CREATE TABLE Parent
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Code NVARCHAR(50) NOT NULL,
    Gender CHAR(1),
    DOB DATE
);
GO

CREATE TABLE Child
(
    ChildID INT PRIMARY KEY IDENTITY(10,10),
    FullName NVARCHAR(50),
    ParentID INT NULL,
    CAdd NVARCHAR(50),

    CONSTRAINT Par_FK
        FOREIGN KEY (ParentID)
        REFERENCES Parent(ID)
        ON DELETE CASCADE
        ON UPDATE SET NULL
);
GO
--**************************************

--**********Alter**********
--Add a new column
ALTER TABLE HR.Employees
ADD NetSalary DECIMAL(10,2)

--Change a column "size,DT"
ALTER TABLE HR.Employees
ALTER COLUMN EmployeeName int;

--Drop a column
ALTER TABLE HR.Employees
DROP COLUMN NetSalary;

--Drop a CONSTRAINT
ALTER TABLE Child
DROP CONSTRAINT Par_FK;
--**************************************

--**********Truncate**********
Truncate table HR.Employees
--**************************************

--**********Drop**********
drop TABLE HR.Employees
--**************************************

--**********Select Into**********
SELECT EmployeeID, EmployeeName, Salary
INTO HR.Employees_Backup
FROM HR.Employees;
Go

select * from HR.Employees_Backup
--**************************************

-- Create,Drop,Permission =>> Users
--**********create**********
CREATE LOGIN Student1
WITH PASSWORD = '12345';

USE Test;
GO

CREATE USER Student1
FOR LOGIN Student1;
GO

--**************************************

--**********Drop**********
SELECT
    s.name AS SchemaName,
    USER_NAME(s.principal_id) AS OwnerName
FROM sys.schemas s
WHERE USER_NAME(s.principal_id) = 'Student1';

ALTER AUTHORIZATION
ON SCHEMA::HR
TO dbo;
GO

Drop USER Student1
go
--**************************************

SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE login_name = 'Student1';

KILL 57;

Drop LOGIN Student1
go
--**************************************

--**********Permission**********

--**********GRANT**********
GRANT SELECT
ON SCHEMA::HR
TO Student1;

GRANT SELECT, INSERT, UPDATE,delete
ON HR.Employees
TO Student1;
GO

SELECT SUSER_NAME();

select * from HR.Employees

select * from HR.Employees_Backup
--**************************************

--**********DENY**********
DENY DELETE
ON dbo.Employees
TO Student1;
GO
--**************************************

--**********REVOKE**********
REVOKE SELECT
ON SCHEMA::HR
TO Student1;

REVOKE SELECT
ON HR.Employees
FROM Student1;
GO
--**************************************


-- DML "Insert,Update,Delete," =>> Data

--**********Insert**********
insert into Employee
values (5,'noha','n',100)

insert into Employee (SSN,EmployeeName)
values (6,'alia')

-- Row Constructor Insert
insert into Employee
values (7,'noha','n',100),
    	(8,'noha','n',100)
--**************************************

--**********Update**********
update Employee
set Code ='noha' --??

update Employee
set Code ='noha'
where Code ='n'
--**************************************

--**********delete**********
delete from Employee --??

delete from Department
where Dep_Id = 300

delete from Department
where Dep_Id = 100

	-- Delete Related Table By FK
    -- Cascade
	-- No Action
	-- Set Null
	-- Set Deafult
--**************************************

--**********Drop - Delete - Truncate**********
Drop table Employee

delete from Employee

truncate table Employee
--**************************************

--DQL "Select" =>> Data

--Select Specific Columns
select Dep_Code
from Department


select FirstName,MiddleName,LastName,Salary
from Instructor

--Select All Columns
select *
from Instructor

--Where Number
select *
from Instructor
where Ins_ID = 6

--Where Text
select *
from Instructor
where Gender = 'm'

-- Random Select With Top
select top 2 *
from Instructor
order by  NEWID()

-- Order By
select *
from Instructor
order by FirstName desc

-- Remove Duplicate Values From Select
select distinct MiddleName
from Instructor

-- Is Null 
select *
from Instructor
where FirstName Is Null

-- Is Not Null
select *
from Instructor
where FirstName Is Not Null

--Mathimatical Opertaor
-- < , > , = 
select *
from Instructor
where Salary = 6000

select *
from Instructor
where Salary > 6000

select *
from Instructor
where Salary >= 6000

select *
from Instructor
where Salary < 6000

select *
from Instructor
where Salary <= 6000

--Logical Opertaor And , OR , IN , Not IN , Between ,Not Between
-- OR 
select *
from Instructor
where Salary <= 6000
OR Gender ='m'

-- AND
select *
from Instructor
where Salary <= 6000
AND Gender ='m'

--IN
select *
from Instructor
where Salary = 5000.00
Or Salary =1500
Or Salary =800

select *
from Instructor
where Salary IN (5000,1500,800)

--Not In
select *
from Instructor
where Salary Not IN (5000,1500,800)

--Between
select *
from Instructor
where DateOfBirth Between '1990' and '2020'

--Not Between
select *
from Instructor
Where DateOfBirth Not Between '1990' and '2020'


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** Joins (Excel) *****---------------------------------------------------
--Cross [Cartesiant Product]		--Inner [Equi Join]		--Outer Join		--Self Join [Recursive]
															--* Right 
															--* Left
															--* Full
--------------------* Inner Join *-------------------
SELECT * FROM Employee

SELECT * FROM Department

--Alias
select emp.FirstName,emp.MiddleName,emp.LastName , dep.Dep_Name
from Employee as emp
inner join Department as dep
on -- PK = FK
dep.Dep_ID = emp.Dep_ID


select emp.FirstName+' '+emp.MiddleName+' '+emp.LastName , dep.Dep_Name
from Employee as emp
inner join Department as dep

on -- PK = FK
dep.Dep_ID = emp.Dep_ID

select emp.FirstName+' '+emp.MiddleName+' '+emp.LastName as EmployeeFullName , dep.Dep_Name
from Employee as emp
inner join Department as dep

on -- PK = FK
dep.Dep_ID = emp.Dep_ID

--ISNULL Function
select ISNULL( emp.FirstName,'no first')+' '+ ISNULL(emp.MiddleName,'no middle')+' '+ ISNULL(emp.LastName,'no last') as EmployeeFullName , dep.Dep_Name
from Employee as emp
inner join Department as dep

on -- PK = FK
dep.Dep_ID = emp.Dep_ID

--Inner Join More Than Two Tables
select st.FirstName , crs.Crs_Name , st_crs.Grade
from Student as st
	inner join Student_Course as st_crs
on st.St_ID = st_crs.St_ID

	inner join Course as crs
on crs.Crs_ID = st_crs.Crs_ID

--------------------* Left Outer Join *-------------------
select ISNULL( emp.FirstName,'no first')+' '+ ISNULL(emp.MiddleName,'no middle')+' '+ ISNULL(emp.LastName,'no last') as EmployeeFullName , dep.Dep_Name
from Employee as emp
left outer join Department as dep

on -- PK = FK
dep.Dep_ID = emp.Dep_ID

--------------------* Right Outer Join *-------------------
select ISNULL( emp.FirstName,'no first')+' '+ ISNULL(emp.MiddleName,'no middle')+' '+ ISNULL(emp.LastName,'no last') as EmployeeFullName , dep.Dep_Name
from Employee as emp
right outer join Department as dep

on -- PK = FK
dep.Dep_ID = emp.Dep_ID

--------------------* Full Outer Join *-------------------
select ISNULL( emp.FirstName,'no first')+' '+ ISNULL(emp.MiddleName,'no middle')+' '+ ISNULL(emp.LastName,'no last') as EmployeeFullName , dep.Dep_Name
from Employee as emp
full outer join Department as dep
on -- PK = FK
dep.Dep_ID = emp.Dep_ID

--------------------* Self Join *-------------------
select  emp.FirstName As EmployeeName, mgr.FirstName As ManagerName
from Employee as emp
inner join Employee as mgr
on mgr.Emp_ID = emp.Manager_ID


select  st.FirstName as StudentName, super.FirstName As SuperName
from Student as st
inner join Student as super
on st.Supervisor_ID = super.St_ID

--------------------* Self Join - Left *-------------------
select  emp.FirstName As EmployeeName, mgr.FirstName As ManagerName
from Employee as emp
Left Outer join Employee as mgr
on mgr.Emp_ID = emp.Manager_ID


--------------------* Cross Join *-------------------
SELECT *
FROM Employee CROSS JOIN Department

--------------------* Joins - DML *-------------------
SELECT *
from Instructor ins Inner Join Instructor_Course ic
On ins.Ins_ID = ic.Ins_ID
Inner Join Course c
On c.crs_id =ic.Crs_ID
Where ins.Address='cairo'

Update Instructor_Course 
SET HourRate = ic.HourRate+10
from Instructor ins Inner Join Instructor_Course ic
On ins.Ins_ID = ic.Ins_ID
Inner Join Course c
On c.crs_id =ic.Crs_ID
Where ins.Address='cairo'

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


--------------------------------------------------
--'%[_]__' Start With Any , Last Char Before Last 2 is under score
SELECT *
FROM Employee--Like Patterns
-- '___'	Len 3 Char
SELECT *
FROM Employee
WHERE FirstName Like '___'

--------------------------------------------------
-- '%'		Any
-- '%a_'	Any and Char Before Last is a
SELECT *
FROM Employee
WHERE FirstName Like '%a_'

--------------------------------------------------
--'a%'	Start With a and ended by Any
SELECT *
FROM Employee
WHERE middlename Like 'a%'

--------------------------------------------------
--'[abm]%'  Start by A or B or M ,and ended by Any 
SELECT *
FROM Employee
WHERE FirstName Like '[abm]%'

--------------------------------------------------
--'[^abm]%' NOT Start by A or B or M and ended by Any 
SELECT *
FROM Employee
WHERE FirstName Like '[^abm]%'

--'[159]%'  Start by 1 or 5 or 9 and ended by Any 

--------------------------------------------------
--'[a-m]%'  (From A to M) and ended by Any
SELECT *
FROM Employee
WHERE FirstName Like '[a-m]%'

--------------------------------------------------
--'[^a-m]%' (Not From A to M) and ended by Any
SELECT *
FROM Employee
WHERE FirstName Like '[^a-m]%'

--------------------------------------------------
--'%[_]%'   Start By Any 
--'%[%]'    Start by Any and Last Char is %
SELECT *
FROM Employee
WHERE FirstName Like '%[_]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------**** DB Integrity (PowerPoint)*****---------------------------------------------------
				--Domain Integrity------------------Entity Integrity-----------------Referential Integrity
--Constraint	--Data Type							PK								 FK
------------	--Default							Unique
------------	--NULL , NOT NULL

--DB Object		--Rule								Index							Trigger	
------------	--Trigger							Trigger
---------------------------------------------------------------------------------------------------------
	--Create Table Codes [Derived]
	--Constraint
			-- Check
			-- Default
			-- Null , Not Null
			-- Data Type
			-- Unique
			-- PK
			-- FK 
Create table Parent
(
ID int Primary key identity (1,2),
Code nvarchar not null,
Geneder char(1) default 'm',
code_unique char(1) unique ,
DOB date,
--Age AS (DateDiff(year,DOB,GETDATE())),
Age AS Year(Getdate())- Year (DOB),
PAdd nvarchar (50) check (PAdd in ('alex','cairo'))
)

drop table child

Create Table Child
(
ChildID Int Not NULL,
FullName NVARCHAR (50),
ParentID INT,
CAdd NVARCHAR (50),
--Default
Gender Char(1) CONSTRAINT Def_Male Default  'M',
Code Char(5),
--Constraint Name Type Column
Degree NVARCHAR(50),
--PK
CONSTRAINT PK_ChildID Primary Key (ChildID),
--FK
CONSTRAINT Dep_FK FOREIGN KEY(ParentID) REFERENCES Parent(ID)
ON Delete Cascade
ON Update Set NULL,
--Check
CONSTRAINT Chk_Add Check(CAdd IN ('Alex','Cairo')),
--Unique
CONSTRAINT Uq_Code Unique  (Code)
)

ALTER Table Child
ADD Constraint Chk_Degree Check (Len(Degree) > 3)

ALTER Table Child
DROP Constraint Chk_Degree



-- Get Info About Table Constraint
SP_HELPCONSTRAINT Child

Create Table StudenParent
(
ParentID Int Primary Key IDentity (1,1),
[Name] Nvarchar(50)
)

Create Table StudentData
(
ID Int Primary Key IDentity (1,1),
DOB Date NOT NULL,
Age AS Year(Getdate())- Year (DOB),
Code Nvarchar(50),
Gender Char(1) Default ('M'),
StudentType NVarchar(10),
Rate int,
Parent_ID INT,

-- Constraint Constraint_Name TypeOfConstraint 
Constraint Chk_Code Check( Code IN ('a','b')),

Constraint Chk_Type Unique (StudentType),

Constraint FK_Parent  foreign key (Parent_ID)  references  StudenParent(ParentID)
)
-- Alter Table Add Constraint
Alter table StudentData
add Constraint Unique_Rate Unique(Rate)

-- Drop Constraint
Alter table StudentData
Drop Constraint Unique_Rate

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------****      Rule     *****---------------------------------------------------
--------------------* Rule Usage *-------------------
--Due to Constraint Applied Both for Old and New Data
--Rule used for applied validation on NEW data Only

--------------------* Create Rule
Create RULE ValidateSalary As @Sal > 1000

--------------------* Bind Rule
SP_BindRule ValidateSalary ,'Instructor.Salary'

--------------------* UnBind Rule
SP_UNBindRule 'Instructor.Salary'

--------------------* DROP Rule
DROP Rule ValidateSalary

--------------------* Create Default
Create Default Def_Code AS 500

--------------------* Bind Default
SP_Bindefault Def_Code ,'Student.Code'

--------------------* UnBind Default
SP_UnBindefault 'Student.Code'

--------------------* DROP Default
DROP Default Def_Code

--------------------* Complex or New Data Type (Bind Rule , Default On Data Type)
Create RULE ValidateSalary As @Sal > 1000

Create Default Def_Code AS 500

SP_AddType NewIntDataType ,'int'

SP_BindRule ValidateSalary,NewIntDataType
SP_Bindefault Def_Code,NewIntDataType

--Use New Type on Table Creation
Create table Staff
(
ID int,
FullName Nvarchar(50),
Rate NewIntDataType
)