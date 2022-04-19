--CREATE SCHEMA procurement;
--go

CREATE TABLE procurement.vendor_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (100) NOT NULL
);
--tạo foreign key bằng constraint. Tên foreign key là fk_group. Có thể có nhiều trường gom lại thành 1 foreign key như sau:
--CONSTRAINT fk_constraint_name FOREIGN KEY (column_1, column2,...) REFERENCES parent_table_name(column1,column2,..)
CREATE TABLE procurement.vendors (
    vendor_id INT IDENTITY PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    group_id INT NOT NULL,
    CONSTRAINT fk_group FOREIGN KEY (group_id) 
    REFERENCES procurement.vendor_groups(group_id)
);
--Cách 2 là dùng ALTER TABLE. Mỗi lần chỉnh sửa phải gọi lại ALTER TABLE
ALTER TABLE procurement.vendors 
DROP CONSTRAINT fk_group;

ALTER TABLE procurement.vendors 
ADD CONSTRAINT fk_group
FOREIGN KEY (group_id) REFERENCES procurement.vendor_groups(group_id)

ALTER TABLE procurement.vendors
ADD 
	description VARCHAR(255),
	summary VARCHAR (50) NULL

--Sau khi thêm khóa ngoại, ta có 2 hành động chính tác động đến khóa ngoại là delete và update. Nên nhớ khi thêm 
--vào 1 record thì giá trị khóa ngoại phải tồn tại ở bảng cha. Ta có thể định nghĩa cách sử dụng khóa ngoại ở 1 bảng:
--FOREIGN KEY (group_id) REFERENCES procurement.vendor_groups(group_id) on UPDATE action ON DELETE action;
--các action là NO ACTION, CASCADE, SET NULL và SET DEFAULT.
--Con có foreignkey refer đến primary key bảng cha: NO ACTION sẽ trả về lỗi và dữ liệu bảng cha được khôi phục; CASCADE thì
--dữ liệu bản con được cập nhập tương ứng với bảng cha; SET NULL thì cập nhập bảng con thành NULL, để dùng đưucọ thì column 
--foreign key của phải cho phép NULL; SET DEFAULT thì SQL Server sẽ về giá trị mặc định, để dùng được thì foreign key phải có 
--giá trị default khi khởi tạo. Mặc định sẽ dùng NO ACTION.

--Để xóa table cha có con chứa FOREIGN KEY trỏ tới -> cách 1 là xóa table con trước r xóa cha bằng cách đặt con trước cha.
--C2 là xóa foreign key của con r xóa được cha(tức k cần xóa hẳn table con).
--ALTER TABLE procurement.vendors 
--DROP CONSTRAINT fk_group;
--DROP TABLE procurement.vendor_groups;

--Có option IF EXISTS để tránh báo lỗi và [database_name.][schema_name.]table_name; tức 2 cái kia nếu k truyền sẽ dùng mặc định
DROP TABLE IF EXISTS BikeStores.procurement.vendors, procurement.vendor_groups;


--Khi chuyển đổi kiểu dữ liệu với ALTER COLUMN thì các giá trị bên trong phải tương thích mới được
DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (c INT NULL, d INT NULL DEFAULT 0);
INSERT INTO t1 
	VALUES (1, 0),(2, 0),(3, 0); --éo hiểu sao default vẫn phải truyền, nếu k sẽ báo lỗi. Đây là insert nhiều giá trị
ALTER TABLE t1 ALTER COLUMN c VARCHAR(2);--ok
INSERT INTO t1 VALUES ('@', 0);
--ALTER TABLE t1 ALTER COLUMN c INT;--lỗi

--Ta có thể tăng kích thước thoải mái nhưng nếu giảm kích thước phải đảm bảo số lượng giá trị hiện tại chưa quá kích thước
--TH đổi từ NULL sang NOT NULL thì phải cập nhập tất cả các dòng sao cho nó từ NULL thành rỗng trước khi thay đổi
UPDATE t1 SET c = '' WHERE c IS NULL;
ALTER TABLE t1 ALTER COLUMN c VARCHAR (20) NOT NULL;
ALTER TABLE t1 DROP COLUMN c;
--2 lưu ý: column có default thì k thể xóa được vì có cái éo gì internal access tới nó ấy; mỗi table có ít nhất 1 column
DROP TABLE t1;

--khi xóa 1 column có constraint thì phải DROP CONSTRAINT trước r mới DROP COLUMN
CREATE TABLE sales.price_lists(
    valid_from DATE,
    price DEC(10,2) NOT NULL CONSTRAINT ck_positive_price CHECK(price >= 0),--mỗi 1 data mới thêm vào sẽ check
    note VARCHAR(255),
);
ALTER TABLE sales.price_lists
DROP CONSTRAINT ck_positive_price;
ALTER TABLE sales.price_lists
DROP COLUMN price, valid_from;
--Xóa column mà là primary key or foreign key thì báo lỗi ngay nên foreign key có thể rời sang trường khác để xóa(ràng buộc toàn vẹn)


/*SQL Server k cung cấp câu lệnh đổi tên table nhưng có 1 thủ tục lưu trữ global là sp_rename có thể dùng để đổi tên bảng
bằng cách exec thủ tục đó. Tên cũ và mới đều phải đặt trong dấu nháy đơn*/
EXEC sp_rename 'sales.price_lists', 'price_groups'
--Chú ý old_name có schema, còn new_name k có schema vì mặc định chơi trong schema kia
--Vc đổi tên sẽ ảnh hưởng đến khóa ngoại của các table khác trỏ đến table này nhưng SQL Server tự động cập nhập nên kp lo
--Ta cx có thể đổi tên bằng giao diện righclick table được 

TRUNCATE TABLE sales.price_groups;
DROP TABLE sales.price_groups;
--Phân biệt TRUNCATE và DELETE FROM TH xóa cả table: truncate sẽ sắp xếp lại trạng thái và xóa file lịch sử transaction của bảng
--trong khi delete thì SQL Server sẽ duyệt và xóa từng record; truncate sẽ reset cả IDENTITY tăng tự động về 0 còn delete tiếp tục 
--tăng; DELETE thì row lock vì chơi từng dòng còn truncate sẽ table lock và page lock khi dùng vì nó tác động đến cả table
--TRUNCATE khá nguy hiểm vì xóa éo bh khôi phục được còn delete thì may ra

CREATE TABLE persons(
    person_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
	birth DATE,
    --email VARCHAR(255) UNIQUE,//dùng TT
    --UNIQUE(email)//dùng ở cuối, thêm phẩy nếu có nhiều
	--Có thể dùng column có UNIQUE như primary key nhưng k hay nên họ chỉ đặt là UNIQUE
	--Tạo như trên thì SQL tự đặt tên cho UNIQUE 1 cái tên rất dài. Ta dùng constraint có thể tự đặt tên
	email VARCHAR(255),
	CONSTRAINT unique_email UNIQUE(email)
);
INSERT INTO persons(first_name, last_name)
VALUES('John', 'Handsome');
INSERT INTO persons(first_name, email)
VALUES('Jane','j.doe@bike.stores');

--có thể thêm unique bằng constraint
ALTER TABLE persons
ADD CONSTRAINT add_unique UNIQUE(first_name, birth)
ALTER TABLE persons
ADD CONSTRAINT lastname_unique UNIQUE(last_name)

--Do UNIQUE cũng chỉ là 1 CONSTRAINT nên có thể xóa được bằng cách xóa constraint
ALTER TABLE persons
DROP CONSTRAINT add_unique;
DROP TABLE persons;
--PRIMARY KEY k chấp nhận giá trị NULL nhưng UNIQUE được có NULL và 2 giá trị cùng NULL vẫn lỗi duplicate value
--Khi dùng PRIMARY KEY và UNIQUE thì SQL tự tạo ra 1 index unique mỗi khi update và insert

--Nên nhớ các điều kiện constraint có thể thêm trực tiếp trong từng trường, thêm ở cuối CREATE TABLE or thêm bằng ALTER TABLE và 
--các CONSTRAINT có thể xóa tùy ý thông qua tên constraint. Do đó người ta sẽ đặt tên cho CONSTRAINT để dễ dàng quản lý