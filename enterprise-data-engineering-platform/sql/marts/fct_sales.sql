-- Mart: sales fact table consumed by BI / analytics.
CREATE TABLE IF NOT EXISTS ANALYTICS.MARTS.FCT_SALES (
    order_id       STRING,
    customer_id    STRING,
    product_id     STRING,
    quantity       NUMBER(10,0),
    unit_price     NUMBER(12,2),
    gross_amount   NUMBER(14,2),
    order_ts       TIMESTAMP_NTZ,
    order_date     DATE
);

INSERT OVERWRITE INTO ANALYTICS.MARTS.FCT_SALES
SELECT
    order_id, customer_id, product_id,
    quantity, unit_price, gross_amount, order_ts, order_date
FROM ANALYTICS.STAGING.STG_SALES;
