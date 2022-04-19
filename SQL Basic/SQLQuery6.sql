--con lồng con, SQL hỗ trợ max đến 32 truy vấn con lồng nhau
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price > (--truy vấn con luôn nằm trong (), truy vấn cha chứa truy vấn con
        SELECT
            AVG (list_price)--dùng thoải mái các hàm. Cái này không trả ra 1 table mà ra đúng 1 số là tb list_price mọi
			--sản phẩm trong data trả ra và so sánh với list_price
        FROM
            production.products
        WHERE
            brand_id IN (
                SELECT
                    brand_id
                FROM
                    production.brands
                WHERE
                    brand_name = 'Strider' OR brand_name = 'Trek'
            )
    )
	AND
	list_price >= ALL (
        SELECT
            AVG (list_price)
        FROM
            production.products
        GROUP BY
            brand_id
    )
ORDER BY
    list_price
--dùng ALL kết hợp với GROUP BY bên trong. Khác với TH trên lấy trung bình cộng của cả table và trả ra 1 số thì ở đây nó trả ra table
--1 cột các trung bình cộng của các nhóm. Từ ALL sẽ đảm bảo list_price phải lớn hơn giá trị lớn nhất của tất cả trung bình cộng của
--từng nhóm


SELECT
    customer_id,
    first_name,
    last_name,
    city
FROM
    sales.customers c --đặt tên ở ngoài dùng được ở trong
WHERE
    EXISTS (--EXISTS đảm bảo table bên trong phải có ít nhất 1 bản ghi. Có thể dùng NOT EXISTS
        SELECT
            customer_id
        FROM
            sales.orders o
        WHERE
            o.customer_id = c.customer_id AND YEAR (order_date) = 2017
    )
ORDER BY
    first_name,
    last_name;


--khi sử dụng subquery, nếu ta cần lấy gì trong query đó ở ngoài thì phải đặt cho nó 1 cái tên ở dưới là t. Khi đó SQL tự hiểu 
--dùng tên đó là t.order_count, ta có thể viết rõ như v or như dưới là cách viết gọn 
SELECT
   AVG(order_count) average_order_count_by_staff
FROM
(
    SELECT
		staff_id, 
        COUNT(order_id) order_count
    FROM sales.orders
    GROUP BY staff_id
) t
go

--Tạo 1 view. Dùng go trước nó nhé để đảm bảo nó là statement đầu tiên of the batch
CREATE VIEW sales.product_info --product_info là tên view
AS
SELECT
    product_name, 
    brand_name
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;
go
--update view
ALTER VIEW sales.product_info 
AS
SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;
go

--sử dụng view. Nhớ go trước
SELECT * FROM sales.product_info;

DROP VIEW sales.product_info;