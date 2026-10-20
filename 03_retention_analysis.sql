WITH customer_last_purchased AS (
	SELECT
		customerkey,
		cleaned_named,
		orderdate,
		row_number() OVER(PARTITION BY customerkey ORDER BY orderdate DESC ) AS rn,
		first_purchased_date,
		cohort_year
	FROM 
		cohort_analysis
), churned_customers AS ( 
	SELECT 
		customerkey ,
		cleaned_named ,
		first_purchased_date,
		orderdate AS last_purchased_date ,
		CASE 
			WHEN orderdate < (SELECT MAX(orderdate) FROM sales)- INTERVAL	'6 months' THEN 'Churned'
		    ELSE 'Active'
		END AS customer_status,
		cohort_year 
	FROM customer_last_purchased 
	WHERE rn=1
		AND first_purchased_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL	'6 months' 
)
SELECT 
	cohort_year ,
	customer_status,
	count(customerkey) AS num_customers,
	SUM(count(customerkey)) OVER(PARTITION BY cohort_year ) AS total_customers,
	round(count(customerkey)/SUM(count(customerkey)) OVER(PARTITION BY cohort_year),2) AS status_percentage
FROM churned_customers
GROUP BY 
	cohort_year ,
	customer_status




