﻿--Cách xóa dữ liệu trùng nhau trong SQL
DROP TABLE IF EXISTS sales.contacts;
 
CREATE TABLE sales.contacts(
    contact_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL,
);

INSERT INTO sales.contacts
    (first_name,last_name,email) 
VALUES
    ('Syed','Abbas','syed.abbas@example.com'),
    ('Catherine','Abel','catherine.abel@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Kim','Abercrombie','kim.abercrombie@example.com'),
    ('Hazem','Abolrous','hazem.abolrous@example.com'),
    ('Hazem','Abolrous','hazem.abolrous@example.com'),
    ('Humberto','Acevedo','humberto.acevedo@example.com'),
    ('Humberto','Acevedo','humberto.acevedo@example.com'),
    ('Pilar','Ackerman','pilar.ackerman@example.com');

--cách dùng ROW_NUMBER()
--VD: sinh ra 1 trường mới là row_num tự động tăng dần từ 1 theo thứ tự tăng dần của email
SELECT 
    ROW_NUMBER() OVER (
		ORDER BY email
    ) row_num, 
    first_name, 
    last_name,
	email
FROM
    sales.contacts;
--Tùy biến dùng nó như 1 bảng cha lấy tiếp con
SELECT * FROM(
	SELECT 
		ROW_NUMBER() OVER (
			ORDER BY email
		) row_num, 
		first_name, 
		last_name,
		email
	FROM
		sales.contacts
) t WHERE row_num > 3
--Dùng PARTITION BY giống kiểu GROUP BY ấy nhưng là trong ROW_NUMBER để chia ra các nhóm theo trường gì
--Ở đây ta chia ra các nhóm theo trường email. Mỗi nhóm có các record cùng giá trị email. Trong từng nhóm ta sẽ 
--sắp xếp contact_id theo thứ tự giảm dần, kể từ đó trong từng nhóm ta gán 1 trường row_num tăng dần từ 1
--VD trong từng nhóm cùng email ta sẽ thấy row_num cứ tăng dần từ 1, sang nhóm mới thì row_num reset lại 1 r tăng tiếp
SELECT * FROM(
	SELECT 
		contact_id,
		ROW_NUMBER() OVER (
			PARTITION BY email
			ORDER BY contact_id DESC
		) row_num, 
		first_name, 
		last_name,
		email
	FROM
		sales.contacts
) t;
--Cái GROUP BY là gom các data trùng thành 1 cột. Còn ROW_NUMBER là thêm vào các data trùng 1 trường mới tự động tăng dần 
--khiến cho mỗi record đều khác nhau
--Ta có thể ORDER BY nhiều trường để nó order theo từng trường 1 mà đánh số row_num

--cte là Common Table Expression
--muốn dùng thì previous phải kết thúc bằng semicolon
WITH cte AS (--cte là tên đặt cho cte để dùng cho phần câu lệnh bên dưới
	--bên trong AS buộc là 1 câu lệnh SELECT để định nghĩa cte có những gì
    SELECT
        contact_id, 
        first_name, 
        last_name, 
        email, 
        ROW_NUMBER() OVER (
            PARTITION BY
                first_name, 
                last_name, 
                email
            ORDER BY
                first_name, 
                last_name, 
                email
        ) row_num
     FROM
        sales.contacts
)
SELECT * FROM cte;--câu lệnh thực thi làm gì với cte
--Ncl: WITH <tên cte>(<params nếu muốn đăt tên lại>) AS (<định nghĩa lại cte bằng SELECT>) <Dùng các câu lệnh làm gì với cte
--thoải mái>

WITH cte(a,b,c,d,e) AS (--có thể đặt lại tên cho từng field ở đây
    SELECT
        contact_id, 
        first_name, 
        last_name, 
        email, 
        ROW_NUMBER() OVER (
            PARTITION BY
                first_name, 
                last_name, 
                email
            ORDER BY
                first_name, 
                last_name, 
                email
        ) row_num
     FROM
        sales.contacts
)
SELECT a,b,e FROM cte;

--xóa data trùng trong bảng
WITH cte AS (
    SELECT
        contact_id, 
        first_name, 
        last_name, 
        email, 
        ROW_NUMBER() OVER (
            PARTITION BY
                first_name, 
                last_name, 
                email
            ORDER BY
                first_name, 
                last_name, 
                email
        ) row_num
     FROM
        sales.contacts
)
DELETE FROM cte
WHERE row_num > 1--chỉ dùng được 1 câu lệnh với cte
--or nếu chỉ cần hiện ra thì WHERE row_num = 1 là được or ta chỉ cần dùng nested Select là được nhưng ta có thể xóa như này. 
--Điều đặc biệt của cte là nó sẽ xóa trực tiếp trên table gốc nó lấy. Tức ta chạy xong cái này là bảng sales.contacts đã bị 
--xóa các record trùng

SELECT
   contact_id, 
   first_name, 
   last_name, 
   email
FROM
   sales.contacts;