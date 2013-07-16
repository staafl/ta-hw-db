CREATE DATABASE TEST
GO
USE TEST
GO

CREATE TABLE Persons
(
  Id INT IDENTITY PRIMARY KEY,
  FirstName NVARCHAR(32) NOT NULL,
  LastName NVARCHAR(32) NOT NULL,
  SSN CHAR(9) NOT NULL
)

CREATE TABLE Accounts
(
  Id INT IDENTITY PRIMARY KEY,
  PersonId INT NOT NULL FOREIGN KEY REFERENCES Persons(Id),
  Balance MONEY NOT NULL
)

INSERT Persons VALUES('John','Smith','012345678')
INSERT Persons VALUES('Mary','Sue','012345678')
INSERT Persons VALUES('Jane','Doe','012345678')

INSERT Accounts VALUES(1, 1000)
INSERT Accounts VALUES(1, -1000)
INSERT Accounts VALUES(2, 320)
INSERT Accounts VALUES(3, 0)
INSERT Accounts VALUES(3, 1200)
GO

-- 2 Create a stored procedure that accepts a number as a parameter and returns all persons who have more money in their accounts than the supplied number.

CREATE PROC usp_FindBalanceOver(@minimumBalance MONEY)
AS
  SELECT *
  FROM Persons JOIN Accounts ON Persons.Id = PersonId
  WHERE Balance > @minimumBalance
GO

EXEC usp_FindBalanceOver 0
EXEC usp_FindBalanceOver 600
EXEC usp_FindBalanceOver 1320
GO

-- 3 Create a function that accepts as parameters - sum, yearly interest rate and number of months. It should calculate and return the new sum. Write a SELECT to test whether the function works as expected.

CREATE FUNCTION dbo.udf_FinalSum(@initialSum MONEY, @yearlyInterestRate FLOAT, @months INT)
    RETURNS MONEY
AS
BEGIN
    DECLARE @monthlyInterestRate FLOAT
    SET @monthlyInterestRate = POWER(1 + @yearlyInterestRate, 1/12.0) - 1
    RETURN @initialSum*POWER(1+@monthlyInterestRate, @months)
END
GO

SELECT *, dbo.udf_FinalSum(initialSum, yearlyInterestRate, months)
FROM (
    VALUES (100, 0.10, 12),
           (100, 0.20, 12),
           (100, 0.20, 18),
           (100, 0.20, 24)
           ) AS Arguments(initialSum, yearlyInterestRate, months)
GO

-- 4 Create a stored procedure that uses the function from the previous example to give an interest to a person's account for one month. It should take the AccountId and the interest rate as parameters.

CREATE PROC usp_CreditAccountInterest(@AccountId INT, @yearlyInterestRate MONEY)
AS
    UPDATE Accounts
    SET Balance = dbo.udf_FinalSum(Balance, @yearlyInterestRate, 1)
    WHERE Id = @AccountId
GO

-- 5 Add two more stored procedures WithdrawMoney( AccountId, money) and DepositMoney (AccountId, money) that operate in transactions.

CREATE PROC usp_WithdrawMoney(@AccountId INT, @amount MONEY)
AS
    BEGIN TRAN
        UPDATE Accounts
        SET Balance = Balance - @amount
        WHERE Id = @AccountId
    COMMIT
GO

CREATE PROC usp_DepositMoney(@AccountId INT, @amount MONEY)
AS
    BEGIN TRAN
        UPDATE Accounts
        SET Balance = Balance + @amount
        WHERE Id = @AccountId
    COMMIT
GO

-- 6 Create another table - Logs(LogID, AccountID, OldSum, NewSum). Add a trigger to the Accounts table that enters a new entry into the Logs table every time the sum on an account changes.

CREATE TABLE Logs
(
    Id INT IDENTITY PRIMARY KEY,
    AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
    OldSum MONEY NOT NULL,
    NewSum MONEY NOT NULL
)
GO

CREATE TRIGGER tr_LogBalanceChange ON Accounts FOR UPDATE
AS
    INSERT dbo.Logs VALUES (
        SELECT inserted.Id, deleted.Balance, inserted.Balance
        FROM deleted JOIN inserted ON deleted.Id = inserted.Id
    )
GO

UPDATE Accounts SET Balance = Balance * 2
GO

-- problems 7-10 are based on ideas I saw in the forum

-- 7 Define a function in the database TelerikAcademy that returns all Employee's names (first or middle or last name) and all town's names that are comprised of given set of letters. Example 'oistmiahf' will return 'Sofia', 'Smith', ... but not 'Rob' and 'Guy'.

USE TelerikAcademy
GO

CREATE ASSEMBLY SqlRegularExpressions
FROM 'd:\telerik academy\db\homework\4-t-sql\SqlRegularExpressions.dll'  --change path to dll
WITH PERMISSION_SET = SAFE
GO

CREATE FUNCTION RegExpLike(@Text nvarchar(MAX), @Pattern nvarchar(255)) RETURNS BIT
AS EXTERNAL NAME SqlRegularExpressions.SqlRegularExpressions.[LIKE]
GO

CREATE FUNCTION udf_AllMatchingNames(@letters VARCHAR(32))
RETURNS @Names TABLE ( Name VARCHAR(32) )
AS
BEGIN
    INSERT @Names
    SELECT * FROM (
        SELECT FirstName FROM Employees
        UNION ALL
        SELECT LastName FROM Employees
        UNION ALL
        SELECT Name FROM Towns
    ) AS Temp(Name)
    WHERE 1 <> dbo.RegExpLike(Name, '[^' + LOWER(@letters) + ']')
    RETURN
END

GO

sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

SELECT * FROM udf_AllMatchingNames('oistmiahf')

GO

-- 8 Using database cursor write a T-SQL script that scans all employees and their addresses and prints all pairs of employees that live in the same town.

DECLARE cursor CURSOR READ_ONLY FOR
SELECT e.FirstName, e.LastName, t.Name,
       o.FirstName, o.LastName
FROM Employees e
JOIN Addresses a
ON a.AddressID = e.AddressID
JOIN Towns t
ON t.TownID = a.TownID,
Employees o
JOIN Addresses a1
ON a1.AddressID = o.AddressID
JOIN Towns t1
ON t1.TownID = a1.TownID

OPEN cursor
DECLARE @firstName1 NVARCHAR(32)
DECLARE @lastName1 NVARCHAR(32)
DECLARE @town NVARCHAR(32)
DECLARE @firstName2 NVARCHAR(32)
DECLARE @lastName2 NVARCHAR(32)
FETCH NEXT FROM cursor
INTO @firstName1, @lastName1, @town, @firstName2, @lastName2

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @firstName1 + ' ' + @lastName1 +
          '     ' + @town + '      ' + @firstName2 + ' ' + @lastName2

    FETCH NEXT FROM cursor
    INTO @firstName1, @lastName1, @town, @firstName2, @lastName2
END

CLOSE cursor
DEALLOCATE cursor
GO

-- 9 * Write a T-SQL script that shows for each town a list of all employees that live in it. Sample output:
-- Sofia -> Svetlin Nakov, Martin Kulov, George Denchev
-- Ottawa -> Jose Saraiva

CREATE TABLE #Temp
(
    ID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(64) NOT NULL,
    TownName NVARCHAR(32) NOT NULL
)

INSERT INTO #Temp
SELECT e.FirstName + ' ' + e.LastName as FullName, t.Name as TownName
FROM Employees e
JOIN Addresses a ON a.AddressID = e.AddressID
JOIN Towns t ON t.TownID = a.TownID
GROUP BY t.TownID, t.Name, e.EmployeeId, e.FirstName, e.LastName

DECLARE @name NVARCHAR(64)
DECLARE @town NVARCHAR(32)

DECLARE cursor1 CURSOR READ_ONLY FOR
SELECT DISTINCT TownName
FROM #Temp

OPEN cursor1
FETCH NEXT FROM cursor1
INTO @town

-- nested loops with separate cursors
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @town

    DECLARE cursor2 CURSOR READ_ONLY FOR
    SELECT ut.FullName
    FROM #Temp
    WHERE TownName = @town
    
    OPEN cursor2

    FETCH NEXT FROM cursor2
    INTO @name

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '   ' + @name
        FETCH NEXT FROM cursor2 INTO @name
    END

    CLOSE cursor2
    DEALLOCATE cursor2
    FETCH NEXT FROM cursor1 INTO @town
END

CLOSE cursor1
DEALLOCATE cursor1

DROP TABLE #TEMP

GO

-- 10 Define a .NET aggregate function StrConcat that takes as input a sequence of strings and return a single string that consists of the input strings separated by ','. For example the following SQL statement should return a single string:
-- SELECT StrConcat(FirstName + ' ' + LastName)
-- FROM Employees

sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

CREATE ASSEMBLY SqlRegularExpressions
FROM 'd:\telerik academy\db\homework\4-t-sql\SqlConcatenate.dll'  --change path to dll
WITH PERMISSION_SET = SAFE
GO

CREATE AGGREGATE StrConcat(@input nvarchar(100))
RETURNS nvarchar(max)
EXTERNAL NAME SqlConcatenate.Concat;
GO


SELECT dbo.STRCONCAT(FirstName + ' ' + LastName) FROM Employees

