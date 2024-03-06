--*************************************************************************--
-- Title: Assignment06
-- Author: BLeBlanc
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,BLeBlanc,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_BLeBlanc')
	 Begin 
	  Alter Database [Assignment06DB_BLeBlanc] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_BLeBlanc;
	 End
	Create Database Assignment06DB_BLeBlanc;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_BLeBlanc;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Create basic view for Categories

CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName AS [Category Name]
FROM dbo.Categories
;
go

SELECT * 
FROM vCategories
;
go

--Create basic view for Products

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName AS [Product Name], CategoryID, UnitPrice AS [Unit Price]
FROM dbo.Products
;
go

SELECT * 
FROM vProducts
;
go
--Create basic view for Employees

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName AS [Employee First Name], EmployeeLastName AS [Employee Last Name], ManagerID
FROM dbo.Employees
;
go

SELECT * 
FROM vEmployees
;
go


--Create basic view for Inventories

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate AS [Inventory Date], EmployeeID, ProductID, Count
FROM dbo.Inventories
;
go

SELECT * 
FROM vInventories
;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Restrict permissions to Categories table, grant permissions to Categories basic view
DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;

--Check permissions
SELECT * FROM Categories;
SELECT * FROM vCategories;

--Restrict permissions to Products table, grant permissions to Products basic view
DENY SELECT ON Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;

--Restrict permissions to Employees table, grant permissions to Employees basic view
DENY SELECT ON Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;

--Restrict permissions to Inventories table, grant permissions to Inventories basic view
DENY SELECT ON Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;





-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Create view combining Category and Product tables

CREATE VIEW vProductsByCategories
WITH SCHEMABINDING
AS
SELECT TOP 1000000
	   c.[Category Name]
     , p.[Product Name]
	 , p.[Unit Price]
FROM dbo.vCategories as c
INNER JOIN dbo.vProducts as p
ON c.CategoryID = p.CategoryID
ORDER BY [Category Name]
		,[Product Name] ASC
;
go



--Verify view
SELECT * FROM vProductsByCategories;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


--Create view
CREATE VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING
AS
SELECT TOP 1000000
      
	   p.[Product Name]
	 , i.[Inventory Date]
	 , i.[Count]
FROM dbo.vInventories as i
INNER JOIN dbo.vProducts as p
ON i.ProductID = p.ProductID
ORDER BY i.[Inventory Date]
		,p.[Product Name] ASC
;
go

--Verify view and add in ordering by Product Name and Inventory Date
SELECT * FROM vInventoriesByProductsByDates
ORDER BY [Product Name]ASC
	   , [Inventory Date] ASC
;
go






-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth



CREATE VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING
AS
SELECT DISTINCT i.[Inventory Date]
               ,[Employee Name] =  e.[Employee First Name] + ' ' + e.[Employee Last Name]
FROM dbo.vInventories as i
INNER JOIN dbo.vEmployees as e
ON i.EmployeeID = e.EmployeeID
;
go


--Verify view and add in ordering by Inventory Date
SELECT * FROM vInventoriesByEmployeesByDates
ORDER BY [Inventory Date] ASC
;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


CREATE VIEW vInventoriesByProductsByCategories
AS
SELECT c.[CategoryName]
     , p.[ProductName]
	 , i.[InventoryDate]
	 , i.[Count]
FROM dbo.Inventories as i
INNER JOIN dbo.Products as p
ON i.ProductID = p.ProductID
INNER JOIN Categories as c
ON c.CategoryID = p.CategoryID

;
go

--Verify view and add in ordering by Category Name, Product Name, and Inventory Date
SELECT * FROM vInventoriesByProductsByCategories
ORDER BY  
	   CategoryName ASC
     , ProductName
	 , InventoryDate
;
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!



CREATE VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING
AS 
SELECT c.[Category Name]
	 , p.[Product Name]
	 , i.[Inventory Date]
	 , i.[Count]
	 , [Employee Name] =  e.[Employee First Name] + ' ' + e.[Employee Last Name]
FROM dbo.vInventories as i
INNER JOIN dbo.vProducts as p
ON i.ProductID = p.ProductID
INNER JOIN dbo.vCategories as c
ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vEmployees as e 
ON i.EmployeeID = e.EmployeeID
;

--Verify view and add in ordering by Category Name, Product Name, and Employee
SELECT * FROM vInventoriesByProductsByEmployees
ORDER BY [Inventory Date]
		,[Category Name] ASC
		,[Product Name] 
;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS 
SELECT c.[Category Name]
	 , p.[Product Name]
	 , i.[Inventory Date]
	 , i.[Count]
	 , [Employee Name] =  e.[Employee First Name] + ' ' + e.[Employee Last Name]
FROM dbo.vInventories as i
INNER JOIN dbo.vProducts as p
ON i.ProductID = p.ProductID
INNER JOIN dbo.vCategories as c
ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vEmployees as e 
ON i.EmployeeID = e.EmployeeID
WHERE i.ProductID IN (SELECT p.ProductID FROM Products AS p WHERE ProductName IN ('Chai', 'Chang'))

;
go 

SELECT * FROM vInventoriesForChaiAndChangByEmployees
ORDER BY [Inventory Date]
		,[Category Name] ASC
		,[Product Name] 
;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
vEmployeesByManager

CREATE VIEW vEmployeesByManager
AS
SELECT
  [Manager Name] = m.[Employee First Name] + ' ' + m.[Employee Last Name]
 ,[Employee Name] = e.[Employee First Name]	+ ' ' + e.[Employee Last Name]
FROM dbo.vEmployees AS e
INNER JOIN dbo.vEmployees as m ON e.ManagerID = m.EmployeeID 
;


SELECT * FROM vEmployeesByManager
ORDER BY [Manager Name] ASC
;
go
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT 
       c.[CategoryID]
	 , c.[Category Name]
	 , p.[ProductID]
	 , p.[Product Name]
	 , p.[Unit Price]
	 , i.[InventoryID]
	 , i.[Inventory Date]
	 , i.[Count]
	 , e.[EmployeeID]
	 , [Employee Name] =  e.[Employee First Name] + ' ' + e.[Employee Last Name]
	 , [Manager Name] = m.[Employee First Name] + ' ' + m.[Employee Last Name]
FROM dbo.vInventories as i
INNER JOIN dbo.vProducts as p
ON i.ProductID = p.ProductID
INNER JOIN dbo.vCategories as c
ON c.CategoryID = p.CategoryID
INNER JOIN dbo.vEmployees as e 
ON i.EmployeeID = e.EmployeeID
INNER JOIN dbo.vEmployees as m ON e.ManagerID = m.EmployeeID 
;
go 

SELECT * FROM vInventoriesByProductsByCategoriesByEmployees
ORDER BY   [Category Name]
         , [ProductID] ASC
		 , [Product Name] ASC
		 , [InventoryID]
;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/