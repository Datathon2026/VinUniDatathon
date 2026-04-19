-- Q1. Trong số các khách hàng có nhiều hơn một đơn hàng, trung vị số ngày giữa hai lần mua liên tiếp (inter-order gap) xấp xỉ là bao nhiêu? (Tính từ orders.csv)
WITH buying_date AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date, 1) OVER(PARTITION BY customer_id ORDER BY order_date) AS pre_order_date
    FROM orders
),
diff_date AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, pre_order_date, order_date) AS day_gap
    FROM buying_date
    WHERE pre_order_date IS NOT NULL
)
SELECT DISTINCT 
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY day_gap) OVER() AS median_day_gap
FROM diff_date;
--> Chọn C
	
-- Q2. Phân khúc sản phẩm (segment) nào trong products.csv có tỷ suất lợi nhuận gộp trung bình cao nhất, với công thức (price − cogs)/price?
SELECT TOP 1
    segment,
    ROUND(AVG((price - cogs)/price),2) AS gross_profit
FROM products p
GROUP BY segment
ORDER BY gross_profit DESC;
--> Chọn D

-- Q3. Trong các bản ghi trả hàng liên kết với sản phẩm thuộc danh mục Streetwear (join returns với products theo product_id), lý do trả hàng nào xuất hiện nhiều nhất?
SELECT TOP 1
    r.return_reason,
    count(*) as count
FROM returns r
JOIN products p
ON r.product_id = p.product_id
WHERE p.category = 'Streetwear'
GROUP BY r.return_reason
ORDER BY count DESC;
--> Chọn B

-- Q4. Trong web_traffic.csv, nguồn truy cập (traffic_source) nào có tỷ lệ thoát trung bình (bounce_rate) thấp nhất trên tất cả các ngày xuất hiện nguồn đó trong cột traffic_source?
SELECT TOP 1
    traffic_source,
    AVG(bounce_rate) as avg_bounce_rate
FROM web_traffic
GROUP BY traffic_source
ORDER BY avg_bounce_rate;
--> Chọn C

-- Q5. Tỷ lệ phần trăm các dòng trong order_items.csv có áp dụng khuyến mãi (tức là promo_id không null) xấp xỉ là bao nhiêu?
SELECT
    ROUND(CAST(COUNT(CASE WHEN promo_id IS NOT NULL THEN 1 END) AS FLOAT)/  CAST(COUNT(*) AS FLOAT)  * 100.0, 2)  AS discount_percentage
FROM order_items o;
--> Chọn C

-- Q6. Trong customers.csv, xét các khách hàng có age_group khác null, nhóm tuổi nào có số đơn hàng trung bình trên mỗi khách hàng cao nhất? (tổng số đơn / số khách hàng trong nhóm)
SELECT TOP 1
    c.age_group,
    CAST(COUNT(o.order_id) AS FLOAT) / CAST(COUNT(DISTINCT(c.customer_id)) AS FLOAT) AS avg_order
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE age_group IS NOT NULL
GROUP BY c.age_group
ORDER BY avg_order DESC;
--> Chọn A

-- Q7. Vùng (region) nào trong geography.csv tạo ra tổng doanh thu cao nhất trong sales_train.csv?
SELECT TOP 1
    g.region,
    SUM(s.revenue) as total_revenue
FROM sales s
JOIN orders o
    ON s.Date = CAST(o.order_date AS DATE)
JOIN geography g
    ON o.zip = g.zip
GROUP BY g.region
ORDER BY total_revenue DESC;
--> Chọn A

-- Q8. Trong các đơn hàng có order_status = ’cancelled’ trong orders.csv, phương thức thanh toán nào được sử dụng nhiều nhất?
SELECT TOP 1
    payment_method,
    count(*) as count
FROM orders o
WHERE order_status = 'cancelled'
GROUP BY payment_method
ORDER BY count DESC;
--> Chọn A

-- Q9. Trong bốn kích thước sản phẩm (S, M, L, XL), kích thước nào có tỷ lệ trả hàng cao nhất, được định nghĩa là số bản ghi trong returns chia cho số dòng trong order_items (join với products theo product_id)?
SELECT TOP 1
    p.size,
    COUNT(*) as count
FROM orders o
JOIN order_items o2
    ON o.order_id = o2.order_id
JOIN products p
    ON o2.product_id = p.product_id
WHERE o.order_status = 'returned'
GROUP BY p.size
ORDER BY count DESC;
--> Chọn D

-- Q10. Trong payments.csv, kế hoạch trả góp nào có giá trị thanh toán trung bình trên mỗi đơn hàng cao nhất?
SELECT TOP 1
    installments,
    (SUM(payment_value) * 1.0) / COUNT(DISTINCT order_id) AS avg_payment_per_order
FROM payments
GROUP BY installments
ORDER BY avg_payment_per_order DESC;
