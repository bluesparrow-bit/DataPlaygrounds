/*
    OLIST BUSINESS PERFORMANCE ANALYSIS
    ----------------------------------
    Business context:
    Olist is a marketplace and e-commerce enablement platform that helps sellers
    reach customers, while managing order flow, logistics, and digital commerce.
    The main business risk in this ecosystem is operational execution, especially
    delivery performance and customer trust.

    Key business findings captured in this file:
    1) Delivery time varies significantly by region/state, indicating fulfillment bottlenecks.
    2) The fulfillment cycle (purchase -> approval -> delivery) creates friction and delays.
    3) Financial and operational mismatches may reduce order profitability and create risk.

    The script reuses the existing table names from the project:
    - dbo.[order]
    - customer
    - geolocation
    - order_item
    - order_payment
    - order_review

    Notes:
    - This is designed to support a future business narrative, not just technical analysis.
    - The content is intentionally documented for a client-facing evaluation and for
    explainability in a Data & AI solutions context.
*/

USE olist;
GO

------------------------------------------------------------------------------
-- 1. Business objective / analytical framing
------------------------------------------------------------------------------
-- Olist's value depends on fast, reliable fulfillment and good customer experience.
-- If fulfillment times and review quality are weak, the marketplace loses trust,
-- sellers underperform, and customer retention declines.
--
-- We therefore review the data through three practical lenses:
--   A. Delivery performance by geography
--   B. Fulfillment cycle efficiency and operational friction
--   C. Financial consistency and operational risk
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 2. Preparation: create working tables for business analysis
------------------------------------------------------------------------------

IF OBJECT_ID(N'dbo.Order_Dates_Intervals', N'U') IS NULL
BEGIN
    SELECT
        o.order_id,
        o.customer_id,
        g.state,
        DATEDIFF(HOUR, o.order_purchase_timestamp, o.order_approved_at) AS purchase_to_approved_hours,
        DATEDIFF(HOUR, o.order_approved_at, o.order_delivered_carrier_date) / 24.0 AS approved_to_delivered_carrier_days,
        DATEDIFF(HOUR, o.order_delivered_carrier_date, o.order_delivered_customer_date) / 24.0 AS delivered_carrier_to_customer_days,
        DATEDIFF(HOUR, o.order_purchase_timestamp, o.order_delivered_customer_date) / 24.0 AS total_time_to_deliver_days,
        o.order_status,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    INTO dbo.Order_Dates_Intervals
    FROM dbo.[order] AS o
    JOIN dbo.customer AS c
        ON c.customer_id = o.customer_id
    JOIN dbo.geolocation AS g
        ON c.customer_zip_code_prefix = g.zip_code_prefix
    WHERE o.order_status = 'delivered';
END;
GO

IF OBJECT_ID(N'dbo.OrderTotals', N'U') IS NULL
BEGIN
    SELECT
        order_id,
        SUM(price) AS Total_Price,
        SUM(freight_value) AS Total_Freight,
        SUM(price + freight_value) AS Order_Total
    INTO dbo.OrderTotals
    FROM dbo.order_item
    GROUP BY order_id;
END;
GO

------------------------------------------------------------------------------
-- 3. Finding 1: Regional delivery delays create fulfillment friction
------------------------------------------------------------------------------
-- Business interpretation:
-- If delivery performance differs sharply by state, Olist may be facing uneven
-- logistics execution or different delivery partner performance in different regions.
-- This matters because delays drive negative reviews, reduce trust, and affect seller
-- performance across the marketplace.

SELECT
    state,
    AVG(purchase_to_approved_hours) AS Avg_Approval_Time_Hours,
    AVG(approved_to_delivered_carrier_days) AS Avg_Carrier_Hand_off_Days,
    AVG(delivered_carrier_to_customer_days) AS Avg_Last_Mile_Days,
    AVG(total_time_to_deliver_days) AS Avg_Total_Delivery_Days,
    MAX(total_time_to_deliver_days) AS Max_Total_Delivery_Days
FROM dbo.Order_Dates_Intervals
GROUP BY state
ORDER BY Avg_Total_Delivery_Days DESC, Max_Total_Delivery_Days DESC;
GO

------------------------------------------------------------------------------
-- 4. Finding 2: Fulfillment cycle friction occurs across multiple stages
------------------------------------------------------------------------------
-- Business interpretation:
-- A marketplace is not only judged by marketing reach. It is judged by how quickly
-- the order moves from purchase to actual customer delivery. Long total cycles, and
-- especially slow approval-to-delivery stages, indicate operational friction.
-- This creates customer dissatisfaction and potential seller reputational risk.

SELECT
    AVG(purchase_to_approved_hours) AS Avg_Purchase_To_Approval_Hours,
    AVG(approved_to_delivered_carrier_days) AS Avg_Approval_To_Carrier_Days,
    AVG(delivered_carrier_to_customer_days) AS Avg_Carrier_To_Customer_Days,
    AVG(total_time_to_deliver_days) AS Avg_Total_Delivery_Days,
    MAX(total_time_to_deliver_days) AS Max_Total_Delivery_Days
FROM dbo.Order_Dates_Intervals;
GO

-- Additional operational drill-down by stage:
SELECT
    TOP 10
    state,
    AVG(purchase_to_approved_hours) AS Avg_Purchase_To_Approval_Hours,
    AVG(approved_to_delivered_carrier_days) AS Avg_Approval_To_Carrier_Days,
    AVG(delivered_carrier_to_customer_days) AS Avg_Carrier_To_Customer_Days,
    AVG(total_time_to_deliver_days) AS Avg_Total_Delivery_Days
FROM dbo.Order_Dates_Intervals
GROUP BY state
ORDER BY Avg_Total_Delivery_Days DESC;
GO

------------------------------------------------------------------------------
-- 5. Finding 3: Payment / order-value consistency could reveal financial risk
------------------------------------------------------------------------------
-- Business interpretation:
-- Order totals and payment values should be logically aligned. Large mismatches or
-- irregular patterns can indicate operational issues in pricing, freight, payment
-- capture, or account reconciliation. This is important for financial transparency,
-- margin understanding, and trust in the platform.

SELECT
    OP.order_id,
    OP.payment_type,
    OP.payment_installments,
    OP.payment_value,
    OT.Total_Price,
    OT.Total_Freight,
    OT.Order_Total,
    (OP.payment_value - OT.Order_Total) AS Payment_Minus_Order_Total,
    ABS(OP.payment_value - OT.Order_Total) AS Absolute_Deviation
FROM dbo.order_payment AS OP
JOIN dbo.OrderTotals AS OT
    ON OP.order_id = OT.order_id
ORDER BY ABS(OP.payment_value - OT.Order_Total) DESC;
GO

-- Summary view for financial consistency monitoring:
SELECT
    COUNT(*) AS Total_Orders_Compared,
    AVG(ABS(OP.payment_value - OT.Order_Total)) AS Avg_Order_Payment_Deviation,
    MAX(ABS(OP.payment_value - OT.Order_Total)) AS Max_Order_Payment_Deviation,
    SUM(CASE WHEN ABS(OP.payment_value - OT.Order_Total) > 10 THEN 1 ELSE 0 END) AS Orders_With_Large_Deviation
FROM dbo.order_payment AS OP
JOIN dbo.OrderTotals AS OT
    ON OP.order_id = OT.order_id;
GO

------------------------------------------------------------------------------
-- 6. Optional additional analysis: review-score impact by delay band
------------------------------------------------------------------------------
-- This query connects delivery performance with customer feedback. It is useful for
-- estimating how much delay affects review quality and customer satisfaction.
-- It also supports the business story: poor operations hurt trust.

WITH DelayBuckets AS (
    SELECT
        o.order_id,
        o.order_status,
        CASE
            WHEN DATEDIFF(HOUR, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 48 THEN '0-2 days'
            WHEN DATEDIFF(HOUR, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 96 THEN '2-4 days'
            WHEN DATEDIFF(HOUR, o.order_purchase_timestamp, o.order_delivered_customer_date) <= 168 THEN '4-7 days'
            ELSE '7+ days'
        END AS delivery_bucket,
        r.review_score
    FROM dbo.[order] AS o
    LEFT JOIN dbo.order_review AS r
        ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    delivery_bucket,
    COUNT(*) AS orders_count,
    AVG(CAST(review_score AS FLOAT)) AS avg_review_score,
    MIN(CAST(review_score AS FLOAT)) AS min_review_score,
    MAX(CAST(review_score AS FLOAT)) AS max_review_score
FROM DelayBuckets
GROUP BY delivery_bucket
ORDER BY
    CASE delivery_bucket
        WHEN '0-2 days' THEN 1
        WHEN '2-4 days' THEN 2
        WHEN '4-7 days' THEN 3
        ELSE 4
    END;
GO

------------------------------------------------------------------------------
-- 7. Business decision support summary
------------------------------------------------------------------------------
-- This script supports the following business conclusions:
-- 1) Geographic variation in fulfillment time indicates uneven operational execution.
-- 2) Long cycles across the order fulfillment journey affect customer trust and review quality.
-- 3) Payment and order mismatch analysis highlights possible financial and operational risks.
--
-- These findings are valuable to Olist leadership because they connect operational
-- performance to marketplace health, customer satisfaction, and financial integrity.
------------------------------------------------------------------------------
