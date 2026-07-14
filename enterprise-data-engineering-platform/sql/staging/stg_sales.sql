-- Staging: 1:1 with the raw external table, light typing + naming only.
CREATE OR REPLACE VIEW ANALYTICS.STAGING.STG_SALES AS
SELECT
    order_id::STRING          AS order_id,
    customer_id::STRING       AS customer_id,
    product_id::STRING        AS product_id,
    quantity::NUMBER(10,0)    AS quantity,
    unit_price::NUMBER(12,2)  AS unit_price,
    order_ts::TIMESTAMP_NTZ   AS order_ts,
    order_date::DATE          AS order_date,
    gross_amount::NUMBER(14,2) AS gross_amount
FROM ANALYTICS.STAGING.RAW_SALES_EXT;
