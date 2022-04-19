CREATE SCHEMA news;
go
CREATE SCHEMA syst;
go
CREATE SCHEMA test;
go
-- tạo schema buộc phải có go và đứng đầu mọi thứ

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: news TO hieu
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: news TO hieu;
--hai chấm cuối dòng éo qtr

DROP SCHEMA news;
DROP SCHEMA syst;
--query nếu fail ở 1 dòng mà k ảnh hưởng thì nó chạy đến đâu thực hiện đến đấy, ở đây k có biên dịch như các lang bth

--nếu k nói rõ database thì nó dùng database mặc định hiển thị ở góc trái trên của phần mềm. Có thể chỉnh
--ở đó or dùng use + go
use BikeStores;
go

--Các options: NULL, NOT NULL, PRIMARY KEY, DEFAULT "value", UNIQUEFOREIGN KEY REFERENCES table_name(column_name)
--IDENTITY(initialVal, incrementalVal) nếu k chỉ định 2 giá trị đó thì nó sẽ là IDENTITY(1,1) sẽ tự tăng như nào
--Nó luôn tự tăng mãi mãi dù add thất bại hay xóa nhưng ID cũ nó sẽ k bù lại vào đâu
--Các types: VARCHAR(50) tiếng anh k dấu, NVACHAR(50) là kiểu tiếng việt có dấu ok, FLOAT, DATETIME
CREATE TABLE SINHVIEN(
    MASINHVIEN INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    TENSINHVIEN NVARCHAR(200) NOT NULL,
    MAKHOA INT NOT NULL FOREIGN KEY REFERENCES sales.stores(store_id),
    NAMSINH INT NULL DEFAULT 0,--DEFAULT thường đi với NULL, DEFAULT k được đi với UNIQUE
    gender CHAR(1) NOT NULL
);

INSERT INTO SINHVIEN(TENSINHVIEN, MAKHOA, NAMSINH, gender)
OUTPUT inserted.MASINHVIEN
VALUES('John', 1, 2, 'M');

INSERT INTO SINHVIEN(TENSINHVIEN, MAKHOA, NAMSINH, gender)
OUTPUT inserted.MASINHVIEN
VALUES('Jane', 1, 2,'F');

CREATE TABLE sales.visits (
    visit_id INT PRIMARY KEY IDENTITY,
    visited_at DATETIME,
    phone VARCHAR(20),
    store_id INT NOT NULL,
    FOREIGN KEY(store_id) REFERENCES sales.stores(store_id) ON UPDATE CASCADE ON DELETE CASCADE
	--constraints foreign key thì cú pháp thêm 1 cái ngoặc ở giữa thôi
);
DROP TABLE SINHVIEN, sales.visits


CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
	discounted_price DEC(10,2) CHECK(discounted_price > 0),
	-- Nên đặt tên cho CHECK để dễ quản lý như dưới. Chú ý vẫn chấp nhận giá trị NULL vì SQL coi NULL và 0 khác nhau
    unit_price DEC(10,2) CONSTRAINT positive_price CHECK(unit_price > 0),
	CHECK (discounted_price < 10000000 AND discounted_price > unit_price)
	--Tạo CHECK ở cuối sẽ kết hợp check được nhiều trường, dùng được AND hoặc OR
);

--Thêm 1 column mới và trong lúc đó ta thêm check vào luôn vì nó cx chỉ là 1 option của column, k đặt tên
ALTER TABLE test.products
ADD price1 DEC(10,2)
CHECK(price1 > 0)

--Dùng ALTER TABLE có đặt tên thì thêm 1 constraint vào column có sẵn
ALTER TABLE test.products
ADD CONSTRAINT valid_price
CHECK(discounted_price > unit_price)

--xóa nó bằng cách DROP CONSTRAINT như bth
--ta có thể tạm thời vô hiệu hóa mà k xóa nó với: 
ALTER TABLE test.products
NOCHECK  CONSTRAINT valid_price

DROP TABLE test.products;
DROP SCHEMA test;