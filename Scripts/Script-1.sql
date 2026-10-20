DROP VIEW cohort_analysis ;

CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.givenname,
            c.age,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    givenname,
    age,
    surname,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchased_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;