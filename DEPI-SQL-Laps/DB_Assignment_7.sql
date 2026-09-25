--Part 1: Stored Proc
--1 Create a stored procedure that accepts an employee ID as input and returns the employee's manager data.

CREATE OR ALTER PROC ReturnEmpManager @empid INT
    AS
    BEGIN
        SELECT *
        FROM Employee
        WHERE Emp_ID = (SELECT Manager_ID
                        FROM Employee
                        WHERE Emp_ID = @empid)
    END;
EXEC ReturnEmpManager 2;
GO

--2 Create a encrypted stored procedure named "GetInstructorCourses" that takes "instructorId" as a parameter and retrieves a list of courses taught by the instructor.

CREATE OR ALTER PROC GetInstructorCourses @instructorId INT
    WITH ENCRYPTION
    AS
    BEGIN
        SELECT *
        FROM Course
        WHERE Crs_ID IN (SELECT Crs_ID 
                        FROM Instructor_Course
                        WHERE Ins_ID = @instructorId
                        )
    END;
EXEC GetInstructorCourses 1;
GO

--3 Create a stored procedure named "AddNewDepartment" that inserts data into all columns of the "Department" table, handles any errors that occur during insertion,
--  and displays an error message that reads "Error in data insertion in [exception error message]".

CREATE OR ALTER PROC AddNewDepartment (
                                        @Dep_ID INT,
                                        @Dep_Name NVARCHAR(50),
                                        @CreationDate DATETIME,
                                        @Dep_Code NVARCHAR(50),
                                        @Dep_Description NVARCHAR(50),
                                        @IsActiveDep INT,
                                        @ManagerID INT)
    AS 
    BEGIN
        BEGIN TRY
            INSERT INTO Department
            VALUES (@Dep_ID, @Dep_Name, @CreationDate, @Dep_Code, @Dep_Description, @IsActiveDep, @ManagerID)
        END TRY
        BEGIN CATCH
            PRINT 'Error in data insertion in ' + ERROR_MESSAGE()
        END CATCH
    END;
EXEC AddNewDepartment 4, 'System Admin', '2010-01-01 10:00:00.000', 'Code004', 'Learning', 1, 2
GO

--4 Create a stored procedure named "InsertEmployeeData" that inserts data into columns (Emp_Id,FirstName,Dep_Id) of the "Employee" table,
--  checks if the department id exists in the "Department" table before insertion,
--  and print message that reads "You are trying to assign an employee to an invalid department" if the department id does not exist.

CREATE OR ALTER PROC InsertEmployeeData @Emp_Id INT, @FirstName NVARCHAR(50), @Dep_Id INT
    AS
    BEGIN
        IF @Dep_Id IN (SELECT Dep_ID FROM Department) 
            BEGIN
                INSERT INTO Employee (Emp_ID, FirstName, Dep_ID)
                VALUES (@Emp_Id, @FirstName, @Dep_Id)
            END
        ELSE
            BEGIN
                PRINT 'You are trying to assign an employee to an invalid department'
            END
    END;
EXEC InsertEmployeeData 1234, 'Mohammad', 123
GO

--5 Write a SQL statement stored procedure named "DeleteDepartment" from the "Department" table (take depId as Parameter). If the department includes employees,
--  Remove them first before deleting the stored procedure.

CREATE OR ALTER PROC DeleteDepartment @depId INT
AS
    BEGIN
        IF @depId IN (SELECT Dep_ID FROM Employee)
            BEGIN
                DELETE FROM Employee WHERE Dep_ID = @depId
                DELETE FROM Department WHERE Dep_ID = @depId
            END
        ELSE
            BEGIN
                DELETE FROM Department WHERE Dep_ID = @depId
            END
    END
BEGIN TRANSACTION
    EXEC DeleteDepartment 2
ROLLBACK TRANSACTION
GO

--6 Create a stored procedure that takes the following parameters and performs a select action: ColumnName, TableName, and WhereCondition.

CREATE OR ALTER PROC Selector (
                                @ColumnName VARCHAR(50),
                                @TableName VARCHAR(50),
                                @WhereCondition VARCHAR(100))
AS
    BEGIN
        BEGIN TRY
            EXEC (
                ' SELECT ' + @ColumnName +
                ' FROM ' + @TableName +
                ' WHERE ' + @WhereCondition)
        END TRY
        BEGIN CATCH
            PRINT ERROR_MESSAGE()
        END CATCH
    END
EXEC Selector 'Dep_ID, Dep_Name, Dep_Code', 'Department', 'Dep_ID IN (1, 2, 3)'
GO

--Part 2: Grouping Options and Pivot
--7 Group the "Sales" table by "Prod_ID" ,"SalesName" using the "Rollup" operator.
--(Display SalesName, Prod_Id , Sum(Qty)



--8 Group the "Sales" table by "Prod_ID" and "SalesName" using the "Cube" operator.
--(Display Prod_ID,SalesName,SUM(Qty))



--9 Group the "Sales" table by "Prod_ID" and "SalesName" using the "Grouping Sets" operator.
--(Display Prod_ID,SalesName,SUM(Qty))



--10 Retrieve pivoting data for employee’s quantities (Ahmed, Khalid, Ali)



--Part 3: Trigger
--Ensure that you have an "AuditHistory" table (or create it) that contains the following columns: Old_Value Nvarchar(50), New_Value Nvarchar(50), UserName(250), and ChangedColumn Nvarchar(50).
--11 Create a trigger that automatically updates the "Qty" column in the "Product" table when a new record is inserted into the "Sales" table.



--12 Write a trigger that prevents insertion into the "Instructor" table.



--13 Design a trigger that captures changes made to the "Price" column of the "Course" table during an update and saves the changes to the "AuditHistory" table.



--14 Write a trigger that prevents any deletions from the "Department" table.


