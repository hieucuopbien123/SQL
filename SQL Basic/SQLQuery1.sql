select @@version;

CREATE DATABASE Testdb;-- database có thể tạo bằng query hoặc giao diện của SSMS
DROP DATABASE Testdb;

--khai báo primary key bằng constraint
CREATE TABLE sales.participants(
    activity_id int NOT NULL,
    customer_id int,
    birth DATE NOT NULL,
    duration DEC(5,2)
	--kiểu DEC(p,[s]) là s số sau dấu chấm và số các chữ số tổng cả trước và sau dấu chấm là p
    --PRIMARY KEY(activity_id, customer_id)
);
--thêm primary key sau khi đã khai báo table nếu chưa define PRIMARY_KEY thì mới dùng được
--Trường mà ta thêm PRIMARY KEY bằng ALTER TABLE phải là NOT NULL nếu k sẽ lỗi. Mặc định của nó là NULL
ALTER TABLE sales.participants 
ADD PRIMARY KEY(activity_id);

DROP TABLE sales.participants

USE BikeStores;
GO

--Dùng SELECT * FROM sẽ chọn tất cả. Nhưng như v sẽ rất nặng nếu data nhiều, chọn các trường cụ thể sẽ giảm tải nhẹ hơn
SELECT
    first_name,
    last_name
FROM
    sales.customers;

SELECT
    *
FROM
    sales.customers
WHERE
    state = 'CA'
    AND
    CITY = 'Encino'
ORDER BY
    first_name ASC;--xếp tăng dần theo mã ASCII. Mặc định cũng là ASC nếu nói ORDER BY mà k specific

CREATE TABLE sales.promotions (
    promotion_id INT PRIMARY KEY IDENTITY (1, 1),
    promotion_name VARCHAR (255) NOT NULL,
    discount NUMERIC (3, 2) DEFAULT 0,--giống DEC(3,2)
    start_date DATE NOT NULL,
);
INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date
) 
OUTPUT inserted.promotion_id,
 inserted.promotion_name,
 inserted.discount--có thể lấy thông tin trả về như này, lấy dữ liệu của inserted
VALUES(
    '2018 Summer Promotion',
    0.15,
    '20180601'
);

--khóa chính tăng tự động thì ta k thể insert thêm mà phải để SQL tự động gán. Ta có thể ép điều này bằng cách tắt->insert->bật
SET IDENTITY_INSERT sales.promotions ON;
INSERT INTO sales.promotions (
    promotion_id,
    promotion_name,
    discount,
    start_date
)
OUTPUT inserted.promotion_id,
 inserted.promotion_name,
 inserted.discount
VALUES( 
	4,
    '2019 Spring Promotion',
    0.25,
    '20190201'
);
SET IDENTITY_INSERT sales.promotions OFF;
DROP TABLE sales.promotions;

--BETWEEN AND
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 1899.00 AND 1999.99
ORDER BY
    list_price DESC;
-- = là so sánh bằng, <> or != là so sánh khác, a in b là a nằm trong b, < hay >, còn có IS NULL và IS NOT NULL