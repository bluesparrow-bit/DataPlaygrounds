--CREATE DATABASE olist

--ALTER DATABASE olist
--SET SINGLE_USER
--WITH ROLLBACK IMMEDIATE;

--DROP DATABASE olist

USE olist

ALTER TABLE GEOLOCATION
	ALTER COLUMN [zip_code_prefix] BIGINT NOT NULL;
	
ALTER TABLE GEOLOCATION
	ADD CONSTRAINT PK_geolocation PRIMARY KEY (zip_code_prefix);
GO


IF NOT EXISTS (SELECT * FROM Order_Dates_Intervals)
	BEGIN
		SELECT 
		o.customer_id,
		g.state,
		DATEDIFF(HOUR, order_purchase_timestamp, order_approved_at) AS purchase_to_approved_hours,
		DATEDIFF(HOUR, order_approved_at, order_delivered_carrier_date)/24 AS approved_to_delivered_carrier_days,
		DATEDIFF(HOUR, order_delivered_carrier_date, order_delivered_customer_date)/24 AS delivered_carrier_to_customer_days,
		DATEDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date)/24 AS total_time_to_deliver_days
		INTO Order_Dates_Intervals
		FROM [dbo].[order] o
		JOIN customer c
		ON c.customer_id = o.customer_id
		JOIN geolocation g
		ON c.customer_zip_code_prefix = g.zip_code_prefix
		WHERE order_status = 'delivered'
	END
GO

SELECT STATE,
AVG(purchase_to_approved_hours) AS Average_Approval_Time_hours,
AVG(approved_to_delivered_carrier_days) AS Average_Carrier_Delivery_Time_days,
AVG(delivered_carrier_to_customer_days) AS Average_Customer_Delivery_Time_days,
AVG(total_time_to_deliver_days) AS Average_Total_Delivery_Time_days,
MAX(purchase_to_approved_hours)/24 AS Higest_Approval_Durtaion_H,
MAX(approved_to_delivered_carrier_days) AS Higest_Carrier_Delivery_Durtaion_D,
MAX(delivered_carrier_to_customer_days) AS Higest_Customer_Delivery_Durtaion_D,
MAX(total_time_to_deliver_days) AS Higest_Total_Durtaion_D
FROM Order_Dates_Intervals
GROUP BY (state)
ORDER BY Higest_Total_Durtaion_D DESC, Higest_Customer_Delivery_Durtaion_D DESC, Higest_Carrier_Delivery_Durtaion_D DESC, Higest_Approval_Durtaion_H DESC

GO

IF NOT EXISTS (SELECT * FROM OrderTotals)
	BEGIN
		SELECT
		order_id,
		SUM(price) AS Total_Price,
		SUM(freight_value) AS Total_Freight,
		SUM(price + freight_value) AS Order_Total
		INTO OrderTotals
		FROM [dbo].[order_item]
		GROUP BY order_id
	END

GO

SELECT
    OP.order_id,
    OP.payment_sequential,
    OP.payment_type,
    OP.payment_installments,
    OP.payment_value,
    OT.Total_Price,
    OT.Total_Freight,
    OT.Order_Total
FROM [dbo].[order_payment] OP
JOIN OrderTotals OT
    ON OP.order_id = OT.order_id;

GO