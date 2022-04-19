DECLARE @bigIntVar BIGINT = 10;
DECLARE @doublePrecisionVar DOUBLE PRECISION = 10.9;
DECLARE @bitVar Bit = 0;--chỉ lưu 0 và 1
DECLARE @money Money = $1;
SET @money += 1;
DECLARE @smallMoneyVar smallMoney = $1;
DECLARE @timeVar Time = '11:20:10.100';--chỉ giờ phút giây mili
DECLARE @realVar real = 1.2;
DECLARE @charVar CHARACTER = 'H';

SELECT @bitVar;
SELECT @money;
SELECT @smallMoneyVar;
SELECT @timeVar;

--Type chuỗi
DECLARE @v1 Char(10) = 'Hello1';--k chứa Unicode, cấp phát tĩnh
DECLARE @v2 Nchar(10) = 'Hello2';--chứa Unicode, cấp phát tĩnh
DECLARE @v3 Varchar(10) = 'Hello3';--k chứa Unicode, cấp phát động max đến n ô nhớ
DECLARE @v4 Nvarchar(20) = N'Nguyễn Thụ Hiếu';--chứa Unicode, cấp phát động max n ô nhớ
--Động tức là lượng ô nhớ bám sát bằng lượng string truyền vào nên tiết kiệm hơn so với tĩnh nhưng nhiêu khi ta muốn mọi
--value trong 1 cột được đồng bộ cùng kích thước thì vẫn dùng tĩnh.
--Tĩnh 10 ô nhớ thì ta nhập vào 5 thì 5 ký tự còn lại mặc định là rỗng còn động k có rỗng nhưu v theo sau
--Nhập Unicode dùng cú pháp N'<chữ>'

--Kiểu Text: k chứa Unicode, cấp phát động theo độ dài chuỗi nhập vào chứ kp bằng số như trên
--Kiểu Ntext: chứa unicode, cấp phát động theo độ dài chuỗi nhập vào
--Lưu ý 2 kiểu này k dùng khai báo cho local var, dùng trong vài TH đb mà ta k xét

SELECT @v1;
SELECT @v2;
SELECT @v3;
SELECT @v4;

DECLARE @datetimeVar DATETIME = '19950419';--có thể yyyymmdd như này
DECLARE @datetimeVar2 DATETIME = '1995-04-19 01:00:00.000';
SELECT @datetimeVar;
SELECT @datetimeVar2;
--DATETIME mặc định là GETDATE(), các kiểu cơ bản bth default là 0/''/0.0. Còn money, bit mặc định là NULL

SELECT COUNT(DISTINCT model_year) FROM production.products
--k có DISTINCT -> số phần tử có cột model_year thì chính là số phần tử
--có DISTINCT -> số lượng model_year khác nhau của bảng

SELECT TOP 5 * FROM production.products

SELECT YEAR(GETDATE()) - YEAR('20010118')

SELECT * 
FROM sales.orders
FULL OUTER JOIN sales.staffs ON sales.orders.staff_id = sales.staffs.staff_id

SELECT * 
FROM sales.orders
CROSS JOIN sales.staffs --tích đề các --muốn điều kiện thì dùng WHERE được
--là 1
SELECT * 
FROM sales.orders, sales.staffs

--2 table muốn UNION với nhau thì phải cùng số cột, ta nên dùng SELECT gì đó 2 cái để cho cùng cột
--A Union B sẽ ra hợp của A và B với các trường định sẵn và nếu bị trùng nhiều cái trong 1 or cả 2 table sẽ bị rút gọn chỉ còn 1
--1345 và 24456 sẽ thành 123456
SELECT first_name FROM sales.contacts
UNION
SELECT last_name FROM sales.staffs
--cột 1 của bảng 1 sẽ hợp với cột 1 của bảng 2 ra cột 1 của bảng gốc lấy tiêu đề là cột của bảng 1

--Phân biệt cái dưới rất xàm lol, khi 2 bảng cùng có first_name thì phải select first_name bảng nào phải nói rõ ra
SELECT sales.contacts.first_name FROM sales.contacts,sales.staffs
--Vc viết 2 bảng liên tiếp nhau FROM table1,table2 tức là tích đề các của 2 table. VD:
--bảng 1 có trường A là 1,2,3 và bảng 2 có trường B là A,B,C thì bảng A,B có 2 trường AB là 1A,1B,1C,2A,2B,2C,3A,3B,3C
--và giả sử như trên ta: SELECT table1.A FROM table1,table2 sẽ ra 1,1,1,2,2,2,3,3,3

--Cách tạo 1 bảng copyTable y hệt sales.staffs nhưng bên trong k có dữ liệu gì
SELECT * INTO CloneTable
FROM sales.staffs
WHERE 6>9

--sau đó có thể thêm data vào 1 bảng từ 1 lệnh select cơ. Thế thì phải bật mode IDENTITY_INSERT cho nó
SET IDENTITY_INSERT CloneTable ON
GO
insert into CloneTable(staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
SELECT staff_id, first_name, last_name, email, phone, active, store_id, manager_id FROM sales.staffs
SET IDENTITY_INSERT CloneTable OFF

SELECT * FROM CloneTable

DROP TABLE CloneTable;

DECLARE @testVar TIMESTAMP = 10;
SELECT @testVar;
DECLARE @testVarChar CHARACTER = '1';
