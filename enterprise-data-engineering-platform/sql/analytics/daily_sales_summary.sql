-- Analytics: daily revenue rollup for dashboards.
CREATE OR REPLACE VIEW ANALYTICS.MARTS.VW_DAILY_SALES AS
SELECT
    order_date,
    COUNT(DISTINCT order_id)  AS orders,
    SUM(quantity)             AS units_sold,
    SUM(gross_amount)         AS revenue,
    AVG(gross_amount)         AS avg_order_value
FROM ANALYTICS.MARTS.FCT_SALES
GROUP BY order_date
ORDER BY order_date;
