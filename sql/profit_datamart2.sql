-- CODE TẠO PROFIT_DATAMART V2 (BỔ SUNG PROFIT MARGIN) -----
-- Xóa bảng nếu đã tồn tại
IF OBJECT_ID('profit_datamart', 'U') IS NOT NULL
    DROP TABLE profit_datamart;

-- Tính tổng giá trị Giao dịch Hàng hóa (Gross Merchandise Value - GMV) của toàn bộ đơn
WITH Order_Total AS (
    SELECT order_id, SUM(CAST(unit_price AS DECIMAL(18,2)) * quantity) AS total_order_gmv
    FROM order_items
    GROUP BY order_id
)

-- Main query
SELECT
   -- Thông tin đơn và khách hàng
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_date,
    s.delivery_date,
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,

   -- Thông tin sản phẩm
    oi.product_id,
    p.category,
    p.segment,

   -- Các biến được thêm trong quá trình EDA
    COALESCE(p.is_deadstock, 0) AS is_deadstock,
    CASE
        WHEN p.cogs >= p.price THEN 'selling_at_loss'
        WHEN p.cogs >= 0.95 * p.price THEN 'margin_risk'
        ELSE 'healthy_margin'
    END AS margin_risk_category,
    oi.promo_id,
    COALESCE(pr.stackable_flag, 0) AS stackable_flag,

   -- Các cột logic số lượng
    oi.quantity AS purchased_quantity,
    CASE
        WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity
        ELSE COALESCE(r.return_quantity, 0)
    END AS returned_quantity,
    (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END) AS kept_quantity,

    oi.unit_price,
    p.cogs,

   -- Các chỉ số tài chính (Financial Metrics)
    CAST((oi.unit_price * oi.quantity) AS DECIMAL(18,2)) AS row_gmv,

    CAST((oi.unit_price * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) AS DECIMAL(18,2)) AS row_realized_revenue,

    CAST((p.cogs * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) AS DECIMAL(18,2)) AS row_actual_cogs,

    CAST(((COALESCE(oi.discount_amount, 0) / NULLIF(oi.quantity, 0)) * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) AS DECIMAL(18,2)) AS row_actual_discount,

    CAST((COALESCE(s.shipping_fee, 0) * 1.0 * (oi.unit_price * oi.quantity) / NULLIF(ot.total_order_gmv, 0)) AS DECIMAL(18,2)) AS allocated_shipping_fee,

    -- Net profit
    CAST((
      (oi.unit_price * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
      - (p.cogs * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
      - ((COALESCE(oi.discount_amount, 0) / NULLIF(oi.quantity, 0)) * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
    ) AS DECIMAL(18,2)) AS row_net_profit,

    -- Profit Margin
    -- Logic: Net Profit / Doanh thu thực nhận. Tránh lỗi chia cho 0 bằng CASE WHEN.
    CASE 
        WHEN (oi.unit_price * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) > 0 
        THEN 
            CAST(
                (
                  (oi.unit_price * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
                  - (p.cogs * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
                  - ((COALESCE(oi.discount_amount, 0) / NULLIF(oi.quantity, 0)) * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
                ) 
                / 
                (oi.unit_price * (oi.quantity - CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
            AS DECIMAL(18,4))
        ELSE 0 
    END AS row_profit_margin

INTO profit_datamart
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN shipments s ON o.order_id = s.order_id
LEFT JOIN Order_Total ot ON o.order_id = ot.order_id
LEFT JOIN returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id
LEFT JOIN promotions pr ON oi.promo_id = pr.promo_id
WHERE(
o.order_status IN ('delivered', 'returned') 
OR(o.order_status = 'shipped' AND s.delivery_date IS NOT NULL))
AND p.price > 0
AND p.cogs >= 0;

SELECT * FROM profit_datamart;