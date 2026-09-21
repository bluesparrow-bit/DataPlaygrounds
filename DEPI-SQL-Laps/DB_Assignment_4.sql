USE DEPI_System;

--Part 1: Using Aggregate Functions
--1-List the course name and average Hour_Rate for each course, but only if Hour_Rate is not NULL.

SELECT Crs_Name, AVG(I.HourRate) As Hour_Rate
FROM Course C
JOIN Instructor_Course I
ON C.Crs_ID = I.Crs_ID
GROUP BY(Crs_Name)
HAVING AVG(I.HourRate) IS NOT NULL;

--2-Retrieve the department name, maximum, minimum, and average salary of its employees, and the number of employees in each department.

SELECT Dep_Name,
		MAX(Salary) AS Max_Salary,
		MIN(Salary) AS Min_Salary,
		AVG(Salary) AS Avg_Salary,
		COUNT(E.Emp_ID) AS Emp_Count
FROM Department D
LEFT JOIN Employee E
ON D.Dep_ID = E.Dep_ID
GROUP BY Dep_Name;

--3-Retrieve the total salaries for employees over 50 years old in a department, but only if the total salaries exceed 3,500.

SELECT
    D.Dep_Name,
    SUM(E.Salary) AS Total_Salaries
FROM Employee AS E
LEFT JOIN Department AS D
    ON E.Dep_ID = D.Dep_ID
WHERE E.Age > 50
GROUP BY D.Dep_Name
HAVING SUM(E.Salary) > 3500;

--Part 2: Using Subqueries
--4-Display all employee data if their salary is less than the average salary of all employees.

SELECT *
FROM Employee
WHERE Salary < (SELECT AVG(Salary)
				FROM Employee);

--5-Display employee addresses where the average salary for that address is less than the average salary for all employees.

SELECT Address, AVG(Salary) AS Avg_Salary
FROM Employee
GROUP BY (Address)
HAVING AVG(Salary) < (SELECT AVG(Salary)
				FROM Employee);

--Part 3: Using Transaction
--6-Insert employees’ data with valid and invalid department IDs, and handle any errors that occur during the transaction. 
--The data should be logged in the Employee Table, and all errors should be displayed.

BEGIN TRY
	BEGIN TRANSACTION
	INSERT INTO Employee ( FirstName, DateOfBirth, Salary)
	VALUES ('Tamer', '2005-09-17', 3060)
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
	SELECT ERROR_NUMBER() AS ERROR_NUM, ERROR_LINE() AS ERROR_LINE, ERROR_MESSAGE() AS ERROR_MESSAGE
END CATCH;

--Part 4: Using Union Operations
--7-Combine salary data for employees and instructors over 25 years old using
--a-Union,

SELECT Salary, Age
FROM Employee
WHERE Age > 25
UNION
SELECT Salary, Age
FROM Instructor
WHERE Age > 25;

--b-Union All,

SELECT Salary, Age
FROM Employee
WHERE Age > 25
UNION ALL
SELECT Salary, Age
FROM Instructor
WHERE Age > 25;

--c-Intersect,

SELECT Salary, Age
FROM Employee
WHERE Age > 25
INTERSECT
SELECT Salary, Age
FROM Instructor
WHERE Age > 25;

--d-and except.

SELECT Salary, Age
FROM Employee
WHERE Age > 25 AND Age IS NOT NULL
EXCEPT
SELECT Salary, Age
FROM Instructor
WHERE Age > 25;

--Part 5: Using Built-in Functions and Global Variables
--8-Use at least 5 SQL built-in functions or global variables, such as CONCAT(), GETDATE(), LEN(),
--@@VERSION, and SUBSTRING(), and describe their functionality.

SELECT Suser_name() AS User_Name, db_name() AS DB_name, @@VERSION AS MSSQL_Version;
--Suser_name()-> RETURNS USER NAME
--db_name()-> RETURNS DATABASE NAME
--@@VERSION-> RETURNS MSSQL VERSION
SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS Full_Name,
			YEAR(GETDATE()) - YEAR(DateOfBirth) AS Calculate_Age, AGE
FROM Employee;
--CONCAT()-> CONCATENATES MULTIPLE STRINGS AND HANDELS NULL VALUES
--GETDATE()-> RETURNS THE CURRENT DATE
--YEAR()-> RETURNS THE YEAR FROM A DATE

--Part 6: Bonus
--9-Display the employee payslip by combining the salary, bonus, and HourRate columns from the 
--Bonus table into a single column called "EmployeePayslip".


SELECT Emp_ID, ISNULL(B.Salary, 0) + ISNULL(B.Bouns, 0) + ISNULL(B.HourRate, 0) AS EmployeePayslip
FROM Employee E
LEFT JOIN Bouns B
ON E.Emp_ID = B.ID
