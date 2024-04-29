-- -----------------------------------0.1. RUNNING THE PRE-REQUSITE FILE-----------------------------------------
-- -----------------------------------0.2. CREATING THE DATABASE FROM FILE--------------------------------------

USE mavenfuzzyfactory;
SELECT * FROM website_sessions;

-- -----------------------------------1. TRAFFIC SOURCE ANALYSIS---------------------------------------------


SELECT *
FROM website_sessions
WHERE user_id BETWEEN 1000 AND 2000;



SELECT 
	utm_content,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000
GROUP BY utm_content                   -- or we can directly type 1 (first row after SELECT)
ORDER BY sessions DESC;				   -- or we can directly type 2 (second row after SELECT)		
									   -- Query reveals that g_ad_1 has maximum sessions 



SELECT 
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1                  
ORDER BY 2 DESC;	-- Query results in revealing that most sessions come from utm_content g_ad_1, and has max orders



SELECT 
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/ COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt  -- Calculating conversion rate ie successful outcomes over number of attempts made.
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1                  
ORDER BY 2 DESC;	 -- Query shows that for conversion rate for g_ad_1 is .0359


-- 1.1 FINDING TOP TRAFFIC SOURCES 

SELECT 	
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS Number_of_sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 
	utm_source,
	utm_campaign,
	http_referer
ORDER BY Number_of_sessions DESC;  -- reveals utm_source gsearch nonbrand has max sessions
 
 
-- 1.2 FINDING ORDERS TO SESSION CONVERSION RATE FOR gsearch nonbrand 


SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS order_to_session_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_campaign = 'nonbrand'
    AND utm_source= 'gsearch' ;  -- reveals order to session conversion rate to be .0288 or 2.88%
    
    
    
    -- -----------------------------------2.-BID OPTIMIZATION---------------------------------------------

SELECT
	YEAR(created_at),
	WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
   	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 150000
GROUP BY 1, 2;


    -- CASE PIVOTING METHOD--

SELECT 
	primary_product_id,
    order_id,
    items_purchased,
    CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END AS single_item_orderid,
	CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END AS two_item_orderid
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
ORDER BY 1; -- displays order ids where orders are one or two items


SELECT 
	primary_product_id,
    COUNT(CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_single_item_orderid,
	COUNT(CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orderid
       
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1
ORDER BY 1;


    -- 2.1 WEEKLY TRAFFIC SOURCE TRENDING--


SELECT 
	-- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
    MIN(DATE(created_at)) AS week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE 
	created_at < '2012-05-12' 
	AND utm_source = 'gsearch' 
    AND utm_campaign= 'nonbrand'
GROUP BY 
	YEAR(created_at), 
    WEEK(created_at);
	
    -- 2.2 CONVERSION RATES BY DEVICE TYPE--


SELECT 
	website_sessions.device_type,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id)/ COUNT(website_sessions.website_session_id) AS orders_to_session_cov_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at< '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;


-- 2.3 TRAFFIC SOURCE SEGMENT TRENDING (USING CASE PIVOTING)--


SELECT 
	-- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
	-- COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
WHERE website_sessions.created_at< '2012-06-09'
	AND website_sessions.created_at> '2012-04-15'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at); 



-- -------------------------------------------3. ANALYZING TOP WEBSITE CONTENT---------------------------------------------



-- CREATING TEMPORARY TABLES 

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id<1000
GROUP BY 1
ORDER BY pvs DESC;  -- query shows the count of times, the user landed on different pages(url)


CREATE TEMPORARY TABLE first_pageview            -- Creating temporary table
SELECT 
	website_session_id,
	MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1;


SELECT 
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page   -- aka entry page
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id;


SELECT 
	website_pageviews.pageview_url AS landing_page,   -- aka entry page
    COUNT(DISTINCT first_pageview.website_session_id) AS session_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY
	website_pageviews.pageview_url;   -- Using Temporary Table, query shows sessions hitting the landing page
    

SELECT
	pageview_url,
    COUNT(DISTINCT(website_session_id)) AS sessions 
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY sessions DESC; 	-- query shows url by sessions in descending order


-- 3.1 Using temporary table to find out how many times different pages were landed on the first time


CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
	website_pageviews.pageview_url AS landing_page_url,
	COUNT(DISTINCT(first_pv_per_session. website_session_id)) AS sessions_hitting_page
FROM first_pv_per_session
	LEFT JOIN website_pageviews
		ON first_pv_per_session.first_pv = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url; 			-- Query reveals that home page if infact the landing page for all users 




-- ----------------------------------------4. LANDING PAGE PERFORMANCE AND TESTING---------------------------------------------

-- A) Finding the bounce rate and the bounced sessions
	-- A1. find the first website_pageview_id for the relevant sessions
	-- A2. find the landing page of each sessions
	-- A3. count page views for each sessions, to find 'bounces'
	-- A4. summarize by counting total sessions





-- A1. finding the first website_pageview_id for the relevant sessions
CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY
	website_session_id;



-- A2. finding the landing page of each sessions
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url = '/home';



-- A3. counting page views for each sessions, to find 'bounces' ie sessions that saw only one landing page and never went to another page.
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_views
FROM sessions_w_home_landing_page
	LEFT JOIN website_pageviews
		ON	website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;



SELECT
	sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY
	sessions_w_home_landing_page.website_session_id;  -- This query reveals which session was bounced and which were not bounced.
    
    
    
-- A4. summarizing by counting total sessions
SELECT
	COUNT(DISTINCT(sessions_w_home_landing_page.website_session_id)) AS sessions,
    COUNT(DISTINCT(bounced_sessions.website_session_id)) AS bounced_sessions
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;  -- Query shows bounced sessions and total sessions
        
SELECT
	COUNT(DISTINCT(sessions_w_home_landing_page.website_session_id)) AS sessions,
    COUNT(DISTINCT(bounced_sessions.website_session_id)) AS bounced_sessions,
    COUNT(DISTINCT(bounced_sessions.website_session_id))/ COUNT(DISTINCT(sessions_w_home_landing_page.website_session_id)) AS bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;  -- Query shows bounce rate

    
-- B) Finding bounce rate of the home page with repect to a new custom landing page called '/lander-1'
    
-- B0. Find when the new page /lander was launched
-- B1. find the first website_pageview_id for relevant sessions
-- B2. identify landingpage of each sessions
-- B3. count page views for each sessions, to find bounces
-- B4. summarize total sessions and bounced sessions


    
-- B0. Find when the new page /lander was launched    
SELECT
	MIN(created_at) AS first_created_at,
	MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL; 				-- first created at '2012-06-19 00:35:54' 23504

    

-- B1. finding the first website_pageview_id for relevant sessions    
 CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at <'2012-07-28'
        AND website_pageviews.website_pageview_id > 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;
    
    
-- B2. identifying landingpage of each sessions   
CREATE TEMPORARY TABLE nonbrand_test_session_w_landing_page
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');
    
    
    
-- B3. count page views for each sessions, to find bounces
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	nonbrand_test_session_w_landing_page.website_session_id,
    nonbrand_test_session_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_views
FROM nonbrand_test_session_w_landing_page
	LEFT JOIN website_pageviews
		ON	website_pageviews.website_session_id = nonbrand_test_session_w_landing_page.website_session_id
GROUP BY 
	nonbrand_test_session_w_landing_page.website_session_id,
    nonbrand_test_session_w_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    

SELECT
	nonbrand_test_session_w_landing_page.landing_page,
	nonbrand_test_session_w_landing_page.website_session_id,
    nonbrand_test_bounced_sessions.website_session_id AS bounced_website_session_id
FROM nonbrand_test_session_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_session_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
ORDER BY
	nonbrand_test_session_w_landing_page.website_session_id;  -- This query reveals which session of home and lander-1 was bounced and which were not bounced.    
    
    
    
-- B4. summarize total sessions and bounced sessions

SELECT
	nonbrand_test_session_w_landing_page.landing_page,
	COUNT(DISTINCT(nonbrand_test_session_w_landing_page.website_session_id)) AS sessions,
    COUNT(DISTINCT(nonbrand_test_bounced_sessions.website_session_id)) AS bounced_sessions
FROM nonbrand_test_session_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_session_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id  -- Query shows bounced sessions and total sessions
GROUP BY 
	nonbrand_test_session_w_landing_page.landing_page;

SELECT
	nonbrand_test_session_w_landing_page.landing_page,
	COUNT(DISTINCT(nonbrand_test_session_w_landing_page.website_session_id)) AS sessions,
    COUNT(DISTINCT(nonbrand_test_bounced_sessions.website_session_id)) AS bounced_sessions,
    COUNT(DISTINCT(nonbrand_test_bounced_sessions.website_session_id)) /COUNT(DISTINCT(nonbrand_test_session_w_landing_page.website_session_id)) AS bounced_rate
FROM nonbrand_test_session_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_session_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id  -- Query shows bounced sessions and total sessions
GROUP BY 
	nonbrand_test_session_w_landing_page.landing_page;     -- bounced rate calculation



-- C) Finding the volume of paid search nonbrand traffic landing on /home and /lander-1 trending weekly since June 1st, and overall paid search bouncerate weekly.

-- C1. find the first website_pageview_id for relevant sessions
-- C2. identify landingpage of each sessions
-- C3. count page views for each sessions, to find bounces
-- C4. summarize by weeek (bounce rate and sessions to each lander)


-- C1. finding the first website_pageview_id for relevant sessions

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count 
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-01'
    AND website_sessions.created_at < '2012-08-31'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_sessions.website_session_id;


-- C2. identify landingpage of each sessions

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;


-- C3 and C4. counting page views for each sessions, to find bounces and the bounce rate

SELECT
	-- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    -- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS bounced_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_counts_lander_and_created_at
GROUP BY YEARWEEK(session_created_at);


-- ------------------------------------------5. ANALYSING AND TESTING CONVERSION FUNNELS---------------------------------------------

-- 5.1. select all page views for relevant sessions
-- 5.2. identify each relevant pageview as the specific funnel type
-- 5.3. create session level conversion funnel view
-- 5.4. aggregate the data to assess funnel performance and findind click_rates


-- 5.1. selecting all page views for relevant sessions
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- time frame of 1 month
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at;            -- Query shows website sessions alongside url of the pages in a session



SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- time frame of 1 month
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at;            -- Query shows flag values as 0 or 1 for the case conditions


-- 5.3. createing a session level conversion funnel view
SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
  FROM (	
SELECT																			-- subquerying previous select statement
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- time frame of 1 month
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at  
) AS pageview_level
GROUP BY 
	website_session_id;


CREATE TEMPORARY TABLE session_level_made_it_flags_demo         -- creating a temporary table from the previous statement
SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
  FROM (	
SELECT																			
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- time frame of 1 month
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at  
) AS pageview_level
GROUP BY 
	website_session_id;


-- 5.4. aggregate the data to assess funnel performance and findind click_rates


SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM session_level_made_it_flags_demo ;				-- query shows total sessions and the number so sessions in product, mrfuzzy,cart page. 



-- Finding click rates
SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT website_session_id) AS lander_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
		/  COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_clickthrough_rates,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickthrough_rate
FROM session_level_made_it_flags_demo;



-- D) NOW finding where the gsearch visitors are lost between lander-1 page and placing an order. using dates between sept 5th and august 5th


-- D1. select all page views for relevant sessions
-- D2. identify each relevant pageview as the specific funnel type
-- D3. create session level conversion funnel view
-- D4. aggregate the data to assess funnel performance and findind click_rates


SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05' 
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at;            -- Query shows flag values as 0 or 1 for the case conditions and different pages


SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
  FROM (	
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05' 
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id;


CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
	website_session_id,
    MAX(product_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
  FROM (	
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
    LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05' 
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id;



SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags ;				-- query shows total sessions and the number so sessions in product, mrfuzzy,cart page. 


-- Finding click rates
SELECT
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
		/  COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS thankyou_click_rt  
FROM session_level_made_it_flags;



-- E) Testing if billing-2 page is performing better than /billing page- finding what % of sessions actually place an order 


-- E1. finding the point of time when billing-2 went live
SELECT
	MIN(website_pageviews.website_pageview_id) as first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';   -- first_pv_id = 53550

SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550 
	AND website_pageviews.created_at< '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2');  -- Query shows website sessions along with billing version and order id
    


SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/ COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM(
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550 
	AND website_pageviews.created_at< '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2') 
) AS billing_sessions_w_orders
GROUP BY 
	billing_version_seen;
    
    
    -- -----------------------------------------6. CHANNEL PORFOLIO OPTIMIZATION------------------------------------------------

-- 6.1 session to order conversion rate for all utm_content
SELECT
	utm_content
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'; -- arbitary dates


SELECT
	utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/ COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- arbitary dates
GROUP BY 1
ORDER BY sessions DESC;


-- 6.2 Bsearch is a second paid search channel, pulling weekly trend sessions by volume and comparing to gsearch non brand

SELECT 
	-- YEARWEEK(created_at) AS yrwk,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-11-29'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at);
	

-- 6.3 pulling percentage of traffic coming on mobile for bsearch non brand, and comparing with gsearch non brand

SELECT * FROM website_sessions;

SELECT 
	utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/  COUNT(DISTINCT website_session_id)  AS pct_mobile
FROM website_sessions
WHERE created_at > '2012-08-22'
	AND created_at < '2012-11-30'
    AND utm_campaign = 'nonbrand'
GROUP BY utm_source;


-- Cross channel Bid Optimization 
-- Pull nonbrand converion rates from session to order for gsearch and bsearch, and slice by device type from aug 22 to sept 18


SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id)/ COUNT(DISTINCT website_sessions.website_session_id)  AS conv_rate
   FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-09-19'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	website_sessions.device_type,  
    website_sessions.utm_source;
  
	
-- Channel portfolio trends 
-- Pull weekly session volume for gsearch and bsearch nonbrand, sliced by device type since nov 4th. show bsearch as percentage of gsearch.

SELECT
    MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
     COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)
		/	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE website_sessions.created_at > '2012-11-04'
	AND website_sessions.created_at < '2012-12-22'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);



-- ---------------------------------------------------7. ANALYZING DIRECT TRAFFIC--------------------------------------------------------

SELECT 
	    CASE 
		WHEN http_referer IS NULL THEN 'direct_type-in'
        WHEN http_referer = 'https://www.gsearch.com' THEN 'gsearch_organic'
        WHEN http_referer = 'https://www.bsearch.com' THEN 'bsearch_organic'
        ELSE 'other'
	END AS casetype,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
	AND utm_content IS NULL
GROUP BY 1
ORDER BY 2 DESC;


-- F) Pull organic search, direct type in and paid brand sessions by month, and find those sessions as % of paid search nobrand.


SELECT DISTINCT 
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group,
    utm_source,
    utm_campaign,
    http_referer
    FROM website_sessions
WHERE created_at < '2012-12-23';



SELECT DISTINCT 
	website_session_id,
    created_at,
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group
   
FROM website_sessions
WHERE created_at < '2012-12-23';
	
    
  SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,

	COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
	COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
        
    COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic,
	COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM (
SELECT DISTINCT 
	website_session_id,
    created_at,
	CASE 
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group
FROM website_sessions
WHERE created_at < '2012-12-23'
) AS sessions_w_channel_group
GROUP BY 1, 2;
  
    
    
    
-- ---------------------------------------------------8. ANALYZING BUSINESS PATTERN AND SEASONALITY--------------------------------------------------------

SELECT
	website_session_id,
    created_at,
    HOUR(created_at),
    WEEKDAY(created_at),
    DAYNAME(created_at)
FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000;
    
    
-- G) monthly and weekly session and order volume patterns to find seasonal trends
    
    SELECT														
		YEAR(website_sessions.created_at) AS yr,
        MONTH(website_sessions.created_at) AS mo,
        COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders
	FROM website_sessions
		LEFT JOIN orders
			ON website_sessions.website_session_id = orders.website_session_id
	WHERE YEAR(website_sessions.created_at) < '2013-01-01'
    GROUP BY 1,2;												-- query shows monthly orders and sessions
    
	SELECT
		YEAR(website_sessions.created_at) AS yr,
        WEEK(website_sessions.created_at) AS wk,
        MIN(DATE(website_sessions.created_at)) AS week_start_date,
        COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders
	FROM website_sessions
		LEFT JOIN orders
			ON website_sessions.website_session_id = orders.website_session_id
	WHERE YEAR(website_sessions.created_at) < '2013-01-01'
    GROUP BY 1,2;
    
    
-- H) Pull the average website session volume, by hour of day and by day week, on date range sept15 to nov 15 2012


SELECT 
	hr,
    AVG(website_sessions) AS avg_sessions,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END), 1) AS mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END), 1) AS tue,
    ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END), 1) AS wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END), 1) AS thu,
    ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END), 1) AS fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END), 1) AS sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END), 1) AS sun
FROM (
SELECT
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
 ) AS daily_hourly_sessions   
 GROUP BY 1;
    
    