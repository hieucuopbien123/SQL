--Cách 1 tạo Local Temp Table với SELECT INTO
SELECT
    product_name,
    list_price
INTO #trek_products --- temporary table tên phải bắt đầu bằng #
FROM
    production.products
WHERE
    brand_id = 9;
go
--Vào System Database -> tempdb -> Temporary Tables sẽ hiện ra table này và đằng sau có hàng loạt ký tự SQL tự thêm vào để
--tránh TH trùng tên vì tất cả temp đều được lưu trữ ở đây. Đổi dữ liệu bảng gốc sẽ k ảnh hưởng đến bảng tạm
DROP TABLE #trek_products;--đằng nào local temp table cx tự xóa khi kết thúc phiên 

--Cách 2: tạo bảng tạm bth r tự insert data vào. INSERT INTO có thể kết hợp câu lệnh SELECT
CREATE TABLE #haro_products (
    product_name VARCHAR(MAX),
    list_price DEC(10,2)
);
INSERT INTO #haro_products
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    brand_id = 2;
DROP TABLE #haro_products;
--Để tạo Global Temporary Table ta đặt tên trước nó 2 dấu thăng là được: ##
GO

	
CREATE PROCEDURE uspProductList --viết gọn lệnh là CREATE PROC <tên>
	AS BEGIN
		SELECT
			product_name,
            list_price
		FROM
			production.products
		ORDER BY
			product_name;
	END;
GO
--Vào database của ta -> Programmability -> Stored Procedures sẽ ra các procedure ta tạo ra
--Có thể update procedure bằng giao diện bằng cách rightclick procedure -> modify
EXEC uspProductList;--or EXECUTE uspProductList;
DROP PROC uspProductList;--DROP PROCEDURE uspProductList;
GO


--params của procedure trong (), type thông qua từ khóa AS, nên quy ước bắt đầu với @
CREATE PROCEDURE uspFindProducts(@min_list_price AS DECIMAL)
	AS
	BEGIN
		SELECT
			product_name,
			list_price
		FROM
			production.products
		WHERE
			list_price >= @min_list_price
		ORDER BY
			list_price;
	END;
GO

--modify procedure
ALTER PROCEDURE uspFindProducts(
    @min_list_price AS DECIMAL = 0--có thể làm nhiều tham số kèm giá trị mặc định
    ,@max_list_price AS DECIMAL = 999999
    ,@name AS VARCHAR(max)--max thì dùng max bộ nhớ có thể luôn
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price AND
        list_price <= @max_list_price AND
        product_name LIKE '%' + @name + '%'--like có thể chơi như này
    ORDER BY
        list_price;
END;
GO
EXECUTE uspFindProducts 900, 1000, 'Hieu';
EXECUTE uspFindProducts @name = 'Trek', @max_list_price = 99999;--tường minh
DROP PROC uspFindProducts;