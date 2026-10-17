USE DEPI_System;

--1. Display all the employees Data.

SELECT * FROM Employee;

--2. Display the employee First name, last name, Salary and Department number.

SELECT FirstName, LastName, Salary FROM Employee;

--3. Display all the Departments names, isActive Status and the department which is
--responsible about it.

SELECT Dep_Name, IsActiveDep, Dep_Description FROM Department

--4. If you know that the company policy is to pay an annual commission for each
--employee with specific percent equals 10% of his/her annual salary .Display each
--employee full name and his annual commission in an ANNUAL COMM column
--(alias).

ALTER TABLE Employee
ADD ANNUAL_COMM Float;

UPDATE Employee
SET ANNUAL_COMM = Salary * 0.10;

SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS Full_Name, ANNUAL_COMM FROM Employee

--5. Display the employees Id, SSN, first name who earns more than 1000 LE
--monthly.

SELECT Emp_ID, SSN, FirstName FROM Employee
WHERE Salary + ANNUAL_COMM > 1000;

--6. Display the employees Id, SSN, first name who earns more than 10000 LE
--annually.

SELECT Emp_ID, SSN, FirstName FROM Employee
WHERE Salary + ANNUAL_COMM > 10000;

--7. Display the names (first, middle, last) As StudentFullName and salaries of the
--female employees

SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS StudentFullName, Salary FROM Employee
WHERE Gender = 'f';

--8. Display each department id, name which managed by a manager with id equals 1.

SELECT Dep_ID, Dep_Name FROM Department
WHERE ManagerID = 1;

--9. Dispaly the ids, names , Salaries of the employees worked on department 1.

SELECT Emp_ID, CONCAT(FirstName, ' ',MiddleName, ' ',LastName) AS Full_Name, Salary FROM Employee
WHERE Dep_ID = 1;
