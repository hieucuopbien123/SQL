﻿--A có khóa ngoại đến primary key của B thì muốn thêm data vào A thì khi thêm giá trị trường FOREIGN KEY của A thì phải đảm bảo B 
--có giá trị PRIMARY KEY đó
SELECT
    *
FROM
	production.products, production.categories--lấy từ nhiều bảng
WHERE product_name IS NOT NULL

SELECT
    product_name,
    category_name,
    list_price
FROM
    production.products p--có thể đặt tên giả cho nó là p như này để tiện dùng về sau
INNER JOIN production.categories c --có thể bỏ chữ INNER thì mặc định SQL cũng hiểu JOIN là INNER JOIN
    ON c.category_id = p.category_id
ORDER BY
    product_name DESC;
/*VD: A có 1,2,3 và B có X,Y,Z thì dùng như cách đầu sẽ ra 9 giá trị do nó lấy tích đề các. Còn dùng như cách 2 mới là chuẩn vì
nó lấy ở 2 bảng lọc ra trùng trường nào mới lấy. Do đó cách 1 ta thấy có 2 trường trùng nhau là category_id vì nó k compare gì hết
VD nó ra 2X và 3Y
Nhưng left join sẽ cho ra 1NULL, 2X và 3Y
*/

--Join 3 bảng
SELECT
    product_name,
    category_name,
    brand_name,
    list_price
FROM
    production.products p
INNER JOIN production.categories c ON c.category_id = p.category_id
INNER JOIN production.brands b ON b.brand_id = p.brand_id
ORDER BY
    product_name DESC;

--sản phẩm phải nằm bên trái còn các đơn hàng nằm bên phải, vc dùng left join tức lấy tất cả của bên trái
--Tức A left join B in ra tất cả cái mà cả A và B có cùng 1 giá trị trường và các cái A có B k có. Hay nói cách khác ta sẽ lấy được
--mọi thứ của bảng bên trái còn bảng bên phải chỉ lấy được những thứ trùng với bảng bên trái
SELECT
    product_name,
    order_id
FROM
    production.products p
LEFT JOIN sales.order_items o ON o.product_id = p.product_id
ORDER BY
    order_id;

--left join 3 bảng
SELECT
    p.product_name,
    o.order_id,
    i.item_id,
    o.order_date
FROM
    production.products p
    LEFT JOIN sales.order_items i
        ON i.product_id = p.product_id
    LEFT JOIN sales.orders o
        ON o.order_id = i.order_id
ORDER BY
    order_id;
--Ở đây nó left join products và order_items thành 1 bảng tạm xong lại left join bảng tạm đó với order để ra kết quả

--Phân biệt dùng WHERE trong left join
SELECT
    product_name,
    order_id
FROM
    production.products p
LEFT JOIN sales.order_items o 
   ON o.product_id = p.product_id
WHERE order_id = 100
ORDER BY
    order_id;
-- =>trả về kết quả trong bảng tạm bị lọc ra 

--TH2 dùng điều kiện như WHERE nhưng lại trong ON của LEFT JOIN thì đầu tiên nó sẽ lọc các thứ ở bảng bên trái thỏa mãn điều kiện
--đó. Sau đó nó lấy tất cả ở bảng bên trái. Do đó ra kết quả khác bên trên. Bên trên lấy hết r lọc nên k có NULL nx. Còn bên dưới
--nó chỉ lọc điều kiện cho bảng bên trái trước r mới lấy tất cả ở bên trái, bước lấy tất cả bên trái đó nó k lọc gì nx nên có NULL
SELECT
    p.product_id,
    product_name,
    order_id
FROM
    production.products p
    LEFT JOIN sales.order_items o 
         ON o.product_id = p.product_id AND
            o.order_id = 100 AND p.product_id = 7
ORDER BY
    order_id DESC;

UPDATE production.products 
SET
    product_name = 'Hill',--nhiều trường bằng dấu phẩy được
	model_year = 2018
WHERE
    product_id = 321;

UPDATE production.products 
SET list_price = REPLACE(list_price,'.99','.98')--số cũng đổi được như string
WHERE
	product_name = 'Hill' AND model_year = 2018

SELECT * FROM production.products 

--Để xóa dữ liệu mà có ràng buộc foreign key thì phải xóa toàn bộ dữ liệu ở bảng con có khóa ngoại trùng với khóa chính trước
--Ta có thể dùng ON DELETE CASCADE khi tạo khóa ngoại ở bảng con để đảm bảo mọi thứ tự động được xóa ở bảng con khi ta xóa bảng cha

CREATE TABLE employees(
	employeesName VARCHAR(100),
	officeCode INT,
)
DELETE FROM employees WHERE officeCode = 4; --xóa có điều kiện
DELETE FROM employees; --xóa tất cả table, gần giống truncate

--trong database employees ta chọn ra 10 employeesName đầu tiên khi sắp xếp employees giảm dần theo employeesName => sau đó xóa
--các data có employeesName bằng với 1 trong 10 employeesName đó
DELETE FROM employees
WHERE employeesName IN 
   (SELECT TOP 10 employeesName
    FROM employees
    ORDER BY employeesName DESC); 

--muốn xóa 10 dòng đầu thì cx ok bằng cách chỉnh sửa phần delete
DELETE TOP(10) FROM employees

DROP TABLE employees