USE TestECommerceDB
GO

-- Add User
DECLARE @HashedPassword VARBINARY(64);
SET @HashedPassword = HASHBYTES('SHA2_512', 'ademide');

EXEC AddUser 'Jerrygan', 'jerryga@email.com', @HashedPassword;

-- Add Product
EXEC AddProduct 'Fruits', 'Foods that can be eaten', 9.5, 25

-- Add Order

DECLARE @OrderItems OrderItemType;

INSERT INTO @OrderItems (ProductID, Quantity, Price)
VALUES (1, 2, 19.99), (2, 1, 9.99);

EXEC PlaceOrder @UserID = 1, @TotalAmount = 49.97, @OrderItems = @OrderItems;

-- Update Product stock
EXEC UpdateProductStock 1, 20

-- Check all products stock level
EXEC GetAllProductStock 

-- Get product stock level
EXEC GetProductStock @ProductName = 'Fruits'

-- Get user orders
EXEC GetUserOrders 1

-- Add payment method
EXEC AddPaymentMethod 'VISA'

-- Add payments
EXEC AddPayment 1, 1, 999.99

-- Add shipping record
EXEC AddShippingRecord 1, ' 14 Oak Street', 'Gotham', 'New Jersey', '935478', 'USA', 'Pending', '2024-10-09', '2020-10-14'

-- Update users record
EXEC UpdateUserInfo 5, 'Jerry Gann', 'jerry.gann@example.com' 

-- Add review
EXEC AddReview 1, 1, 5, 'Amazing product. Will definitely refer'

--Get product review
EXEC GetProductReviews 1

-- Get order details
EXEC GetOrderDetails 1

--Monthly sales details
EXEC sp_CalculateMonthlySales

-- Yearly sales details
EXEC sp_CalculateYearlySales

SELECT * FROM Users
SELECT * FROM Products
SELECT * FROM OrderItems
SELECT * FROM Payments
SELECT * FROM PaymentMethods
select * from Shipping
SELECT * FROM Reviews