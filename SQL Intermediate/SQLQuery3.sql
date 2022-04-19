﻿--procedure k có giá trị trả về nhưng hàm thì buộc có. Dùng function thoải mái trong phạm vi database
--Vào database hiện tại -> Programmability -> Functions -> Scalar-valued Function
CREATE FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2),
    @discount DEC(4,2)
)
RETURNS DEC(10,2)
AS
BEGIN
    RETURN @quantity * @list_price * (1 - @discount);
END;
GO

SELECT sales.udfNetSale(10,100,0.1) net_sale--gọi ez với tên và tham số

--Đừng nhầm vì ta k định nghĩa hàm SUM nh
SELECT
    order_id, 
    SUM(sales.udfNetSale(quantity, list_price, discount)) net_amount
FROM
    sales.order_items
GROUP BY
    order_id
ORDER BY
    net_amount DESC;

GO
ALTER FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2)
)
RETURNS DEC(10,2)
AS
BEGIN
    RETURN @quantity * @list_price;--tự cast để cộng
END;
GO
DROP FUNCTION sales.udfNetSale;


DECLARE @product_table TABLE (
    product_name VARCHAR(MAX) NOT NULL,
    brand_id INT NOT NULL,
    list_price DEC(11,2) NOT NULL
);

INSERT INTO @product_table
SELECT
    product_name,
    brand_id,
    list_price
FROM
    production.products
WHERE
    category_id = 1;

SELECT * FROM @product_table;

--KHi dùng biến table JOIN với bảng tạm thì phải đặt bí danh cho nó. VD ở dưới ta đặt là pt
SELECT
    brand_name,
    product_name,
    list_price
FROM
    production.brands b
INNER JOIN @product_table pt ON b.brand_id = pt.brand_id;--Chỉ là 1 cách rút gọn của: @product_table AS pt

--Sử dụng function return về 1 biến TABLE
GO
CREATE OR ALTER FUNCTION udfSplit(--tồn tại thì modify, chưa thì create
    @string VARCHAR(MAX), 
    @delimiter VARCHAR(50) = ' ')
RETURNS @parts TABLE (--trả ra 1 biến kiểu table, ở đây ta đặt tên luôn để dùng nó trong hàm
	idx INT IDENTITY PRIMARY KEY,
	val VARCHAR(MAX)   
)
AS
BEGIN
	DECLARE @index INT = -1;
	WHILE (LEN(@string) > 0)--lấy length của biến kiểu VARCHAR
	BEGIN
		SET @index = CHARINDEX(@delimiter , @string);--trả ra index của @delimiter trong @string bắt đầu từ vị trí 1
		--nếu như string k có ký tự @delimeter nào thì trả ra 0
     
		IF (@index = 0) AND (LEN(@string) > 0)  
		BEGIN 
			INSERT INTO @parts VALUES (@string);
			BREAK--dừng vòng loop ngoài
		END

		IF (@index > 1)  
		BEGIN 
			--lấy @string từ 0 đến vị trí @index - 1 và gán phần string còn lại sang mé bên phải
			INSERT INTO @parts VALUES (LEFT(@string, @index - 1));
			SET @string = RIGHT(@string, (LEN(@string) - @index));--lấy từ vị trí nào đến hết cuối
		END
		ELSE
			SET @string = RIGHT(@string, (LEN(@string) - @index)); 
	END
	RETURN--k cần return tên biến nx vì nó là @part được xử lý bên trên r
END
GO
SELECT * FROM udfSplit('foo,bar,baz,',',');