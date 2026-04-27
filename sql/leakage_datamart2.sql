-- CODE TẠO LEAKAGE_DATAMART VER 2---
-- Xóa bảng cũ nếu tồn tại
IF OBJECT_ID('leakage_datamart', 'U') IS NOT NULL 
    DROP TABLE leakage_datamart; 
-- Tính tổng giá trị Giao dịch Hàng hóa (Gross Merchandise Value - GMV) của toàn bộ đơn
WITH Order_Total AS ( 
    SELECT 
        order_id, 
        SUM(CAST(unit_price AS DECIMAL(18,2)) * quantity) AS total_order_gmv 
    FROM order_items 
    GROUP BY order_id
) 


SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_status, 
    o.order_date,
    YEAR(o.order_date) AS order_year, 
    MONTH(o.order_date) AS order_month,
    
    oi.product_id, 
    p.category, 
    p.segment, 
    
    -- Mặc định 'no_return' đối với hàng Hủy (Cancelled) hoặc các mặt hàng không bị trả lại trong một đơn hàng hoàn trả một phần.
    COALESCE(r.return_reason, 'no_return') AS return_reason,

    -- Lấy số lượng mua gốc
    oi.quantity AS purchased_quantity,
    
    -- Sửa lỗi ERR_RET_001: Ràng buộc tính hợp lệ của số lượng trả hàng: số lượng trả không được phép lớn hơn số lượng khách đã mua
    CASE 
        WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity
        ELSE COALESCE(r.return_quantity, 0) 
    END AS actual_return_quantity,

    oi.unit_price, 
    COALESCE(oi.discount_amount, 0) AS original_discount_amount,
    
    -- Đo lường giá trị hàng hóa không thể chuyển đổi thành dòng tiền do đơn 'cancelled' hoặc 'returned'
    CAST(
        CASE 
            WHEN o.order_status = 'cancelled' OR (o.order_status = 'returned' AND r.return_reason IS NOT NULL) THEN 
                (oi.unit_price * (CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
            ELSE 0 
        END 
    AS DECIMAL(18,2)) AS row_lost_gmv,

    -- Tiền hoàn lại cho khách hàng khi xảy ra trả hàng (refund amount)
    -- Logic: Giá trị trả lại = (Đơn giá x Số lượng thực trả) - (Khuyến mãi trung bình/SP x Số lượng thực trả)
    -- Công ty chỉ hoàn lại số tiền thực tế khách đã thanh toán sau khi trừ đi phần chiết khấu
    CAST(
        CASE 
            WHEN o.order_status = 'returned' AND r.return_reason IS NOT NULL THEN 
                (oi.unit_price * (CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) 
                - 
                ((COALESCE(oi.discount_amount, 0) / NULLIF(oi.quantity, 0)) * (CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END))
            ELSE 0 
        END 
    AS DECIMAL(18,2)) AS row_refund_amount,

    -- Reverse Logistic Cost (Chi phí vận chuyển chiều đi): Áp dụng cho các đơn hàng bị trả lại (Returned) với lý do hợp lệ, hoặc đơn hàng bị hủy (Cancelled) có phí ship đã phát sinh
    -- Logic: Phân bổ phí vận chuyển chiều đi theo tỷ trọng hàng trả, sau đó nhân hệ số phạt
    CAST(
        CASE 
            WHEN o.order_status = 'returned' AND r.return_reason IS NOT NULL THEN
                CASE 
                    -- Lỗi từ công ty (Chất lượng, Vận hành): Công ty chịu phạt đền bù gấp đôi phí ship (Hệ số x2).
                    WHEN r.return_reason IN ('not_as_described', 'defective', 'late_delivery') THEN 
                        2.0 * (COALESCE(s.shipping_fee, 0) * (oi.unit_price * (CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) / NULLIF(ot.total_order_gmv, 0))
                    -- Lỗi từ khách hàng (Đổi ý, Sai size): Công ty chỉ chịu phí ship thu hồi cơ bản (Hệ số x1).
                    WHEN r.return_reason IN ('wrong_size', 'changed_mind') THEN 
                        1.0 * (COALESCE(s.shipping_fee, 0) * (oi.unit_price * (CASE WHEN COALESCE(r.return_quantity, 0) > oi.quantity THEN oi.quantity ELSE COALESCE(r.return_quantity, 0) END)) / NULLIF(ot.total_order_gmv, 0))
                    ELSE 0 
                END
            ELSE 0 
        END 
    AS DECIMAL(18,2)) AS row_reverse_logistic_cost

INTO leakage_datamart

FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
LEFT JOIN shipments s ON o.order_id = s.order_id
LEFT JOIN Order_Total ot ON o.order_id = ot.order_id
-- LEFT JOIN với returns để join chính xác thông tin hàng bị trả về
LEFT JOIN returns r ON oi.order_id = r.order_id AND oi.product_id = r.product_id

-- Chỉ lọc các trạng thái gây ra sự cố dòng tiền và rủi ro vận hành (Cancelled, Returned).
WHERE o.order_status IN ('returned', 'cancelled');
ALTER TABLE leakage_datamart ADD row_total_financial_loss DECIMAL(18,2);
GO

UPDATE leakage_datamart 
SET row_total_financial_loss = row_refund_amount + row_reverse_logistic_cost;

SELECT * FROM leakage_datamart;