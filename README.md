# SQL ECOMMERCE MARKETTNG DATA ANALYTICS

## About the Dataset:
The dataset Maven Fuzzy Factory, an E-Commerce company, was designed and structured with Advanced SQL: MySQL Data Analysis & Business Intelligence Course by Maven Analytics. The dataset can be downloaded [here](https://www.udemy.com/course/advanced-sql-mysql-for-analytics-business-intelligence/?couponCode=KEEPLEARNING). The data setting is for the purpose of studying.

## Objectives of the Analysis:
The objectives of the analysis (as they appear in the code file) are as under:

### 1. TRAFFIC SOURCE ANALYSIS:
To understand where the customers are coming from and which channels are driving the highest quality traffic. This part deals in Conversion Rate Analysis which is the percentage of sessions that convert to sales or to revenue activity. We do this to find out how highly qualified that traffic is and how valuable is the traffic source is to us. To achieve this objective, we use the utm parameters stored in the database to identify paid website sessions and then, from our session data, we can link to our order data to understand how much revenue our paid campaigns are driving

This objective helps us in: 
-	Analyzing search data and shifting budget towards the engines, campaigns or keywords driving the strongest conversion rates.
-	Comparing user behavior patterns across traffic sources to inform creative and messaging strategy.
-	Identifying opportunities to eliminate wasted spend or scale high-converting traffic.

Example of SQL codes for this section is as under:

```
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
ORDER BY 2 DESC;
```
```
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
```

### 2. BID OPTIMIZATION
Analyzing for bid optimization is about understanding the value of various segments of paid traffic, so that we can optimize our marketing budget. For example the intent is to bid up in segments which performs better relative to the segment that does not.

This primarily helps us in:
- Using conversion rate and revenue per click analyses to figure out how much we should spend per click to acquire customers 
- Understanding how your website and products perform for various subsegments of traffic (i.e. mobile vs desktop) to optimize within channels 
- Analyzing the impact that bid changes have on your ranking in the auctions, and the volume of customers driven to your site 


Example of SQL codes for this section is as under:

```
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
```
```
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
```

### 3. ANALYZING TOP WEBSITE CONTENT:

This helps us in: 
- Finding the most-viewed pages that customers view on our site 
- Identifying the most common entry pages to your website — the first thing a user sees 
- For most-viewed pages and most common entry pages, understanding how those pages perform for our business objectives 

Example of SQL codes for this section is as under:

```
3.1 Using temporary table to find out how many times different pages were landed on the first time

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
```

### 4. LANDING PAGE PERFORMANCE AND TESTING:
Landing page analysis and testing is about understanding the performance of our key landing pages and then testing to improve your results

This helps us in: 
- Identifying oour top opportunities for landing pages — high volume pages with higher-than-expected bounce rates or low conversion rates 
- Setting up A/B experiments on your live traffic to see if we can improve our bounce rates and conversion rates 
- Analyzing test results and making recommendations on which version of landing pages we should use going forward

Example of SQL codes for this section is as under:
```
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
```
```
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
```


### 5. ANALYSING AND TESTING CONVERSION FUNNELS:
Conversion funnel analysis is about understanding and optimizing each step of the user's experience on their journey toward purchasing the products. It reflects what percentage of customers move from home page to the product page and then to the cart and then to buying the product.

This helps us in:
-	Identifying the most common paths customers take before purchasing our products 
-	Identifying how many of our users continue on to each next step in your conversion flow, and how many users abandon at each step 
-	Optimizing critical pain points where users are abandoning, so that we can convert more users and sell more products

Example of SQL codes for this section is as under:
```
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

```

### 6. CHANNEL PORFOLIO OPTIMIZATION:
Analyzing a portfolio of marketing channels is about bidding efficiently and using data to maximize the effectiveness of our marketing budget.

This helps us in:
-	Understanding which marketing channels are driving the most sessions and orders through our website 
-	Understanding differences in user characteristics and conversion performance across marketing channels 
-	Optimizing bids and allocating marketing spend across a multi-channel portfolio to achieve maximum performance 

Example of SQL codes for this section is as under:

```
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
```
### 7. ANALYZING DIRECT TRAFFIC :
Analyzing our branded or direct traffic is about keeping a pulse on how well your brand is doing with consumers, and how well our brand drives business.

This helps us in:
- Identifying how much revenue we are generating from direct traffic — this is high margin revenue without a direct cost of customer acquisition 
- Understanding whether or not our paid traffic is generating a "halo" effect, and promoting additional direct traffic 
- Assessing the impact of various initiatives on how many customers seek out our business

Example of SQL codes for this section is as under:

```
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

```

### 8. ANALYZING BUSINESS PATTERN AND SEASONALITY:
Analyzing business patterns is about generating insights to help us maximize efficiency and anticipate future trends.

This helps us in: 
- Day-parting analysis to understand how much support staff we should have at different times of day or days of the week 
- Analyzing seasonality to better prepare for upcoming spikes or slowdowns in demand

```
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
    
```

## RESULTS
The analysis of the data presented remarkable opportunities for the company to make the right decision, resulting in growth of customers and more customers generating revenue by buying more products.





















