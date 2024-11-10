CREATE DATABASE TestECommerceDB;
GO

USE TestECommerceDB;
GO

-- Users

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Products 

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Categories

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL
);


-- ProductCategories

CREATE TABLE ProductCategories (
    ProductID INT,
    CategoryID INT,
    PRIMARY KEY (ProductID, CategoryID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Orders Table

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- OrderItems 

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- PaymentMethods 

CREATE TABLE PaymentMethods (
    PaymentMethodID INT PRIMARY KEY IDENTITY(1,1),
    MethodName NVARCHAR(50) NOT NULL
);

-- Payments Table

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    PaymentMethodID INT,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID)
);

-- Shipping
CREATE TABLE Shipping (
    ShippingID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ShippingAddress VARCHAR(255) NOT NULL,
    ShippingCity VARCHAR(100) NOT NULL,
    ShippingState VARCHAR(100),
    ShippingZip VARCHAR(20),
    ShippingCountry VARCHAR(100) NOT NULL,
    ShippingStatus VARCHAR(50) NOT NULL,
    ShippingDate DATETIME,
    DeliveryDate DATETIME,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


-- Adding Indexes

CREATE INDEX IDX_Users_Email ON Users(Email);
CREATE INDEX IDX_Products_ProductName ON Products(ProductName);
CREATE INDEX IDX_Orders_UserID ON Orders(UserID);
CREATE INDEX IDX_Shipping_OrderID ON Shipping(OrderID);
CREATE INDEX IDX_Shipping_ShippingStatus ON Shipping(ShippingStatus);


-- Adding Constraints

ALTER TABLE Users ADD CONSTRAINT CHK_Email CHECK (Email LIKE '%_@__%.__%');
ALTER TABLE Products ADD CONSTRAINT CHK_Price CHECK (Price > 0);
ALTER TABLE OrderItems ADD CONSTRAINT CHK_Quantity CHECK (Quantity > 0);
ALTER TABLE Shipping ADD CONSTRAINT CHK_ShippingStatus CHECK (ShippingStatus IN ('Pending', 'Shipped', 'In Transit', 'Delivered', 'Cancelled'));

-- Insert Users

INSERT INTO Users (UserName, Email, PasswordHash) VALUES
('JohnDoe', 'john@example.com', HASHBYTES('SHA2_512', 'hashedpassword1')),
('JaneSmith', 'jane@example.com', HASHBYTES('SHA2_512', 'hashedpassword2'));


-- Insert Categories

INSERT INTO Categories (CategoryName) VALUES
('Electronics'),
('Books'),
('Clothing');


-- Insert Products

INSERT INTO Products (ProductName, Description, Price, Stock) VALUES
('Laptop', 'A high-performance laptop', 999.99, 50),
('Smartphone', 'Latest model smartphone', 699.99, 100),
('T-Shirt', 'Cotton T-shirt', 19.99, 200);


-- Insert Orders and Order Items

INSERT INTO Orders (UserID, TotalAmount) VALUES
(1, 1019.98),
(2, 719.98);

INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 999.99),
(1, 3, 1, 19.99),
(2, 2, 1, 699.99),
(2, 3, 1, 19.99);

-- Insert Shipping
INSERT INTO Shipping (OrderID, ShippingAddress, ShippingCity, ShippingState, ShippingZip, ShippingCountry, ShippingStatus, ShippingDate, DeliveryDate)
VALUES 
(1, '123 Baker St', 'London', 'Greater London', 'NW1 6XE', 'United Kingdom', 'Shipped', '2024-10-01 10:00:00', '2024-10-05 15:00:00'),
(2, '456 High St', 'Manchester', 'Greater Manchester', 'M1 2AB', 'United Kingdom', 'In Transit', '2024-10-02 12:00:00', NULL),
(2, '789 King St', 'Edinburgh', 'Scotland', 'EH1 1BB', 'United Kingdom', 'Delivered', '2024-09-28 09:00:00', '2024-10-03 14:00:00');

-- Add a New User
GO

CREATE PROCEDURE AddUser
    @UserName NVARCHAR(50),
    @Email NVARCHAR(100),
    @PasswordHash VARBINARY(64) 
AS
BEGIN
    INSERT INTO Users (UserName, Email, PasswordHash)
    VALUES (@UserName, @Email, @PasswordHash);
END;


-- Add a New Product
GO

CREATE PROCEDURE AddProduct
    @ProductName NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @Price DECIMAL(10, 2),
    @Stock INT
AS
BEGIN
    INSERT INTO Products (ProductName, Description, Price, Stock)
    VALUES (@ProductName, @Description, @Price, @Stock);
END;


-- Place an Order

-- Place an Order

-- Create an OrderItemType Table

CREATE TYPE dbo.OrderItemType AS TABLE ( 
	ProductID INT, 
	Quantity INT, 
	Price DECIMAL(10, 2) 
); 

GO

CREATE PROCEDURE PlaceOrder
    @UserID INT,
    @TotalAmount DECIMAL(10, 2),
    @OrderItems dbo.OrderItemType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OrderID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Orders (UserID, TotalAmount)
        VALUES (@UserID, @TotalAmount);

        SET @OrderID = SCOPE_IDENTITY();

        INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
        SELECT @OrderID, ProductID, Quantity, Price
        FROM @OrderItems;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;



-- Update Product Stock
GO

CREATE PROCEDURE UpdateProductStock
    @ProductID INT,
    @Stock INT
AS
BEGIN
    UPDATE Products
    SET Stock = @Stock
    WHERE ProductID = @ProductID;
END;

-- Check stocks level
GO

CREATE PROCEDURE GetAllProductStock
AS
BEGIN
    SELECT ProductID, ProductName, Stock
    FROM Products;
END;

-- Check stock level for product
GO

CREATE PROCEDURE GetProductStock
    @ProductID INT = NULL,
    @ProductName NVARCHAR(100) = NULL
AS
BEGIN
    IF @ProductID IS NOT NULL
    BEGIN
        SELECT ProductID, ProductName, Stock
        FROM Products
        WHERE ProductID = @ProductID;
    END
    ELSE IF @ProductName IS NOT NULL
    BEGIN
        SELECT ProductID, ProductName, Stock
        FROM Products
        WHERE ProductName = @ProductName;
    END
    ELSE
    BEGIN
        PRINT 'Please provide either ProductID or ProductName.';
    END
END;


-- Get User Orders
GO

CREATE PROCEDURE GetUserOrders
    @UserID INT
AS
BEGIN
    SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, oi.Quantity, oi.Price
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.UserID = @UserID;
END;


-- Add Payment
GO

CREATE PROCEDURE AddPayment
    @OrderID INT,
    @PaymentMethodID INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Payments (OrderID, PaymentMethodID, Amount, PaymentDate)
    VALUES (@OrderID, @PaymentMethodID, @Amount, GETDATE());
END;

-- Add shipping record
GO

CREATE PROCEDURE AddShippingRecord
    @OrderID INT,
    @ShippingAddress NVARCHAR(255),
    @ShippingCity NVARCHAR(100),
    @ShippingState NVARCHAR(100),
    @ShippingZip NVARCHAR(20),
    @ShippingCountry NVARCHAR(100),
    @ShippingStatus NVARCHAR(50),
    @ShippingDate DATETIME,
    @DeliveryDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Shipping (OrderID, ShippingAddress, ShippingCity, ShippingState, ShippingZip, ShippingCountry, ShippingStatus, ShippingDate, DeliveryDate)
    VALUES (@OrderID, @ShippingAddress, @ShippingCity, @ShippingState, @ShippingZip, @ShippingCountry, @ShippingStatus, @ShippingDate, @DeliveryDate);
END;

--Add Payment method
GO

CREATE PROCEDURE AddPaymentMethod
	@MethodName NVARCHAR (50)
AS
BEGIN 
	INSERT INTO PaymentMethods (MethodName)
	VALUES (@MethodName)
END;

-- Update User Information
GO

CREATE PROCEDURE UpdateUserInfo
    @UserID INT,
    @UserName NVARCHAR(50),
    @Email NVARCHAR(100)
AS
BEGIN
    UPDATE Users
    SET UserName = @UserName, Email = @Email
    WHERE UserID = @UserID;
END;

--Create Reviews table

CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(1000),
    ReviewDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Add a Review
GO

CREATE PROCEDURE AddReview
    @ProductID INT,
    @UserID INT,
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Reviews (ProductID, UserID, Rating, Comment, ReviewDate)
    VALUES (@ProductID, @UserID, @Rating, @Comment, GETDATE());
END;


-- Get Product Reviews
GO

CREATE PROCEDURE GetProductReviews
    @ProductID INT
AS
BEGIN
    SELECT r.UserID, r.Rating, r.Comment, r.ReviewDate
    FROM Reviews AS r
	JOIN Users AS u ON r.UserID = u.UserID
    WHERE r.ProductID = @ProductID;
END;


-- Get All Products
GO

CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT ProductID, ProductName, Description, Price, Stock
    FROM Products;
END;


-- Get Order Details
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    JOIN Products p ON oi.ProductID = p.ProductID
    WHERE o.OrderID = @OrderID;
END;

-- Calculate monthly sales
GO

CREATE PROCEDURE sp_CalculateMonthlySales
AS
BEGIN
    SELECT 
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalAmount) AS MonthlySales
    FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
    ORDER BY Year, Month;
END;

-- Calculate yearly sales
GO

CREATE PROCEDURE sp_CalculateYearlySales
AS
BEGIN
    SELECT 
        YEAR(OrderDate) AS Year,
        SUM(TotalAmount) AS YearlySales
    FROM Orders
    GROUP BY YEAR(OrderDate)
    ORDER BY Year;
END;

-- Create a role for managing products
CREATE ROLE ProductManager;

-- Create a role for managing orders
CREATE ROLE OrderManager;

-- Create a role for managing users
CREATE ROLE UserManager;

-- Grant permissions to ProductManager role
GRANT EXECUTE ON AddProduct TO ProductManager;
GRANT EXECUTE ON UpdateProductStock TO ProductManager;
GRANT EXECUTE ON GetAllProducts TO ProductManager;

-- Grant permissions to OrderManager role
GRANT EXECUTE ON GetOrderDetails TO OrderManager;
GRANT EXECUTE ON GetUserOrders TO OrderManager;
GRANT EXECUTE ON AddShippingRecord TO OrderManager;
GRANT EXECUTE ON AddPayment TO OrderManager;
GRANT EXECUTE ON AddPaymentMethod TO OrderManager;

-- Grant permissions to UserManager role
GRANT EXECUTE ON AddUser TO UserManager;
GRANT EXECUTE ON UpdateUserInfo TO UserManager;