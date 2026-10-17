--Part 1: Using Index
--1 Write this query : Select * From Employee, Display the actual execution plan and mention the scanning type.

Select *
From Employee;
--				Actual Execution Plan
-- SELECT <---- Compute Scalar <---- Clusterd Index Scan
--------------------------------------------------------
--		SCANNING TYPE -> CLUSTERED INDEX SCAN

--2 Create or use any table that doesn't have a primary key column. Then write:
--Select * From YourTable and Mention which scanning type is being used.

SELECT *
INTO Employee_HP
FROM Employee;

SELECT *
FROM Employee_HP;
--	SCANNING TYPE -> Table Scan

--3 Create an index on the column "Salary" that allows you to cluster the data in the "Employee" table. Describe the problem.

CREATE CLUSTERED INDEX Salary_CL
ON Employee(Salary);
-- Table already have an existing clustered index 'PK_Employee' so we can't create another one until we delete this one
-- clusterd index is limited to 1 per table

--4 Create a unique non-clustered index on the "Dep_ID" column in the "Employee" table. Describe the problem.

CREATE UNIQUE INDEX Dep_ID_U
ON Employee(Dep_ID);
-- The column is not uniqe it has duplicates so it can't have a unique index

--5 Create a non-clustered index on the "Dep_ID" column in the "Employee" table. Then, select Dep_ID from Employee.
--Trace the actual execution plan and mention the scanning type.

CREATE INDEX Dep_ID_U
ON Employee(Dep_ID)

SELECT Dep_ID
FROM Employee;
--			Actual Execution Plan
-- SELECT <---- INDEX SCAN (NON-CLUSTERD)
-----------------------------------------
--	SCANNING TYPE -> INDEX SCAN (NON-CLUSTERD)

--Part 2: View
--6 Create an encrypted view named “VW_EmployeeData” that displays "Employee" data for all columns except Salary.

GO
CREATE OR ALTER VIEW VW_EmployeeData
WITH ENCRYPTION
AS
SELECT [Emp_ID], [FirstName], [MiddleName], [LastName], [DateOfBirth],
		[Age], [SSN], [Address], [Gender], [Code], [Dep_ID],
		[HiringDate], [Manager_ID], [Pos_ID], [ANNUAL_COMM]
FROM Employee;
GO
SELECT * FROM VW_EmployeeData
GO

--7 Create a view named "VW_Department" that displays "Department" data and allows insert/update only for departments with
--"Dep_Code" values of "SD", "OS", or "BI".

-- You Mean Dep_Name >>> ???
CREATE OR ALTER VIEW VW_Department
AS
SELECT *
FROM Department
GO

CREATE OR ALTER TRIGGER T_VW_Department
ON VW_Department
INSTEAD OF INSERT, UPDATE
AS
	BEGIN
		IF EXISTS (SELECT * FROM INSERTED WHERE Dep_Name NOT IN ('SD', 'OS', 'BI'))
			BEGIN
				PRINT ('INSERT/UPDATE ON DEPARTMENTS OTHER THAN (SD, OS, BI) IS NOT ALLOWED')
			END
		ELSE
			BEGIN
				IF EXISTS (
					SELECT *
					FROM Department D
					INNER JOIN INSERTED I
						ON D.Dep_ID = I.Dep_ID
				)
				BEGIN
					UPDATE Department
					SET
						Dep_Name = I.Dep_Name,
						CreationDate = I.CreationDate,
						Dep_Code = I.Dep_Code,
						Dep_Description = I.Dep_Description,
						IsActiveDep = I.IsActiveDep,
						ManagerID = I.ManagerID
					FROM Department D
					INNER JOIN INSERTED I
						ON D.Dep_ID = I.Dep_ID
				END

				ELSE
					BEGIN
						INSERT INTO Department
						(Dep_ID, Dep_Name, CreationDate, Dep_Code, Dep_Description, IsActiveDep, ManagerID)
						SELECT
							Dep_ID, Dep_Name, CreationDate, Dep_Code, Dep_Description, IsActiveDep, ManagerID
						FROM INSERTED
					END

			END
	END

GO
SELECT * FROM VW_Department;
GO

--8 Create a view named "VW_EmployeeDepartment" that retrieves a list of all employees, including those who are assigned
--to a department (dep_Name) and those who are not.

CREATE VIEW VW_EmployeeDepartment
AS 
SELECT Emp_ID, FirstName, ISNULL(Dep_Name, 'NOT ASSIGNED') AS Dep_Name
FROM Employee E
LEFT JOIN Department D
ON E.Dep_ID = D.Dep_id;
GO

--9 Create a schema-bound and encrypted view named "VW_Student" for "Student" data, specifically columns "Id" and "Names".
--Then, create an Unique Clustered index on it (St_ID).

CREATE OR ALTER VIEW VW_Student
WITH SCHEMABINDING, ENCRYPTION 
AS
SELECT St_ID, [FirstName], [MiddleName], [LastName]
FROM DBO.Student
GO
CREATE UNIQUE CLUSTERED INDEX St_UCL
ON VW_Student (St_ID);
GO

--Part 3: Function
--10 Create a user-defined scalar function that accepts two parameters: an employee’s “EmployeeID" and a "Percentage" increase.
--The function should calculate and return the new salary after the increase is applied.

CREATE OR ALTER FUNCTION Emp_Bouns (@Emp_ID INT, @Percentage INT) 
RETURNS MONEY 
	BEGIN
		DECLARE @NEW_SALARY MONEY
		SELECT @NEW_SALARY = Salary + (Salary * @Percentage/100)
		FROM Employee 
		WHERE Emp_ID = @Emp_ID
	RETURN @NEW_SALARY
END;
GO
SELECT DBO.Emp_Bouns(2, 50) AS NEW_SALARY
GO

--11 Write an inline function in SQL Server that accepts a table-valued parameter and returns all rows where
--the gender column equals ‘m’ or ‘f’ (Parameter).

CREATE OR ALTER FUNCTION DBO.Employee_Gender_Search (@gender CHAR)
RETURNS TABLE
	AS
	RETURN(	
	SELECT * 
	FROM Employee
	WHERE Gender = @gender
)
GO
SELECT * FROM [dbo].[Employee_Gender_Search]('m')
GO

--12 Create a multi-statement table-valued function in SQL Server that accepts an integer parameter called empId.
--The function should return a table with three columns: EmployeeId, EmployeeSalary, and StatusMessage.
--If EmployeeSalary is less than 2000, the StatusMessage should be 'Low'; otherwise, it should be 'High'.

CREATE OR ALTER FUNCTION Emp_Info (@empId INT)
RETURNS TABLE
	AS
	RETURN(
	SELECT Emp_ID AS EmployeeId, Salary AS EmployeeSalary,
		CASE
		WHEN Salary < 2000 THEN 'Low'
		ELSE 'High'
		END AS StatusMessage
	FROM Employee
	WHERE Emp_ID = @empId
)
GO
SELECT * FROM Emp_Info(3)