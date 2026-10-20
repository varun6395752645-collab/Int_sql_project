CREATE VIEW cohort_analysis AS 
WITH customer_revenue AS (
	SELECT 
		s.customerkey ,
		s.orderdate ,
		SUM(s.quantity *s.netprice *s.exchangerate ) AS total_net_revenue,
		count (s.orderkey ),
		c.countryfull ,
		c.givenname ,
		c.age ,
		c.surname 
	FROM sales s
	LEFT JOIN customer c ON c.customerkey =s.customerkey 
	GROUP BY 
		s.customerkey ,
		s.orderdate ,
		c.countryfull ,
		c.age ,
		c.givenname ,
		c.surname 
)
SELECT 
	cr.*,
	MIN(cr.orderdate) over(PARTITION BY cr.customerkey) AS  first_purchased_date,
	EXTRACT(YEAR FROM MIN(cr.orderdate) over(PARTITION BY cr.customerkey)) AS cohort_year
FROM customer_revenue cr 


