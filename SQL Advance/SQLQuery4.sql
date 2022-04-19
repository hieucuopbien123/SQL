SELECT * FROM sys.databases; --table lưu các database hiện tại 
SELECT * FROM INFORMATION_SCHEMA.TABLES --lưu các SCHEMA và table 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS --lưu tổ hợp SCHEMA TABLE và COLUMN
SELECT * FROM sys.all_columns -- lưu tất cả các cột
SELECT * FROM sys.columns -- lưu các cột
EXEC sp_help 'production.products' -- ra nhiều bảng chứa thông tin của bảng nào

CREATE INDEX index_name ON production.products(list_price)--dấu phẩy ngăn cách đánh index nhiều trường
--vào table -> vào indexes sẽ thấy các indexes tạo ra
--index giúp tìm kiếm trong table nhanh hơn nhưng insert delete chậm hơn. Bất kể kiểu tìm kiếm nào đều có tốc độ tìm kiếm và
--update dữ liệu nghịch nhau. Trong các cơ sở dữ liệu lớn mới thấy rõ sự khác biệt về tốc độ
--k thể đánh 2 index cùng trường. Các trường được đánh index có thể dùng where tìm kiếm tốc độ cao
--1 table ta chỉ được tạo ra 1 cái index
SELECT * FROM production.products
WHERE list_price >= 100 --maybe nhanh hơn
CREATE UNIQUE INDEX IndexNameUnique ON production.categories(category_id)
--UNIQUE INDEX để đánh cho các trường của table mà unique ở mỗi record, nó cũng ngăn cản dữ liệu mới thêm vào mà bị trùng với
--dữ liệu đã có trong SQL. 2 loại INDEX dùng nào cũng được

DROP INDEX index_name ON production.products
DROP INDEX IndexNameUnique ON production.categories

EXEC sp_addtype 'TNAME', 'nvarchar(100)', 'NOT NULL'
--vào database hiện tại -> Programmability -> Types -> User-Defined Data Types sẽ hiện các type ta định nghĩa
GO
CREATE TABLE TEST(
	name TNAME
)
GO
--phải tắt tab này đi thì khi mở UI của table mới thấy type của ta
DROP TABLE TEST
EXEC sp_droptype 'TNAME'
--có thể xóa type bằng giao diện
--khi xóa type phải đảm bảo k có table nào dùng nó nếu k sẽ error. Sửa type rất phức tạp vì nó yêu cầu query tất cả các column
--dùng type đó và chuyển sang type khác

--tạo type mới bằng lệnh khác, type cũng có thể dùng schema
CREATE TYPE dbo.ADDRESS FROM nvarchar(2) NOT NULL
GO
CREATE TABLE TEST(
	name dbo.ADDRESS
)
GO
DROP TABLE TEST
DROP TYPE dbo.ADDRESS;--xóa cũng khác
GO

GO
CREATE RULE list_rule  
AS   
@list IN ('1389', '0736', '0877');
GO
CREATE TABLE TEST(
	name nvarchar(50)
)
GO
EXEC sp_bindrule list_rule, 'TEST.name'
INSERT INTO TEST(name) VALUES ('1389');
--bh thêm vào cột name chỉ được 3 giá trị xđ trong rule
DROP TABLE TEST
DROP RULE list_rule;


--Dùng con trỏ: thao tác từng dòng của record thì làm gì
DECLARE productsCursor CURSOR FOR SELECT product_id, product_name, list_price FROM production.products
OPEN productsCursor

DECLARE @product_id int
DECLARE @product_name varchar(225)
DECLARE @list_price DEC(10,2)

FETCH NEXT FROM productsCursor INTO @product_id, @product_name, @list_price
WHILE @@FETCH_STATUS = 0
BEGIN
	IF(@list_price > 200)
	BEGIN
		PRINT @product_name + ' >100'
	END
	ELSE
	IF @list_price > 100
	BEGIN
		PRINT @product_name + ' >100'
	END
	FETCH NEXT FROM productsCursor INTO @product_id, @product_name, @list_price
END

CLOSE productsCursor
DEALLOCATE productsCursor

--Khi tạo ra 1 database sẽ tạo ra 2 file .mdf và .ldf còn tập ndf thứ cấp ta k cần quan tâm thì thông thường nó sẽ tự tạo 
--2 tập tin này cho ta trong thư mục dưới nhưng điều này ta hoàn toàn tùy chỉnh được
DROP DATABASE IF EXISTS QLKH
CREATE DATABASE QLKH 
ON 
	( NAME = QLKH_dat, --tên của cục này 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\QLKHdat.mdf', 
	SIZE = 10, --kích thước ban đầu của file
	MAXSIZE = 50, --kích thước lớn nhất của file
	FILEGROWTH = 5 ) --mdf lưu dữ liệu chính, sau này database mở rộng ra thì kích thước file tăng lên dần dần
	--ở đây nó sẽ tăng lên cứ mỗi 5MB 1 cục nếu file size bị vượt quá
LOG ON --LOG ON sẽ viết log cho các thao tác trong database vào file nào
	( NAME = QLKH_log, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\QLKHlog.ldf', 
	SIZE = 5MB, --có thể rõ đuôi MB or để bth cx là MB
	MAXSIZE = 25MB, 
	FILEGROWTH = 5MB ); 
GO
-- Bên trên là hoàn toàn mặc định vì nếu ta k specific như v thì khi database tạo ra nó cũng tự tạo 2 file ở thư mục đó
