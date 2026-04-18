-- 1. TẠO VÀ SỬ DỤNG DATABASE
CREATE DATABASE Datathon2026;
GO
USE Datathon2026;
GO


-- 2. TẠO CÁC BẢNG MASTER (Không khóa ngoại)
CREATE TABLE geography (
    zip INT PRIMARY KEY,
    city VARCHAR(255),
    region VARCHAR(255),
    district VARCHAR(255)
);


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    segment VARCHAR(100),
    size VARCHAR(50),
    color VARCHAR(50),
    price FLOAT,
    cogs FLOAT,
    CONSTRAINT chk_cogs_price CHECK (cogs < price)
);


CREATE TABLE promotions (
    promo_id VARCHAR(50) PRIMARY KEY,
    promo_name VARCHAR(255),
    promo_type VARCHAR(50),
    discount_value FLOAT,
    start_date DATE,
    end_date DATE,
    applicable_category VARCHAR(100),
    promo_channel VARCHAR(100),
    stackable_flag INT,
    min_order_value FLOAT
);


-- 3. TẠO BẢNG CUSTOMERS (Có khóa ngoại)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    zip INT,
    city VARCHAR(255),
    signup_date DATE,
    gender VARCHAR(50),
    age_group VARCHAR(50),
    acquisition_channel VARCHAR(255),
    FOREIGN KEY (zip) REFERENCES geography(zip)
);


-- 4. TẠO CÁC BẢNG TRANSACTION
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    zip INT,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    device_type VARCHAR(50),
    order_source VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (zip) REFERENCES geography(zip)
);


CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price FLOAT,
    discount_amount FLOAT,
    promo_id VARCHAR(50),
    promo_id_2 VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id),
    FOREIGN KEY (promo_id_2) REFERENCES promotions(promo_id)
);


CREATE TABLE payments (
    order_id INT PRIMARY KEY,
    payment_method VARCHAR(50),
    payment_value FLOAT,
    installments INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE shipments (
    order_id INT PRIMARY KEY,
    ship_date DATE,
    delivery_date DATE,
    shipping_fee FLOAT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    order_id INT,
    product_id INT,
    return_date DATE,
    return_reason VARCHAR(255),
    return_quantity INT,
    refund_amount FLOAT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


CREATE TABLE reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id INT,
    product_id INT,
    customer_id INT,
    review_date DATE,
    rating INT,
    review_title VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- 5. TẠO CÁC BẢNG ANALYTICAL & OPERATIONAL
CREATE TABLE sales (
    Date DATE PRIMARY KEY,
    Revenue FLOAT,
    COGS FLOAT
);


CREATE TABLE inventory (
    snapshot_date DATE,
    product_id INT,
    stock_on_hand INT,
    units_received INT,
    units_sold INT,
    stockout_days INT,
    days_of_supply FLOAT,
    fill_rate FLOAT,
    stockout_flag INT,
    overstock_flag INT,
    reorder_flag INT,
    sell_through_rate FLOAT,
    product_name VARCHAR(255),
    category VARCHAR(100),
    segment VARCHAR(100),
    year INT,
    month INT,
    PRIMARY KEY (snapshot_date, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


CREATE TABLE web_traffic (
    date DATE PRIMARY KEY,
    sessions INT,
    unique_visitors INT,
    page_views INT,
    bounce_rate FLOAT,
    avg_session_duration_sec FLOAT,
    traffic_source VARCHAR(100)
);

-- 1. NẠP MASTER TABLES
BULK INSERT geography FROM 'C:\DatathonData\geography.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT products FROM 'C:\DatathonData\products.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT promotions FROM 'C:\DatathonData\promotions.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


-- 2. NẠP CUSTOMERS
BULK INSERT customers FROM 'C:\DatathonData\customers.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


-- 3. NẠP TRANSACTION TABLES
BULK INSERT orders FROM 'C:\DatathonData\orders.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT order_items FROM 'C:\DatathonData\order_items.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT payments FROM 'C:\DatathonData\payments.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT shipments FROM 'C:\DatathonData\shipments.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT returns FROM 'C:\DatathonData\returns.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT reviews FROM 'C:\DatathonData\reviews.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


-- 4. NẠP ANALYTICAL & OPERATIONAL TABLES
BULK INSERT sales FROM 'C:\DatathonData\sales.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT inventory FROM 'C:\DatathonData\inventory.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
BULK INSERT web_traffic FROM 'C:\DatathonData\web_traffic.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


-- Q1: Trong số các khách hàng có nhiều hơn một đơn hàng, trung vị số ngày giữa hai lần
-- mua liên tiếp (inter-order gap) xấp xỉ là bao nhiêu? (Tính từ orders.csv)
WITH multi_customers AS (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
),
order_gaps AS (
    SELECT 
        o.customer_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_date
        ) AS prev_order_date
    FROM orders o
    JOIN multi_customers m
        ON o.customer_id = m.customer_id
),
diff_days AS (
    SELECT 
        DATEDIFF(DAY, prev_order_date, order_date) AS gap_days
    FROM order_gaps
    WHERE prev_order_date IS NOT NULL
)
SELECT 
    PERCENTILE_CONT(0.5) 
    WITHIN GROUP (ORDER BY gap_days) 
    OVER () AS median_gap_days
FROM diff_days;

-- Q2. Phân khúc sản phẩm (segment) nào trong products.csv có tỷ suất lợi nhuận gộp
-- trung bình cao nhất, với công thức (price − cogs)/price?
SELECT TOP 1
    segment,
    AVG((price - cogs) * 1.0 / price) AS avg_margin
FROM products
GROUP BY segment
ORDER BY avg_margin DESC;

-- Q3. Trong các bản ghi trả hàng liên kết với sản phẩm thuộc danh mục Streetwear (join
-- returns với products theo product_id), lý do trả hàng nào xuất hiện nhiều nhất?
SELECT TOP 1
    r.return_reason,
    COUNT(*) AS total_returns
FROM returns r
JOIN products p
    ON r.product_id = p.product_id
WHERE p.category = 'Streetwear'
GROUP BY r.return_reason
ORDER BY total_returns DESC;

-- Q4. Trong web_traffic.csv, nguồn truy cập (traffic_source) nào có tỷ lệ thoát trung
-- bình (bounce_rate) thấp nhất trên tất cả các ngày xuất hiện nguồn đó trong cột traffic_source?
SELECT TOP 1
    traffic_source,
    AVG(bounce_rate) AS avg_bounce
FROM web_traffic
GROUP BY traffic_source
ORDER BY avg_bounce ASC;

-- Q5: Tỷ lệ phần trăm các dòng trong order_items.csv có áp dụng khuyến mãi (tức là promo_id
-- không null) xấp xỉ là bao nhiêu?
SELECT 
    COUNT(CASE WHEN promo_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS pct
FROM order_items;

-- Q6. Trong customers.csv, xét các khách hàng có age_group khác null, nhóm tuổi nào có số
-- đơn hàng trung bình trên mỗi khách hàng cao nhất? (tổng số đơn / số khách hàng trong
-- nhóm)
SELECT TOP 1
    c.age_group,
    COUNT(o.order_id)*1.0 / COUNT(DISTINCT c.customer_id) AS avg_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.age_group IS NOT NULL
GROUP BY c.age_group
ORDER BY avg_orders DESC;

-- Q7. Vùng (region) nào trong geography.csv tạo ra tổng doanh thu cao nhất trong
-- sales_train.csv?
SELECT TOP 1
    g.region,
    SUM(s.revenue) AS total_revenue
FROM sales s
JOIN orders o
    ON CAST(o.order_date AS DATE) = s.date   -- nếu sales theo ngày
JOIN geography g
    ON o.zip = g.zip
GROUP BY g.region
ORDER BY total_revenue DESC;

-- Q8. Trong các đơn hàng có order_status = ’cancelled’ trong orders.csv, phương thức
-- thanh toán nào được sử dụng nhiều nhất?
SELECT TOP 1
    payment_method,
    COUNT(*) AS cnt
FROM orders
WHERE order_status = 'cancelled'
GROUP BY payment_method
ORDER BY cnt DESC;

-- Q9. Trong bốn kích thước sản phẩm (S, M, L, XL), kích thước nào có tỷ lệ trả hàng cao
-- nhất, được định nghĩa là số bản ghi trong returns chia cho số dòng trong order_items (join
-- với products theo product_id)?

SELECT TOP 1
    p.size,
    COUNT(r.return_id)*1.0 / COUNT(oi.product_id) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN returns r 
    ON oi.product_id = r.product_id 
    AND oi.order_id = r.order_id
GROUP BY p.size
ORDER BY return_rate DESC;

-- Trong payments.csv, kế hoạch trả góp nào có giá trị thanh toán trung bình trên
-- mỗi đơn hàng cao nhất?
SELECT TOP 1
    installments,
    AVG(payment_value) AS avg_pay
FROM payments
GROUP BY installments
ORDER BY avg_pay DESC;