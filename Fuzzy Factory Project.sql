/* 1 - First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. */

/* 2 - Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. */

/* 3 - I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? */

/* 4 - Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimizations.*/

/* 5 - We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.*/

/* 6 - Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved.*/

/* 7 - We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each product cross-sells from one another? */

/* 8 - In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and opportunities for us going forward? 
 No right or wrong answer here – I’d just like to hear your perspective! */
 
 USE mavenfuzzyfactory;
 
 -- 1 - First Question -- 
 /* 1 - First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. */
-- First I want to know what are the outside dates to provide a proper quarter
 SELECT 
	min(created_at) AS first_date,
    max(created_at) AS last_date
FROM website_sessions;

-- Then I do my querry splitting by year and quarter
 SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(DATE (ws.created_at)) AS qtr,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders 
FROM website_sessions ws 
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1,2;


-- 2 - Second Question -- 
/* 2 - Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. */

SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(DATE (ws.created_at)) AS qtr,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order_cvr,
    SUM(price_usd)/COUNT(DISTINCT o.order_id) AS revenue_per_order,
    SUM(price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws 
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1,2;

-- 3 - Third Question -- 
/* 3 - I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? */

SELECT * FROM website_sessions;
SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(DATE (ws.created_at)) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS bsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_search_overall,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in
FROM 
	website_sessions ws 
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1,2;

-- 4 - Fourth Question -- 
/* 4 - Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimizations.*/
-- Period of major improvements/optimization : 
	-- at the end of the 4th quarter of 2012 
    -- at the end of the 1st quarter of 2012
    -- 4th quarter of 2013 brand search 
    -- 3rd quarter of 2014 bsearch nonbrand
SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(DATE (ws.created_at)) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_cvr,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_cvr,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_search_overall_cvr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_cvr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_cvr
FROM 
	website_sessions ws 
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY 1,2;

-- 5 - Fifth Question -- 
/* 5 - We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.*/

SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd ELSE NULL END) AS product_1_revenue,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS product_1_margin,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd ELSE NULL END) AS product_2_revenue,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS product_2_margin,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd ELSE NULL END) AS product_3_revenue,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS product_3_margin,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd ELSE NULL END) AS product_4_revenue,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS product_4_margin,
    COUNT(DISTINCT order_id) AS total_sales,
    SUM(price_usd) AS revenue
FROM orders
GROUP BY 1,2;

-- 6 - Sixth Question -- 
/* 6 - Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved.*/

CREATE TEMPORARY TABLE product_page
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    website_session_id AS product_page_session,
    website_pageview_id AS product_website_pageview_id
FROM 
	website_pageviews 
WHERE 
	pageview_url = '/products';
    
-- subquerry
SELECT 
	yr,
    mo,
    product_page_session,
    wp.website_session_id AS session_next_products
FROM 
	product_page pp
	LEFT JOIN website_pageviews wp ON pp.product_page_session = wp.website_session_id
    AND website_pageview_id > product_website_pageview_id
GROUP BY 1,2,3;


SELECT 
    yr,
    mo,
    COUNT(DISTINCT product_page_session) AS product_sessions,
    COUNT(DISTINCT session_next_products) AS following_pages_session,
    COUNT(DISTINCT session_next_products)/COUNT(DISTINCT product_page_session) AS click_through_rate,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT product_page_session) AS product_to_order_cvr
FROM
    (SELECT 
        yr,
            mo,
            product_page_session,
            wp.website_session_id AS session_next_products
    FROM
        product_page pp
    LEFT JOIN website_pageviews wp ON pp.product_page_session = wp.website_session_id
        AND website_pageview_id > product_website_pageview_id
    GROUP BY 1 , 2 , 3) AS post_session_info
    LEFT JOIN orders o ON post_session_info.product_page_session = o.website_session_id
GROUP BY 1 , 2;
    
-- 7 - Seventh Question --     
/* 7 - We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each product cross-sells from one another? */   
CREATE TEMPORARY TABLE primary_product
SELECT 
    created_at, 
    order_id, 
    primary_product_id
FROM
    orders
WHERE
    created_at > '2014-12-05'
ORDER BY order_id;   



SELECT 
	primary_product.* ,
    oi.product_id
FROM 
	primary_product
LEFT JOIN order_items oi ON primary_product.order_id = oi.order_id
	AND oi.is_primary_item = 0 ;
    
SELECT 
	primary_product_id, 
    COUNT(DISTINCT data_for_cross_sell.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_id ELSE NULL END) AS cross_sell_p1,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_id ELSE NULL END) AS cross_sell_p2,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_id ELSE NULL END) AS cross_sell_p3,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_id ELSE NULL END) AS cross_sell_p4
FROM 
	( SELECT 
	primary_product.* ,
    oi.product_id
FROM 
	primary_product
LEFT JOIN order_items oi ON primary_product.order_id = oi.order_id
	AND  oi.is_primary_item = 0 ) AS data_for_cross_sell
GROUP BY 1;
    

    
-- 8 - Eighth Question -- 
/* 8 - In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and opportunities for us going forward? 
 No right or wrong answer here – I’d just like to hear your perspective! */    

Create additional products similar to the cross sell best sold items 
Improving the ad campaigns 
Improve the mobile customer experience to improve the mobile sessions and users 






