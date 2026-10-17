--Part 1: Using Ranking Function and CTE
--1 Retrieve the rank of each employee based on their salary, with ties given the same rank and no gaps in the ranking. (Display Emp_Id, Names , Salaries)

SELECT Emp_Id, FirstName , Salary,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
FROM Employee;

--2 Retrieve the rank of each employee based on their salary, with ties given the same rank and no gaps in the ranking portioned by Department id (Display Emp_Id, Names , Salaries, Dep_Id)


SELECT Emp_Id, FirstName ,Dep_ID, Salary,  
DENSE_RANK() OVER (PARTITION BY Dep_ID ORDER BY Salary DESC) AS Salary_Rank
FROM Employee;

--3 Retrieve the rank of each employee based on their age, with sequential/Serial rank in the ranking. (Display Emp_Id, Names , age)

SELECT Emp_ID, FirstName, Age,
ROW_NUMBER() OVER(ORDER BY Age) AS Serial
FROM Employee;

--4 Retrieve the rank of each employee based on their age, with sequential/Serial rank in the ranking portioned by Address (Display Emp_Id, Names , age, Address)

SELECT Emp_ID, FirstName, Age, Address,
ROW_NUMBER() OVER(PARTITION BY Address ORDER BY Age DESC) AS Serial
FROM Employee;

--5 Retrieve the grouping of each employee based on their department id, into 3 Groups (Display Emp_Id, Names , Dep_Id)

SELECT Emp_ID, FirstName, Dep_ID,
NTILE(3) OVER(PARTITION BY Dep_ID ORDER BY Dep_ID) AS Group_3
FROM Employee;

--6 From Query(3) Try to delete actual last employee ranked and make sure that table actually affected.

DECLARE @num_Of_DeletedRecords INT
WITH Query_3 AS 
(
SELECT * 
FROM (
    SELECT Emp_ID, FirstName, Age,
    ROW_NUMBER() OVER(ORDER BY Age ) AS Serial
    FROM Employee
    ) AS SelectedData
)
DELETE FROM Query_3 WHERE Serial = (SELECT MAX(Serial) FROM Query_3)
SELECT @num_Of_DeletedRecords = @@ROWCOUNT
	IF  @num_Of_DeletedRecords = 0
		SELECT  'No rows were deleted.'
	ELSE IF @num_Of_DeletedRecords =1
		SELECT  'One row was deleted.';

--Part 2: Using Schema & IF EXISTS
--7 Create a new schema named "HR" if it doesn't already exist, using the "IF NOT EXISTS" keyword to avoid errors if the schema already exists.
DROP SCHEMA HR;
IF NOT EXISTS(SELECT name FROM SYS.schemas WHERE name = 'HR')
    BEGIN
        EXEC('CREATE SCHEMA HR;')
    END
ELSE
    BEGIN
        PRINT  'SCHEMA ALREADY EXISTS'
    END;

--8 Transfer the tables "Student", "Instructor", and "Employee" to the new "HR" schema.

ALTER SCHEMA HR TRANSFER [dbo].[Student];
ALTER SCHEMA HR TRANSFER [dbo].[Instructor];
ALTER SCHEMA HR TRANSFER [dbo].[Employee];

--Part 3: Case, IIF
--9 Display Employee data , Gender in case of ‘M’ Display Male , ‘F’ Display Female.

SELECT *,
    CASE
    WHEN Gender = 'm' THEN 'Male'
    WHEN Gender = 'F' THEN 'Female'
    END AS Gender
FROM Employee;

--10 Using Case Statement to update Instuctor salary data Whithin value

UPDATE Instructor
SET Salary = (  
    CASE 
--salary less than 500 updated it by updated it by 10 %
        WHEN (Salary < 500) THEN Salary + (Salary * 10/100)
--salary Between 500 and 1000 updated it by updated it by 20 %
        WHEN (Salary > 500) AND (Salary < 1000) THEN (Salary + (Salary * 20/100)) 
--others updated it by 30 %
        ELSE Salary + (Salary * 30/100)
        END
        );

--Part 5: Variables, Select Into, Insert Based On Select
--11 Declare TempEmp Table Variable with EID , ESalary, FName

DECLARE @TempEmp Table (EID INT , ESalary FLOAT, FName NVARCHAR(50))

--12 Insert Data on it From Employee Table

INSERT INTO @TempEmp
    SELECT Emp_ID AS EID,
    Salary AS ESalary,
    FirstName AS FName
    FROM Employee;

--13 Try To Copy Department Table With All (Stucture and Data) With Named New_Department_Data

SELECT *
INTO New_Department_Data
FROM Department;

--14 Try To Copy Department Table With (Structure ONLY) With Named New_Department

SELECT *
INTO New_Department
FROM Department
WHERE 1 = 2;

--Part 6: Try Date Function

SELECT Dep_ID, Dep_Name,
(YEAR(GETDATE()) - YEAR(CreationDate)) AS Dep_Age,
YEAR(CreationDate) AS CREATION_YEAR
FROM Department