DECLARE @model_year SMALLINT, 
        @product_name AS VARCHAR(MAX);
SET @model_year = 2018 + 3;
--dùng toán tử số học thoải mái, các lệnh bên dưới dùng biến thoải mái. Có thể lưu hẳn câu lệnh SQL vào biến

DECLARE @product_count INT;
SET @product_count = (--lệnh này trả ra số nguyên đúng kiểu mà biến lưu
    SELECT
        COUNT(*) 
    FROM
        production.products 
);
SELECT @product_count;

--Or ta gán giá trị của nó bên trong Select
DECLARE @list_price DECIMAL(10,2);
SELECT
    @product_name = product_name,
    @list_price = list_price
FROM
    production.products
WHERE
    product_id = 100;
--xem giá trị 2 biến đó
SELECT
    @product_name AS product_name, 
    @list_price AS list_price;
GO

--Kết hợp
CREATE  PROC uspGetProductList(
    @model_year SMALLINT
) AS
BEGIN
    DECLARE @product_list VARCHAR(MAX);
  
    SET @product_list = '';
  
    SELECT
        @product_list = @product_list + product_name 
                        + CHAR(10)--CHAR(10) là line feed, char(9) là tab
    FROM
        production.products
    WHERE
        model_year = @model_year
    ORDER BY
        product_name;
  
    PRINT @product_list;--hàm  PRINT sẽ in ra ở tab Messages chứ k hiện dạng bảng
END;
GO
EXEC uspGetProductList 2018;
DROP PROC uspGetProductList;
GO
--OUTPUT ở tham số ý chỉ biến này sẽ lấy được ở bên ngoài sau khi kết thúc procedure
CREATE PROCEDURE uspFindProductByModel (
    @model_year SMALLINT,
    @product_count INT OUTPUT
) AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;
    SELECT @product_count = @@ROWCOUNT;
	IF @product_count <> 0 --có thể lồng nhiều thoải mái
		PRINT @product_count
	ELSE 
		PRINT 'No record found'
	--@@ROWCOUNT là biến toàn cục lưu tổng số lượng record và lệnh này sẽ gán nó vào biến @product_count
END;
GO

DECLARE @count INT = 0;
EXEC uspFindProductByModel 
	@model_year = 2018, 
	@product_count = @count OUTPUT;--nhớ có từ khóa OUTPUT ở sau
SELECT @count AS 'Number of products found';--tên cột có space có thể nhét trong ''
DROP PROC uspFindProductByModel; 
--Chú ý NULL + data = NULL nên nếu khai báo biến mà kiểu cộng lên thì phải khởi tạo giá trị ban đầu của nó khác null tránh lỗi
--Chú ý GO sẽ đóng scope cũ: khai báo biến -> GO -> K dùng được biến đó nx vì sau GO sẽ sang 1 scope mới là 1 khối block mới

--Khối lệnh BEGIN END là tập hợp 1 or nhiều câu lệnh khác chia ra để nhìn cho dễ, có thể dùng lồng nhau, giống {} của C++
--IF ELSE phải đi với BEGIN END ở từng cục IF và ELSE nếu thực hiện nhiều lệnh, còn 1 lệnh thì viết gọn được

DECLARE @counter INT = 1;
WHILE @counter <= 5
BEGIN
    PRINT @counter;--tự xuống dòng với PRINT
    SET @counter = @counter + 1;
END